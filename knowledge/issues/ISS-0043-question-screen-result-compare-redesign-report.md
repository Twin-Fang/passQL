---
type: completion-report
id: ISS-0043
created: 2026-04-10
topics: [practice]
status: resolved
resolves: "[[ISS-0043-question-screen-result-compare-redesign]]"
related: ["[[DEC-0041-result-screen-by-execution-mode]]"]
source: "https://github.com/Twin-Fang/passQL/issues/70"
---

# ISS-0043 완료 리포트: 실행 결과 비교 응답, 스키마 뷰어, SQL 실행기

GitHub #70 백엔드 `## 개요` 리포트 댓글(2026-04-10)과 프론트 작업 댓글(2026-04-10) 기준.

## 해결 방법
- 백엔드: `QuestionExecutionService` 실제 구현 — `executeChoice(questionUuid, sql)`(sandboxDbName 기반, CONCEPT_ONLY 차단), `submitWithResult(...)`(EXECUTABLE은 선택 SQL·`answerSql` 실행 결과 포함, CONCEPT_ONLY는 키 비교만). `QuestionController`는 `QuestionExecutionService` 단일 진입점. `SubmissionService.recordSubmission()` 분리. `ErrorCode.INVALID_EXECUTION_MODE(400)`. `V0_0_44__add_schema_sample_data.sql`(`question.schema_sample_data TEXT`).
- 프론트: `ResultTable`(공용), `SchemaViewer`(`schemaDisplay` 정규식 파싱, PK/FK 아이콘, 샘플 데이터, DDL 토글), `SqlPlayground`(EXECUTABLE에만 표시) 신규. `AnswerFeedback`은 `executionMode`로 `SqlCompareBlock`/`TextCompareBlock` 분기, 오답 시에만 "AI에게 자세히 물어보기". `ChoiceCard`에 `ResultTable` 적용. 컴포넌트 단위 테스트 3종.

## 근본 원인 (확정)
`/execute`의 DB 이름 오용(`question.getSandboxDbName()` 사용으로 수정)과 화면·응답 구성 부족.

## 재발 방지
백엔드 주의사항: `correctResult`는 정답 여부와 무관하게 항상 실행된다. `/execute` 호출은 `ExecutionLog`를 남기지 않아 `/admin/monitor` 통계에 잡히지 않는다(별도 이슈 필요). 기존 문제의 `schema_sample_data`는 NULL. 프론트: `schemaDisplay` 포맷이 바뀌면 `parseSchemaDisplay` 정규식을 고쳐야 한다.

## 교훈
(원본에 없음, 볼트 정리) 샌드박스 실행이 DB를 못 찾으면 넘기는 DB 이름이 `sandbox_` 형식인지부터 본다 — 이후 GitHub #88·#104에서도 같은 DB 이름 문제가 이어졌다.
