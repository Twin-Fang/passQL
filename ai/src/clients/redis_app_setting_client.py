"""src.clients.redis_app_setting_client
Spring 과 공유하는 Redis 읽기 클라이언트 (AI 연결 목록 passql:ai:connections 등)
연결 1개를 지연 생성해 재사용, 연결 실패 후 30초 동안은 시도 없이 None
"""
import asyncio
import logging
import time

import redis.asyncio as redis_asyncio

from src.core.config import settings

logger = logging.getLogger(__name__)

# 연결 실패 후 재시도 대기 (30초)
RECONNECT_COOLDOWN_SECONDS = 30
# 연결·읽기 대기 상한 (2초, LLM 호출 경로를 오래 막지 않게)
REDIS_SOCKET_TIMEOUT_SECONDS = 2

_redis_client: redis_asyncio.Redis | None = None
_last_failure_time: float = 0.0
# 첫 연결 동시 진입 시 클라이언트 1개만 만들도록 직렬화
_connect_lock = asyncio.Lock()


async def _get_redis() -> redis_asyncio.Redis | None:
    """연결된 클라이언트 (없으면 생성·ping, 쿨다운 중이거나 실패면 None)"""
    global _redis_client, _last_failure_time
    if _redis_client is not None:
        return _redis_client
    async with _connect_lock:
        # 대기 중 다른 요청이 연결을 마쳤으면 그대로 사용
        if _redis_client is not None:
            return _redis_client
        # 실패 후 쿨다운이 끝나지 않았으면 즉시 None (타임아웃 반복 방지)
        if time.monotonic() - _last_failure_time < RECONNECT_COOLDOWN_SECONDS:
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
        except Exception as error:
            _last_failure_time = time.monotonic()
            await client.aclose()
            logger.warning(f"[redis app setting] connect failed, retry after {RECONNECT_COOLDOWN_SECONDS}s : {error}")
        return _redis_client


async def close_redis_client() -> None:
    """Redis 연결 종료 (lifespan 종료 시)"""
    global _redis_client
    if _redis_client is not None:
        await _redis_client.aclose()
        _redis_client = None


async def get_raw_value(full_key: str) -> str | None:
    """접두사 없는 Redis 키 값 그대로 (미연결·없음·읽기 실패 > None)"""
    try:
        client = await _get_redis()
        if client is None:
            return None
        return await client.get(full_key)
    except Exception as error:
        logger.warning(f"[redis app setting] raw read failed : key={full_key} : {error}")
        return None
