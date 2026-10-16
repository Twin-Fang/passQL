"""설정 비밀값 복호화 (#492): Java 와 공유하는 고정 벡터, 변조·AAD 불일치 거부, Gemini 키 대체 경로"""
import base64

import pytest

from src.clients import redis_app_setting_client
from src.clients.setting_secret_cipher import SettingSecretError, decrypt_setting_secret, is_encrypted
from src.core.config import settings

# Java 테스트(SettingSecretCipherTest)와 같은 고정 벡터: 마스터 키 0x00..0x1f
TEST_MASTER_KEY = base64.b64encode(bytes(range(32))).decode()
FIXED_VECTOR_KEY = "ai.gemini_api_key"
FIXED_VECTOR_PLAIN = "AIza-test-key-123"
FIXED_VECTOR_STORED = "enc:v1:AAECAwQFBgcICQoLBkuseuiRp2j5bPzuyMRJX7AOJnAIWX9Qw4vxeETP6FHO"


@pytest.fixture(autouse=True)
def master_key(monkeypatch):
    monkeypatch.setattr(settings, "SETTING_ENCRYPTION_KEY", TEST_MASTER_KEY)
    monkeypatch.setattr(settings, "GEMINI_API_KEY", "env-fallback-key")


def test_java_가_만든_고정_벡터를_복호화():
    assert decrypt_setting_secret(FIXED_VECTOR_KEY, FIXED_VECTOR_STORED) == FIXED_VECTOR_PLAIN


def test_다른_setting_key_는_거부():
    with pytest.raises(SettingSecretError):
        decrypt_setting_secret("other.api_key", FIXED_VECTOR_STORED)


def test_변조된_암호문은_거부():
    payload = bytearray(base64.b64decode(FIXED_VECTOR_STORED[len("enc:v1:"):]))
    payload[-1] ^= 0x01
    tampered = "enc:v1:" + base64.b64encode(bytes(payload)).decode()
    with pytest.raises(SettingSecretError):
        decrypt_setting_secret(FIXED_VECTOR_KEY, tampered)


def test_깨진_base64_는_거부():
    with pytest.raises(SettingSecretError):
        decrypt_setting_secret(FIXED_VECTOR_KEY, "enc:v1:not base64!!")


def test_마스터_키가_없거나_길이가_틀리면_거부(monkeypatch):
    monkeypatch.setattr(settings, "SETTING_ENCRYPTION_KEY", "")
    with pytest.raises(SettingSecretError):
        decrypt_setting_secret(FIXED_VECTOR_KEY, FIXED_VECTOR_STORED)
    monkeypatch.setattr(settings, "SETTING_ENCRYPTION_KEY", base64.b64encode(b"short").decode())
    with pytest.raises(SettingSecretError):
        decrypt_setting_secret(FIXED_VECTOR_KEY, FIXED_VECTOR_STORED)


def test_접두사로_암호문_여부_판정():
    assert is_encrypted(FIXED_VECTOR_STORED)
    assert not is_encrypted("AIza-plain")
    assert not is_encrypted("")


def test_gemini_키는_Redis_암호문을_복호화(monkeypatch):
    monkeypatch.setattr(redis_app_setting_client, "get_setting", lambda key, fallback: FIXED_VECTOR_STORED)
    assert redis_app_setting_client.get_gemini_api_key() == FIXED_VECTOR_PLAIN


def test_gemini_키_평문은_그대로(monkeypatch):
    monkeypatch.setattr(redis_app_setting_client, "get_setting", lambda key, fallback: "legacy-plain")
    assert redis_app_setting_client.get_gemini_api_key() == "legacy-plain"


def test_gemini_키_복호화_실패는_env_키로_대체(monkeypatch):
    monkeypatch.setattr(settings, "SETTING_ENCRYPTION_KEY", "")
    monkeypatch.setattr(redis_app_setting_client, "get_setting", lambda key, fallback: FIXED_VECTOR_STORED)
    assert redis_app_setting_client.get_gemini_api_key() == "env-fallback-key"


def test_Redis_가_없으면_env_키(monkeypatch):
    monkeypatch.setattr(redis_app_setting_client, "get_setting", lambda key, fallback: fallback)
    assert redis_app_setting_client.get_gemini_api_key() == "env-fallback-key"
