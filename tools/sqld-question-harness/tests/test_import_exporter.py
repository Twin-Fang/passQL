"""등록 산출물: 가져오기 JSON 은 v1 필드·순서 유지, v2 메타는 별도"""
from sqld_harness.import_exporter import render_stem, to_import_item, to_question_metadata

# 서버 QuestionExportDto 필드 순서 (#511 v1 출력과 동일)
IMPORT_ITEM_FIELDS = [
    "questionUuid", "topicCode", "difficulty", "executionMode", "choiceSetPolicy", "stem", "hint",
    "schemaDdl", "schemaSampleData", "schemaIntent", "answerSql", "choices",
]


def test_import_item_keeps_v1_shape(not_in_question):
    item = to_import_item(not_in_question)
    assert list(item) == IMPORT_ITEM_FIELDS
    assert item["executionMode"] == "CONCEPT_ONLY" and item["choiceSetPolicy"] == "CURATED_ONLY"
    assert list(item["choices"][0]) == ["choiceKey", "kind", "body", "isCorrect", "rationale"]
    assert "whyPlausible" not in item["choices"][1]


def test_render_stem_includes_table_with_null_and_sql(not_in_question):
    stem = render_stem(not_in_question)
    assert "[T2]\n| ID |\n| --- |\n| 1 |\n| NULL |" in stem
    assert stem.endswith("```sql\nSELECT COUNT(*) FROM T1 WHERE ID NOT IN (SELECT ID FROM T2);\n```")


def test_metadata_carries_v2_fields(not_in_question):
    metadata = to_question_metadata(not_in_question, {"correctReason": "x"})
    assert metadata["trend"]["isLatestTrend"] is True
    assert metadata["concepts"] == ["NOT IN", "NULL 3값 논리"]
    assert metadata["explanation"] == {"correctReason": "x"}
