"""src.utils.auth
X-API-Key 헤더 인증 dependency
"""
import logging
import secrets

from fastapi import Header, HTTPException
from src.core.config import settings

logger = logging.getLogger(__name__)


async def verify_api_key(x_api_key: str = Header(None)):
    """
    X-API-Key 헤더 검증 dependency

    Spring 서버가 AI 서버를 호출할 때 사용하는 API Key를 검증합니다.

    Args:
        x_api_key: 요청 헤더의 X-API-Key 값

    Raises:
        HTTPException: API Key가 없거나 일치하지 않을 때 401 반환
    """
    # 상수 시간 비교 (응답 시간 차로 키를 추측하지 못하게), 비ASCII 대비 bytes 비교
    is_api_key_matched = bool(x_api_key) and secrets.compare_digest(
        x_api_key.encode("utf-8"), settings.AI_SERVER_API_KEY.encode("utf-8")
    )
    if not is_api_key_matched:
        logger.warning(f"인증 실패: 유효하지 않은 X-API-Key")
        raise HTTPException(status_code=401, detail="Unauthorized")
