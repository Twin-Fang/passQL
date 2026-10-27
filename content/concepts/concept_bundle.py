"""개념 파일 작성 공통: 보기·확인 문제·SQL 검증 항목 생성, 단원 코드 9개 (#577)
sqlChecks 는 Oracle 검증 전용 > 가져오기 JSON 에서 빠짐"""

from typing import NamedTuple

# 서버 topic.code 9개 (단원 순서 = 앱 단원 번호)
TOPIC_CODES = (
    "data_modeling",
    "sql_basic_select",
    "sql_ddl_dml_tcl",
    "sql_function",
    "sql_join",
    "sql_subquery",
    "sql_group_aggregate",
    "sql_window",
    "sql_hierarchy_pivot",
)


def choice(key, body, is_correct=False, rationale=None):
    """보기 1개 (A~D, 정답 여부, 고른 뒤 보여 줄 한 줄 이유)"""
    return {"choiceKey": key, "body": body, "isCorrect": is_correct, "rationale": rationale}


def question(order, stem, anchor, explanation, choices, stem_sql=None):
    """확인 문제 1개 (순서 1~5, 다시 읽기 앵커 = 자세히 문단 {#앵커})"""
    return {"sortOrder": order, "stem": stem, "stemSql": stem_sql, "explanation": explanation,
            "rereadAnchor": anchor, "choices": choices}


def sql_check(sql, rows, is_ordered=False, setup=None):
    """Oracle 결과 검증 1개: setup 실행 > sql 결과 행 == rows (날짜는 'YYYY-MM-DD' 문자열로 비교)"""
    return {"sql": sql, "rows": rows, "isOrdered": is_ordered, "setup": setup}


def sql_error_check(sql, error_code, setup=None):
    """Oracle 오류 검증 1개: sql 실행 시 error_code(예: 'ORA-00937') 오류가 나야 함"""
    return {"sql": sql, "errorCode": error_code, "setup": setup}


class SqlExample(NamedTuple):
    """SQL 예시 1개: 본문 마크다운(sql 코드 블록 + 결과 표)과 같은 행으로 만든 검증 항목"""
    markdown: str
    check: dict


def sql_example(sql, columns, rows, is_ordered=True):
    """SQL + 결과 열·행 > SqlExample (본문 표와 sqlChecks 가 한 원본에서 나와 어긋나지 않음)"""
    from concept_dataset import to_markdown_table  # 순환 import 방지 (concept_dataset 은 이 모듈을 쓰지 않음)

    markdown = f"```sql\n{sql}\n```\n\n{to_markdown_table(columns, rows)}"
    return SqlExample(markdown, sql_check(sql, [list(row) for row in rows], is_ordered))
