"""src.clients.ai_connection_store
AI 연결 목록 읽기: Spring 이 Redis 에 쓴 사용 중 연결(우선순위 순) > 키 복호화 > 연결 목록 (#695)
목록이 비었거나 못 읽으면 환경변수 키로 비상 연결 구성
"""
import json
import logging
from dataclasses import dataclass

from src.clients.redis_app_setting_client import get_raw_value
from src.clients.setting_secret_cipher import SettingSecretError, decrypt_setting_secret, is_encrypted
from src.core.config import settings
from src.core.exceptions import CustomError

logger = logging.getLogger(__name__)

# Spring AiConnectionService 가 쓰는 키 (값: JSON 배열, 사용 중 연결만 우선순위 순)
AI_CONNECTIONS_REDIS_KEY = "passql:ai:connections"
# 키 암호문 AAD 접두사 (Spring 과 같은 값: "ai_connection:" + connection_uuid)
CONNECTION_SECRET_AAD_PREFIX = "ai_connection:"

# 제공자 코드 3종 (Spring AiProvider enum 이름과 같음)
PROVIDER_GEMINI = "GEMINI"
PROVIDER_CLAUDE = "CLAUDE"
PROVIDER_OPENAI = "OPENAI"
SUPPORTED_PROVIDERS = (PROVIDER_GEMINI, PROVIDER_CLAUDE, PROVIDER_OPENAI)

# 비상 연결 기본 모델 (Redis 목록이 없을 때만)
EMERGENCY_CLAUDE_MODEL = "claude-haiku-5-5"
EMERGENCY_GEMINI_MODEL = "gemini-2.5-flash-lite"


@dataclass(frozen=True)
class AiConnection:
    connection_name: str
    provider: str
    default_model: str
    api_key: str


def _decrypt_connection_key(connection_uuid: str, stored_value: str) -> str:
    """암호문 > 평문 (AAD = ai_connection:{uuid}), 평문은 그대로, 복호화 실패 > 빈 문자열 (호출 시 키 미설정으로 다음 연결)"""
    if not stored_value or not is_encrypted(stored_value):
        return stored_value or ""
    try:
        return decrypt_setting_secret(CONNECTION_SECRET_AAD_PREFIX + connection_uuid, stored_value)
    except SettingSecretError as error:
        logger.error(f"[ai connection] decrypt failed : connection={connection_uuid} : {error}")
        return ""


def parse_ai_connections(raw_json: str | None) -> list[AiConnection]:
    """Redis JSON 배열 > 연결 목록 (형식 오류·모르는 제공자 항목은 건너뜀, 순서 유지)"""
    if not raw_json:
        return []
    try:
        items = json.loads(raw_json)
    except json.JSONDecodeError as error:
        logger.error(f"[ai connection] invalid json : {error}")
        return []
    if not isinstance(items, list):
        return []
    connections = []
    for item in items:
        if not isinstance(item, dict) or item.get("provider") not in SUPPORTED_PROVIDERS:
            continue
        connections.append(AiConnection(
            connection_name=str(item.get("connection_name") or item.get("connection_uuid") or ""),
            provider=item["provider"],
            default_model=str(item.get("default_model") or ""),
            api_key=_decrypt_connection_key(str(item.get("connection_uuid") or ""), str(item.get("encrypted_api_key") or "")),
        ))
    return connections


def build_emergency_connections() -> list[AiConnection]:
    """환경변수 키 > 비상 연결 (Claude 먼저, 다음 Gemini)"""
    connections = []
    if settings.CLAUDE_API_KEY:
        connections.append(AiConnection("env-claude", PROVIDER_CLAUDE, EMERGENCY_CLAUDE_MODEL, settings.CLAUDE_API_KEY))
    if settings.GEMINI_API_KEY:
        connections.append(AiConnection("env-gemini", PROVIDER_GEMINI, EMERGENCY_GEMINI_MODEL, settings.GEMINI_API_KEY))
    return connections


async def load_ai_connections() -> list[AiConnection]:
    """Redis 연결 목록 > 없으면 비상 연결 > 둘 다 없으면 CustomError"""
    connections = parse_ai_connections(await get_raw_value(AI_CONNECTIONS_REDIS_KEY))
    if connections:
        return connections
    emergency_connections = build_emergency_connections()
    if emergency_connections:
        logger.warning("[ai connection] redis list empty, env emergency connections used")
        return emergency_connections
    raise CustomError("사용 가능한 AI 연결 없음")
