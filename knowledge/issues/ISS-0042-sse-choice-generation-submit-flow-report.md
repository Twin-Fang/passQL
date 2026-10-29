---
type: completion-report
id: ISS-0042
created: 2026-04-10
topics: [practice, ai]
status: resolved
resolves: "[[ISS-0042-sse-choice-generation-submit-flow]]"
related: ["[[DEC-0040-choice-response-hides-answer]]"]
source: "https://github.com/Twin-Fang/passQL/issues/69"
---

# ISS-0042 완료 리포트: SSE 선택지 생성 엔드포인트와 `QuestionChoiceSetItem` 기반 제출

GitHub #69 `## 개요` 리포트 댓글(2026-04-10) 기준.

## 해결 방법
- `QuestionController`: `POST /api/questions/{questionUuid}/generate-choices` — `SseEmitter`(60초) + Virtual Thread. `ChoiceSetResolver.resolveForUser()`로 프리페치 캐시(`AI_PREFETCH` 미소비 세트) 히트 시 즉시 반환, 미스 시 AI 생성 → `SandboxValidator` 검증 → 최대 3회 재시도 → 저장. 이벤트: `status`(generating/validating) → `complete`(choiceSetId + choices) / `error`.
- DTO 신규: `SseStatusEvent`, `SseErrorEvent`, `ChoiceSetGenerateResponse`. 응답에서 `isCorrect`, `rationale` 제외.
- `SubmitRequest`에 `choiceSetId`, `SubmitResult`에 `selectedResult`, `correctResult`, `correctSql`, `selectedSql` 추가.
- `SubmissionService`: 구 `QuestionChoice` 참조 제거, `QuestionChoiceSetItem.isCorrect`로 판정, `Submission.choiceSetUuid` 저장, 최초 제출 시 `consumedAt` 기록, EXECUTABLE이면 선택·정답 SQL을 `SandboxExecutor`로 실행.
- `ErrorCode.CHOICE_SET_ITEM_NOT_FOUND`, `QuestionControllerDocs` 갱신. DB 마이그레이션 불필요(V0_0_28에 이미 있음).

## 근본 원인 (확정)
이슈 노트와 같다.

## 재발 방지
리포트 주의사항: `QuestionService`, `AdminQuestionDeleteService`는 여전히 구 `QuestionChoice`를 참조한다(문제 상세 조회 호환용, FE 마이그레이션 후 단계적 제거 필요). FE `submitAnswer()`에 `choiceSetId` 포함이 필요하다. CONCEPT_ONLY는 실행 결과 4필드가 null.

## 교훈
논의 기록 없음.
