"""src.clients.ollama_client
Ollama API 클라이언트 (임베딩 전용)
"""
import logging

from src.clients.shared_http_client import send_request
from src.core.config import settings
from src.core.exceptions import CustomError

logger = logging.getLogger(__name__)


class OllamaClient:
    """
    Ollama API 비동기 클라이언트

    Ollama /api/embed 호출: 문제 텍스트 > 임베딩 벡터
    """

    def __init__(self):
        self.base_url = settings.OLLAMA_API_URL.rstrip("/")
        self.api_key = settings.OLLAMA_API_KEY
        self.timeout = settings.OLLAMA_TIMEOUT_SEC

    def _headers(self) -> dict:
        """공통 요청 헤더 반환"""
        return {
            "Content-Type": "application/json",
            "X-API-Key": self.api_key,
        }

    async def embed(self, model: str, text: str) -> list[float]:
        """
        Ollama /api/embed 호출

        Args:
            model: 임베딩 모델명 (예: "qwen3-embedding:4b")
            text: 임베딩할 텍스트

        Returns:
            list[float]: 임베딩 벡터

        Raises:
            CustomError: API 호출 실패 또는 응답 파싱 실패 시
        """
        # TODO: 배치 임베딩 지원 추가
        url = f"{self.base_url}/api/embed"
        payload = {
            "model": model,
            "input": text,
        }

        logger.info(f"Ollama embed 호출: model={model}, text_length={len(text)}")

        response = await send_request(
            "Ollama embed", "POST", url,
            headers=self._headers(), json_body=payload, timeout_seconds=self.timeout,
        )
        data = response.json()

        # Ollama /api/embed 응답: {"embeddings": [[...]], ...}
        embeddings = data.get("embeddings", [])
        if not embeddings or not embeddings[0]:
            raise CustomError("Ollama embed 응답에 embeddings가 없습니다")

        vector = embeddings[0]
        logger.info(f"Ollama embed 응답 수신: vector_dim={len(vector)}")
        return vector


# 싱글턴 인스턴스
ollama_client = OllamaClient()
