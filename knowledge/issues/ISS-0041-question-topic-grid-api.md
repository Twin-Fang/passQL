---
type: issue
id: ISS-0041
created: 2026-04-10
topics: [practice, question-bank]
symptoms: ["/api/meta/topics 미사용", MOCK_TOPICS, "topic code 불일치", sql_join, JOIN, "카테고리 그리드 없음", TopicTree]
root_cause: "프론트 Mock topic 코드(JOIN·SUBQUERY 등 임의 코드)가 BE DB 시드 9개 코드 체계와 달랐고, /questions에 카테고리 그리드 화면이 없었다"
status: resolved
resolution: "[[ISS-0041-question-topic-grid-api-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/68"
---

# ISS-0041: 문제 탭 카테고리 선택이 Topic API 대신 Mock 코드를 써서 BE와 불일치

GitHub #68 (원본: 이슈 본문과 댓글).

## 증상
`/questions` 카테고리 선택이 BE `GET /api/meta/topics`를 쓰지 않고 Mock·하드코딩으로 표시된다. FE Mock 코드(`JOIN`, `SUBQUERY`, `GROUP_BY`, `DDL`, `CONSTRAINT`)와 BE DB 코드(`sql_join`, `sql_subquery`, `sql_group_aggregate`, `sql_ddl_dml_tcl` 등)가 다르고, BE 9개 중 5개(`data_modeling`, `sql_basic_select`, `sql_function`, `sql_window`, `sql_hierarchy_pivot`)가 FE에 없다. `CONSTRAINT`는 BE에 없다.

## 재현 조건
문제 탭(`/questions`) 진입.

## 조사 기록
- 2026-04-10: 이슈 본문이 BE 시드(`V0_0_22__rebuild_schema_uuid_unification.sql`) 9개 토픽과 FE/BE 대조표를 정리. BE 변경 없음.

## 근본 원인
프론트가 임의 코드 체계의 Mock을 썼고 카테고리 그리드 화면이 없었다.
