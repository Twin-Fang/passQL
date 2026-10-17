"""
등록 산출물: 지문 렌더(지문 + 데이터 표 + SQL) > 관리자 가져오기 JSON 항목 (서버 QuestionExportDto 모양 그대로)
v2 메타(경향·개념·해설 초안)는 가져오기 JSON 에 넣지 않고 별도 메타 파일로 (서버 DTO 변경 전까지 호환 유지)
"""
from .constants import CHOICE_KEYS
from .question_schema import get_choices, get_concepts, get_schema_version, get_trend

# 운영 샌드박스는 PostgreSQL > Oracle 기준 검증 문제는 실행 대상 아님 (서버 ExecutionMode)
IMPORT_EXECUTION_MODE = "CONCEPT_ONLY"
# 고정 보기 세트 (서버 ChoiceSetPolicy, #511)
IMPORT_CHOICE_SET_POLICY = "CURATED_ONLY"
NULL_DISPLAY_TEXT = "NULL"


def render_markdown_table(table):
    header = "| " + " | ".join(table["columns"]) + " |"
    divider = "| " + " | ".join("---" for _ in table["columns"]) + " |"
    body = ["| " + " | ".join(NULL_DISPLAY_TEXT if value is None else str(value) for value in row) + " |" for row in table["rows"]]
    return "\n".join([f"[{table['name']}]", header, divider, *body])


def render_stem(question):
    """지문 + 데이터 표 + SQL 블록 (개념형은 스키마 화면이 없어 지문에 데이터 포함)"""
    parts = [str(question["stem"]).strip()]
    for table in question.get("tables") or []:
        parts.append(render_markdown_table(table))
    if question.get("displaySql"):
        parts.append("```sql\n" + question["displaySql"].strip() + "\n```")
    return "\n\n".join(parts)


def to_import_item(question):
    """문제 YAML > 가져오기 JSON 항목 1건 (v1 출력과 같은 필드·순서)"""
    choices = [
        {
            "choiceKey": CHOICE_KEYS[index],
            "kind": choice.get("kind", "TEXT"),
            "body": str(choice["body"]),
            "isCorrect": bool(choice.get("isCorrect")),
            "rationale": choice["rationale"],
        }
        for index, choice in enumerate(get_choices(question))
    ]
    return {
        "questionUuid": question.get("questionUuid"),
        "topicCode": question["topicCode"],
        "difficulty": question["difficulty"],
        "executionMode": IMPORT_EXECUTION_MODE,
        "choiceSetPolicy": IMPORT_CHOICE_SET_POLICY,
        "stem": render_stem(question),
        "hint": question.get("hint"),
        "schemaDdl": question.get("ddl"),
        "schemaSampleData": question.get("data"),
        "schemaIntent": question.get("intent"),
        "answerSql": question.get("answerSql"),
        "choices": choices,
    }


def to_question_metadata(question, explanation=None):
    """문제 > 메타 파일 항목 (경향 태그·개념·의도·함정·난이도 근거·해설 초안). 서버 연동 시 그대로 매핑"""
    return {
        "id": str(question["id"]),
        "questionUuid": question.get("questionUuid"),
        "schemaVersion": get_schema_version(question),
        "intent": question.get("intent"),
        "trapDesign": question.get("trapDesign"),
        "difficultyReason": question.get("difficultyReason"),
        "concepts": get_concepts(question),
        "trend": get_trend(question),
        "explanation": explanation,
    }
