"""중복 과금 방지 판정 (#877): LLM 재시도 대상, 요청 시간 상한, 실패 응답 error_kind, 템플릿 1회 치환, 정리 삭제 상한"""
import asyncio
import json
from pathlib import Path

import httpx
import pytest

from src.clients import llm_client, shared_http_client
from src.clients.ai_connection_store import AiConnection
from src.core.exceptions import ErrorKind, LlmUnavailableError
from src.services.question_generation_service import render_template
from src.services.question_vector_index_service import is_prune_deletion_allowed

ERROR_KIND_SNAPSHOT_PATH = Path(__file__).parent / "snapshots" / "error_kinds.json"
CLAUDE_PRO = AiConnection("claude-pro", "CLAUDE", "claude-haiku-5-5", "claude-key-1")


def _status_error(status_code: int) -> httpx.HTTPStatusError:
    request = httpx.Request("POST", "https://example.test")
    return httpx.HTTPStatusError("failed", request=request, response=httpx.Response(status_code, request=request))


@pytest.mark.parametrize("error, is_retryable", [
    (httpx.ConnectError("refused"), True),
    (httpx.ConnectTimeout("connect timeout"), True),
    (_status_error(429), True),
    # 요청이 도착해 과금됐을 수 있음 > 재시도 안 함 (Spring AiServerRetryPredicate 와 같은 기준)
    (httpx.ReadTimeout("read timeout"), False),
    (_status_error(500), False),
    (_status_error(503), False),
])
def test_billed_request_retries_only_unsent_or_rate_limited(error, is_retryable):
    assert shared_http_client._is_retryable_billed_http_error(error) is is_retryable


def test_unbilled_request_still_retries_read_timeout_and_server_error():
    assert shared_http_client._is_transient_http_error(httpx.ReadTimeout("read timeout"))
    assert shared_http_client._is_transient_http_error(_status_error(503))


def test_llm_request_deadline_raises_llm_unavailable(monkeypatch):
    class SlowClient:
        async def chat(self, **kwargs):
            await asyncio.sleep(1)

    async def fake_load():
        return [CLAUDE_PRO]

    monkeypatch.setattr(llm_client, "load_ai_connections", fake_load)
    monkeypatch.setattr(llm_client, "_select_client", lambda provider: SlowClient())
    monkeypatch.setattr(llm_client, "LLM_REQUEST_DEADLINE_SECONDS", 0.01)

    with pytest.raises(LlmUnavailableError):
        asyncio.run(llm_client.chat("system", "user", None, 0.3, 256))


def test_error_kinds_match_snapshot_shared_with_spring():
    assert sorted(kind.value for kind in ErrorKind) == json.loads(ERROR_KIND_SNAPSHOT_PATH.read_text(encoding="utf-8"))


def test_validation_failure_body_carries_invalid_request_kind(api_client):
    response = api_client.post("/api/ai/index-question", json={"question_uuid": "not-a-uuid"})

    assert response.status_code == 422
    assert response.json()["error_kind"] == ErrorKind.INVALID_REQUEST


def test_template_renders_once_without_reinjecting_variable_values():
    rendered = render_template("{stem} / {answer_sql} / {unknown}", {"stem": "{answer_sql}", "answer_sql": None})
    assert rendered == "{answer_sql} /  / {unknown}"


@pytest.mark.parametrize("deletion_count, point_count, is_allowed", [
    (20, 20, True),
    (50, 100, True),
    (51, 100, False),
    (900, 1000, False),
])
def test_prune_deletion_is_capped_by_ratio(deletion_count, point_count, is_allowed):
    assert is_prune_deletion_allowed(deletion_count, point_count) is is_allowed
