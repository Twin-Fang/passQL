"""src.services.ollama_client
Ollama API 클라이언트 (임베딩 전용)
"""
import logging
import httpx
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

        try:
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.post(url, json=payload, headers=self._headers())
                response.raise_for_status()
                data = response.json()

            # Ollama /api/embed 응답: {"embeddings": [[...]], ...}
            embeddings = data.get("embeddings", [])
            if not embeddings or not embeddings[0]:
                raise CustomError("Ollama embed 응답에 embeddings가 없습니다")

            vector = embeddings[0]
            logger.info(f"Ollama embed 응답 수신: vector_dim={len(vector)}")
            return vector

        except httpx.HTTPStatusError as e:
            logger.error(f"Ollama embed HTTP 오류: {e.response.status_code} - {e.response.text}")
            raise CustomError(f"Ollama embed HTTP 오류: {e.response.status_code}")
        except httpx.RequestError as e:
            logger.error(f"Ollama embed 요청 오류: {e}")
            raise CustomError(f"Ollama embed 요청 오류: {e}")
        except CustomError:
            raise
        except Exception as e:
            logger.error(f"Ollama embed 예기치 않은 오류: {e}")
            raise CustomError(f"Ollama embed 예기치 않은 오류: {e}")


# 싱글턴 인스턴스
ollama_client = OllamaClient()
