---
type: decision
id: DEC-0041
created: 2026-04-10
reviewed: null
topics: [practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0043-question-screen-result-compare-redesign]]", "[[ISS-0043-question-screen-result-compare-redesign-report]]"]
---

# DEC-0041: 제출 결과는 `executionMode`로 나눈다 — EXECUTABLE은 SQL과 실행 결과 비교, CONCEPT_ONLY는 텍스트 비교만

## 문제 정의 (Context)
결과 화면에 실행 결과 비교가 없었고 CONCEPT_ONLY 문제에도 SQL이 표시됐다 (GitHub #70).

## 결정 (Decision)
- 서버 `submitWithResult`: EXECUTABLE은 선택 SQL과 `answerSql`을 샌드박스에서 실행해 `selectedResult`·`correctResult`를 함께 반환한다. CONCEPT_ONLY는 SQL을 실행하지 않고 `isCorrect`, `correctKey`, `rationale`만 반환한다.
- CONCEPT_ONLY 문제에 `/execute`를 호출하면 400 `INVALID_EXECUTION_MODE`.
- 프론트 `AnswerFeedback`: EXECUTABLE은 `SqlCompareBlock`(SQL + `ResultTable`), CONCEPT_ONLY(또는 undefined)는 `TextCompareBlock`(본문 텍스트). 오답일 때만 내 선택 블록을 위에 표시.
- 원본 이유(프론트 댓글): "EXECUTABLE 문제는 SQL 실행 결과 비교가 핵심 학습 포인트이나 CONCEPT_ONLY 문제에는 불필요한 SQL 표시가 UX를 해침".

## 검토한 대안 (Alternatives)
- 이슈 본문은 EXECUTABLE 비교를 "나란히 (또는 상하)"로 열어 두었다. 그 밖의 대안은 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 오답 시 "내 SQL 결과 vs 정답 SQL 결과"를 직접 비교할 수 있다.

**부정**
- 백엔드 주의사항: `correctResult`를 정답일 때도 실행한다(오답 시에만 필요하면 `!isCorrect` 조건으로 최적화 가능).

## 영향 범위 (Scope)
`QuestionExecutionService`, `SubmitResult`, `QuestionController` execute·submit, 프론트 `AnswerFeedback.tsx`, `ResultTable.tsx`, `SqlPlayground.tsx`.

## 출처 (References)
- GitHub #70 이슈 본문 「제출 후 결과 비교 화면」, 백엔드 `## 개요` 리포트 댓글, 프론트 작업 댓글(2026-04-10)
