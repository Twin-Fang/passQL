"""src.clients.shared_http_client
외부 HTTP 호출 공통: 공유 AsyncClient 1개(lifespan 생성·종료), 일시 오류 재시도, 실패 > CustomError 변환
Ollama·Qdrant·Claude·OpenAI 클라이언트가 모두 send_request 를 거친다
"""
import logging
from typing import Any, Optional

import httpx

from src.core.exceptions import CustomError
from src.core.external_call_limits import LOGGED_RESPONSE_TEXT_MAXIMUM_LENGTH
from src.core.retry import call_with_retry, is_rate_limited_status_code, is_transient_status_code

logger = logging.getLogger(__name__)

# 요청별 timeout 미지정 시 기본값 (30초)
DEFAULT_TIMEOUT_SECONDS = 30

# 요청이 상대 서버에 닿기 전 실패한 전송 오류 3종: 연결 실패, 연결 시간 초과, 연결 풀 대기 초과
UNSENT_REQUEST_ERROR_TYPES = (httpx.ConnectError, httpx.ConnectTimeout, httpx.PoolTimeout)

_shared_http_client: Optional[httpx.AsyncClient] = None


def open_shared_http_client() -> httpx.AsyncClient:
    """공유 클라이언트 생성 (이미 열려 있으면 그대로, lifespan 시작 시)"""
    global _shared_http_client
    if _shared_http_client is None or _shared_http_client.is_closed:
        _shared_http_client = httpx.AsyncClient(timeout=DEFAULT_TIMEOUT_SECONDS)
    return _shared_http_client


async def close_shared_http_client() -> None:
    """공유 클라이언트 종료 (lifespan 종료 시)"""
    global _shared_http_client
    if _shared_http_client is not None:
        await _shared_http_client.aclose()
        _shared_http_client = None


def _is_transient_http_error(error: Exception) -> bool:
    """과금 없는 호출 재시도 대상: 연결·타임아웃 등 전송 오류, 429·5xx 응답"""
    if isinstance(error, httpx.HTTPStatusError):
        return is_transient_status_code(error.response.status_code)
    return isinstance(error, httpx.TransportError)


def is_unsent_request_error(error: Exception) -> bool:
    """요청 미전송 오류 여부 (읽기 시간 초과는 상대가 처리·과금했을 수 있어 제외)"""
    return isinstance(error, UNSENT_REQUEST_ERROR_TYPES)


def _is_retryable_billed_http_error(error: Exception) -> bool:
    """LLM 호출 재시도 대상: 요청 미전송 오류, 429 응답 (Spring AiServerRetryPredicate 와 같은 기준)"""
    if isinstance(error, httpx.HTTPStatusError):
        return is_rate_limited_status_code(error.response.status_code)
    return is_unsent_request_error(error)


async def send_request(
    operation_name: str,
    method: str,
    url: str,
    *,
    headers: Optional[dict] = None,
    json_body: Any = None,
    params: Optional[dict] = None,
    timeout_seconds: float = DEFAULT_TIMEOUT_SECONDS,
    passthrough_status_codes: tuple[int, ...] = (),
    is_billed_request: bool = False,
) -> httpx.Response:
    """
    HTTP 요청 1건: 공유 클라이언트 > 재시도 포함 전송 > 상태 검사 > 응답
    passthrough_status_codes(예: 404) 응답은 그대로 반환, is_billed_request(LLM)는 요청 미전송·429만 재시도
    """

    async def send_once() -> httpx.Response:
        # lifespan 없이 쓰이는 경우(테스트·스크립트) 대비 지연 생성
        client = open_shared_http_client()
        response = await client.request(
            method, url, headers=headers, json=json_body, params=params, timeout=timeout_seconds
        )
        if response.status_code not in passthrough_status_codes:
            response.raise_for_status()
        return response

    try:
        is_retryable_error = _is_retryable_billed_http_error if is_billed_request else _is_transient_http_error
        return await call_with_retry(operation_name, send_once, is_retryable_error)
    except httpx.HTTPStatusError as error:
        logger.error(
            f"[{operation_name}] HTTP error {error.response.status_code} : "
            f"{error.response.text[:LOGGED_RESPONSE_TEXT_MAXIMUM_LENGTH]}"
        )
        raise CustomError(f"{operation_name} HTTP 오류: {error.response.status_code}") from error
    except httpx.RequestError as error:
        logger.error(f"[{operation_name}] request error : {error!r}")
        raise CustomError(f"{operation_name} 요청 오류: {type(error).__name__}") from error
