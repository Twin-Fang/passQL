---
type: decision
id: DEC-0040
created: 2026-04-10
reviewed: null
topics: [practice, ai]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0042-sse-choice-generation-submit-flow]]", "[[ISS-0042-sse-choice-generation-submit-flow-report]]", "[[ISS-0046-sse-submit-fe-integration-guide]]"]
---

# DEC-0040: 선택지 생성 응답에는 정답·해설을 넣지 않고, 정답 판정은 제출 시 서버가 `choiceSetId`의 선택지 세트로 한다

## 문제 정의 (Context)
AI 선택지를 SSE로 내려주고 제출을 새 선택지 세트 테이블 기반으로 옮기면서, 정답 정보를 언제 누구에게 줄지 정해야 했다 (GitHub #69).

## 결정 (Decision)
- SSE `complete` 이벤트의 선택지 항목은 `key`, `kind`, `body`, `sortOrder`만 담는다. `isCorrect`, `rationale`은 제외한다 — 원본 이유: 사용자에게 정답 노출 방지.
- 제출(`POST /submit`)은 `{ choiceSetId, selectedChoiceKey }`를 받고 `QuestionChoiceSetItem.isCorrect`로 판정한다. 최초 제출 시 `choiceSet.consumedAt`을 기록한다(리포트: 재사용 방지 및 분석 데이터).
- EXECUTABLE 문제는 제출 응답에 선택 SQL·정답 SQL과 각 실행 결과를 함께 담는다 — 이슈 본문: passQL의 핵심 차별점인 "눈으로 보고 비교하는 재미".

## 검토한 대안 (Alternatives)
논의 기록 없음. (대체된 기존 방식: 구 `question_choice` 단일 테이블 기반 판정, `selectedChoiceKey`만 받는 제출.)

## 결과 (Consequences)
**긍정**
- 정답이 선택지 생성 단계에서 클라이언트로 나가지 않는다. 제출 기록이 어떤 선택지 세트에서 나왔는지(`choiceSetUuid`) 남는다.

**부정**
- 클라이언트는 `choiceSetId`를 보관해 제출해야 한다(SSE를 쓰지 않는 경로는 `choiceSets[0].choiceSetUuid`를 넘겨야 한다 — GitHub #78).

## 영향 범위 (Scope)
`QuestionController` generate-choices·submit, `ChoiceSetGenerateResponse`, `SubmitRequest`, `SubmitResult`, `SubmissionService`. 볼트의 기존 결정 DEC-0028(선택지 세트 실시간 생성·프리페치)을 구현하는 경로다.

## 출처 (References)
- GitHub #69 이슈 본문 「해결 방안」, 구현 계획 댓글 Task 4, `## 개요` 리포트 댓글(2026-04-10)
