"""src.clients.llm_schema
Gemini 응답 스키마 > JSON Schema 변환 (Claude 도구 input_schema, OpenAI JSON 지시 공통)
"""
from typing import Any

# Gemini 스키마 전용 키 (JSON Schema 에 없음 > 제거)
GEMINI_ONLY_SCHEMA_KEYS = ("propertyOrdering",)


def to_json_schema(gemini_schema: Any) -> Any:
    """Gemini 응답 스키마(type 대문자, nullable) > JSON Schema (type 소문자, null 허용 type 배열)"""
    if isinstance(gemini_schema, list):
        return [to_json_schema(element) for element in gemini_schema]
    if not isinstance(gemini_schema, dict):
        return gemini_schema
    json_schema = {}
    for key, value in gemini_schema.items():
        if key in GEMINI_ONLY_SCHEMA_KEYS or key == "nullable":
            continue
        if key == "type" and isinstance(value, str):
            json_schema[key] = value.lower()
        elif key == "properties" and isinstance(value, dict):
            json_schema[key] = {name: to_json_schema(child) for name, child in value.items()}
        else:
            json_schema[key] = to_json_schema(value)
    if gemini_schema.get("nullable") is True and isinstance(json_schema.get("type"), str):
        json_schema["type"] = [json_schema["type"], "null"]
    return json_schema
