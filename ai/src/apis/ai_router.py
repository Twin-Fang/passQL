"""src.apis.ai_router
AI 엔드포인트 (Spring AiGatewayClient 전용): 문제·선택지 생성, 프롬프트 테스트, RAG 색인·추천·정리
"""
from fastapi import APIRouter, Depends

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
from src.services.question_generation_service import question_generation_service
from src.services.question_recommendation_service import question_recommendation_service
from src.services.question_vector_index_service import question_vector_index_service
from src.utils.auth import verify_api_key

# 전 엔드포인트 X-API-Key 필수 (Spring 전용), 실패 응답은 core.exception_handlers 공통 처리
router = APIRouter(prefix="/api/ai", tags=["AI"], dependencies=[Depends(verify_api_key)])


# === 실시간 선택지 세트 생성 / 프롬프트 테스트 (신규) ===


@router.post(
    "/generate-question-full",
    response_model=GenerateQuestionFullResponse,
    status_code=200,
)
async def generate_question_full(request: GenerateQuestionFullRequest):
    """
    관리자 문제 등록용 AI 생성.
    Spring 이 프롬프트 전문·response_schema 를 내려주면
    그대로 Gemini structured output 을 호출한다.
    """
    return await question_generation_service.generate_question_full(request)


@router.post(
    "/generate-choice-set",
    response_model=GenerateChoiceSetResponse,
    status_code=200,
)
async def generate_choice_set(request: GenerateChoiceSetRequest):
    """
    사용자 풀이용 AI 선택지 세트 생성 (메인 트래픽).
    """
    return await question_generation_service.generate_choice_set(request)


@router.post(
    "/test-prompt",
    response_model=TestPromptResponse,
    status_code=200,
)
async def test_prompt(request: TestPromptRequest):
    """
    관리자 프롬프트 테스트.
    response_schema 가 있으면 JSON 강제, 없으면 일반 텍스트.
    """
    return await question_generation_service.test_prompt(request)


# === RAG 기반 개인화 추천 ===


@router.post(
    "/index-question",
    response_model=IndexQuestionResponse,
    status_code=200,
)
async def index_question(request: IndexQuestionRequest):
    """
    문제 1개를 settings.OLLAMA_EMBED_MODEL 로 임베딩하여 Qdrant에 적재.

    문제 등록/수정 시 Java 서버에서 호출한다.
    컬렉션이 없으면 자동 생성된다.

    - POST /api/ai/index-question
    - Header: X-API-Key: {AI_SERVER_API_KEY}
    - Body: IndexQuestionRequest
    - 성공: 200 + IndexQuestionResponse
    """
    return await question_vector_index_service.index_question(request)


@router.post(
    "/index-questions-bulk",
    response_model=IndexQuestionsBulkResponse,
    status_code=200,
)
async def index_questions_bulk(request: IndexQuestionsBulkRequest):
    """
    문제 목록을 일괄 Qdrant 적재 (관리자 전체 재색인용).

    개별 실패는 스킵하고 계속 진행하며 실패 목록을 반환한다.

    - POST /api/ai/index-questions-bulk
    - Header: X-API-Key: {AI_SERVER_API_KEY}
    - Body: IndexQuestionsBulkRequest
    - 성공: 200 + IndexQuestionsBulkResponse
    """
    return await question_vector_index_service.index_questions_bulk(request)


@router.post(
    "/recommend",
    response_model=RecommendResponse,
    status_code=200,
)
async def recommend(request: RecommendRequest):
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
    return await question_recommendation_service.recommend(request)


@router.post(
    "/index-status",
    response_model=IndexStatusResponse,
    status_code=200,
)
async def index_status(request: IndexStatusRequest):
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
    return await question_vector_index_service.get_index_status(request)


@router.post(
    "/prune-index",
    response_model=PruneIndexResponse,
    status_code=200,
)
async def prune_index(request: IndexStatusRequest):
    """
    활성 문제 UUID 목록에 없는 Qdrant 포인트(고아 벡터)를 삭제한다 (#412).

    - POST /api/ai/prune-index
    - Header: X-API-Key: {AI_SERVER_API_KEY}
    - Body: IndexStatusRequest (Java의 활성 문제 UUID 전체)
    - 성공: 200 + PruneIndexResponse
    """
    return await question_vector_index_service.prune_index(request)

