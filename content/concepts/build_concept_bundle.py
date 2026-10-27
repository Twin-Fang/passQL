"""개념 묶음 조립: 개념 파일 수집 > 구조 검증(서버 ConceptBundleValidator 와 같은 규칙) > 글 점검 > 가져오기 JSON
사용법·옵션은 content/concepts/README.md"""
import argparse
import importlib.util
import json
import re
import sys
from pathlib import Path

CONCEPTS_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(CONCEPTS_DIR))

from concept_bundle import TOPIC_CODES  # noqa: E402

DEFAULT_OUTPUT_PATH = CONCEPTS_DIR / "build" / "concept_bundle.json"
# 관련 문제 연결 원본: {tagKey: [운영 question UUID, ...]} (개념 화면 "관련 문제 더 풀기")
RELATED_QUESTIONS_PATH = CONCEPTS_DIR / "related_questions.json"

# 서버 규칙 (ConceptBundleValidator, ConceptDetailSectionParser)
TAG_KEY_PATTERN = re.compile(r"[a-z0-9-]{1,100}")
HEADING_PATTERN = re.compile(r"^## (.+?) \{#([a-z0-9-]{1,80})\}\s*$")
CHECK_QUESTION_COUNT = 5
CHOICE_KEYS = ("A", "B", "C", "D")

# 글 점검: 설계 18장 금지 말투 (경고)
BANNED_PHRASES = ("완벽", "마스터", "핵심 중의 핵심", "중요합니다", "라고 할 수 있습니다", "해 볼게요!", "먼저,", "마지막으로,")
EMOJI_PATTERN = re.compile("[\U0001F300-\U0001FAFF☀-➿]")
CORE_LINE_RANGE = (3, 5)
PLAIN_TEXT_MARKUP_PATTERN = re.compile(r"`|\*\*")
# SQL 주석에서 영문·숫자·기호 뒤 조사 앞 빈칸 (예: "TRIM 은", "WHERE 에서")
SPACED_PARTICLE_PATTERN = re.compile(r"[A-Za-z0-9_)'\]] (은|는|이|가|을|를|에|에서|에는|의|로|으로|와|과|도|만)(?=[\s,.)]|$)")

# 영문 사이 가운뎃점 뒤 줄바꿈 자리 (폭 0 빈칸): "SELECT·INSERT·UPDATE" 같은 긴 낱말이 글자 중간에서 잘리지 않게
LATIN_MIDDLE_DOT_PATTERN = re.compile(r"(?<=[A-Za-z0-9_)])·(?=[A-Za-z(])")
ZERO_WIDTH_SPACE = "\u200b"
# 굵게 구간 (**글자**)
BOLD_SPAN_PATTERN = re.compile(r"\*\*(.+?)\*\*")

EXPORT_KEYS = ("tagKey", "topicCode", "sortOrder", "title", "summary", "coreMd", "detailMd",
               "checkQuestions", "relatedQuestionUuids")


def load_concepts(topic_filter=None):
    """{topicCode}/*.py 마다 CONCEPT 1개 > (파일 경로, 개념) 목록 (단원 순서 > sortOrder 순)"""
    loaded = []
    for topic_code in TOPIC_CODES:
        if topic_filter and topic_code != topic_filter:
            continue
        for path in sorted((CONCEPTS_DIR / topic_code).glob("*.py")):
            spec = importlib.util.spec_from_file_location(f"concept_{topic_code}_{path.stem}", path)
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)
            loaded.append((path, module.CONCEPT))
    loaded.sort(key=lambda item: (TOPIC_CODES.index(item[1]["topicCode"]) if item[1].get("topicCode") in TOPIC_CODES
                                  else len(TOPIC_CODES), item[1].get("sortOrder") or 0))
    return loaded


def find_detail_anchors(detail_md):
    """자세히 본문 > 앵커 목록 (코드 펜스 안 무시, 첫 제목 앞 글·앵커 없는 제목·중복 앵커는 오류)"""
    anchors, errors = [], []
    is_inside_fence, has_heading = False, False
    for line in detail_md.splitlines():
        if line.strip().startswith("```"):
            is_inside_fence = not is_inside_fence
            continue
        if is_inside_fence:
            continue
        if line.startswith("## "):
            match = HEADING_PATTERN.match(line)
            if not match:
                errors.append(f"heading without anchor: {line}")
                continue
            if match.group(2) in anchors:
                errors.append(f"duplicate anchor: {match.group(2)}")
            anchors.append(match.group(2))
            has_heading = True
        elif line.startswith("#"):
            errors.append(f"unsupported heading level: {line}")
        elif line.strip() and not has_heading:
            errors.append("text before first heading")
    return anchors, errors


def validate_concept(path, concept, seen_tag_keys, seen_orders_by_topic):
    """개념 1개 > (오류 목록, 경고 목록)"""
    errors, warnings = [], []
    tag_key = concept.get("tagKey") or ""

    # 식별·소속 (tagKey 형식·중복, 파일 이름, 단원, 순서)
    if not TAG_KEY_PATTERN.fullmatch(tag_key):
        errors.append("tagKey must match [a-z0-9-]{1,100}")
    elif tag_key in seen_tag_keys:
        errors.append("duplicate tagKey")
    seen_tag_keys.add(tag_key)
    if path.stem != tag_key.replace("-", "_"):
        errors.append(f"file name must be {tag_key.replace('-', '_')}.py")
    topic_code = concept.get("topicCode")
    if topic_code not in TOPIC_CODES or path.parent.name != topic_code:
        errors.append(f"topicCode {topic_code} must match folder {path.parent.name}")
    order = concept.get("sortOrder")
    if not isinstance(order, int) or order in seen_orders_by_topic.setdefault(topic_code, set()):
        errors.append(f"sortOrder must be unique int in topic: {order}")
    seen_orders_by_topic[topic_code].add(order)

    # 필수 글 (제목, 요약, 핵심만, 자세히)
    for field in ("title", "summary", "coreMd", "detailMd"):
        if not (concept.get(field) or "").strip():
            errors.append(f"{field} required")
    anchors, anchor_errors = find_detail_anchors(concept.get("detailMd") or "")
    errors += anchor_errors

    # 확인 문제 5개 (순서 1~5, 보기 A~D 4개·정답 1개, 다시 읽기 앵커 존재)
    questions = concept.get("checkQuestions") or []
    if len(questions) != CHECK_QUESTION_COUNT:
        errors.append(f"need {CHECK_QUESTION_COUNT} check questions, was {len(questions)}")
    if sorted(question.get("sortOrder") for question in questions) != list(range(1, len(questions) + 1)):
        errors.append("check question sortOrder must be 1..5")
    for question in questions:
        errors += validate_check_question(question, anchors)

    # 표 칸 안 || 는 칸 구분선으로 읽혀 표가 깨짐 (코드 블록 밖 표 줄만)
    for field in ("detailMd", "coreMd"):
        prose = re.sub(r"```[\s\S]*?```", "", concept.get(field) or "")
        if any(line.lstrip().startswith("|") and "||" in line for line in prose.splitlines()):
            errors.append(f"{field}: table row contains || (breaks table)")
    warnings += lint_text(concept)
    return errors, warnings


def validate_check_question(question, anchors):
    where = f"Q{question.get('sortOrder')}: "
    errors = []
    for field in ("stem", "explanation"):
        if not (question.get(field) or "").strip():
            errors.append(where + f"{field} required")
    if question.get("rereadAnchor") not in anchors:
        errors.append(where + f"rereadAnchor not in detail anchors: {question.get('rereadAnchor')}")
    choices = question.get("choices") or []
    keys = [choice.get("choiceKey") for choice in choices]
    bodies = [(choice.get("body") or "").strip() for choice in choices]
    if tuple(keys) != CHOICE_KEYS or len(set(bodies)) != len(CHOICE_KEYS) or not all(bodies):
        errors.append(where + "need choices A~D with unique non-empty bodies")
    correct_count = sum(1 for choice in choices if choice.get("isCorrect"))
    if correct_count != 1:
        errors.append(where + f"need exactly 1 correct, was {correct_count}")
    if any(not (choice.get("rationale") or "").strip() for choice in choices):
        errors.append(where + "every choice needs a rationale")
    # 보기·보기 이유는 앱에서 일반 글자로 그림 (` ** 가 그대로 보임)
    if any(PLAIN_TEXT_MARKUP_PATTERN.search((choice.get("body") or "") + (choice.get("rationale") or "")) for choice in choices):
        errors.append(where + "choice body/rationale must be plain text (no ` or **)")
    return errors


def lint_text(concept):
    """글 점검 경고: 금지 말투·느낌표·이모지, 핵심만 줄 수, 정답 위치 쏠림"""
    warnings = []
    texts = [concept.get("summary") or "", concept.get("coreMd") or "", concept.get("detailMd") or ""]
    for question in concept.get("checkQuestions") or []:
        texts += [question.get("stem") or "", question.get("explanation") or ""]
        texts += [(choice.get("body") or "") + " " + (choice.get("rationale") or "") for choice in question.get("choices") or []]
    # 코드 블록·인라인 코드 안 기호(!= 등)는 점검 제외
    joined = "\n".join(re.sub(r"`[^`\n]*`", "", re.sub(r"```[\s\S]*?```", "", text)) for text in texts)
    for phrase in BANNED_PHRASES:
        if phrase in joined:
            warnings.append(f"banned phrase: {phrase}")
    if "!" in joined:
        warnings.append("exclamation mark")
    if EMOJI_PATTERN.search(joined):
        warnings.append("emoji")
    sql_comments = [line.split("--", 1)[1] for text in texts for block in re.findall(r"```[\s\S]*?```", text)
                    for line in block.splitlines() if "--" in line]
    spaced_particles = [comment.strip() for comment in sql_comments if SPACED_PARTICLE_PATTERN.search(comment)]
    if spaced_particles:
        warnings.append(f"SQL comment particle spacing x{len(spaced_particles)}: {spaced_particles[0][:60]}")
    core_line_count = len([line for line in (concept.get("coreMd") or "").splitlines() if line.strip()])
    if not CORE_LINE_RANGE[0] <= core_line_count <= CORE_LINE_RANGE[1]:
        warnings.append(f"coreMd lines {core_line_count} (want 3~5)")
    correct_keys = [next((choice["choiceKey"] for choice in question.get("choices") or [] if choice.get("isCorrect")), None)
                    for question in concept.get("checkQuestions") or []]
    if correct_keys and max(correct_keys.count(key) for key in CHOICE_KEYS) >= 3:
        warnings.append(f"correct answer positions skewed: {''.join(key or '?' for key in correct_keys)}")
    return warnings


def load_related_question_uuids_by_tag_key():
    """관련 문제 연결 파일 > {tagKey: [UUID]} (파일 없으면 빈 연결)"""
    if not RELATED_QUESTIONS_PATH.exists():
        return {}
    return json.loads(RELATED_QUESTIONS_PATH.read_text(encoding="utf-8"))


def to_app_markdown(markdown):
    """앱 화면용 글 정리 (코드 펜스 안은 그대로)
    표 줄: 칸마다 인라인 코드 표시·굵게 짝 제거, 첫 칸이 빈 묶음 줄은 위 줄 값으로 채움 (앱 표 부품은 칸 글자를 그대로 그림)
    글 줄: 굵게 구간 안 인라인 코드 표시 제거 (앱 렌더러는 굵게 안 코드를 못 그림)
    공통: 영문 가운뎃점 뒤 줄바꿈 자리 (빈칸 없는 긴 영문 낱말이 글자 중간에서 잘림)"""
    if not markdown:
        return markdown
    lines, is_inside_fence, previous_first_cell = [], False, None
    for line in markdown.splitlines():
        if line.strip().startswith("```"):
            is_inside_fence = not is_inside_fence
        elif not is_inside_fence:
            if line.lstrip().startswith("|"):
                line, previous_first_cell = _to_app_table_row(line, previous_first_cell)
            else:
                previous_first_cell = None
                line = BOLD_SPAN_PATTERN.sub(lambda match: "**" + match.group(1).replace("`", "") + "**", line)
            line = LATIN_MIDDLE_DOT_PATTERN.sub("·" + ZERO_WIDTH_SPACE, line)
        lines.append(line)
    return "\n".join(lines)


def _to_app_table_row(line, previous_first_cell):
    """표 줄 1개 > (정리한 줄, 이번 줄 첫 칸 값) (구분 줄 |---| 은 그대로)"""
    cells = line.strip().strip("|").split("|")
    if all(set(cell.strip()) <= set("-: ") for cell in cells):
        return line, previous_first_cell
    cells = [BOLD_SPAN_PATTERN.sub(r"\1", cell).replace("`", "") for cell in cells]
    if not cells[0].strip() and previous_first_cell:
        cells[0] = f" {previous_first_cell} "
    return "|" + "|".join(cells) + "|", cells[0].strip()


def to_export_item(concept, related_question_uuids_by_tag_key):
    """개념 > 가져오기 항목 (sqlChecks 제외, 관련 문제는 연결 파일 기준, 앱 화면용 글 정리)"""
    item = {key: concept.get(key) for key in EXPORT_KEYS}
    for field in ("title", "summary", "coreMd", "detailMd"):
        item[field] = to_app_markdown(item[field])
    item["checkQuestions"] = [{**question, "stem": to_app_markdown(question["stem"]),
                               "explanation": to_app_markdown(question["explanation"]),
                               "choices": [{**choice, "body": to_app_markdown(choice["body"]),
                                            "rationale": to_app_markdown(choice["rationale"])} for choice in question["choices"]]}
                              for question in item["checkQuestions"]]
    item["relatedQuestionUuids"] = related_question_uuids_by_tag_key.get(concept["tagKey"], [])
    return item


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--topic", choices=TOPIC_CODES)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()

    concepts = load_concepts(args.topic)
    seen_tag_keys, seen_orders_by_topic = set(), {}
    error_count = 0
    for path, concept in concepts:
        errors, warnings = validate_concept(path, concept, seen_tag_keys, seen_orders_by_topic)
        error_count += len(errors)
        for message in errors:
            print(f"ERROR {concept.get('tagKey')}: {message}")
        for message in warnings:
            print(f"WARN  {concept.get('tagKey')}: {message}")

    # 관련 문제 연결 검증 (없는 tagKey, 개념 안 중복 UUID) — --topic 이어도 전체 개념 기준
    related_question_uuids_by_tag_key = load_related_question_uuids_by_tag_key()
    all_tag_keys = seen_tag_keys if not args.topic else {concept["tagKey"] for _, concept in load_concepts()}
    for tag_key, question_uuids in related_question_uuids_by_tag_key.items():
        if tag_key not in all_tag_keys:
            error_count += 1
            print(f"ERROR related_questions.json: unknown tagKey {tag_key}")
        elif len(set(question_uuids)) != len(question_uuids):
            error_count += 1
            print(f"ERROR related_questions.json: duplicate uuid in {tag_key}")

    counts_by_topic = {code: sum(1 for _, concept in concepts if concept.get("topicCode") == code) for code in TOPIC_CODES}
    print("concepts by topic: " + ", ".join(f"{code}={count}" for code, count in counts_by_topic.items()))
    if error_count:
        print(f"[concept bundle] rejected : {error_count} errors")
        sys.exit(1)

    if args.topic and args.output is None:
        print("[concept bundle] validated only (--topic without --output)")
        return
    output_path = args.output or DEFAULT_OUTPUT_PATH
    output_path.parent.mkdir(parents=True, exist_ok=True)
    bundle = {"concepts": [to_export_item(concept, related_question_uuids_by_tag_key) for _, concept in concepts]}
    output_path.write_text(json.dumps(bundle, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"[concept bundle] wrote {len(concepts)} concepts : {output_path}")


if __name__ == "__main__":
    main()
