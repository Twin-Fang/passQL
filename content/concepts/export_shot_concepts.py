"""스토어 캡처용 개념 응답 데이터 생성: 개념 원본 > app/tool/store_shots/shot_concept_data.dart (단원 9개 + 대표 개념 3개)
실행: python3 -I content/concepts/export_shot_concepts.py [--all] (--all 은 63개 전체 점검용, 커밋하지 않고 기본으로 다시 생성)"""
import json
import re
import sys
from pathlib import Path

CONCEPTS_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(CONCEPTS_DIR))

from build_concept_bundle import HEADING_PATTERN, load_concepts, to_export_item  # noqa: E402
from concept_bundle import TOPIC_CODES  # noqa: E402

OUTPUT_PATH = CONCEPTS_DIR.parent.parent / "app" / "tool" / "store_shots" / "shot_concept_data.dart"
# 캡처 대표 개념 3개: 새 개념(표 많음), SQL 결과 표 많은 개념, 긴 글 개념
SHOT_TAG_KEYS = ("select-relational-database", "window-rank", "modeling-normalization")
# 캡처 단원 이름 (운영 topic.display_name 과 같은 글자, 2026-10-27 관리자 화면 기준)
TOPIC_DISPLAY_NAMES = {
    "data_modeling": "데이터 모델링",
    "sql_basic_select": "SELECT 기본",
    "sql_ddl_dml_tcl": "DDL / DML / TCL",
    "sql_function": "SQL 함수",
    "sql_join": "JOIN",
    "sql_subquery": "서브쿼리",
    "sql_group_aggregate": "그룹함수 / 집계",
    "sql_window": "윈도우 함수",
    "sql_hierarchy_pivot": "계층 / PIVOT",
}
# 캡처용 고정 UUID: 단원 3333...-{순번}, 개념 4444...-{순번}, 문제 5555...-{개념순번}{문제순번}
TOPIC_UUID_FORMAT = "33333333-0000-4000-8000-{:012d}"
CONCEPT_UUID_FORMAT = "44444444-0000-4000-8000-{:012d}"
QUESTION_UUID_FORMAT = "55555555-0000-4000-8000-{:012d}"
# "실전 문제 더 풀기"로 여는 기존 문제 (가짜 API 가 같은 상세로 응답)
RELATED_QUESTION_UUIDS = [f"22222222-0000-4000-8000-{index:012d}" for index in range(1, 6)]


def to_detail_sections(detail_md):
    """자세히 본문 > [{anchor, title, bodyMd}] (서버 ConceptDetailSectionParser 와 같은 규칙, 코드 펜스 안 무시)"""
    sections, is_inside_fence = [], False
    for line in detail_md.splitlines():
        if line.strip().startswith("```"):
            is_inside_fence = not is_inside_fence
        match = None if is_inside_fence else HEADING_PATTERN.match(line)
        if match:
            sections.append({"anchor": match.group(2), "title": match.group(1), "lines": []})
        elif sections:
            sections[-1]["lines"].append(line)
    return [{"anchor": section["anchor"], "title": section["title"], "bodyMd": "\n".join(section["lines"]).strip()}
            for section in sections]


def build_shot_data(is_all_concepts=False):
    """개념 원본 > 캡처 응답 묶음 (topics, conceptsByTopic, detailByConcept, questionsByConcept, answerKeyByQuestion)"""
    # 운영 가져오기와 같은 글 정리를 거친 개념 (표 칸 표시 제거, 영문 가운뎃점 줄바꿈 자리)
    concepts = [to_export_item(concept, {}) for _, concept in load_concepts()]
    topic_uuid_by_code = {code: TOPIC_UUID_FORMAT.format(index + 1) for index, code in enumerate(TOPIC_CODES)}
    concept_uuid_by_tag_key = {concept["tagKey"]: CONCEPT_UUID_FORMAT.format(index + 1) for index, concept in enumerate(concepts)}

    topics, concepts_by_topic = [], {}
    for index, code in enumerate(TOPIC_CODES):
        topic_concepts = [concept for concept in concepts if concept["topicCode"] == code]
        topics.append({"topicUuid": topic_uuid_by_code[code], "displayName": TOPIC_DISPLAY_NAMES[code], "orderIndex": index,
                       "conceptCount": len(topic_concepts), "completedCount": 0, "isLocked": False})
        concepts_by_topic[topic_uuid_by_code[code]] = {
            "topicUuid": topic_uuid_by_code[code], "displayName": TOPIC_DISPLAY_NAMES[code], "isLocked": False,
            "concepts": [{"conceptUuid": concept_uuid_by_tag_key[concept["tagKey"]], "title": concept["title"],
                          "summary": concept["summary"], "status": "NOT_STARTED", "checkCorrectCount": 0,
                          "checkQuestionCount": len(concept["checkQuestions"])} for concept in topic_concepts],
        }

    detail_by_concept, questions_by_concept, answer_key_by_question = {}, {}, {}
    for concept_index, concept in enumerate(concepts, start=1):
        if not is_all_concepts and concept["tagKey"] not in SHOT_TAG_KEYS:
            continue
        concept_uuid = concept_uuid_by_tag_key[concept["tagKey"]]
        same_topic = [other for other in concepts if other["topicCode"] == concept["topicCode"]]
        position = same_topic.index(concept)
        detail_by_concept[concept_uuid] = {
            "conceptUuid": concept_uuid, "topicUuid": topic_uuid_by_code[concept["topicCode"]],
            "title": concept["title"], "summary": concept["summary"], "coreMd": concept["coreMd"],
            "detailSections": to_detail_sections(concept["detailMd"]),
            "previousConceptUuid": concept_uuid_by_tag_key[same_topic[position - 1]["tagKey"]] if position > 0 else None,
            "nextConceptUuid": concept_uuid_by_tag_key[same_topic[position + 1]["tagKey"]] if position + 1 < len(same_topic) else None,
            "lastMode": "READ", "lastDepth": "CORE", "isRead": False, "checkCorrectCount": 0,
            "relatedQuestionUuids": RELATED_QUESTION_UUIDS,
        }
        questions = []
        for question in concept["checkQuestions"]:
            question_uuid = QUESTION_UUID_FORMAT.format(concept_index * 10 + question["sortOrder"])
            questions.append({"questionUuid": question_uuid, "sortOrder": question["sortOrder"], "stem": question["stem"],
                              "stemSql": question.get("stemSql"),
                              "choices": [{"choiceKey": choice["choiceKey"], "body": choice["body"]} for choice in question["choices"]]})
            answer_key_by_question[question_uuid] = {
                "correctKey": next(choice["choiceKey"] for choice in question["choices"] if choice["isCorrect"]),
                "explanation": question["explanation"], "rereadAnchor": question["rereadAnchor"],
                "rationaleByChoiceKey": {choice["choiceKey"]: choice["rationale"] for choice in question["choices"]},
            }
        questions_by_concept[concept_uuid] = questions

    return {"topics": topics, "conceptsByTopic": concepts_by_topic, "detailByConcept": detail_by_concept,
            "questionsByConcept": questions_by_concept, "answerKeyByQuestion": answer_key_by_question}


def main():
    is_all_concepts = "--all" in sys.argv[1:]
    data_json = json.dumps(build_shot_data(is_all_concepts), ensure_ascii=False)
    # Dart raw 문자열(r'''...''') 안에 ''' 가 나오면 끊기므로 확인
    if "'''" in data_json:
        raise SystemExit("[shot concepts] rejected : data contains '''")
    OUTPUT_PATH.write_text(
        "// 생성 파일: content/concepts/export_shot_concepts.py (손으로 고치지 않음)\n"
        f"// 스토어 캡처 가짜 API 의 개념 응답 원본 (단원 9개 + {'개념 전체' if is_all_concepts else '대표 개념 3개'}, #577)\n"
        f"const String shotConceptDataJson = r'''{data_json}''';\n",
        encoding="utf-8",
    )
    print(f"[shot concepts] wrote {OUTPUT_PATH} ({len(data_json)} chars)")


if __name__ == "__main__":
    main()
