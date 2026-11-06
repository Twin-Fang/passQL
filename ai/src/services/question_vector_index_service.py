"""src.services.question_vector_index_service
문제 벡터 색인 관리: 임베딩 적재(단건·일괄), 색인 상태 비교, 고아 벡터 정리
"""
import logging

from src.clients.ollama_client import ollama_client
from src.clients.qdrant_search_client import qdrant_search_client
from src.core.config import settings
from src.core.exceptions import CustomError, InvalidRequestError
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

# 임베딩 텍스트에 넣을 문제 본문 앞부분 길이 (글자 수)
EMBEDDED_STEM_PREVIEW_LENGTH = 300
# 정리 1회 삭제 상한: 컬렉션 포인트의 50% 초과 삭제 거부 (호출부 버그·키 유출로 색인이 통째로 지워지지 않게, #877)
PRUNE_MAXIMUM_DELETION_RATIO = 0.5
# 작은 컬렉션은 비율과 무관하게 이 수까지 삭제 허용
PRUNE_ALWAYS_ALLOWED_DELETION_COUNT = 20


def is_prune_deletion_allowed(deletion_count: int, collection_point_count: int) -> bool:
    """정리 삭제 수가 상한 이내인지 (상한 = max(20, 포인트 수 × 50%))"""
    deletion_limit = max(PRUNE_ALWAYS_ALLOWED_DELETION_COUNT, collection_point_count * PRUNE_MAXIMUM_DELETION_RATIO)
    return deletion_count <= deletion_limit


class QuestionVectorIndexService:
    """
    문제 벡터 색인: 문제 텍스트 > Ollama 임베딩 > Qdrant 업서트, DB UUID <-> Qdrant UUID 비교·정리
    """

    def _build_embed_text(self, request: IndexQuestionRequest) -> str:
        """임베딩 텍스트: 토픽 경로·난이도·태그·본문 앞 300자를 구조화해 결합"""
        topic_path = request.topic_display_name
        if request.subtopic_display_name:
            topic_path = f"{request.topic_display_name} > {request.subtopic_display_name}"

        joined_tags = ", ".join(request.tag_keys) if request.tag_keys else "없음"
        stem_preview = request.stem[:EMBEDDED_STEM_PREVIEW_LENGTH]

        return (
            f"[TOPIC] {topic_path}\n"
            f"[DIFFICULTY] {request.difficulty}/5\n"
            f"[TAGS] {joined_tags}\n"
            f"[STEM] {stem_preview}"
        )

    async def index_question(self, request: IndexQuestionRequest) -> IndexQuestionResponse:
        """문제 1개: 컬렉션 확인(없으면 생성) > 기존 포인트 여부 > 임베딩 > 차원 검사 > 업서트 (실패 > CustomError)"""
        question_uuid = str(request.question_uuid)
        collection = settings.QDRANT_COLLECTION
        logger.info(f"[index-question] question_uuid={question_uuid}")

        await qdrant_search_client.create_collection_if_not_exists(collection, settings.EMBEDDING_VECTOR_DIMENSION)

        # 기존 포인트 여부로 created 판단 (벡터 없이 ID 만 조회)
        existing_points = await qdrant_search_client.retrieve_points(
            collection, [question_uuid], should_include_vector=False
        )
        is_created = question_uuid not in existing_points

        # 임베딩 (모델은 .env 한 곳: 컬렉션 차원과 묶여 있어 관리자 설정으로 바꾸지 않음)
        embed_text = self._build_embed_text(request)
        embed_model = settings.OLLAMA_EMBED_MODEL
        vector = await ollama_client.embed(model=embed_model, text=embed_text)
        # 차원 불일치 (.env 모델만 바꾼 경우) > 업서트 전 원인 명시
        if len(vector) != settings.EMBEDDING_VECTOR_DIMENSION:
            raise CustomError(
                f"임베딩 차원 불일치: model={embed_model}, dimension={len(vector)}, "
                f"expected={settings.EMBEDDING_VECTOR_DIMENSION}"
            )

        # Qdrant upsert (question_uuid 를 point_id 로 사용)
        payload = {
            "question_uuid": question_uuid,
            "topic": request.topic_display_name,
            "subtopic": request.subtopic_display_name or "",
            "difficulty": request.difficulty,
            "tag_keys": request.tag_keys,
        }
        try:
            await qdrant_search_client.upsert(
                collection=collection, point_id=question_uuid, vector=vector, payload=payload
            )
        except CustomError:
            # 컬렉션이 지워졌을 수 있음 > 다음 요청에서 존재 확인부터 다시
            qdrant_search_client.forget_confirmed_collection(collection)
            raise

        logger.info(f"[index-question] indexed : question_uuid={question_uuid}, created={is_created}")
        return IndexQuestionResponse(question_uuid=question_uuid, created=is_created)

    async def index_questions_bulk(self, request: IndexQuestionsBulkRequest) -> IndexQuestionsBulkResponse:
        """여러 문제 순차 적재 (관리자 전체 재색인용, 개별 실패는 건너뛰고 실패 목록 반환)"""
        logger.info(f"[index-questions-bulk] started : total={len(request.questions)}")

        succeeded_count = 0
        failed_uuids: list[str] = []

        for question in request.questions:
            try:
                await self.index_question(question)
                succeeded_count += 1
            except Exception as error:
                logger.warning(
                    f"[index-questions-bulk] item failed : question_uuid={question.question_uuid}, error={error}"
                )
                failed_uuids.append(str(question.question_uuid))

        logger.info(f"[index-questions-bulk] completed : succeeded={succeeded_count}, failed={len(failed_uuids)}")
        return IndexQuestionsBulkResponse(
            total=len(request.questions),
            succeeded=succeeded_count,
            failed=len(failed_uuids),
            failed_uuids=failed_uuids,
        )

    async def get_index_status(self, request: IndexStatusRequest) -> IndexStatusResponse:
        """DB 문제 UUID <-> Qdrant 포인트 UUID 비교 > 미색인·고아 수 (Qdrant 전체 ID scroll)"""
        logger.info(f"[index-status] requested : db_uuid_count={len(request.question_uuids)}")

        qdrant_uuid_set = set(await qdrant_search_client.scroll_all_ids(settings.QDRANT_COLLECTION))
        db_uuid_set = {str(question_uuid) for question_uuid in request.question_uuids}

        # 차집합: DB 에 있지만 Qdrant 에 없는 UUID = 미색인
        unindexed_uuids = list(db_uuid_set - qdrant_uuid_set)

        logger.info(
            f"[index-status] result : db={len(db_uuid_set)}, qdrant={len(qdrant_uuid_set)}, "
            f"unindexed={len(unindexed_uuids)}"
        )
        return IndexStatusResponse(
            collection_points_count=len(qdrant_uuid_set),
            db_question_count=len(db_uuid_set),
            unindexed_count=len(unindexed_uuids),
            unindexed_uuids=unindexed_uuids,
            orphan_count=len(qdrant_uuid_set - db_uuid_set),
        )

    async def prune_index(self, request: IndexStatusRequest) -> PruneIndexResponse:
        """
        활성 문제 UUID 에 없는 Qdrant 포인트(고아 벡터) 삭제 (#412)
        거부 2가지 (400): 활성 목록 비어 있음(전체 삭제), 삭제 수가 상한 초과 (#877)
        """
        if not request.question_uuids:
            raise InvalidRequestError("활성 문제 UUID 목록이 비어 있어 정리를 거부합니다")

        active_uuid_set = {str(question_uuid) for question_uuid in request.question_uuids}
        qdrant_ids = await qdrant_search_client.scroll_all_ids(settings.QDRANT_COLLECTION)
        orphan_uuids = sorted(set(qdrant_ids) - active_uuid_set)
        if not is_prune_deletion_allowed(len(orphan_uuids), len(qdrant_ids)):
            raise InvalidRequestError(
                f"정리 대상이 너무 많아 거부합니다: 삭제 {len(orphan_uuids)}개 / 전체 {len(qdrant_ids)}개 "
                f"(상한 {int(PRUNE_MAXIMUM_DELETION_RATIO * 100)}%)"
            )
        await qdrant_search_client.delete_points(settings.QDRANT_COLLECTION, orphan_uuids)

        logger.info(f"[prune-index] orphans deleted : {len(orphan_uuids)} (active {len(active_uuid_set)})")
        return PruneIndexResponse(deleted_count=len(orphan_uuids), deleted_uuids=orphan_uuids)


# 싱글턴 인스턴스
question_vector_index_service = QuestionVectorIndexService()
