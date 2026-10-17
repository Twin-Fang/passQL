"""src.clients.gemini_client
Google Gemini API 클라이언트 (google-genai SDK)
"""
import json
import logging
from typing import Any, Optional

import httpx
from google import genai
from google.genai import errors, types

from src.core.exceptions import CustomError
from src.core.retry import call_with_retry, is_transient_status_code
from src.clients.redis_app_setting_client import get_gemini_api_key

logger = logging.getLogger(__name__)

# 호출 1회 응답 대기 상한 (30초, Java 쪽 AI 서버 호출 제한보다 길지 않게) (#497)
CALL_TIMEOUT_MILLISECONDS = 30_000
# 응답 detail 고정 문구 (SDK 예외 문자열은 로그에만)
CALL_FAILED_DETAIL = "Gemini API 호출 실패"
JSON_PARSE_FAILED_DETAIL = "Gemini structured 응답 JSON 파싱 실패"
# 파싱 실패 로그에 남길 응답 최대 길이
LOGGED_RESPONSE_TEXT_MAXIMUM_LENGTH = 500


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
    비동기 호출(client.aio)로 이벤트 루프를 막지 않고, 클라이언트는 키가 바뀔 때만 새로 만든다 (#497)
    """

    def __init__(self) -> None:
        self._cached_api_key: Optional[str] = None
        self._cached_client: Optional[genai.Client] = None

    async def _get_client(self) -> genai.Client:
        api_key = await get_gemini_api_key()
        if not api_key:
            raise CustomError("Gemini API Key 미설정 — Redis(DB) 또는 환경변수를 확인하세요")
        if self._cached_client is None or self._cached_api_key != api_key:
            self._cached_client = genai.Client(
                api_key=api_key,
                http_options=types.HttpOptions(timeout=CALL_TIMEOUT_MILLISECONDS),
            )
            self._cached_api_key = api_key
        return self._cached_client

    async def _generate_text(
        self, operation_name: str, model: str, user_prompt: str, config: types.GenerateContentConfig
    ) -> str:
        """generate_content 1건: 일시 오류 재시도 > 빈 응답 검사 > 텍스트 (실패는 고정 문구 CustomError)"""
        client = await self._get_client()

        async def generate_once():
            return await client.aio.models.generate_content(model=model, contents=user_prompt, config=config)

        try:
            response = await call_with_retry(operation_name, generate_once, _is_transient_gemini_error)
        except Exception as error:
            logger.error(f"[{operation_name}] failed : model={model}, {error!r}", exc_info=True)
            raise CustomError(CALL_FAILED_DETAIL) from error

        text = response.text
        if not text or not text.strip():
            raise CustomError(f"Gemini returned empty response (model={model})")
        return text

    async def chat(
        self,
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
        return await self._generate_text("gemini chat", model, user_prompt, config)

    async def chat_structured(
        self,
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
        text = await self._generate_text("gemini chat_structured", model, user_prompt, config)
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
