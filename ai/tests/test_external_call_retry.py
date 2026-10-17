"""외부 호출 공통 지점: 일시 오류 재시도 횟수, 비일시 오류 즉시 실패, CustomError 변환, Gemini 고정 문구"""
import asyncio

import httpx
import pytest
from google.genai import errors

from src.clients import shared_http_client
from src.clients.gemini_client import CALL_FAILED_DETAIL, gemini_client
from src.core import retry
from src.core.exceptions import CustomError

TEST_URL = "http://external.test/resource"


@pytest.fixture(autouse=True)
def skip_backoff_sleep(monkeypatch):
    """backoff 대기 제거 (재시도 횟수만 검증)"""
    async def no_sleep(seconds):
        return None

    monkeypatch.setattr(retry.asyncio, "sleep", no_sleep)


def _install_fake_transport(monkeypatch, status_codes: list[int]) -> list[int]:
    """공유 클라이언트를 가짜 전송으로 교체: 호출마다 status_codes 를 차례로 응답, 호출 기록 반환"""
    received_status_codes: list[int] = []

    def handle_request(request: httpx.Request) -> httpx.Response:
        status_code = status_codes[min(len(received_status_codes), len(status_codes) - 1)]
        received_status_codes.append(status_code)
        return httpx.Response(status_code, json={"result": "ok"})

    fake_client = httpx.AsyncClient(transport=httpx.MockTransport(handle_request))
    monkeypatch.setattr(shared_http_client, "_shared_http_client", fake_client)
    return received_status_codes


def _send_test_request(**options) -> httpx.Response:
    return asyncio.run(shared_http_client.send_request("test call", "GET", TEST_URL, **options))


def test_transient_status_is_retried_then_succeeds(monkeypatch):
    received_status_codes = _install_fake_transport(monkeypatch, [503, 429, 200])
    assert _send_test_request().status_code == 200
    assert received_status_codes == [503, 429, 200]


def test_transient_status_gives_up_after_maximum_retries(monkeypatch):
    received_status_codes = _install_fake_transport(monkeypatch, [500])
    with pytest.raises(CustomError) as raised:
        _send_test_request()
    assert raised.value.message == "test call HTTP 오류: 500"
    assert len(received_status_codes) == 1 + retry.MAXIMUM_RETRY_COUNT


def test_client_error_status_is_not_retried(monkeypatch):
    received_status_codes = _install_fake_transport(monkeypatch, [400, 200])
    with pytest.raises(CustomError):
        _send_test_request()
    assert received_status_codes == [400]


def test_passthrough_status_is_returned_without_error(monkeypatch):
    received_status_codes = _install_fake_transport(monkeypatch, [404])
    assert _send_test_request(passthrough_status_codes=(404,)).status_code == 404
    assert received_status_codes == [404]


def test_timeout_is_retried_and_converted_to_custom_error(monkeypatch):
    attempt_count = 0

    def raise_timeout(request: httpx.Request) -> httpx.Response:
        nonlocal attempt_count
        attempt_count += 1
        raise httpx.ReadTimeout("timed out", request=request)

    monkeypatch.setattr(
        shared_http_client, "_shared_http_client", httpx.AsyncClient(transport=httpx.MockTransport(raise_timeout))
    )
    with pytest.raises(CustomError) as raised:
        _send_test_request()
    assert raised.value.message == "test call 요청 오류: ReadTimeout"
    assert attempt_count == 1 + retry.MAXIMUM_RETRY_COUNT


class _FakeGeminiModels:
    """client.aio.models 대역: 정해진 예외를 차례로 던지고 마지막엔 텍스트 응답"""

    def __init__(self, raised_errors: list[Exception]):
        self.raised_errors = raised_errors
        self.call_count = 0

    async def generate_content(self, **kwargs):
        self.call_count += 1
        if self.raised_errors:
            raise self.raised_errors.pop(0)
        return type("FakeResponse", (), {"text": "응답"})()


def _install_fake_gemini(monkeypatch, raised_errors: list[Exception]) -> _FakeGeminiModels:
    fake_models = _FakeGeminiModels(raised_errors)
    fake_client = type("FakeClient", (), {"aio": type("FakeAio", (), {"models": fake_models})()})()

    async def fake_get_client():
        return fake_client

    monkeypatch.setattr(gemini_client, "_get_client", fake_get_client)
    return fake_models


def _chat() -> str:
    return asyncio.run(
        gemini_client.chat(system_prompt="system", user_prompt="user", model="gemini-test", temperature=0.1, max_tokens=10)
    )


def test_gemini_server_error_is_retried(monkeypatch):
    fake_models = _install_fake_gemini(monkeypatch, [errors.ServerError(503, {"error": {"message": "busy"}})])
    assert _chat() == "응답"
    assert fake_models.call_count == 2


def test_gemini_client_error_returns_fixed_detail_without_sdk_message(monkeypatch):
    sdk_error = errors.ClientError(400, {"error": {"message": "secret-internal-detail"}})
    fake_models = _install_fake_gemini(monkeypatch, [sdk_error])
    with pytest.raises(CustomError) as raised:
        _chat()
    assert raised.value.message == CALL_FAILED_DETAIL
    assert fake_models.call_count == 1
