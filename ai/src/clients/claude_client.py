"""src.clients.claude_client
Anthropic Claude Messages API 클라이언트 (공유 httpx 경유)
"""
import logging
from typing import Any

from src.clients.llm_schema import to_json_schema
from src.clients.shared_http_client import send_request
from src.core.exceptions import CustomError

logger = logging.getLogger(__name__)

CLAUDE_MESSAGES_URL = "https://api.anthropic.com/v1/messages"
CLAUDE_API_VERSION = "2023-06-01"
# 호출 1회 응답 대기 상한 (30초, Gemini 와 같은 기준) (#688)
CALL_TIMEOUT_SECONDS = 30
# JSON 강제 응답용 도구 이름 (tool_choice 로 이 도구만 쓰게 함)
STRUCTURED_RESPONSE_TOOL_NAME = "submit_response"


class ClaudeClient:
    """
    Claude Messages API 래퍼 (GeminiClient 와 같은 메서드 모양)

    - chat: 일반 텍스트 응답
    - chat_structured: 도구 1개 강제 호출 > 도구 입력(dict)을 응답으로 사용
    """

    async def _send_messages(self, operation_name: str, api_key: str, request_body: dict[str, Any]) -> dict[str, Any]:
        """Messages API 1건 (HTTP 실패 > CustomError, 원인 HTTPStatusError 는 __cause__)"""
        response = await send_request(
            operation_name,
            "POST",
            CLAUDE_MESSAGES_URL,
            headers={"x-api-key": api_key, "anthropic-version": CLAUDE_API_VERSION},
            json_body=request_body,
            timeout_seconds=CALL_TIMEOUT_SECONDS,
        )
        return response.json()

    @staticmethod
    def _build_request_body(
        system_prompt: str, user_prompt: str, model: str, max_tokens: int
    ) -> dict[str, Any]:
        # temperature 미전송: Claude 최신 모델이 파라미터 자체를 거부 (400 deprecated)
        return {
            "model": model,
            "max_tokens": max_tokens,
            # thinking 끔: 켜져 있으면 thinking 토큰이 max_tokens 를 먼저 써서 본문이 비거나 잘림
            "thinking": {"type": "disabled"},
            "system": system_prompt,
            "messages": [{"role": "user", "content": user_prompt}],
        }

    async def chat(
        self, api_key: str, system_prompt: str, user_prompt: str, model: str, temperature: float, max_tokens: int
    ) -> str:
        """일반 텍스트 응답 (text 블록 이어 붙임, 빈 응답 > CustomError)"""
        logger.debug(f"Claude chat: model={model}, max_tokens={max_tokens}")
        request_body = self._build_request_body(system_prompt, user_prompt, model, max_tokens)
        response_body = await self._send_messages("claude chat", api_key, request_body)
        text = "".join(
            block.get("text", "") for block in response_body.get("content", []) if block.get("type") == "text"
        )
        if not text.strip():
            raise CustomError(f"Claude returned empty response (model={model})")
        return text

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
        """JSON 강제 응답: 응답 스키마 > 도구 input_schema > 강제 호출 > 도구 입력 dict"""
        logger.debug(f"Claude chat_structured: model={model}, max_tokens={max_tokens}")
        request_body = self._build_request_body(system_prompt, user_prompt, model, max_tokens)
        request_body["tools"] = [{
            "name": STRUCTURED_RESPONSE_TOOL_NAME,
            "description": "응답을 정해진 JSON 형식으로 제출",
            "input_schema": to_json_schema(response_schema),
        }]
        request_body["tool_choice"] = {"type": "tool", "name": STRUCTURED_RESPONSE_TOOL_NAME}
        response_body = await self._send_messages("claude chat_structured", api_key, request_body)
        for block in response_body.get("content", []):
            if block.get("type") == "tool_use" and isinstance(block.get("input"), dict):
                return block["input"]
        logger.error(f"[claude chat_structured] no tool_use block : stop_reason={response_body.get('stop_reason')}")
        raise CustomError("Claude structured 응답에 JSON 블록 없음")


# 싱글턴
claude_client = ClaudeClient()
