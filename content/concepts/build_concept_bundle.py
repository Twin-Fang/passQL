"""개념 묶음 조립: 개념 파일 수집 > 구조 검증(서버 ConceptBundleValidator 와 같은 규칙) > 글 점검 > 가져오기 JSON

실행: python3 -I content/concepts/build_concept_bundle.py [--topic data_modeling] [--output 경로]
  - 오류가 하나라도 있으면 JSON 을 쓰지 않고 종료코드 1, 경고는 출력만
  - 기본 출력: content/concepts/build/concept_bundle.json (gitignore, 관리자 > 개념 묶음 가져오기에 사용)
"""
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

# 서버 규칙 (ConceptBundleValidator, ConceptDetailSectionParser)
TAG_KEY_PATTERN = re.compile(r"[a-z0-9-]{1,100}")
HEADING_PATTERN = re.compile(r"^## (.+?) \{#([a-z0-9-]{1,80})\}\s*$")
CHECK_QUESTION_COUNT = 5
CHOICE_KEYS = ("A", "B", "C", "D")

# 글 점검: 설계 18장 금지 말투 (경고)
BANNED_PHRASES = ("완벽", "마스터", "핵심 중의 핵심", "중요합니다", "라고 할 수 있습니다", "해 볼게요!", "먼저,", "마지막으로,")
EMOJI_PATTERN = re.compile("[\U0001F300-\U0001FAFF☀-➿]")
CORE_LINE_RANGE = (3, 5)

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
    return errors


def lint_text(concept):
    """글 점검 경고: 금지 말투·느낌표·이모지, 핵심만 줄 수, 정답 위치 쏠림"""
    warnings = []
    texts = [concept.get("summary") or "", concept.get("coreMd") or "", concept.get("detailMd") or ""]
    for question in concept.get("checkQuestions") or []:
        texts += [question.get("stem") or "", question.get("explanation") or ""]
        texts += [(choice.get("body") or "") + " " + (choice.get("rationale") or "") for choice in question.get("choices") or []]
    joined = "\n".join(re.sub(r"```[\s\S]*?```", "", text) for text in texts)
    for phrase in BANNED_PHRASES:
        if phrase in joined:
            warnings.append(f"banned phrase: {phrase}")
    if "!" in joined:
        warnings.append("exclamation mark")
    if EMOJI_PATTERN.search(joined):
        warnings.append("emoji")
    core_line_count = len([line for line in (concept.get("coreMd") or "").splitlines() if line.strip()])
    if not CORE_LINE_RANGE[0] <= core_line_count <= CORE_LINE_RANGE[1]:
        warnings.append(f"coreMd lines {core_line_count} (want 3~5)")
    correct_keys = [next((choice["choiceKey"] for choice in question.get("choices") or [] if choice.get("isCorrect")), None)
                    for question in concept.get("checkQuestions") or []]
    if correct_keys and max(correct_keys.count(key) for key in CHOICE_KEYS) >= 3:
        warnings.append(f"correct answer positions skewed: {''.join(key or '?' for key in correct_keys)}")
    return warnings


def to_export_item(concept):
    return {key: concept.get(key, [] if key == "relatedQuestionUuids" else None) for key in EXPORT_KEYS}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--topic", choices=TOPIC_CODES)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT_PATH)
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

    counts_by_topic = {code: sum(1 for _, concept in concepts if concept.get("topicCode") == code) for code in TOPIC_CODES}
    print("concepts by topic: " + ", ".join(f"{code}={count}" for code, count in counts_by_topic.items()))
    if error_count:
        print(f"[concept bundle] rejected : {error_count} errors")
        sys.exit(1)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    bundle = {"concepts": [to_export_item(concept) for _, concept in concepts]}
    args.output.write_text(json.dumps(bundle, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"[concept bundle] wrote {len(concepts)} concepts : {args.output}")


if __name__ == "__main__":
    main()
