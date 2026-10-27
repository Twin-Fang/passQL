"""LLM 제공자 선택(모델 이름 접두사)·관리자 일괄 모델·Gemini 스키마 > JSON Schema 변환 (#688)"""
import asyncio

from src.clients import llm_client
from src.clients.claude_client import claude_client, to_json_schema
from src.clients.gemini_client import gemini_client


def test_claude_prefix_selects_claude_client():
    assert llm_client.is_claude_model("claude-haiku-5-5")
    assert llm_client._select_client(" Claude-sonnet-5-5") is claude_client
    assert llm_client._select_client("gemini-2.5-flash-lite") is gemini_client


def test_model_override_wins_over_prompt_model(monkeypatch):
    async def fake_override():
        return "claude-haiku-5-5"

    monkeypatch.setattr(llm_client, "get_model_override", fake_override)
    assert asyncio.run(llm_client.resolve_model("gemini-2.5-flash-lite")) == "claude-haiku-5-5"


def test_empty_override_keeps_prompt_model(monkeypatch):
    async def fake_override():
        return ""

    monkeypatch.setattr(llm_client, "get_model_override", fake_override)
    assert asyncio.run(llm_client.resolve_model("gemini-2.5-flash-lite")) == "gemini-2.5-flash-lite"


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
