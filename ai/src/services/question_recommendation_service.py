"""src.services.question_recommendation_service
오답 벡터 기반 개인화 문제 추천 (Qdrant 유사도 검색)
"""
import logging

from src.clients.qdrant_search_client import qdrant_search_client
from src.core.config import settings
from src.models.ai_request import RecommendRequest
from src.models.ai_response import RecommendedQuestion, RecommendResponse

logger = logging.getLogger(__name__)


class QuestionRecommendationService:
    """
    문제 추천: 최근 오답 벡터 평균 > 푼 문제 제외 검색 (벡터 없으면 빈 결과, Spring 이 RANDOM 대체)
    """

    async def recommend(self, req: RecommendRequest) -> RecommendResponse:
        """
        사용자의 최근 오답 문제 벡터를 기반으로 유사 문제를 추천.

        흐름:
        1. recent_wrong_question_uuids로 Qdrant에서 각 문제의 벡터 조회
        2. 조회된 벡터들의 평균을 쿼리 벡터로 사용
        3. solved_question_uuids를 must_not 필터로 Qdrant 검색
        4. 벡터가 없으면 빈 결과 반환 (Java에서 RANDOM fallback 처리)

        Args:
            req: RecommendRequest

        Returns:
            RecommendResponse: 추천 문제 목록

        Raises:
            CustomError: Qdrant 검색 실패 시
        """
        logger.info(
            f"[recommend] size={req.size}, wrong_count={len(req.recent_wrong_question_uuids)}, "
            f"solved_count={len(req.solved_question_uuids)}"
        )

        # 오답 문제 벡터 수집
        source_vectors: list[list[float]] = []
        for uuid in req.recent_wrong_question_uuids:
            vec = await qdrant_search_client.get_vector(settings.QDRANT_COLLECTION, uuid)
            if vec:
                source_vectors.append(vec)

        # 쿼리에 사용할 오답 벡터가 없으면 빈 결과 — Java에서 RANDOM fallback 적용
        if not source_vectors:
            logger.info("[recommend] 쿼리 벡터 없음 — 빈 결과 반환 (Java RANDOM fallback 예정)")
            return RecommendResponse(items=[], query_source_count=0)

        # 여러 벡터를 단순 평균하여 쿼리 벡터 합성
        dim = len(source_vectors[0])
        query_vector = [
            sum(v[i] for v in source_vectors) / len(source_vectors)
            for i in range(dim)
        ]

        # 이미 푼 문제 제외하여 Qdrant 검색
        results = await qdrant_search_client.search(
            collection=settings.QDRANT_COLLECTION,
            vector=query_vector,
            top_k=req.size,
            must_not_ids=req.solved_question_uuids if req.solved_question_uuids else None,
        )

        items = [
            RecommendedQuestion(
                question_uuid=r["payload"]["question_uuid"],
                score=r["score"],
            )
            for r in results
            if r.get("payload", {}).get("question_uuid")
        ]

        logger.info(f"[recommend] 추천 완료: {len(items)}개")
        return RecommendResponse(items=items, query_source_count=len(source_vectors))


# 싱글턴 인스턴스
question_recommendation_service = QuestionRecommendationService()
