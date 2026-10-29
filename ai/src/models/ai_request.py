"""src.models.ai_request
AI 기능 요청 모델 정의
"""
from typing import Any, Optional

from pydantic import BaseModel, Field

# 목록 크기 상한: Spring 실제 최대치보다 넉넉하게 (초과 시 422, Spring 은 null·RANDOM fallback)
# 문제 1개 태그 수
MAXIMUM_TAG_KEY_COUNT = 100
# 일괄 색인 문제 수 (Spring 은 현재 1건씩 index-question 으로 보냄)
MAXIMUM_BULK_INDEX_QUESTION_COUNT = 1_000
# 최근 오답 UUID 수 (Spring RecommendationService.WRONG_QUESTION_LIMIT = 10)
MAXIMUM_RECENT_WRONG_QUESTION_COUNT = 100
# 제외 UUID 수 (Spring SOLVED_QUESTION_LIMIT 200 + 세션 노출 문제)
MAXIMUM_SOLVED_QUESTION_COUNT = 5_000
# 활성 문제 UUID 전체 수 (Spring 활성 문제 전량, 문제 수 증가 여유)
MAXIMUM_ACTIVE_QUESTION_COUNT = 200_000


# === 실시간 선택지 세트 생성 (신규) ===


class LlmConfig(BaseModel):
    """
    Spring 에서 프롬프트 전문·모델·response_schema 를 포함해 내려준다.
    Python 서버는 이것을 그대로 Gemini 에 넘긴다.
    """
    model: str
    system_prompt: str
    user_template: str
    temperature: float = 0.8
    max_tokens: int = 2048
    response_schema: Optional[dict[str, Any]] = None


class QuestionFullContext(BaseModel):
    """관리자 문제 등록용 — 전체 문제(stem+answer_sql+seed choices) 생성 컨텍스트"""
    schema_ddl: str
    schema_sample_data: str
    schema_intent: Optional[str] = None
    topic: str
    subtopic: Optional[str] = None
    difficulty: int = Field(ge=1, le=5)
    hint: Optional[str] = None


class ChoiceSetContext(BaseModel):
    """사용자 풀이용 — 기존 문제에 대한 선택지 4개 세트 생성 컨텍스트"""
    question_uuid: str
    stem: str
    # CONCEPT_ONLY 문제는 SQL·스키마 3개 없음 > Spring 이 null 전송 (프롬프트에는 빈 문자열로 치환, #575)
    answer_sql: Optional[str] = None
    schema_ddl: Optional[str] = None
    schema_sample_data: Optional[str] = None
    schema_intent: Optional[str] = None
    difficulty: int = Field(ge=1, le=5)


class GenerateQuestionFullRequest(BaseModel):
    context: QuestionFullContext
    llm_config: LlmConfig


class GenerateChoiceSetRequest(BaseModel):
    context: ChoiceSetContext
    llm_config: LlmConfig


class TestPromptRequest(BaseModel):
    llm_config: LlmConfig
    variables: dict[str, str] = Field(default_factory=dict)


# === RAG 기반 개인화 추천 ===


class IndexQuestionRequest(BaseModel):
    """문제 1개를 Qdrant에 임베딩 적재하는 요청"""
    question_uuid: str
    topic_display_name: str
    subtopic_display_name: Optional[str] = None
    difficulty: int = Field(ge=1, le=5)
    tag_keys: list[str] = Field(default_factory=list, max_length=MAXIMUM_TAG_KEY_COUNT)
    stem: str


class IndexQuestionsBulkRequest(BaseModel):
    """여러 문제를 Qdrant에 일괄 적재하는 요청 (관리자 전체 재색인용)"""
    questions: list[IndexQuestionRequest] = Field(max_length=MAXIMUM_BULK_INDEX_QUESTION_COUNT)


class RecommendRequest(BaseModel):
    """사용자 신호 기반 개인화 문제 추천 요청

    Java가 Submission DB에서 사용자 신호를 집계하여 전달한다.
    Python은 임베딩 검색만 담당.
    """
    size: int = Field(default=3, ge=1, le=5)
    # 최근 오답 문제 UUID 목록 — 이 문제들의 벡터를 쿼리로 활용
    recent_wrong_question_uuids: list[str] = Field(
        default_factory=list, max_length=MAXIMUM_RECENT_WRONG_QUESTION_COUNT
    )
    # 이미 푼 문제 UUID 목록 — Qdrant 필터로 제외
    solved_question_uuids: list[str] = Field(default_factory=list, max_length=MAXIMUM_SOLVED_QUESTION_COUNT)


class IndexStatusRequest(BaseModel):
    """DB 전체 문제 UUID 목록 기반 색인 상태 확인 요청.

    Java가 DB에서 조회한 전체 문제 UUID를 전달하면
    Python이 Qdrant scroll과 비교하여 미색인 목록 반환.
    """
    # Java가 DB에서 조회한 전체 문제 UUID 목록
    question_uuids: list[str] = Field(max_length=MAXIMUM_ACTIVE_QUESTION_COUNT)
