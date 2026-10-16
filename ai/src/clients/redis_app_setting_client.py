"""src.clients.redis_app_setting_client
Spring과 공유하는 Redis에서 app_setting 값을 읽어오는 클라이언트.

Redis 키 형식: passql:settings:{setting_key}
값이 없으면 .env 기본값(fallback)을 사용한다.
"""
import logging
import time
import redis
from src.clients.setting_secret_cipher import SettingSecretError, decrypt_setting_secret, is_encrypted
from src.core.config import settings

logger = logging.getLogger(__name__)

REDIS_PREFIX = "passql:settings:"
_RETRY_INTERVAL_SEC = 30  # 연결 실패 후 재시도 대기 시간

_redis_client: redis.Redis | None = None
_last_failure_time: float = 0.0


def _get_redis() -> redis.Redis | None:
    global _redis_client, _last_failure_time
    if _redis_client is not None:
        return _redis_client
    # 실패 후 쿨다운이 끝나지 않았으면 즉시 None 반환 (타임아웃 반복 방지)
    if time.monotonic() - _last_failure_time < _RETRY_INTERVAL_SEC:
        return None
    try:
        client = redis.Redis(
            host=settings.REDIS_HOST,
            port=settings.REDIS_PORT,
            password=settings.REDIS_PASSWORD or None,
            decode_responses=True,
            socket_connect_timeout=2,
            socket_timeout=2,
        )
        client.ping()
        _redis_client = client
        logger.info(f"Redis 연결 성공: {settings.REDIS_HOST}:{settings.REDIS_PORT}")
    except Exception as e:
        _last_failure_time = time.monotonic()
        logger.warning(f"Redis 연결 실패 — {_RETRY_INTERVAL_SEC}초 후 재시도: {e}")
    return _redis_client


def get_setting(key: str, fallback: str) -> str:
    """
    Redis에서 설정값을 읽어온다. 없거나 연결 실패 시 fallback 반환.

    Args:
        key: app_setting의 setting_key (예: 'ai.gemini_model')
        fallback: Redis 미연결 또는 키 없을 때 사용할 기본값

    Returns:
        str: 설정값
    """
    try:
        client = _get_redis()
        if client is None:
            return fallback
        value = client.get(REDIS_PREFIX + key)
        if value is not None:  # 빈 문자열("")도 유효한 설정값으로 처리 (Java와 동일)
            _SENSITIVE = ("key", "secret", "password", "token")
            log_value = "***" if any(k in key.lower() for k in _SENSITIVE) else value
            logger.debug(f"Redis 설정 로드: {key}={log_value}")
            return value
    except Exception as e:
        logger.warning(f"Redis 설정 읽기 실패 ({key}) — fallback 사용: {e}")
    return fallback


GEMINI_API_KEY_SETTING = "ai.gemini_api_key"


def get_gemini_api_key() -> str:
    """Redis 암호문 > 복호화, 평문(전환 전)은 그대로, 복호화 실패·미설정은 env GEMINI_API_KEY"""
    stored_value = get_setting(GEMINI_API_KEY_SETTING, settings.GEMINI_API_KEY)
    if not is_encrypted(stored_value):
        return stored_value
    try:
        return decrypt_setting_secret(GEMINI_API_KEY_SETTING, stored_value)
    except SettingSecretError as error:
        logger.error(f"Gemini 키 복호화 실패 — env GEMINI_API_KEY 로 대체: {error}")
        return settings.GEMINI_API_KEY

