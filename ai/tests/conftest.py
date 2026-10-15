"""공통 픽스처: 테스트용 API 키, 인증 헤더 붙인 TestClient"""
import pytest
from fastapi.testclient import TestClient

from src.core.config import settings
from src.main import app

TEST_AI_SERVER_API_KEY = "test-ai-server-api-key"


@pytest.fixture
def api_client(monkeypatch) -> TestClient:
    monkeypatch.setattr(settings, "AI_SERVER_API_KEY", TEST_AI_SERVER_API_KEY)
    # raise_server_exceptions=False: 예외 처리기가 만든 500 응답을 그대로 검증
    return TestClient(
        app,
        headers={"X-API-Key": TEST_AI_SERVER_API_KEY},
        raise_server_exceptions=False,
    )
