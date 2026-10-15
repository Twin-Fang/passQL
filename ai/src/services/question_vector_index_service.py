"""src.services.question_vector_index_service
문제 벡터 색인 관리: 임베딩 적재(단건·일괄), 색인 상태 비교, 고아 벡터 정리
"""
import logging

from src.clients.ollama_client import ollama_client
from src.clients.qdrant_search_client import qdrant_search_client
from src.core.config import settings
from src.core.exceptions import CustomError
from src.models.ai_request import (
    IndexQuestionRequest,
    IndexQuestionsBulkRequest,
    IndexStatusRequest,
)
from src.models.ai_response import (
    IndexQuestionResponse,
    IndexQuestionsBulkResponse,
    IndexStatusResponse,
    PruneIndexResponse,
)

logger = logging.getLogger(__name__)


class QuestionVectorIndexService:
    """
    문제 벡터 색인: 문제 텍스트 > Ollama 임베딩 > Qdrant 업서트, DB UUID <-> Qdrant UUID 비교·정리
    """

    def _build_embed_text(self, req: IndexQuestionRequest) -> str:
        """
        문제 임베딩용 텍스트를 조합한다.
        토픽/서브토픽/난이도/태그/문제 본문 앞 300자를 구조화된 형태로 결합.
        """
        topic_path = req.topic_display_name
        if req.subtopic_display_name:
            topic_path = f"{req.topic_display_name} > {req.subtopic_display_name}"

        tags_str = ", ".join(req.tag_keys) if req.tag_keys else "없음"
        stem_preview = req.stem[:300] if len(req.stem) > 300 else req.stem

        return (
            f"[TOPIC] {topic_path}\n"
            f"[DIFFICULTY] {req.difficulty}/5\n"
            f"[TAGS] {tags_str}\n"
            f"[STEM] {stem_preview}"
        )

    async def index_question(self, req: IndexQuestionRequest) -> IndexQuestionResponse:
        """
        문제 1개 임베딩 > Qdrant 문제 컬렉션(settings.QDRANT_COLLECTION) 업서트.

        컬렉션이 없으면 자동 생성한다.

        Args:
            req: IndexQuestionRequest

        Returns:
            IndexQuestionResponse: 적재 결과 (created 여부)

        Raises:
            CustomError: 임베딩 생성 또는 Qdrant 저장 실패 시
        """
        logger.info(f"[index-question] question_uuid={req.question_uuid}")

        # 컬렉션 없으면 자동 생성
        await qdrant_search_client.create_collection_if_not_exists(
            settings.QDRANT_COLLECTION, settings.EMBEDDING_VECTOR_DIMENSION
        )

        # 기존 벡터 존재 여부로 created 판단
        existing = await qdrant_search_client.get_vector(settings.QDRANT_COLLECTION, req.question_uuid)
        created = existing is None

        # 임베딩 (모델은 .env 한 곳: 컬렉션 차원과 묶여 있어 관리자 설정으로 바꾸지 않음)
        embed_text = self._build_embed_text(req)
        embed_model = settings.OLLAMA_EMBED_MODEL
        vector = await ollama_client.embed(model=embed_model, text=embed_text)
        # 차원 불일치 (.env 모델만 바꾼 경우) > 업서트 전 원인 명시
        if len(vector) != settings.EMBEDDING_VECTOR_DIMENSION:
            raise CustomError(
                f"임베딩 차원 불일치: model={embed_model}, dimension={len(vector)}, "
                f"expected={settings.EMBEDDING_VECTOR_DIMENSION}"
            )

        # Qdrant upsert (question_uuid를 point_id로 사용)
        payload = {
            "question_uuid": req.question_uuid,
            "topic": req.topic_display_name,
            "subtopic": req.subtopic_display_name or "",
            "difficulty": req.difficulty,
            "tag_keys": req.tag_keys,
        }
        await qdrant_search_client.upsert(
            collection=settings.QDRANT_COLLECTION,
            point_id=req.question_uuid,
            vector=vector,
            payload=payload,
        )

        logger.info(f"[index-question] 적재 완료: question_uuid={req.question_uuid}, created={created}")
        return IndexQuestionResponse(question_uuid=req.question_uuid, created=created)

    async def index_questions_bulk(self, req: IndexQuestionsBulkRequest) -> IndexQuestionsBulkResponse:
        """
        여러 문제를 순차적으로 임베딩 적재 (관리자 전체 재색인용).

        개별 실패는 스킵하고 계속 진행하며 실패 목록을 반환한다.

        Args:
            req: IndexQuestionsBulkRequest

        Returns:
            IndexQuestionsBulkResponse: 성공/실패 집계

        Raises:
            CustomError: 치명적 오류 시
        """
        logger.info(f"[index-questions-bulk] 총 {len(req.questions)}개 처리 시작")

        succeeded = 0
        failed_uuids: list[str] = []

        for q in req.questions:
            try:
                await self.index_question(q)
                succeeded += 1
            except Exception as e:
                logger.warning(f"[index-questions-bulk] 개별 실패: question_uuid={q.question_uuid}, err={e}")
                failed_uuids.append(q.question_uuid)

        logger.info(f"[index-questions-bulk] 완료: succeeded={succeeded}, failed={len(failed_uuids)}")
        return IndexQuestionsBulkResponse(
            total=len(req.questions),
            succeeded=succeeded,
            failed=len(failed_uuids),
            failed_uuids=failed_uuids,
        )

    async def get_index_status(self, req: IndexStatusRequest) -> IndexStatusResponse:
        """
        DB 전체 문제 UUID와 Qdrant 색인 UUID를 비교하여 미색인 목록 반환.

        흐름:
        1. Qdrant scroll_all_ids로 컬렉션의 모든 포인트 UUID 수집
        2. DB UUID 집합과 차집합 계산 → 미색인 UUID 목록 도출

        Args:
            req: IndexStatusRequest (Java에서 전달한 DB 전체 문제 UUID 목록)

        Returns:
            IndexStatusResponse: 컬렉션 포인트 수, DB 문제 수, 미색인 수, 미색인 UUID 목록
        """
        logger.info(f"[index-status] 요청: db_uuid_count={len(req.question_uuids)}")

        # Qdrant에서 현재 색인된 모든 UUID 수집
        qdrant_ids = await qdrant_search_client.scroll_all_ids(settings.QDRANT_COLLECTION)
        qdrant_uuid_set = set(qdrant_ids)
        db_uuid_set = set(req.question_uuids)

        # 차집합: DB에 있지만 Qdrant에 없는 UUID = 미색인
        unindexed = list(db_uuid_set - qdrant_uuid_set)

        logger.info(
            f"[index-status] 결과: db={len(db_uuid_set)}, qdrant={len(qdrant_uuid_set)}, "
            f"미색인={len(unindexed)}"
        )
        # 미색인 UUID 앞 10개만 DEBUG 출력 (목록이 길 경우 로그 폭발 방지)
        logger.debug(
            f"[index-status] 미색인 UUID (앞 10개): "
            f"{unindexed[:10]}{'...' if len(unindexed) > 10 else ''}"
        )

        return IndexStatusResponse(
            collection_points_count=len(qdrant_uuid_set),
            db_question_count=len(db_uuid_set),
            unindexed_count=len(unindexed),
            unindexed_uuids=unindexed,
            orphan_count=len(qdrant_uuid_set - db_uuid_set),
        )

    async def prune_index(self, req: IndexStatusRequest) -> PruneIndexResponse:
        """
        Java가 넘긴 활성 문제 UUID에 없는 Qdrant 포인트(고아 벡터)를 삭제한다 (#412).

        문제 삭제·비활성 때 벡터를 지우는 경로가 없어, 남은 벡터가 추천 결과 상위를 차지했다.
        활성 목록이 비어 있으면 컬렉션 전체 삭제가 되므로 거부한다 — 호출부 버그로 색인이 날아가는 것을 막는다.
        """
        if not req.question_uuids:
            raise CustomError("활성 문제 UUID 목록이 비어 있어 정리를 거부합니다")

        qdrant_ids = await qdrant_search_client.scroll_all_ids(settings.QDRANT_COLLECTION)
        orphans = sorted(set(qdrant_ids) - set(req.question_uuids))
        await qdrant_search_client.delete_points(settings.QDRANT_COLLECTION, orphans)

        logger.info(f"[prune-index] 고아 벡터 삭제: {len(orphans)}개 (활성 {len(req.question_uuids)}개 기준)")
        return PruneIndexResponse(deleted_count=len(orphans), deleted_uuids=orphans)


# 싱글턴 인스턴스
question_vector_index_service = QuestionVectorIndexService()
