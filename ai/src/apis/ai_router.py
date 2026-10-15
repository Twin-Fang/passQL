"""src.apis.ai_router
AI 엔드포인트 (Spring AiGatewayClient 전용): 문제·선택지 생성, 프롬프트 테스트, RAG 색인·추천·정리
"""
import logging
from fastapi import APIRouter, Depends, HTTPException
from src.models.ai_request import (
    GenerateChoiceSetRequest,
    GenerateQuestionFullRequest,
    IndexQuestionRequest,
    IndexQuestionsBulkRequest,
    IndexStatusRequest,
    RecommendRequest,
    TestPromptRequest,
)
from src.models.ai_response import (
    GenerateChoiceSetResponse,
    GenerateQuestionFullResponse,
    IndexQuestionResponse,
    IndexQuestionsBulkResponse,
    IndexStatusResponse,
    PruneIndexResponse,
    RecommendResponse,
    TestPromptResponse,
)
from src.services.ai_service import ai_service
from src.utils.auth import verify_api_key
from src.core.exceptions import CustomError

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api/ai", tags=["AI"])


# === 실시간 선택지 세트 생성 / 프롬프트 테스트 (신규) ===


@router.post(
    "/generate-question-full",
    response_model=GenerateQuestionFullResponse,
    status_code=200,
)
async def generate_question_full(
    request: GenerateQuestionFullRequest,
    _: None = Depends(verify_api_key),
):
    """
    관리자 문제 등록용 AI 생성.
    Spring 이 프롬프트 전문·response_schema 를 내려주면
    그대로 Gemini structured output 을 호출한다.
    """
    logger.info(
        f"[generate-question-full] topic={request.context.topic}, "
        f"difficulty={request.context.difficulty}"
    )
    try:
        return await ai_service.generate_question_full(request)
    except CustomError as e:
        logger.error(f"[generate-question-full] 실패: {e.message}")
        raise HTTPException(status_code=500, detail=e.message)
    except Exception as e:
        logger.error(f"[generate-question-full] 예기치 않은 오류: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="서버 내부 오류가 발생했습니다")


@router.post(
    "/generate-choice-set",
    response_model=GenerateChoiceSetResponse,
    status_code=200,
)
async def generate_choice_set(
    request: GenerateChoiceSetRequest,
    _: None = Depends(verify_api_key),
):
    """
    사용자 풀이용 AI 선택지 세트 생성 (메인 트래픽).
    """
    logger.info(
        f"[generate-choice-set] question_uuid={request.context.question_uuid}"
    )
    try:
        return await ai_service.generate_choice_set(request)
    except CustomError as e:
        logger.error(f"[generate-choice-set] 실패: {e.message}")
        raise HTTPException(status_code=500, detail=e.message)
    except Exception as e:
        logger.error(f"[generate-choice-set] 예기치 않은 오류: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="서버 내부 오류가 발생했습니다")


@router.post(
    "/test-prompt",
    response_model=TestPromptResponse,
    status_code=200,
)
async def test_prompt(
    request: TestPromptRequest,
    _: None = Depends(verify_api_key),
):
    """
    관리자 프롬프트 테스트.
    response_schema 가 있으면 JSON 강제, 없으면 일반 텍스트.
    """
    logger.info(f"[test-prompt] model={request.llm_config.model}")
    try:
        return await ai_service.test_prompt(request)
    except CustomError as e:
        logger.error(f"[test-prompt] 실패: {e.message}")
        raise HTTPException(status_code=500, detail=e.message)
    except Exception as e:
        logger.error(f"[test-prompt] 예기치 않은 오류: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="서버 내부 오류가 발생했습니다")


# === RAG 기반 개인화 추천 ===


@router.post(
    "/index-question",
    response_model=IndexQuestionResponse,
    status_code=200,
)
async def index_question(
    request: IndexQuestionRequest,
    _: None = Depends(verify_api_key),
):
    """
    문제 1개를 qwen3-embedding:4b으로 임베딩하여 Qdrant에 적재.

    문제 등록/수정 시 Java 서버에서 호출한다.
    컬렉션이 없으면 자동 생성된다.

    - POST /api/ai/index-question
    - Header: X-API-Key: {AI_SERVER_API_KEY}
    - Body: IndexQuestionRequest
    - 성공: 200 + IndexQuestionResponse
    """
    logger.info(f"[index-question] question_uuid={request.question_uuid}")
    try:
        return await ai_service.index_question(request)
    except CustomError as e:
        logger.error(f"[index-question] 실패: {e.message}")
        raise HTTPException(status_code=500, detail=e.message)
    except Exception as e:
        logger.error(f"[index-question] 예기치 않은 오류: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="서버 내부 오류가 발생했습니다")


@router.post(
    "/index-questions-bulk",
    response_model=IndexQuestionsBulkResponse,
    status_code=200,
)
async def index_questions_bulk(
    request: IndexQuestionsBulkRequest,
    _: None = Depends(verify_api_key),
):
    """
    문제 목록을 일괄 Qdrant 적재 (관리자 전체 재색인용).

    개별 실패는 스킵하고 계속 진행하며 실패 목록을 반환한다.

    - POST /api/ai/index-questions-bulk
    - Header: X-API-Key: {AI_SERVER_API_KEY}
    - Body: IndexQuestionsBulkRequest
    - 성공: 200 + IndexQuestionsBulkResponse
    """
    logger.info(f"[index-questions-bulk] 요청 count={len(request.questions)}")
    try:
        return await ai_service.index_questions_bulk(request)
    except CustomError as e:
        logger.error(f"[index-questions-bulk] 실패: {e.message}")
        raise HTTPException(status_code=500, detail=e.message)
    except Exception as e:
        logger.error(f"[index-questions-bulk] 예기치 않은 오류: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="서버 내부 오류가 발생했습니다")


@router.post(
    "/recommend",
    response_model=RecommendResponse,
    status_code=200,
)
async def recommend(
    request: RecommendRequest,
    _: None = Depends(verify_api_key),
):
    """
    사용자 신호 기반 개인화 문제 추천.

    Java가 Submission DB에서 최근 오답/푼 문제를 집계하여 전달하면
    Python은 Qdrant 벡터 검색으로 유사 문제를 반환한다.
    오답 벡터가 없으면 빈 결과 반환 (Java에서 RANDOM fallback 처리).

    - POST /api/ai/recommend
    - Header: X-API-Key: {AI_SERVER_API_KEY}
    - Body: RecommendRequest
    - 성공: 200 + RecommendResponse
    """
    logger.info(
        f"[recommend] size={request.size}, "
        f"wrong={len(request.recent_wrong_question_uuids)}, "
        f"solved={len(request.solved_question_uuids)}"
    )
    try:
        return await ai_service.recommend(request)
    except CustomError as e:
        logger.error(f"[recommend] 실패: {e.message}")
        raise HTTPException(status_code=500, detail=e.message)
    except Exception as e:
        logger.error(f"[recommend] 예기치 않은 오류: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="서버 내부 오류가 발생했습니다")


@router.post(
    "/index-status",
    response_model=IndexStatusResponse,
    status_code=200,
)
async def index_status(
    request: IndexStatusRequest,
    _: None = Depends(verify_api_key),
):
    """
    DB 전체 문제 UUID와 Qdrant 색인 UUID를 비교하여 미색인 목록 반환.

    Java 서버가 DB에서 조회한 전체 문제 UUID를 전달하면
    Python이 Qdrant scroll로 현재 색인된 UUID와 비교하여 미색인 목록을 반환한다.
    관리자 임베딩 인덱스 관리 화면에서 사용한다.

    - POST /api/ai/index-status
    - Header: X-API-Key: {AI_SERVER_API_KEY}
    - Body: IndexStatusRequest
    - 성공: 200 + IndexStatusResponse
    """
    logger.info(f"[index-status] db_uuid_count={len(request.question_uuids)}")
    try:
        return await ai_service.get_index_status(request)
    except CustomError as e:
        logger.error(f"[index-status] 실패: {e.message}")
        raise HTTPException(status_code=500, detail=e.message)
    except Exception as e:
        logger.error(f"[index-status] 예기치 않은 오류: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="서버 내부 오류가 발생했습니다")


@router.post(
    "/prune-index",
    response_model=PruneIndexResponse,
    status_code=200,
)
async def prune_index(
    request: IndexStatusRequest,
    _: None = Depends(verify_api_key),
):
    """
    활성 문제 UUID 목록에 없는 Qdrant 포인트(고아 벡터)를 삭제한다 (#412).

    - POST /api/ai/prune-index
    - Header: X-API-Key: {AI_SERVER_API_KEY}
    - Body: IndexStatusRequest (Java의 활성 문제 UUID 전체)
    - 성공: 200 + PruneIndexResponse
    """
    logger.info(f"[prune-index] keep_count={len(request.question_uuids)}")
    try:
        return await ai_service.prune_index(request)
    except CustomError as e:
        logger.error(f"[prune-index] 실패: {e.message}")
        raise HTTPException(status_code=500, detail=e.message)
    except Exception as e:
        logger.error(f"[prune-index] 예기치 않은 오류: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="서버 내부 오류가 발생했습니다")

