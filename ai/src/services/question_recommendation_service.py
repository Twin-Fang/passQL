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

    async def recommend(self, request: RecommendRequest) -> RecommendResponse:
        """추천: 오답 벡터 1회 일괄 조회 > 평균 쿼리 벡터 > 푼 문제 제외 검색 (오답 벡터 없으면 빈 결과)"""
        logger.info(
            f"[recommend] size={request.size}, wrong_count={len(request.recent_wrong_question_uuids)}, "
            f"solved_count={len(request.solved_question_uuids)}"
        )

        # 오답 문제 벡터 수집 (요청 순서 유지, 중복 제거)
        wrong_question_uuids = list(dict.fromkeys(str(uuid) for uuid in request.recent_wrong_question_uuids))
        vector_by_question_uuid = await qdrant_search_client.retrieve_points(
            settings.QDRANT_COLLECTION, wrong_question_uuids, should_include_vector=True
        )
        source_vectors = [vector for vector in vector_by_question_uuid.values() if vector]

        # 쿼리에 쓸 오답 벡터가 없으면 빈 결과 (Spring 이 RANDOM 대체)
        if not source_vectors:
            logger.info("[recommend] no source vector : empty result (Spring RANDOM fallback)")
            return RecommendResponse(items=[], query_source_count=0)

        # 여러 벡터 단순 평균 > 쿼리 벡터
        query_vector = [sum(components) / len(source_vectors) for components in zip(*source_vectors)]

        solved_question_uuids = [str(uuid) for uuid in request.solved_question_uuids]
        results = await qdrant_search_client.search(
            collection=settings.QDRANT_COLLECTION,
            vector=query_vector,
            top_k=request.size,
            must_not_ids=solved_question_uuids or None,
        )

        items = [
            RecommendedQuestion(question_uuid=result["payload"]["question_uuid"], score=result["score"])
            for result in results
            if result.get("payload", {}).get("question_uuid")
        ]

        logger.info(f"[recommend] completed : item_count={len(items)}")
        return RecommendResponse(items=items, query_source_count=len(source_vectors))


# 싱글턴 인스턴스
question_recommendation_service = QuestionRecommendationService()
