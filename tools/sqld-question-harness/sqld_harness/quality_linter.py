"""
품질 점검 (Oracle 불필요): 오답 함정 타당성, 보기 길이 균형, 지문 명확성 체크리스트, 표<->데이터 일치, 순서 의존 기대값
묶음 규칙 2개: 정답 위치 분포, 중복 문제
"""
import re
from collections import Counter

from .constants import (
    ANSWER_POSITION_MINIMUM_SAMPLE,
    ANSWER_POSITION_SHARE_LIMIT,
    CHOICE_KEYS,
    CORRECT_CHOICE_LENGTH_RATIO_LIMIT,
    MINIMUM_PLAUSIBLE_REASON_LENGTH,
    RECOMMENDED_MINIMUM_CONCEPT_COUNT,
)
from .findings import SEVERITY_ERROR, SEVERITY_INFO, SEVERITY_WARNING, Finding
from .question_schema import (
    get_choices,
    get_concepts,
    get_correct_choice_index,
    get_expect_type,
    is_concept_question,
    is_current_schema,
)
from .sql_script import parse_simple_insert_rows, to_display_value

# 묶음 규칙 finding 의 문제 id 자리 표시
BATCH_QUESTION_ID = "(batch)"
# 지문 고르는 기준 단어 (하나도 없으면 무엇을 고르는지 불명확)
STEM_SELECTION_KEYWORDS = ("옳은", "옳지 않은", "틀린", "아닌", "가장", "결과", "행 수", "다른", "적절", "해당", "값", "오류", "수행되는")
# 지문 질문형 끝맺음
STEM_QUESTION_ENDINGS = ("?", "것은", "고르시오", "무엇인가")
ORDER_BY_PATTERN = re.compile(r"\bORDER\s+BY\b", re.IGNORECASE)
NUMERIC_BODY_PATTERN = re.compile(r"^-?\d+(\.\d+)?$")


def lint_question(question):
    """문제 1건 > 품질 finding 목록"""
    question_id = str(question.get("id"))
    findings = []

    def add(severity, rule, message):
        findings.append(Finding(severity, rule, question_id, message))

    _check_wrong_choice_plausibility(question, add)
    _check_choice_length_balance(question, add)
    _check_numeric_choice_order(question, add)
    _check_duplicate_choice_bodies(question, add)
    _check_stem_clarity(question, add)
    _check_table_shape(question, add)
    _check_table_matches_data(question, add)
    _check_order_dependent_expect(question, add)
    if is_current_schema(question) and 0 < len(get_concepts(question)) < RECOMMENDED_MINIMUM_CONCEPT_COUNT:
        add(SEVERITY_INFO, "trend.concept-combination", "2026 경향: 개념 2~3개 결합 권장 (concepts 1개)")
    return findings


def _check_wrong_choice_plausibility(question, add):
    """오답마다 '왜 그럴듯한지'(whyPlausible) 필수: v2 보기별 error, v1 문제당 info 1건 (rationale 로 대체 중)"""
    missing_keys = []
    for index, choice in enumerate(get_choices(question)[: len(CHOICE_KEYS)]):
        if choice.get("isCorrect"):
            continue
        reason = str(choice.get("whyPlausible") or "").strip()
        if not reason:
            missing_keys.append(CHOICE_KEYS[index])
        elif len(reason) < MINIMUM_PLAUSIBLE_REASON_LENGTH:
            add(SEVERITY_WARNING, "trap.why-plausible-short", f"{CHOICE_KEYS[index]} whyPlausible 너무 짧음: {reason!r}")
    if not missing_keys:
        return
    if is_current_schema(question):
        for choice_key in missing_keys:
            add(SEVERITY_ERROR, "trap.why-plausible", f"{choice_key} 오답의 whyPlausible(학습자가 고를 만한 이유) 누락")
    else:
        add(SEVERITY_INFO, "trap.why-plausible-legacy", f"v1 문제: 오답 {', '.join(missing_keys)} whyPlausible 없음 (v2 이전 시 작성)")


def _check_choice_length_balance(question, add):
    """정답만 유독 길면 내용 없이 길이로 정답 추측 가능"""
    choices = get_choices(question)
    correct_index = get_correct_choice_index(question)
    if correct_index is None or len(choices) < 2:
        return
    lengths = [len(str(choice.get("body", ""))) for choice in choices]
    wrong_lengths = [length for index, length in enumerate(lengths) if index != correct_index]
    average_wrong_length = sum(wrong_lengths) / len(wrong_lengths)
    correct_length = lengths[correct_index]
    is_unique_longest = correct_length > max(wrong_lengths)
    if is_unique_longest and average_wrong_length > 0 and correct_length / average_wrong_length >= CORRECT_CHOICE_LENGTH_RATIO_LIMIT:
        add(SEVERITY_WARNING, "balance.correct-longest", f"정답 보기만 길음 (정답 {correct_length}자, 오답 평균 {average_wrong_length:.0f}자)")


def _check_numeric_choice_order(question, add):
    """숫자 보기는 오름차순 배치 (시험 관례, 배치로 정답 단서 차단)"""
    bodies = [str(choice.get("body", "")).strip() for choice in get_choices(question)]
    if bodies and all(NUMERIC_BODY_PATTERN.match(body) for body in bodies):
        numbers = [float(body) for body in bodies]
        if numbers != sorted(numbers):
            add(SEVERITY_WARNING, "balance.numeric-order", f"숫자 보기 오름차순 배치 필요: {', '.join(bodies)}")


def _check_duplicate_choice_bodies(question, add):
    """같은 내용 보기 2개 금지 (결과 JSON 은 공백 무시, SQL·글은 연속 공백 하나로 비교, #555)"""
    seen_keys_by_body = {}
    for index, choice in enumerate(get_choices(question)[: len(CHOICE_KEYS)]):
        body = str(choice.get("body", "")).strip()
        if not body:
            continue
        comparable_body = re.sub(r"\s+", "", body) if body[0] in "[{" else re.sub(r"\s+", " ", body)
        if comparable_body in seen_keys_by_body:
            add(SEVERITY_ERROR, "choice.duplicate-body",
                f"{seen_keys_by_body[comparable_body]} 와 {CHOICE_KEYS[index]} 보기 내용이 같음 (사실상 3지선다)")
        else:
            seen_keys_by_body[comparable_body] = CHOICE_KEYS[index]


def _check_stem_clarity(question, add):
    """지문 체크리스트 4개: 질문형 끝맺음, 고르는 기준, 데이터 표 노출, SQL 노출"""
    stem = str(question.get("stem", "")).strip()
    if not stem:
        return
    question_line = stem.splitlines()[-1].strip() if "?" not in stem else stem
    if not any(ending in question_line for ending in STEM_QUESTION_ENDINGS):
        add(SEVERITY_WARNING, "stem.question-form", "지문이 질문형으로 끝나지 않음")
    if not any(keyword in stem for keyword in STEM_SELECTION_KEYWORDS):
        add(SEVERITY_WARNING, "stem.selection-criterion", "무엇을 고르는지 기준 단어 없음 (옳은/옳지 않은/가장/결과 등)")
    if is_concept_question(question):
        return
    has_data = bool(str(question.get("data") or "").strip())
    if has_data and not question.get("tables"):
        add(SEVERITY_WARNING, "stem.data-hidden", "data 가 있으나 tables(지문 표) 없음 > 학습자가 데이터를 볼 수 없음")
    is_all_sql_choices = all(choice.get("kind") == "SQL" for choice in get_choices(question))
    if question.get("answerSql") and not question.get("displaySql") and not is_all_sql_choices:
        add(SEVERITY_WARNING, "stem.sql-hidden", "displaySql 없음 > 지문에 추적할 SQL 이 안 보임")


def _check_table_shape(question, add):
    """지문 표: 행마다 리스트 + 컬럼 수 일치 (문자열 행은 글자 단위로 쪼개져 렌더링됨)"""
    for table in question.get("tables") or []:
        column_count = len(table.get("columns") or [])
        for row_number, row in enumerate(table.get("rows") or [], start=1):
            if not isinstance(row, list) or len(row) != column_count:
                add(SEVERITY_ERROR, "data.table-shape", f"표 {table.get('name')} {row_number}행 {row!r}: 컬럼 {column_count}개짜리 리스트 필요")
                break


def _check_table_matches_data(question, add):
    """지문 표(tables) <-> 실제 INSERT 데이터 일치 (단순 INSERT 만 비교, 파싱 불가 시 생략)"""
    tables = question.get("tables") or []
    if not tables or not question.get("data"):
        return
    rows_by_table = parse_simple_insert_rows(question["data"])
    if rows_by_table is None:
        return
    for table in tables:
        # 모양 오류 표는 data.table-shape 로 이미 보고
        if not all(isinstance(row, list) for row in table.get("rows") or []):
            continue
        displayed_rows = [_to_comparable_row(row) for row in table.get("rows") or []]
        inserted_rows = [_to_comparable_row(row) for row in rows_by_table.get(str(table["name"]).upper(), [])]
        if displayed_rows != inserted_rows:
            add(SEVERITY_ERROR, "data.table-mismatch", f"표 {table['name']} 와 INSERT 데이터 불일치 (표 {len(displayed_rows)}행, INSERT {len(inserted_rows)}행)")


def _to_comparable_row(row):
    return ["NULL" if value is None else str(to_display_value(value)) for value in row]


def _check_order_dependent_expect(question, add):
    """ORDER BY 없는 SQL 결과를 순서 있는 rows 로 비교 > DB 내부 순서에 의존 (실행마다 달라질 수 있음)"""
    for index, choice in enumerate(get_choices(question)[: len(CHOICE_KEYS)]):
        expect = choice.get("expect") or {}
        expect_type = get_expect_type(choice)
        if expect_type == "rows":
            sql, expected_rows = question.get("answerSql") or "", expect.get("rows") or []
        elif expect_type == "body_rows":
            sql, expected_rows = str(choice.get("body", "")), expect.get("body_rows") or []
        else:
            continue
        if expect.get("ordered", True) and len(expected_rows) > 1 and not ORDER_BY_PATTERN.search(sql):
            add(SEVERITY_WARNING, "expect.order-dependent", f"{CHOICE_KEYS[index]} ORDER BY 없는 결과를 순서 비교 (ordered: false 권장)")


def find_answer_position_findings(questions):
    """정답 위치 분포: 한 키 쏠림 경고 (표본 수 기준 이상일 때)"""
    positions = [get_correct_choice_index(question) for question in questions]
    position_counter = Counter(CHOICE_KEYS[index] for index in positions if index is not None)
    total = sum(position_counter.values())
    if total < ANSWER_POSITION_MINIMUM_SAMPLE:
        return []
    findings = []
    for choice_key, count in sorted(position_counter.items()):
        if count / total > ANSWER_POSITION_SHARE_LIMIT:
            findings.append(Finding(SEVERITY_WARNING, "distribution.answer-position", BATCH_QUESTION_ID, f"정답 {choice_key} 쏠림 {count}/{total} ({count / total:.0%})"))
    return findings
