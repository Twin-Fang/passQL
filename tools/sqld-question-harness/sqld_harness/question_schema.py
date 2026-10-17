"""
문제 YAML 로드·구조 검증: v1(#511)·v2(#524) 공통 dict 형태 유지, v2 필드는 접근 함수로 조회
YAML 1개 파일에 '---' 로 여러 문제, 폴더면 *.yaml 전체
"""
from pathlib import Path

from .constants import (
    ALL_EXPECT_TYPES,
    CHOICE_KEYS,
    CONCEPT_EXPECT_TYPE,
    KNOWN_TOPIC_CODES,
    MAXIMUM_DIFFICULTY,
    MINIMUM_DIFFICULTY,
    PICK_TYPES,
    SCHEMA_VERSION_CURRENT,
    SCHEMA_VERSION_LEGACY,
)
from .findings import SEVERITY_ERROR, SEVERITY_WARNING, Finding

# 로드 시 붙이는 내부 필드 (가져오기 JSON·캐시 키에서 제외)
SOURCE_FILE_FIELD = "_sourceFile"


def load_questions(path):
    """경로(파일·폴더) > 문제 dict 목록 (id 없으면 '{파일명}_{순번}')"""
    import yaml  # 지연 import: 문서 렌더만 쓰는 환경 배려

    target = Path(path)
    files = sorted(target.glob("*.yaml")) if target.is_dir() else [target]
    questions = []
    for file in files:
        for document in yaml.safe_load_all(file.read_text(encoding="utf-8")):
            if document:
                document.setdefault("id", f"{file.stem}_{len(questions)}")
                document[SOURCE_FILE_FIELD] = file.name
                questions.append(document)
    return questions


# ── v2 필드 접근 (v1 문제는 기본값) ─────────────────────────

def get_schema_version(question):
    return int(question.get("schemaVersion", SCHEMA_VERSION_LEGACY))


def is_current_schema(question):
    return get_schema_version(question) >= SCHEMA_VERSION_CURRENT


def get_choices(question):
    return question.get("choices") or []


def get_correct_choice_index(question):
    """정답 보기 위치 (0부터, 정답이 정확히 1개가 아니면 None)"""
    indexes = [index for index, choice in enumerate(get_choices(question)) if choice.get("isCorrect")]
    return indexes[0] if len(indexes) == 1 else None


def get_expect_type(choice):
    """보기 expect 종류 1개 (없으면 None)"""
    expect = choice.get("expect") or {}
    if expect.get(CONCEPT_EXPECT_TYPE):
        return CONCEPT_EXPECT_TYPE
    return next((expect_type for expect_type in ALL_EXPECT_TYPES if expect_type in expect), None)


def is_concept_question(question):
    """실행 근거 없이 설명형 보기만 있는 문제 (1과목·개념 2과목)"""
    choices = get_choices(question)
    return bool(choices) and all(get_expect_type(choice) == CONCEPT_EXPECT_TYPE for choice in choices)


def get_concepts(question):
    return [str(concept) for concept in (question.get("concepts") or [])]


def get_trend(question):
    """경향 태그: templates(템플릿 id), examRounds(근거 회차), isLatestTrend(최신 경향 표시)"""
    trend = question.get("trend") or {}
    return {
        "templates": [str(template) for template in (trend.get("templates") or [])],
        "examRounds": [int(round_number) for round_number in (trend.get("examRounds") or [])],
        "isLatestTrend": bool(trend.get("isLatestTrend")),
    }


# ── 구조 검증 (Oracle 불필요) ──────────────────────────────

def find_structure_findings(question):
    """구조 규칙: 보기 4개·정답 1개·근거·expect·토픽·난이도·pick·개념형 출처, v2 필수 필드"""
    question_id = str(question.get("id"))
    findings = []

    def add(severity, rule, message):
        findings.append(Finding(severity, rule, question_id, message))

    choices = get_choices(question)
    if len(choices) != len(CHOICE_KEYS):
        add(SEVERITY_ERROR, "structure.choice-count", f"보기 {len(choices)}개 (4개 필요)")
    if sum(1 for choice in choices if choice.get("isCorrect")) != 1:
        add(SEVERITY_ERROR, "structure.correct-count", "정답 보기 1개 필요")
    for index, choice in enumerate(choices[: len(CHOICE_KEYS)]):
        choice_key = CHOICE_KEYS[index]
        if not str(choice.get("body", "")).strip():
            add(SEVERITY_ERROR, "structure.choice-body", f"{choice_key} 보기 본문 비어 있음")
        if not choice.get("rationale"):
            add(SEVERITY_ERROR, "structure.rationale", f"{choice_key} 보기 근거(rationale) 누락")
        if get_expect_type(choice) is None:
            add(SEVERITY_ERROR, "structure.expect", f"{choice_key} 보기 expect 누락")
    if not str(question.get("stem", "")).strip():
        add(SEVERITY_ERROR, "structure.stem", "지문(stem) 누락")
    if any(get_expect_type(choice) == CONCEPT_EXPECT_TYPE for choice in choices) and not question.get("sourceNote"):
        add(SEVERITY_ERROR, "structure.source-note", "개념형 보기는 sourceNote(근거 출처) 필수")
    if _needs_answer_sql(choices) and not question.get("answerSql"):
        add(SEVERITY_ERROR, "structure.answer-sql", "rows·scalar·same_as_answer 보기는 answerSql 필수")
    if question.get("pick") and question["pick"] not in PICK_TYPES:
        add(SEVERITY_ERROR, "structure.pick", f"pick 은 {'|'.join(PICK_TYPES)} 만 허용")
    _add_metadata_findings(question, add)
    return findings


def _needs_answer_sql(choices):
    return any(get_expect_type(choice) in ("rows", "scalar", "same_as_answer") for choice in choices)


def _add_metadata_findings(question, add):
    """토픽·난이도 범위, v2 필수 메타 (의도·함정·난이도 근거·개념)"""
    topic_code = question.get("topicCode")
    if not topic_code:
        add(SEVERITY_ERROR, "structure.topic", "topicCode 누락")
    elif topic_code not in KNOWN_TOPIC_CODES:
        add(SEVERITY_WARNING, "structure.topic", f"서버 기본 토픽이 아님: {topic_code}")
    difficulty = question.get("difficulty")
    if not isinstance(difficulty, int) or not MINIMUM_DIFFICULTY <= difficulty <= MAXIMUM_DIFFICULTY:
        add(SEVERITY_ERROR, "structure.difficulty", f"difficulty {difficulty!r} (1~5 정수)")
    if not question.get("intent"):
        add(SEVERITY_WARNING, "structure.intent", "출제 의도(intent) 누락")
    if is_current_schema(question):
        # v2 필수: 함정 설계·난이도 근거·개념 태그
        if not question.get("trapDesign"):
            add(SEVERITY_ERROR, "v2.trap-design", "trapDesign(꼬는 포인트) 누락")
        if not question.get("difficultyReason"):
            add(SEVERITY_ERROR, "v2.difficulty-reason", "difficultyReason(난이도 근거) 누락")
        if not get_concepts(question):
            add(SEVERITY_ERROR, "v2.concepts", "concepts(개념 태그) 누락")


def find_duplicate_id_findings(questions):
    """문제 id 중복 (캐시·스키마 이름 충돌 방지)"""
    seen, findings = set(), []
    for question in questions:
        question_id = str(question.get("id"))
        if question_id in seen:
            findings.append(Finding(SEVERITY_ERROR, "structure.duplicate-id", question_id, "문제 id 중복"))
        seen.add(question_id)
    return findings
