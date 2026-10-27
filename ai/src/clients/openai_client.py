"""src.clients.openai_client
OpenAI Chat Completions API 클라이언트 (공유 httpx 경유, #695)
"""
import json
import logging
from typing import Any

from src.clients.llm_schema import to_json_schema
from src.clients.shared_http_client import send_request
from src.core.exceptions import CustomError

logger = logging.getLogger(__name__)

OPENAI_CHAT_COMPLETIONS_URL = "https://api.openai.com/v1/chat/completions"
# 호출 1회 응답 대기 상한 (30초, Gemini·Claude 와 같은 기준)
CALL_TIMEOUT_SECONDS = 30
# JSON 응답 지시 문구 (json_object 모드는 스키마를 강제하지 않아 시스템 프롬프트로 형식 전달)
STRUCTURED_RESPONSE_INSTRUCTION = "응답은 다음 JSON 스키마를 따르는 JSON 객체 하나로만 작성:\n"
# 파싱 실패 로그에 남길 응답 최대 길이
LOGGED_RESPONSE_TEXT_MAXIMUM_LENGTH = 500


class OpenAiClient:
    """
    OpenAI Chat Completions 래퍼 (Gemini·Claude 와 같은 메서드 모양)

    - chat: 일반 텍스트 응답
    - chat_structured: json_object 모드 + 시스템 프롬프트 스키마 지시 > 파싱된 dict
    temperature 미전송 (추론 모델이 기본값 외 값을 거부)
    """

    @staticmethod
    def _build_request_body(system_prompt: str, user_prompt: str, model: str, max_tokens: int) -> dict[str, Any]:
        return {
            "model": model,
            "max_completion_tokens": max_tokens,
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
        }

    async def _send_and_read_text(self, operation_name: str, api_key: str, request_body: dict[str, Any]) -> str:
        """Chat Completions 1건 > 첫 응답 본문 (HTTP 실패 > CustomError, 원인 HTTPStatusError 는 __cause__)"""
        response = await send_request(
            operation_name,
            "POST",
            OPENAI_CHAT_COMPLETIONS_URL,
            headers={"Authorization": f"Bearer {api_key}"},
            json_body=request_body,
            timeout_seconds=CALL_TIMEOUT_SECONDS,
        )
        choices = response.json().get("choices") or []
        text = (choices[0].get("message") or {}).get("content") if choices else None
        if not text or not text.strip():
            raise CustomError(f"OpenAI returned empty response (model={request_body['model']})")
        return text

    async def chat(
        self, api_key: str, system_prompt: str, user_prompt: str, model: str, temperature: float, max_tokens: int
    ) -> str:
        logger.debug(f"OpenAI chat: model={model}, max_tokens={max_tokens}")
        request_body = self._build_request_body(system_prompt, user_prompt, model, max_tokens)
        return await self._send_and_read_text("openai chat", api_key, request_body)

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
        """JSON 강제 응답: 스키마 지시 추가 > json_object 모드 > 본문 JSON 파싱"""
        logger.debug(f"OpenAI chat_structured: model={model}, max_tokens={max_tokens}")
        schema_instruction = STRUCTURED_RESPONSE_INSTRUCTION + json.dumps(
            to_json_schema(response_schema), ensure_ascii=False
        )
        request_body = self._build_request_body(f"{system_prompt}\n\n{schema_instruction}", user_prompt, model, max_tokens)
        request_body["response_format"] = {"type": "json_object"}
        text = await self._send_and_read_text("openai chat_structured", api_key, request_body)
        try:
            return json.loads(text)
        except json.JSONDecodeError as error:
            logger.error(
                f"[openai chat_structured] json parse failed : {error}, "
                f"text={text[:LOGGED_RESPONSE_TEXT_MAXIMUM_LENGTH]}"
            )
            raise CustomError("OpenAI structured 응답 JSON 파싱 실패") from error


# 싱글턴
openai_client = OpenAiClient()
