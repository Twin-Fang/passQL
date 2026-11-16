"""
등록 산출물: 지문 렌더(지문 + SQL, 데이터는 ddl·data 스키마 표로만 #905) > 관리자 가져오기 JSON 항목 (서버 QuestionExportDto 모양 그대로)
경향·개념은 internalTags(관리자 전용 태그, #1117)로 가져오기 JSON 에 싣고, 해설 초안 등 나머지 v2 메타는 별도 메타 파일로
"""
from .constants import CHOICE_KEYS
from .internal_tags import build_internal_tags
from .question_figure import build_figure_svg
from .question_schema import get_choices, get_concepts, get_schema_version, get_trend

# 운영 샌드박스는 PostgreSQL > Oracle 기준 검증 문제는 실행 대상 아님 (서버 ExecutionMode)
IMPORT_EXECUTION_MODE = "CONCEPT_ONLY"
# 고정 보기 세트 (서버 ChoiceSetPolicy, #511)
IMPORT_CHOICE_SET_POLICY = "CURATED_ONLY"


def render_stem(question):
    """지문 + SQL 블록 (tables 는 data 대조용 작성 보조, 앱·웹은 ddl·data 로 스키마 표를 그림)"""
    parts = [str(question["stem"]).strip()]
    if question.get("displaySql"):
        parts.append("```sql\n" + question["displaySql"].strip() + "\n```")
    return "\n\n".join(parts)


def to_import_item(question):
    """문제 YAML > 가져오기 JSON 항목 1건 (v1 필드·순서 + 끝에 internalTags, figureSvg #1132)"""
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
        "internalTags": build_internal_tags(question),
        "figureSvg": build_figure_svg(question),
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
