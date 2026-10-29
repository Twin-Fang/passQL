"""src.clients.gemini_client
Google Gemini API 클라이언트 (google-genai SDK)
"""
import json
import logging
from typing import Any

import httpx
from google import genai
from google.genai import errors, types

from src.clients.token_usage import record_token_usage
from src.core.exceptions import CustomError
from src.core.external_call_limits import LLM_CALL_TIMEOUT_SECONDS, LOGGED_RESPONSE_TEXT_MAXIMUM_LENGTH
from src.core.retry import call_with_retry, is_transient_status_code

logger = logging.getLogger(__name__)


def _record_usage(response: types.GenerateContentResponse) -> None:
    """토큰 기록: 입력 = prompt, 출력 = 답변 + thinking (둘 다 출력 단가로 과금, Spring GeminiClient 와 같은 기준)"""
    usage = response.usage_metadata
    if usage is None:
        return
    completion_tokens = (usage.candidates_token_count or 0) + (usage.thoughts_token_count or 0)
    record_token_usage(usage.prompt_token_count, completion_tokens)

# SDK timeout 단위 밀리초 (공통 LLM 호출 상한 환산)
CALL_TIMEOUT_MILLISECONDS = LLM_CALL_TIMEOUT_SECONDS * 1000
# 응답 detail 고정 문구 (SDK 예외 문자열은 로그에만)
CALL_FAILED_DETAIL = "Gemini API 호출 실패"
JSON_PARSE_FAILED_DETAIL = "Gemini structured 응답 JSON 파싱 실패"


def _is_transient_gemini_error(error: Exception) -> bool:
    """재시도 대상: SDK 429·5xx 응답, 연결·타임아웃 등 전송 오류"""
    if isinstance(error, errors.APIError):
        return is_transient_status_code(error.code)
    return isinstance(error, httpx.TransportError)


class GeminiClient:
    """
    Google Gemini API 래퍼.

    - chat: 일반 텍스트 응답
    - chat_structured: response_schema(JSON mode) 강제 응답
    비동기 호출(client.aio)로 이벤트 루프를 막지 않고, 클라이언트는 키별로 한 번만 만든다 (#497, #695)
    """

    def __init__(self) -> None:
        # API 키 > SDK 클라이언트 (연결이 여러 개라 키마다 따로 보관)
        self._client_by_api_key: dict[str, genai.Client] = {}

    def _get_client(self, api_key: str) -> genai.Client:
        client = self._client_by_api_key.get(api_key)
        if client is None:
            client = genai.Client(
                api_key=api_key,
                http_options=types.HttpOptions(timeout=CALL_TIMEOUT_MILLISECONDS),
            )
            self._client_by_api_key[api_key] = client
        return client

    async def _generate_text(
        self, operation_name: str, api_key: str, model: str, user_prompt: str, config: types.GenerateContentConfig
    ) -> str:
        """generate_content 1건: 일시 오류 재시도 > 빈 응답 검사 > 텍스트 (실패는 고정 문구 CustomError, 원인은 __cause__)"""
        client = self._get_client(api_key)

        async def generate_once():
            return await client.aio.models.generate_content(model=model, contents=user_prompt, config=config)

        try:
            response = await call_with_retry(operation_name, generate_once, _is_transient_gemini_error)
        except Exception as error:
            logger.error(f"[{operation_name}] failed : model={model}, {error!r}", exc_info=True)
            raise CustomError(CALL_FAILED_DETAIL) from error

        _record_usage(response)
        text = response.text
        if not text or not text.strip():
            raise CustomError(f"Gemini returned empty response (model={model})")
        return text

    async def chat(
        self,
        api_key: str,
        system_prompt: str,
        user_prompt: str,
        model: str,
        temperature: float,
        max_tokens: int,
    ) -> str:
        """
        일반 텍스트 응답.

        Raises:
            CustomError: Gemini 호출 실패 또는 빈 응답
        """
        logger.debug(f"Gemini chat: model={model}, max_tokens={max_tokens}")
        config = types.GenerateContentConfig(
            system_instruction=system_prompt,
            temperature=temperature,
            max_output_tokens=max_tokens,
        )
        return await self._generate_text("gemini chat", api_key, model, user_prompt, config)

    async def chat_structured(
        self,
        api_key: str,
        system_prompt: str,
        user_prompt: str,
        model: str,
        temperature: float,
        max_tokens: int,
        response_schema: dict[str, Any],
    ) -> dict[str, Any]:
        """
        JSON 강제 응답 (response_schema = JSON Schema dict) > 파싱된 dict

        Raises:
            CustomError: Gemini 호출 실패, 빈 응답, JSON 파싱 실패
        """
        logger.debug(f"Gemini chat_structured: model={model}, max_tokens={max_tokens}")
        config = types.GenerateContentConfig(
            system_instruction=system_prompt,
            temperature=temperature,
            max_output_tokens=max_tokens,
            response_mime_type="application/json",
            response_schema=response_schema,
        )
        text = await self._generate_text("gemini chat_structured", api_key, model, user_prompt, config)
        try:
            return json.loads(text)
        except json.JSONDecodeError as error:
            logger.error(
                f"[gemini chat_structured] json parse failed : {error}, "
                f"text={text[:LOGGED_RESPONSE_TEXT_MAXIMUM_LENGTH]}"
            )
            raise CustomError(JSON_PARSE_FAILED_DETAIL) from error


# 싱글턴
gemini_client = GeminiClient()
