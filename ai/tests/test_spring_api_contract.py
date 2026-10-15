"""Spring AiGatewayClient 호출 계약 고정: 경로·메서드·요청/응답 스키마 <-> 스냅샷"""
import json
from pathlib import Path

from src.main import app

# server/PQL-Domain-AI/.../AiGatewayClient.java 의 postToPython 호출 경로 8개
SPRING_CALLED_PATHS = [
    "/api/ai/generate-question-full",
    "/api/ai/generate-choice-set",
    "/api/ai/test-prompt",
    "/api/ai/index-question",
    "/api/ai/index-questions-bulk",
    "/api/ai/recommend",
    "/api/ai/index-status",
    "/api/ai/prune-index",
]

SNAPSHOT_PATH = Path(__file__).parent / "snapshots" / "spring_called_endpoints_openapi.json"


def _resolve_schema_references(schema, component_schemas: dict):
    """$ref 를 실제 스키마로 펼침 (스키마 이름 변경과 무관하게 형태만 비교)"""
    if isinstance(schema, dict):
        if "$ref" in schema:
            schema_name = schema["$ref"].rsplit("/", 1)[-1]
            return _resolve_schema_references(component_schemas[schema_name], component_schemas)
        return {
            key: _resolve_schema_references(child, component_schemas)
            for key, child in schema.items()
            # title 은 클래스 이름에서 생성되어 계약과 무관
            if key != "title"
        }
    if isinstance(schema, list):
        return [_resolve_schema_references(child, component_schemas) for child in schema]
    return schema


def build_spring_called_endpoint_contract() -> dict:
    """경로별 요청 body·200 응답 스키마 추출 (POST 만)"""
    openapi = app.openapi()
    component_schemas = openapi["components"]["schemas"]
    contract_by_path = {}
    for path in SPRING_CALLED_PATHS:
        operation = openapi["paths"][path]["post"]
        request_schema = operation["requestBody"]["content"]["application/json"]["schema"]
        response_schema = operation["responses"]["200"]["content"]["application/json"]["schema"]
        contract_by_path[path] = {
            "request": _resolve_schema_references(request_schema, component_schemas),
            "response": _resolve_schema_references(response_schema, component_schemas),
        }
    return contract_by_path


def test_spring_called_endpoints_are_post_only():
    openapi_paths = app.openapi()["paths"]
    for path in SPRING_CALLED_PATHS:
        assert path in openapi_paths, f"Spring 호출 경로 누락: {path}"
        assert set(openapi_paths[path].keys()) == {"post"}


def test_spring_called_endpoint_schemas_match_snapshot():
    expected_contract = json.loads(SNAPSHOT_PATH.read_text(encoding="utf-8"))
    assert build_spring_called_endpoint_contract() == expected_contract
