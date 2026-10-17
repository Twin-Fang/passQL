"""src.core.retry
외부 호출 일시 오류 재시도 공통 지점: 최대 2회, 지수 backoff (Gemini·Ollama·Qdrant 공통)
일시 오류 판정은 호출하는 쪽이 넘긴다 (httpx·SDK 예외 종류가 달라서)
"""
import asyncio
import logging
from typing import Awaitable, Callable, TypeVar

logger = logging.getLogger(__name__)

ResultType = TypeVar("ResultType")

# 첫 호출 뒤 추가 시도 횟수 (총 3회)
MAXIMUM_RETRY_COUNT = 2
# 첫 재시도 대기 (0.5초 > 1초 순으로 2배씩)
INITIAL_BACKOFF_SECONDS = 0.5
# 일시 오류로 보는 HTTP 상태: 429 요청 과다, 5xx 서버 오류
TOO_MANY_REQUESTS_STATUS_CODE = 429
SERVER_ERROR_MINIMUM_STATUS_CODE = 500


def is_transient_status_code(status_code: int) -> bool:
    return status_code == TOO_MANY_REQUESTS_STATUS_CODE or status_code >= SERVER_ERROR_MINIMUM_STATUS_CODE


async def call_with_retry(
    operation_name: str,
    call: Callable[[], Awaitable[ResultType]],
    is_transient_error: Callable[[Exception], bool],
) -> ResultType:
    """호출 > 일시 오류면 backoff 후 재호출 (최대 MAXIMUM_RETRY_COUNT회), 그 외 오류·마지막 실패는 그대로 raise"""
    attempt_number = 0
    while True:
        try:
            return await call()
        except Exception as error:
            if attempt_number >= MAXIMUM_RETRY_COUNT or not is_transient_error(error):
                raise
            backoff_seconds = INITIAL_BACKOFF_SECONDS * (2 ** attempt_number)
            attempt_number += 1
            logger.warning(
                f"[external retry] {operation_name} transient error, retry {attempt_number}/{MAXIMUM_RETRY_COUNT} "
                f"after {backoff_seconds}s : {type(error).__name__}"
            )
            await asyncio.sleep(backoff_seconds)
