"""src.clients.redis_app_setting_client
Spring과 공유하는 Redis에서 app_setting 값을 읽어오는 클라이언트.

Redis 키 형식: passql:settings:{setting_key}
값이 없으면 .env 기본값(fallback)을 사용한다.
"""
import logging
import time

import redis.asyncio as redis_asyncio

from src.core.config import settings

logger = logging.getLogger(__name__)

REDIS_PREFIX = "passql:settings:"
_RETRY_INTERVAL_SEC = 30  # 연결 실패 후 재시도 대기 시간
# 연결·읽기 대기 상한 (2초, Gemini 호출 경로를 오래 막지 않게)
REDIS_SOCKET_TIMEOUT_SECONDS = 2
# 로그에 값 대신 *** 를 남길 설정 키 조각
SENSITIVE_KEY_FRAGMENTS = ("key", "secret", "password", "token")

_redis_client: redis_asyncio.Redis | None = None
_last_failure_time: float = 0.0


async def _get_redis() -> redis_asyncio.Redis | None:
    global _redis_client, _last_failure_time
    if _redis_client is not None:
        return _redis_client
    # 실패 후 쿨다운이 끝나지 않았으면 즉시 None 반환 (타임아웃 반복 방지)
    if time.monotonic() - _last_failure_time < _RETRY_INTERVAL_SEC:
        return None
    client = redis_asyncio.Redis(
        host=settings.REDIS_HOST,
        port=settings.REDIS_PORT,
        password=settings.REDIS_PASSWORD or None,
        decode_responses=True,
        socket_connect_timeout=REDIS_SOCKET_TIMEOUT_SECONDS,
        socket_timeout=REDIS_SOCKET_TIMEOUT_SECONDS,
    )
    try:
        await client.ping()
        _redis_client = client
        logger.info(f"[redis app setting] connected : {settings.REDIS_HOST}:{settings.REDIS_PORT}")
    except Exception as e:
        _last_failure_time = time.monotonic()
        await client.aclose()
        logger.warning(f"[redis app setting] connect failed, retry after {_RETRY_INTERVAL_SEC}s : {e}")
    return _redis_client


async def close_redis_client() -> None:
    """Redis 연결 종료 (lifespan 종료 시)"""
    global _redis_client
    if _redis_client is not None:
        await _redis_client.aclose()
        _redis_client = None


def _mask_setting_value(key: str, value: str) -> str:
    """민감 키(key·secret·password·token 포함) 값 > ***"""
    return "***" if any(fragment in key.lower() for fragment in SENSITIVE_KEY_FRAGMENTS) else value


async def get_setting(key: str, fallback: str) -> str:
    """
    Redis에서 설정값을 읽어온다. 없거나 연결 실패 시 fallback 반환.

    Args:
        key: app_setting의 setting_key (예: 'ai.gemini_model')
        fallback: Redis 미연결 또는 키 없을 때 사용할 기본값

    Returns:
        str: 설정값
    """
    try:
        client = await _get_redis()
        if client is None:
            return fallback
        value = await client.get(REDIS_PREFIX + key)
        if value is not None:  # 빈 문자열("")도 유효한 설정값으로 처리 (Java와 동일)
            logger.debug(f"[redis app setting] loaded : {key}={_mask_setting_value(key, value)}")
            return value
    except Exception as e:
        logger.warning(f"[redis app setting] read failed, using fallback : key={key} : {e}")
    return fallback


async def get_raw_value(full_key: str) -> str | None:
    """접두사 없는 Redis 키 값 그대로 (미연결·없음·읽기 실패 > None)"""
    try:
        client = await _get_redis()
        if client is None:
            return None
        return await client.get(full_key)
    except Exception as e:
        logger.warning(f"[redis app setting] raw read failed : key={full_key} : {e}")
        return None
