"""src.clients.qdrant_search_client
Qdrant 벡터 DB 클라이언트 (search / upsert)
"""
import logging

from src.clients.shared_http_client import send_request
from src.core.config import settings

logger = logging.getLogger(__name__)

# 일반 요청 응답 대기 상한 (30초)
REQUEST_TIMEOUT_SECONDS = 30
# scroll 은 대용량 가능 (60초)
SCROLL_TIMEOUT_SECONDS = 60
# scroll 1페이지 포인트 수
SCROLL_PAGE_SIZE = 1000
# 응답 그대로 받는 상태: 404 컬렉션·포인트 없음
NOT_FOUND_STATUS_CODE = 404


class QdrantSearchClient:
    """
    Qdrant REST API 비동기 클라이언트: 벡터 저장, 유사도 검색
    - search: 벡터 유사도 검색 (top_k 결과 반환)
    - upsert: 벡터 + payload 저장 (없으면 삽입, 있으면 갱신)
    """

    def __init__(self):
        self.base_url = settings.QDRANT_URL.rstrip("/")
        self.api_key = settings.QDRANT_API_KEY
        self.timeout = REQUEST_TIMEOUT_SECONDS

    def _headers(self) -> dict:
        """공통 요청 헤더 반환"""
        headers = {"Content-Type": "application/json"}
        if self.api_key:
            headers["api-key"] = self.api_key
        return headers

    async def create_collection_if_not_exists(
        self,
        collection: str,
        vector_size: int,
    ) -> bool:
        """
        Qdrant 컬렉션이 없으면 생성 (있으면 스킵)

        Args:
            collection: 생성할 컬렉션 이름
            vector_size: 벡터 차원 수 (settings.EMBEDDING_VECTOR_DIMENSION)

        Returns:
            bool: True=신규 생성, False=이미 존재

        Raises:
            CustomError: API 호출 실패 시
        """
        collection_url = f"{self.base_url}/collections/{collection}"
        check_response = await send_request(
            "Qdrant create_collection", "GET", collection_url,
            headers=self._headers(), timeout_seconds=self.timeout,
            passthrough_status_codes=(NOT_FOUND_STATUS_CODE,),
        )
        if check_response.status_code != NOT_FOUND_STATUS_CODE:
            logger.info(f"Qdrant 컬렉션 이미 존재: {collection}")
            return False

        # 컬렉션 없음 > 생성
        body = {
            "vectors": {
                "size": vector_size,
                "distance": "Cosine",
            }
        }
        await send_request(
            "Qdrant create_collection", "PUT", collection_url,
            headers=self._headers(), json_body=body, timeout_seconds=self.timeout,
        )
        logger.info(f"Qdrant 컬렉션 생성 완료: {collection}, dim={vector_size}")
        return True

    async def get_vector(
        self,
        collection: str,
        point_id: int | str,
    ) -> list[float] | None:
        """
        Qdrant에서 특정 point의 벡터를 조회

        Args:
            collection: 컬렉션 이름
            point_id: 포인트 ID

        Returns:
            list[float] | None: 벡터 (없으면 None)

        Raises:
            CustomError: API 호출 실패 시
        """
        url = f"{self.base_url}/collections/{collection}/points/{point_id}"
        response = await send_request(
            "Qdrant get_vector", "GET", url,
            headers=self._headers(), params={"with_vector": "true"}, timeout_seconds=self.timeout,
            passthrough_status_codes=(NOT_FOUND_STATUS_CODE,),
        )
        if response.status_code == NOT_FOUND_STATUS_CODE:
            return None
        return response.json().get("result", {}).get("vector")

    async def search(
        self,
        collection: str,
        vector: list[float],
        top_k: int = 3,
        must_not_ids: list[str] | None = None,
    ) -> list[dict]:
        """
        Qdrant 컬렉션에서 벡터 유사도 검색

        Args:
            collection: 검색할 컬렉션 이름
            vector: 쿼리 벡터
            top_k: 반환할 최대 결과 수
            must_not_ids: 결과에서 제외할 question_uuid 목록 (이미 푼 문제 제외)

        Returns:
            list[dict]: [{"id": ..., "score": ..., "payload": {...}}, ...] 형식의 결과 목록

        Raises:
            CustomError: API 호출 실패 시
        """
        url = f"{self.base_url}/collections/{collection}/points/search"
        payload: dict = {
            "vector": vector,
            "limit": top_k,
            "with_payload": True,
        }

        # 이미 푼 문제 제외 필터 — question_uuid payload 값 기준
        if must_not_ids:
            payload["filter"] = {
                "must_not": [
                    {
                        "key": "question_uuid",
                        "match": {"any": must_not_ids},
                    }
                ]
            }

        logger.info(f"Qdrant search: collection={collection}, top_k={top_k}, vector_dim={len(vector)}, must_not_count={len(must_not_ids) if must_not_ids else 0}")

        response = await send_request(
            "Qdrant search", "POST", url,
            headers=self._headers(), json_body=payload, timeout_seconds=self.timeout,
        )
        results = response.json().get("result", [])
        logger.info(f"Qdrant search 완료: 결과 수={len(results)}")
        return results

    async def get_collection_info(self, collection: str) -> dict:
        """
        Qdrant 컬렉션 기본 정보 조회 (포인트 수, 벡터 차원, 상태).

        Args:
            collection: 조회할 컬렉션 이름

        Returns:
            dict: {"points_count": int, "vector_size": int, "status": str}
                  컬렉션 미존재 시 {"points_count": 0, "vector_size": 0, "status": "not_found"}

        Raises:
            CustomError: API 호출 실패 시
        """
        url = f"{self.base_url}/collections/{collection}"
        logger.debug(f"[qdrant] get_collection_info 요청: url={url}")
        response = await send_request(
            "Qdrant get_collection_info", "GET", url,
            headers=self._headers(), timeout_seconds=self.timeout,
            passthrough_status_codes=(NOT_FOUND_STATUS_CODE,),
        )
        if response.status_code == NOT_FOUND_STATUS_CODE:
            logger.info(f"[qdrant] 컬렉션 없음: {collection}")
            return {"points_count": 0, "vector_size": 0, "status": "not_found"}

        result = response.json().get("result", {})
        config = result.get("config", {}).get("params", {})
        vectors_config = config.get("vectors", {})
        # 단일 벡터 컬렉션 — vectors 키 없이 바로 size/distance
        vector_size = vectors_config.get("size", 0) if isinstance(vectors_config, dict) else 0
        points_count = result.get("points_count", 0)
        status = result.get("status", "unknown")

        logger.debug(
            f"[qdrant] get_collection_info 응답: collection={collection}, "
            f"points_count={points_count}, vector_size={vector_size}, status={status}"
        )
        return {"points_count": points_count, "vector_size": vector_size, "status": status}

    async def scroll_all_ids(self, collection: str) -> list[str]:
        """
        Qdrant 컬렉션의 모든 포인트 ID(UUID 문자열)를 페이지네이션으로 수집.

        scroll API: limit=1000씩, next_page_offset이 None이 될 때까지 반복.
        with_payload=false, with_vector=false — ID만 수집하여 응답 최소화.

        Args:
            collection: 조회할 컬렉션 이름

        Returns:
            list[str]: 전체 포인트 UUID 문자열 목록

        Raises:
            CustomError: API 호출 실패 시
        """
        url = f"{self.base_url}/collections/{collection}/points/scroll"
        all_ids: list[str] = []
        offset = None
        page = 0

        logger.info(f"[qdrant] scroll_all_ids 시작: collection={collection}")

        # 페이지 단위 수집 (next_page_offset 없을 때까지)
        while True:
            body: dict = {
                "limit": SCROLL_PAGE_SIZE,
                "with_payload": False,
                "with_vector": False,
            }
            if offset is not None:
                body["offset"] = offset

            response = await send_request(
                "Qdrant scroll_all_ids", "POST", url,
                headers=self._headers(), json_body=body, timeout_seconds=SCROLL_TIMEOUT_SECONDS,
                passthrough_status_codes=(NOT_FOUND_STATUS_CODE,),
            )
            if response.status_code == NOT_FOUND_STATUS_CODE:
                logger.info("[qdrant] scroll_all_ids: 컬렉션 없음 — 빈 목록 반환")
                return []

            result = response.json().get("result", {})
            points = result.get("points", [])
            next_offset = result.get("next_page_offset")

            page_ids = [str(p["id"]) for p in points if "id" in p]
            all_ids.extend(page_ids)

            logger.debug(
                f"[qdrant] scroll_all_ids page {page}: "
                f"offset={offset}, collected={len(page_ids)}, total_so_far={len(all_ids)}"
            )
            page += 1

            if not next_offset:
                break
            offset = next_offset

        logger.info(f"[qdrant] scroll_all_ids 완료: collection={collection}, total={len(all_ids)}")
        return all_ids

    async def upsert(
        self,
        collection: str,
        point_id: int | str,
        vector: list[float],
        payload: dict,
    ) -> None:
        """
        Qdrant 컬렉션에 벡터 + payload 저장 (upsert)

        Args:
            collection: 저장할 컬렉션 이름
            point_id: 포인트 ID (question_id 등)
            vector: 저장할 벡터
            payload: 저장할 메타데이터 딕셔너리

        Raises:
            CustomError: API 호출 실패 시
        """
        # TODO: 배치 upsert 지원 추가
        url = f"{self.base_url}/collections/{collection}/points"
        body = {
            "points": [
                {
                    "id": point_id,
                    "vector": vector,
                    "payload": payload,
                }
            ]
        }

        logger.info(f"Qdrant upsert: collection={collection}, id={point_id}, vector_dim={len(vector)}")

        await send_request(
            "Qdrant upsert", "PUT", url,
            headers=self._headers(), json_body=body, timeout_seconds=self.timeout,
        )
        logger.info(f"Qdrant upsert 완료: id={point_id}")

    async def delete_points(self, collection: str, point_ids: list[str]) -> None:
        """
        Qdrant 컬렉션에서 포인트를 ID로 삭제한다 (고아 벡터 정리용).

        Raises:
            CustomError: API 호출 실패 시
        """
        if not point_ids:
            return
        url = f"{self.base_url}/collections/{collection}/points/delete?wait=true"
        await send_request(
            "Qdrant delete_points", "POST", url,
            headers=self._headers(), json_body={"points": point_ids}, timeout_seconds=self.timeout,
        )
        logger.info(f"[qdrant] delete_points 완료: collection={collection}, count={len(point_ids)}")

# 싱글턴 인스턴스
qdrant_search_client = QdrantSearchClient()
