"""Oracle 버전 호환 점검: 23ai 전용 문법 5종 탐지, 실제 컬럼명 별칭·문자열 리터럴·인라인 뷰 별칭 오탐 없음"""
from sqld_harness.oracle_compatibility import RULE_ORACLE_VERSION, find_23ai_only_syntax, find_oracle_compatibility_findings


def test_select_alias_in_having_is_detected():
    sql = "SELECT DEPT_ID, SUM(SAL) AS TOTAL FROM EMP GROUP BY DEPT_ID HAVING TOTAL > 100"
    assert find_23ai_only_syntax(sql) == ["GROUP BY·HAVING 에서 SELECT 별칭 참조"]


def test_select_alias_in_group_by_is_detected():
    sql = "SELECT SUBSTR(ENAME, 1, 1) AS INITIAL_LETTER, COUNT(*) FROM EMP GROUP BY INITIAL_LETTER"
    assert find_23ai_only_syntax(sql) == ["GROUP BY·HAVING 에서 SELECT 별칭 참조"]


def test_alias_same_as_real_column_is_not_detected():
    sql = "SELECT DEPT_ID AS DEPT_ID, SUM(SAL) AS TOTAL FROM EMP GROUP BY DEPT_ID HAVING SUM(SAL) > 100"
    assert find_23ai_only_syntax(sql) == []


def test_inline_view_alias_in_outer_where_is_not_detected():
    sql = "SELECT DEPT_ID, TOTAL FROM (SELECT DEPT_ID, SUM(SAL) AS TOTAL FROM EMP GROUP BY DEPT_ID) WHERE TOTAL > 100"
    assert find_23ai_only_syntax(sql) == []


def test_other_23ai_syntax_is_detected():
    assert find_23ai_only_syntax("SELECT 1") == ["FROM 없는 SELECT"]
    assert find_23ai_only_syntax("INSERT INTO T VALUES (1, 'A'), (2, 'B')") == ["다중 행 VALUES"]
    assert find_23ai_only_syntax("CREATE TABLE T (FLAG BOOLEAN)") == ["BOOLEAN 타입·리터럴"]
    assert find_23ai_only_syntax("DROP TABLE IF EXISTS T") == ["IF [NOT] EXISTS"]


def test_keyword_inside_string_literal_is_not_detected():
    assert find_23ai_only_syntax("SELECT 'GROUP BY TOTAL' AS TOTAL FROM DUAL") == []


def test_question_finding_names_location(not_in_question):
    not_in_question["choices"][1]["kind"] = "SQL"
    not_in_question["choices"][1]["body"] = "SELECT ID AS K FROM T1 GROUP BY K"
    findings = find_oracle_compatibility_findings(not_in_question)
    assert [(finding.rule, finding.severity) for finding in findings] == [(RULE_ORACLE_VERSION, "warning")]
    assert findings[0].message.startswith("choices[1]")


def test_valid_fixture_has_no_finding(not_in_question, pick_question):
    assert find_oracle_compatibility_findings(not_in_question) == []
    assert find_oracle_compatibility_findings(pick_question) == []
