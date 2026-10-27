"""AI 연결 목록·시도 순서·fallback 판정·Gemini 스키마 변환 (#688, #695)"""
import asyncio
import json

import httpx
import pytest

from src.clients import ai_connection_store, llm_client
from src.clients.ai_connection_store import AiConnection
from src.clients.llm_schema import to_json_schema
from src.core.config import settings
from src.core.exceptions import CustomError

CLAUDE_PRO = AiConnection("claude-pro", "CLAUDE", "claude-haiku-5-5", "claude-key-1")
CLAUDE_DEV = AiConnection("claude-dev", "CLAUDE", "claude-haiku-5-5", "claude-key-2")
GEMINI_MAIN = AiConnection("gemini-main", "GEMINI", "gemini-2.5-flash-lite", "gemini-key")


def _http_error(status_code: int, body: str = "{}") -> CustomError:
    """send_request 가 만드는 모양: CustomError(원인 HTTPStatusError)"""
    request = httpx.Request("POST", "https://example.test")
    response = httpx.Response(status_code, text=body, request=request)
    try:
        raise httpx.HTTPStatusError("failed", request=request, response=response)
    except httpx.HTTPStatusError as status_error:
        error = CustomError(f"HTTP 오류: {status_code}")
        error.__cause__ = status_error
        return error


@pytest.mark.parametrize("model, provider", [
    ("claude-haiku-5-5", "CLAUDE"),
    (" Gemini-2.5-flash-lite ", "GEMINI"),
    ("gpt-5-mini", "OPENAI"),
    ("o4-mini", "OPENAI"),
    ("llama3.1", None),
    ("", None),
    (None, None),
])
def test_model_name_maps_to_provider(model, provider):
    assert llm_client.to_provider(model) == provider


def test_plan_puts_prompt_provider_connections_first_with_prompt_model():
    attempts = llm_client.plan_attempts([GEMINI_MAIN, CLAUDE_PRO, CLAUDE_DEV], "claude-sonnet-5-5")
    assert [(a.connection.connection_name, a.model) for a in attempts] == [
        ("claude-pro", "claude-sonnet-5-5"),
        ("claude-dev", "claude-sonnet-5-5"),
        ("gemini-main", "gemini-2.5-flash-lite"),
    ]


def test_plan_without_matching_provider_uses_default_models_in_priority_order():
    attempts = llm_client.plan_attempts([CLAUDE_PRO, GEMINI_MAIN], "gpt-5-mini")
    assert [(a.connection.connection_name, a.model) for a in attempts] == [
        ("claude-pro", "claude-haiku-5-5"),
        ("gemini-main", "gemini-2.5-flash-lite"),
    ]


@pytest.mark.parametrize("error, expected", [
    (_http_error(429), True),
    (_http_error(401), True),
    (_http_error(503), True),
    (_http_error(400, '{"error":{"message":"Your credit balance is too low"}}'), True),
    (_http_error(400, '{"error":{"code":"insufficient_quota"}}'), True),
    (_http_error(400, '{"error":{"message":"API key not valid. Please pass a valid API key.","status":"INVALID_ARGUMENT"}}'), True),
    (_http_error(400, '{"error":{"message":"messages.0: content empty"}}'), False),
    (CustomError("Claude returned empty response"), False),
])
def test_fallback_error_classification(error, expected):
    assert llm_client.is_fallback_error(error) is expected


def test_transport_error_is_fallback():
    error = CustomError("요청 오류")
    error.__cause__ = httpx.ConnectTimeout("timeout")
    assert llm_client.is_fallback_error(error)


class _RecordingClient:
    """호출 기록 + 연결 키별 미리 정한 결과(예외면 raise)"""

    def __init__(self, outcome_by_api_key):
        self.outcome_by_api_key = outcome_by_api_key
        self.called_api_keys = []

    async def chat(self, api_key, **kwargs):
        self.called_api_keys.append(api_key)
        outcome = self.outcome_by_api_key[api_key]
        if isinstance(outcome, Exception):
            raise outcome
        return outcome


def _patch_connections_and_client(monkeypatch, connections, client):
    async def fake_load():
        return connections

    monkeypatch.setattr(llm_client, "load_ai_connections", fake_load)
    monkeypatch.setattr(llm_client, "_select_client", lambda provider: client)


def test_quota_error_falls_back_to_next_connection(monkeypatch):
    client = _RecordingClient({"claude-key-1": _http_error(429), "claude-key-2": "두 번째 연결 응답"})
    _patch_connections_and_client(monkeypatch, [CLAUDE_PRO, CLAUDE_DEV], client)

    result = asyncio.run(llm_client.chat("system", "user", "claude-haiku-5-5", 0.3, 256))

    assert (result.content, result.connection_name, result.model) == ("두 번째 연결 응답", "claude-dev", "claude-haiku-5-5")
    assert client.called_api_keys == ["claude-key-1", "claude-key-2"]


def test_bad_request_fails_immediately_without_fallback(monkeypatch):
    client = _RecordingClient({"claude-key-1": _http_error(400, '{"error":"bad"}'), "claude-key-2": "unused"})
    _patch_connections_and_client(monkeypatch, [CLAUDE_PRO, CLAUDE_DEV], client)

    with pytest.raises(CustomError):
        asyncio.run(llm_client.chat("system", "user", "claude-haiku-5-5", 0.3, 256))
    assert client.called_api_keys == ["claude-key-1"]


def test_empty_key_connection_is_skipped(monkeypatch):
    client = _RecordingClient({"gemini-key": "Gemini 응답"})
    _patch_connections_and_client(monkeypatch, [AiConnection("claude-empty", "CLAUDE", "claude-haiku-5-5", ""), GEMINI_MAIN], client)

    result = asyncio.run(llm_client.chat("system", "user", None, 0.3, 256))

    assert result.connection_name == "gemini-main"
    assert client.called_api_keys == ["gemini-key"]


def test_all_connections_failing_raises_last_error(monkeypatch):
    client = _RecordingClient({"claude-key-1": _http_error(429), "gemini-key": _http_error(503)})
    _patch_connections_and_client(monkeypatch, [CLAUDE_PRO, GEMINI_MAIN], client)

    with pytest.raises(CustomError, match="503"):
        asyncio.run(llm_client.chat("system", "user", None, 0.3, 256))


def test_redis_connection_json_parses_in_order_and_skips_unknown_provider():
    raw_json = json.dumps([
        {"connection_uuid": "u1", "connection_name": "claude-pro", "provider": "CLAUDE",
         "default_model": "claude-haiku-5-5", "encrypted_api_key": "plain-key"},
        {"connection_uuid": "u2", "connection_name": "unknown", "provider": "MISTRAL",
         "default_model": "x", "encrypted_api_key": "k"},
        {"connection_uuid": "u3", "connection_name": "gemini-main", "provider": "GEMINI",
         "default_model": "gemini-2.5-flash-lite", "encrypted_api_key": "gemini-plain"},
    ])
    connections = ai_connection_store.parse_ai_connections(raw_json)
    assert connections == [
        AiConnection("claude-pro", "CLAUDE", "claude-haiku-5-5", "plain-key"),
        AiConnection("gemini-main", "GEMINI", "gemini-2.5-flash-lite", "gemini-plain"),
    ]
    assert ai_connection_store.parse_ai_connections("not json") == []
    assert ai_connection_store.parse_ai_connections(None) == []


def test_empty_redis_list_uses_env_emergency_connections(monkeypatch):
    async def fake_raw_value(key):
        return None

    monkeypatch.setattr(ai_connection_store, "get_raw_value", fake_raw_value)
    monkeypatch.setattr(settings, "CLAUDE_API_KEY", "env-claude-key")
    monkeypatch.setattr(settings, "GEMINI_API_KEY", "env-gemini-key")

    connections = asyncio.run(ai_connection_store.load_ai_connections())

    assert [(c.connection_name, c.provider) for c in connections] == [("env-claude", "CLAUDE"), ("env-gemini", "GEMINI")]


def test_no_connection_at_all_raises(monkeypatch):
    async def fake_raw_value(key):
        return "[]"

    monkeypatch.setattr(ai_connection_store, "get_raw_value", fake_raw_value)
    monkeypatch.setattr(settings, "CLAUDE_API_KEY", "")
    monkeypatch.setattr(settings, "GEMINI_API_KEY", "")

    with pytest.raises(CustomError, match="사용 가능한 AI 연결 없음"):
        asyncio.run(ai_connection_store.load_ai_connections())


def test_gemini_schema_converts_to_json_schema():
    gemini_schema = {
        "type": "OBJECT",
        "propertyOrdering": ["stem"],
        "properties": {
            "stem": {"type": "STRING", "description": "지문"},
            "hint": {"type": "STRING", "nullable": True},
            "choices": {"type": "ARRAY", "minItems": 1, "items": {"type": "OBJECT", "properties": {"key": {"type": "STRING"}}}},
        },
        "required": ["stem"],
    }
    assert to_json_schema(gemini_schema) == {
        "type": "object",
        "properties": {
            "stem": {"type": "string", "description": "지문"},
            "hint": {"type": ["string", "null"]},
            "choices": {"type": "array", "minItems": 1, "items": {"type": "object", "properties": {"key": {"type": "string"}}}},
        },
        "required": ["stem"],
    }
