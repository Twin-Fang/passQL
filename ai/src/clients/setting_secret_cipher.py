"""src.clients.setting_secret_cipher
설정 비밀값 복호화: AES-256-GCM, 저장 형식 enc:v1:{base64(nonce ‖ 암호문 ‖ tag)}
AAD = setting_key, Spring(SettingSecretCipher)가 만든 암호문을 읽는다
"""
import base64
import binascii

from cryptography.exceptions import InvalidTag
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

from src.core.config import settings

# 암호문 접두사 (없으면 전환 전 평문)
ENCRYPTED_PREFIX = "enc:v1:"
MASTER_KEY_BYTES = 32
NONCE_BYTES = 12


class SettingSecretError(Exception):
    """마스터 키 미설정·형식 오류, 암호문 변조·AAD 불일치"""


def is_encrypted(stored_value: str) -> bool:
    return stored_value.startswith(ENCRYPTED_PREFIX)


def decrypt_setting_secret(setting_key: str, stored_value: str) -> str:
    """enc:v1:... > 평문 (실패는 SettingSecretError, 값은 에러 메시지에 넣지 않음)"""
    master_key = _read_master_key()
    try:
        payload = base64.b64decode(stored_value[len(ENCRYPTED_PREFIX):], validate=True)
        nonce, cipher_and_tag = payload[:NONCE_BYTES], payload[NONCE_BYTES:]
        plain_bytes = AESGCM(master_key).decrypt(nonce, cipher_and_tag, setting_key.encode("utf-8"))
        return plain_bytes.decode("utf-8")
    except (InvalidTag, binascii.Error, ValueError) as error:
        raise SettingSecretError(f"decrypt failed : key={setting_key}") from error


def _read_master_key() -> bytes:
    """SETTING_ENCRYPTION_KEY (base64, 32바이트) 검증"""
    if not settings.SETTING_ENCRYPTION_KEY:
        raise SettingSecretError("SETTING_ENCRYPTION_KEY is not configured")
    try:
        master_key = base64.b64decode(settings.SETTING_ENCRYPTION_KEY.strip(), validate=True)
    except binascii.Error as error:
        raise SettingSecretError("SETTING_ENCRYPTION_KEY is not valid base64") from error
    if len(master_key) != MASTER_KEY_BYTES:
        raise SettingSecretError(f"SETTING_ENCRYPTION_KEY must be {MASTER_KEY_BYTES} bytes")
    return master_key
