"""src.clients.llm_client
LLM 호출 단일 진입점: 연결 목록 > 시도 순서 > 연결별 호출 > 사용량 초과·키 문제·서버 오류면 다음 연결 (#695)
규칙 원본은 Spring AiConnectionRouter (같은 판정·순서)
"""
import logging
from dataclasses import dataclass
from typing import Any, Awaitable, Callable

import httpx
from google.genai import errors as gemini_errors

from src.clients.ai_connection_store import (
    PROVIDER_CLAUDE,
    PROVIDER_GEMINI,
    PROVIDER_OPENAI,
    AiConnection,
    load_ai_connections,
)
from src.clients.claude_client import claude_client
from src.clients.gemini_client import gemini_client
from src.clients.openai_client import openai_client
from src.clients.token_usage import start_token_usage
from src.core.exceptions import CustomError

logger = logging.getLogger(__name__)

# 모델 이름 접두사 > 제공자 (소문자 비교)
CLAUDE_MODEL_PREFIXES = ("claude-",)
GEMINI_MODEL_PREFIXES = ("gemini-",)
OPENAI_MODEL_PREFIXES = ("gpt-", "chatgpt-", "o1", "o3", "o4")

# 다음 연결로 넘기는 HTTP 상태: 401·403 키 무효·권한, 402 결제, 404 모델 없음, 429 한도 초과 (5xx 는 별도 판정)
FALLBACK_STATUS_CODES = (401, 402, 403, 404, 429)
SERVER_ERROR_MINIMUM_STATUS_CODE = 500
BAD_REQUEST_STATUS_CODE = 400
# 400 이지만 계정 문제인 응답 본문 표식 (소문자 비교): Claude 크레딧 부족, OpenAI 한도, Gemini 무효·만료 키
ACCOUNT_ERROR_BODY_MARKERS = ("credit balance", "insufficient_quota", "quota", "api_key_invalid", "api key not valid",
                              "api key expired")


@dataclass(frozen=True)
class LlmAttempt:
    connection: AiConnection
    model: str


@dataclass(frozen=True)
class LlmResult:
    content: Any
    connection_name: str
    model: str
    # 응답한 연결의 토큰 수 (제공자가 안 주면 None, 호출 기록·비용 추정용 #699)
    prompt_tokens: int | None = None
    completion_tokens: int | None = None


def to_provider(model: str | None) -> str | None:
    """모델 이름 > 제공자 (claude-* Claude, gemini-* Gemini, gpt-·chatgpt-·o1·o3·o4 OpenAI, 그 외 None)"""
    normalized_model = (model or "").strip().lower()
    if normalized_model.startswith(CLAUDE_MODEL_PREFIXES):
        return PROVIDER_CLAUDE
    if normalized_model.startswith(GEMINI_MODEL_PREFIXES):
        return PROVIDER_GEMINI
    if normalized_model.startswith(OPENAI_MODEL_PREFIXES):
        return PROVIDER_OPENAI
    return None


def plan_attempts(connections: list[AiConnection], prompt_model: str | None) -> list[LlmAttempt]:
    """시도 순서: 프롬프트 모델 제공자 연결(프롬프트 모델) 먼저 > 나머지 연결(각 기본 모델), 제공자 연결 없으면 전부 기본 모델"""
    prompt_provider = to_provider(prompt_model)
    matching_connections = [c for c in connections if c.provider == prompt_provider]
    if not matching_connections:
        return [LlmAttempt(c, c.default_model) for c in connections]
    other_connections = [c for c in connections if c.provider != prompt_provider]
    return ([LlmAttempt(c, prompt_model.strip()) for c in matching_connections]
            + [LlmAttempt(c, c.default_model) for c in other_connections])


def _read_status_and_body(error: BaseException) -> tuple[int | None, str]:
    """오류(또는 원인 __cause__) > (HTTP 상태, 응답 본문), 상태 없는 오류는 (None, 문자열)"""
    root_error = error.__cause__ if isinstance(error, CustomError) and error.__cause__ else error
    if isinstance(root_error, httpx.HTTPStatusError):
        return root_error.response.status_code, root_error.response.text
    if isinstance(root_error, gemini_errors.APIError):
        return root_error.code, str(root_error)
    return None, str(root_error)


def is_fallback_error(error: BaseException) -> bool:
    """다음 연결로 넘길 오류: 전송 오류, 401·402·403·404·429·5xx, 크레딧·한도·무효 키 표식 있는 400"""
    root_error = error.__cause__ if isinstance(error, CustomError) and error.__cause__ else error
    if isinstance(root_error, httpx.TransportError):
        return True
    status_code, body = _read_status_and_body(error)
    if status_code is None:
        return False
    if status_code in FALLBACK_STATUS_CODES or status_code >= SERVER_ERROR_MINIMUM_STATUS_CODE:
        return True
    lowered_body = body.lower()
    return status_code == BAD_REQUEST_STATUS_CODE and any(marker in lowered_body for marker in ACCOUNT_ERROR_BODY_MARKERS)


def _describe_error(error: BaseException) -> str:
    """로그용 오류 종류 (상태 코드 또는 예외 이름, 본문·키 미포함)"""
    status_code, _ = _read_status_and_body(error)
    return f"http {status_code}" if status_code is not None else type(error.__cause__ or error).__name__


def _select_client(provider: str):
    return {PROVIDER_CLAUDE: claude_client, PROVIDER_GEMINI: gemini_client, PROVIDER_OPENAI: openai_client}[provider]


async def _call_with_fallback(
    operation_name: str, prompt_model: str | None, call: Callable[[Any, LlmAttempt], Awaitable[Any]]
) -> LlmResult:
    """시도 순서대로 호출 > 성공 결과 / fallback 대상 오류면 다음 연결 / 그 외 즉시 raise / 전부 실패면 마지막 오류"""
    attempts = plan_attempts(await load_ai_connections(), prompt_model)
    last_error: BaseException | None = None
    for attempt in attempts:
        connection_name = attempt.connection.connection_name
        # 키 미설정·복호화 실패 연결은 호출 없이 다음 연결
        if not attempt.connection.api_key:
            logger.warning(f"[llm fallback] {operation_name} skipped : connection={connection_name}, api key empty")
            last_error = CustomError(f"AI 연결 키 미설정: {connection_name}")
            continue
        try:
            usage = start_token_usage()
            content = await call(_select_client(attempt.connection.provider), attempt)
            return LlmResult(content=content, connection_name=connection_name, model=attempt.model,
                             prompt_tokens=usage.prompt_tokens, completion_tokens=usage.completion_tokens)
        except Exception as error:
            if not is_fallback_error(error):
                raise
            logger.warning(
                f"[llm fallback] {operation_name} failed : connection={connection_name}, "
                f"model={attempt.model}, error={_describe_error(error)}, next connection"
            )
            last_error = error
    if isinstance(last_error, CustomError):
        raise last_error
    raise CustomError("사용 가능한 AI 연결 없음") from last_error


async def chat(
    system_prompt: str, user_prompt: str, prompt_model: str | None, temperature: float, max_tokens: int
) -> LlmResult:
    """일반 텍스트 응답 (content = str)"""
    async def call(client, attempt: LlmAttempt):
        return await client.chat(
            api_key=attempt.connection.api_key,
            system_prompt=system_prompt,
            user_prompt=user_prompt,
            model=attempt.model,
            temperature=temperature,
            max_tokens=max_tokens,
        )

    return await _call_with_fallback("chat", prompt_model, call)


async def chat_structured(
    system_prompt: str,
    user_prompt: str,
    prompt_model: str | None,
    temperature: float,
    max_tokens: int,
    response_schema: dict[str, Any],
) -> LlmResult:
    """JSON 강제 응답 (content = dict)"""
    async def call(client, attempt: LlmAttempt):
        return await client.chat_structured(
            api_key=attempt.connection.api_key,
            system_prompt=system_prompt,
            user_prompt=user_prompt,
            model=attempt.model,
            temperature=temperature,
            max_tokens=max_tokens,
            response_schema=response_schema,
        )

    return await _call_with_fallback("chat_structured", prompt_model, call)
