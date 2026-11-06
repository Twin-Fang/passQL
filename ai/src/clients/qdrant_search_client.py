"""src.clients.qdrant_search_client
Qdrant 벡터 DB 클라이언트: 컬렉션 확인·생성, 포인트 일괄 조회, 유사도 검색, 업서트, ID 전체 수집, 삭제
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
    Qdrant REST API 비동기 클라이언트
    컬렉션 존재 확인은 프로세스당 1회 (확인된 이름 보관, 업서트 실패 시 forget_confirmed_collection 으로 다시 확인)
    """

    def __init__(self):
        self.base_url = settings.QDRANT_URL.rstrip("/")
        self.api_key = settings.QDRANT_API_KEY
        self.timeout = REQUEST_TIMEOUT_SECONDS
        self._confirmed_collection_names: set[str] = set()

    def _headers(self) -> dict:
        """공통 요청 헤더 (api-key 는 설정된 경우만)"""
        headers = {"Content-Type": "application/json"}
        if self.api_key:
            headers["api-key"] = self.api_key
        return headers

    async def create_collection_if_not_exists(self, collection: str, vector_size: int) -> bool:
        """컬렉션 확인 > 없으면 생성 (True = 신규 생성, 이미 확인된 컬렉션은 호출 없이 False)"""
        if collection in self._confirmed_collection_names:
            return False
        collection_url = f"{self.base_url}/collections/{collection}"
        check_response = await send_request(
            "Qdrant create_collection", "GET", collection_url,
            headers=self._headers(), timeout_seconds=self.timeout,
            passthrough_status_codes=(NOT_FOUND_STATUS_CODE,),
        )
        if check_response.status_code != NOT_FOUND_STATUS_CODE:
            self._confirmed_collection_names.add(collection)
            return False

        # 컬렉션 없음 > 생성 (코사인 거리)
        body = {"vectors": {"size": vector_size, "distance": "Cosine"}}
        await send_request(
            "Qdrant create_collection", "PUT", collection_url,
            headers=self._headers(), json_body=body, timeout_seconds=self.timeout,
        )
        self._confirmed_collection_names.add(collection)
        logger.info(f"[qdrant] collection created : {collection}, dimension={vector_size}")
        return True

    def forget_confirmed_collection(self, collection: str) -> None:
        """컬렉션 확인 기록 삭제 (컬렉션 재생성 등으로 쓰기가 실패했을 때 다음 호출에서 다시 확인)"""
        self._confirmed_collection_names.discard(collection)

    async def retrieve_points(
        self, collection: str, point_ids: list[str], should_include_vector: bool
    ) -> dict[str, list[float] | None]:
        """포인트 여러 개 1회 조회 > {포인트 ID: 벡터 또는 None} (없는 포인트 제외, 컬렉션 없으면 빈 dict)"""
        if not point_ids:
            return {}
        url = f"{self.base_url}/collections/{collection}/points"
        body = {"ids": point_ids, "with_payload": False, "with_vector": should_include_vector}
        response = await send_request(
            "Qdrant retrieve_points", "POST", url,
            headers=self._headers(), json_body=body, timeout_seconds=self.timeout,
            passthrough_status_codes=(NOT_FOUND_STATUS_CODE,),
        )
        if response.status_code == NOT_FOUND_STATUS_CODE:
            return {}
        points = response.json().get("result") or []
        return {str(point["id"]): point.get("vector") for point in points if "id" in point}

    async def search(
        self,
        collection: str,
        vector: list[float],
        top_k: int = 3,
        must_not_ids: list[str] | None = None,
    ) -> list[dict]:
        """벡터 유사도 검색 > [{"id", "score", "payload"}, ...] (must_not_ids: 결과에서 뺄 question_uuid 목록)"""
        url = f"{self.base_url}/collections/{collection}/points/search"
        body: dict = {"vector": vector, "limit": top_k, "with_payload": True}

        # 이미 푼 문제 제외 필터 (question_uuid payload 값 기준)
        if must_not_ids:
            body["filter"] = {"must_not": [{"key": "question_uuid", "match": {"any": must_not_ids}}]}

        response = await send_request(
            "Qdrant search", "POST", url,
            headers=self._headers(), json_body=body, timeout_seconds=self.timeout,
        )
        results = response.json().get("result", [])
        logger.info(
            f"[qdrant] search : collection={collection}, top_k={top_k}, "
            f"must_not_count={len(must_not_ids or [])}, result_count={len(results)}"
        )
        return results

    async def scroll_all_ids(self, collection: str) -> list[str]:
        """컬렉션 전체 포인트 ID 수집 (1000개씩 scroll, payload·벡터 제외, 컬렉션 없으면 빈 목록)"""
        url = f"{self.base_url}/collections/{collection}/points/scroll"
        all_ids: list[str] = []
        offset = None

        # 페이지 단위 수집 (next_page_offset 없을 때까지)
        while True:
            body: dict = {"limit": SCROLL_PAGE_SIZE, "with_payload": False, "with_vector": False}
            if offset is not None:
                body["offset"] = offset

            response = await send_request(
                "Qdrant scroll_all_ids", "POST", url,
                headers=self._headers(), json_body=body, timeout_seconds=SCROLL_TIMEOUT_SECONDS,
                passthrough_status_codes=(NOT_FOUND_STATUS_CODE,),
            )
            if response.status_code == NOT_FOUND_STATUS_CODE:
                logger.info(f"[qdrant] scroll_all_ids : collection not found, empty list : {collection}")
                return []

            result = response.json().get("result", {})
            all_ids.extend(str(point["id"]) for point in result.get("points", []) if "id" in point)
            offset = result.get("next_page_offset")
            if not offset:
                break

        logger.info(f"[qdrant] scroll_all_ids : collection={collection}, total={len(all_ids)}")
        return all_ids

    async def upsert(self, collection: str, point_id: str, vector: list[float], payload: dict) -> None:
        """벡터 + payload 저장 (없으면 삽입, 있으면 갱신)"""
        url = f"{self.base_url}/collections/{collection}/points"
        body = {"points": [{"id": point_id, "vector": vector, "payload": payload}]}
        await send_request(
            "Qdrant upsert", "PUT", url,
            headers=self._headers(), json_body=body, timeout_seconds=self.timeout,
        )
        logger.info(f"[qdrant] upsert : collection={collection}, id={point_id}, dimension={len(vector)}")

    async def delete_points(self, collection: str, point_ids: list[str]) -> None:
        """포인트 ID 목록 삭제 (고아 벡터 정리용, 빈 목록이면 호출 없음)"""
        if not point_ids:
            return
        url = f"{self.base_url}/collections/{collection}/points/delete?wait=true"
        await send_request(
            "Qdrant delete_points", "POST", url,
            headers=self._headers(), json_body={"points": point_ids}, timeout_seconds=self.timeout,
        )
        logger.info(f"[qdrant] delete_points : collection={collection}, count={len(point_ids)}")


# 싱글턴 인스턴스
qdrant_search_client = QdrantSearchClient()
