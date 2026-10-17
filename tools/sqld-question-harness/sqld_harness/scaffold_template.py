"""
YAML v2 빈 양식: 새 문제 작성 시작점 (필드 순서 = 작성 순서: 경향 근거 > 의도·함정 > 데이터·SQL > 보기 > 해설)
"""

SCAFFOLD_TEMPLATE = """\
schemaVersion: 2
id: {question_id}
topicCode: sql_subquery            # 서버 토픽 코드
difficulty: 3                       # 1~5
# (a) 출제 경향 근거
trend:
  templates: [T01]                  # 경향 카탈로그 템플릿 id
  examRounds: [61, 62]              # 근거 회차
  isLatestTrend: true               # 최신 회차 근거가 있을 때만 true (학습 화면 '최신 경향' 표시)
# (b) 출제 설계
intent: NOT IN 서브쿼리에 NULL 포함 시 UNKNOWN
trapDesign: 서브쿼리 결과에 NULL 1건을 섞어 NOT EXISTS 와 결과가 갈리게 함
difficultyReason: 개념 2개 결합(NOT IN 전개 + 3값 논리), 행 수 계산 1단계
concepts: [NOT IN, NULL 3값 논리]
stem: 다음 SQL의 실행 결과로 옳은 것은?
tables:
  - name: T1
    columns: [ID]
    rows: [[1], [2]]
displaySql: |
  SELECT COUNT(*) FROM T1 WHERE ID NOT IN (SELECT ID FROM T2);
ddl: |
  CREATE TABLE T1 (ID NUMBER);
  CREATE TABLE T2 (ID NUMBER);
data: |
  INSERT INTO T1 VALUES (1);
  INSERT INTO T1 VALUES (2);
  INSERT INTO T2 VALUES (NULL);
answerSql: |
  SELECT COUNT(*) FROM T1 WHERE ID NOT IN (SELECT ID FROM T2);
hint: ID NOT IN (NULL) 은 ID <> NULL 이라 항상 UNKNOWN 이다.
choices:
  - {{body: "0", isCorrect: true, expect: {{scalar: 0}}, rationale: "ID <> NULL 이 UNKNOWN 이라 0건."}}
  - {{body: "1", expect: {{scalar: 1}}, rationale: "...", whyPlausible: "학습자가 이 보기를 고르는 이유"}}
  - {{body: "2", expect: {{scalar: 2}}, rationale: "...", whyPlausible: "NOT EXISTS 처럼 NULL 을 건너뛴다고 착각"}}
  - {{body: "3", expect: {{scalar: 3}}, rationale: "...", whyPlausible: "..."}}
# (e) 해설 (선택, 없으면 보기 근거·함정·힌트로 초안 조립)
explanation:
  examTip: NOT IN 서브쿼리를 보면 NULL 부터 찾는다.
"""


def build_scaffold_yaml(question_id):
    return SCAFFOLD_TEMPLATE.format(question_id=question_id)
