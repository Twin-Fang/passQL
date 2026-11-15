"""
내부 관리 태그 (#1117): 문제 YAML > 가져오기 JSON internalTags
규칙은 서버 QuestionInternalTagRule 과 같음 (앞뒤 공백 제거, 영문만 소문자, 공백·* 쉼표 금지, 64자, 문제당 20개)
태그 순서: source > round > trend > batch > concept > YAML internalTags (20개 초과분은 뒤에서부터 버림)
"""
import re
from pathlib import Path

from .findings import SEVERITY_ERROR, SEVERITY_WARNING, Finding
from .question_schema import SOURCE_FILE_FIELD, get_concepts, get_trend

# 서버 QuestionInternalTagNamespace 접두 (네임스페이스:값)
NAMESPACE_SOURCE = "source"    # 파생 출처 문항: source:{회차}-{실번호}
NAMESPACE_ROUND = "round"      # 근거 회차: round:63
NAMESPACE_TREND = "trend"      # 경향 카탈로그 템플릿: trend:t41
NAMESPACE_BATCH = "batch"      # 원본 YAML 파일 묶음: batch:batch06
NAMESPACE_CONCEPT = "concept"  # 핵심 개념: concept:비등가조인
NAMESPACE_SEPARATOR = ":"

# 서버 QuestionInternalTagRule.MAXIMUM_TAG_LENGTH, MAXIMUM_TAG_COUNT_PER_QUESTION
MAXIMUM_TAG_LENGTH = 64
MAXIMUM_TAG_COUNT_PER_QUESTION = 20

# trend.sources 항목 형식: {회차}-{실번호} 예 63-17
SOURCE_QUESTION_PATTERN = re.compile(r"^\d+-\d+$")
# 개념 값에서 하이픈으로 바꿀 문자 (공백류, 서버 금지 문자 * 쉼표)
CONCEPT_VALUE_REPLACE_PATTERN = re.compile(r"[\s*,]+")
# 파일명 묶음 접두: 첫 하이픈 앞 (batch06-round63a-... > batch06)
BATCH_PREFIX_SEPARATOR = "-"


def normalize_tag(raw_tag):
    """태그 1개 정규화: 앞뒤 공백 제거 > 영문 A-Z 만 소문자 (서버 normalizeTag 와 같음)"""
    return "".join(character.lower() if "A" <= character <= "Z" else character for character in str(raw_tag).strip())


def find_tag_reject_reason(tag):
    """정규화된 태그 거부 사유 (통과면 None, 서버 findRejectReason 과 같은 순서)"""
    if not tag:
        return "빈 태그"
    if len(tag) > MAXIMUM_TAG_LENGTH:
        return f"태그 {MAXIMUM_TAG_LENGTH}자 초과: {tag}"
    if any(character.isspace() or not character.isprintable() for character in tag):
        return f"태그에 공백 포함: {tag}"
    if "*" in tag or "," in tag:
        return f"태그에 쓸 수 없는 문자(*, 쉼표): {tag}"
    if NAMESPACE_SEPARATOR in tag:
        namespace, _, value = tag.partition(NAMESPACE_SEPARATOR)
        if not namespace or not value:
            return f"네임스페이스 또는 값이 비어 있음: {tag}"
    return None


def to_concept_value(concept):
    """개념 > 태그 값 (공백·금지 문자 > 하이픈, 앞뒤 하이픈 제거): 'NULL 3값 논리' > 'null-3값-논리'"""
    return CONCEPT_VALUE_REPLACE_PATTERN.sub("-", normalize_tag(concept)).strip("-")


def get_batch_name(question):
    """원본 파일명 > 묶음 이름 (batch06-round63a-window.yaml > batch06, 파일 정보 없으면 None)"""
    source_file = question.get(SOURCE_FILE_FIELD)
    if not source_file:
        return None
    return Path(source_file).stem.split(BATCH_PREFIX_SEPARATOR)[0] or None


def build_internal_tags(question):
    """문제 > internalTags: 출처·회차·유형·묶음·개념·YAML 자유 태그 > 정규화 > 규칙 위반·중복 제외 > 최대 20개"""
    trend = get_trend(question)
    candidate_tags = [f"{NAMESPACE_SOURCE}{NAMESPACE_SEPARATOR}{source}" for source in trend["sources"]]
    candidate_tags += [f"{NAMESPACE_ROUND}{NAMESPACE_SEPARATOR}{round_number}" for round_number in trend["examRounds"]]
    candidate_tags += [f"{NAMESPACE_TREND}{NAMESPACE_SEPARATOR}{template_id}" for template_id in trend["templates"]]
    batch_name = get_batch_name(question)
    if batch_name:
        candidate_tags.append(f"{NAMESPACE_BATCH}{NAMESPACE_SEPARATOR}{batch_name}")
    candidate_tags += [f"{NAMESPACE_CONCEPT}{NAMESPACE_SEPARATOR}{to_concept_value(concept)}" for concept in get_concepts(question)]
    candidate_tags += [str(tag) for tag in (question.get("internalTags") or [])]

    internal_tags = []
    for candidate_tag in candidate_tags:
        tag = normalize_tag(candidate_tag)
        # 64자 넘는 태그는 잘라서 씀 (개념 문구가 긴 경우)
        if len(tag) > MAXIMUM_TAG_LENGTH:
            tag = tag[:MAXIMUM_TAG_LENGTH].rstrip("-")
        if find_tag_reject_reason(tag) is None and tag not in internal_tags:
            internal_tags.append(tag)
    return internal_tags[:MAXIMUM_TAG_COUNT_PER_QUESTION]


def find_internal_tag_findings(question):
    """태그 원본 검증: trend.sources 형식, YAML internalTags 규칙 위반 (버려지는 태그를 미리 알림)"""
    question_id = str(question.get("id"))
    findings = []
    for source in get_trend(question)["sources"]:
        if not SOURCE_QUESTION_PATTERN.match(source):
            findings.append(Finding(SEVERITY_ERROR, "tag.source-format", question_id, f"trend.sources 형식 {{회차}}-{{실번호}} 아님: {source}"))
    for raw_tag in question.get("internalTags") or []:
        reject_reason = find_tag_reject_reason(normalize_tag(raw_tag))
        if reject_reason:
            findings.append(Finding(SEVERITY_WARNING, "tag.invalid", question_id, f"internalTags 제외됨: {reject_reason}"))
    return findings
