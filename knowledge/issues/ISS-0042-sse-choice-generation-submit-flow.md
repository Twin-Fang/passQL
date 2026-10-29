---
type: issue
id: ISS-0042
created: 2026-04-10
topics: [practice, ai]
symptoms: [generate-choices, SSE, "엔드포인트 없음", "SubmitRequest choiceSetId 없음", QuestionChoice, "choiceSetUuid NULL", SubmitResult, "실행 결과 비교 없음"]
root_cause: "FE가 기대하는 SSE 선택지 생성 엔드포인트가 BE에 없었고, SubmissionService가 구 question_choice 테이블을 참조해 choiceSetUuid를 저장하지 않았으며 SubmitResult에 실행 결과가 없었다"
status: resolved
resolution: "[[ISS-0042-sse-choice-generation-submit-flow-report]]"
related: ["[[DEC-0040-choice-response-hides-answer]]", "[[ISS-0046-sse-submit-fe-integration-guide]]"]
source: "https://github.com/Twin-Fang/passQL/issues/69"
---

# ISS-0042: 선택지 생성 SSE 엔드포인트 부재와 제출 플로우의 구 테이블 참조

GitHub #69 (원본: 이슈 본문, 구현 계획 댓글, 리포트 댓글). 이슈는 `작업전` 라벨인 채로 2026-04-10에 닫혔다.

## 증상
1. FE의 `POST /api/questions/{questionUuid}/generate-choices`(SSE) 호출 코드는 완성됐는데 BE 엔드포인트가 없다. `generate_choice_set` 프롬프트(V0_0_28)와 `AiGatewayClient`는 있으나 연결하는 Controller/Service가 없다.
2. `SubmissionService.submit()`이 `QuestionChoiceRepository.findByQuestionUuidAndChoiceKey()`로 구 `question_choice`를 참조해 `Submission.choiceSetUuid`가 항상 NULL.
3. FE는 `{ choiceSetId, selectedChoiceKey }`를 보내는데 BE `SubmitRequest`는 `selectedChoiceKey`만 받는다.
4. `SubmitResult`가 `{ isCorrect, correctKey, rationale }`뿐이라 선택 SQL과 정답 SQL 실행 결과를 비교해 보여줄 수 없다.

## 재현 조건
문제 풀이 화면 진입 후 선택지 생성·제출.

## 조사 기록
- 2026-04-10: 구현 계획 댓글(SSE DTO, `ChoiceSetGenerationService`, `SubmissionService` 전면 리팩토링).
- 2026-04-10: 리포트 — 기존 `ChoiceSetGenerationService`·`SandboxValidator`·`ChoiceSetResolver`를 재활용.

## 근본 원인
선택지 세트 구조(V0_0_28)는 생겼지만 그것을 쓰는 SSE 엔드포인트와 제출 경로 마이그레이션이 없었다.
