---
type: completion-report
id: ISS-0048
created: 2026-04-11
topics: [practice, question-bank]
status: resolved
resolves: "[[ISS-0048-execution-mode-choice-policy-mismatch]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/88"
---

# ISS-0048 완료 리포트: CONCEPT_ONLY SSE 이중 차단, `sandboxDbName` 폴백, `choiceSetPolicy` 응답 추가

GitHub #88 `## 개요` 리포트 댓글(2026-04-11) 기준.

## 해결 방법
- `QuestionDetail`에 `choiceSetPolicy` 추가, `QuestionService.getQuestion()`에 포함, `updateChoiceSetPolicy()` 신규(내부 메서드).
- `ChoiceSetResolver`: `ExecutionMode.CONCEPT_ONLY` 조기 거부. `SandboxValidator`: `schemaDdl` null·blank 체크.
- `SubmissionService.submit()`: `sandboxDbName` null이면 `questionUuid.toString()`을 DB명으로 폴백(`QuestionExecutionService`와 같은 정책으로 통일).
- 프론트: `ChoiceSetPolicy` 타입(`"AI_ONLY" | "ODD_ONE_OUT" | "CURATED_ONLY" | "HYBRID"`) 추가, `needsSseGeneration`에 `executionMode === "EXECUTABLE"` 조건 — CONCEPT_ONLY는 "선택지가 아직 준비되지 않았습니다" 표시. mock·contract test에 `choiceSetPolicy: "AI_ONLY"`.

## 근본 원인 (확정)
이슈 노트와 같다.

## 재발 방지
리포트 주의사항: `sandboxDbName` null 레거시 문제는 UUID를 DB명으로 쓰는 폴백에 의존하므로 신규 문제는 `sandboxDbName`을 채워 생성해야 한다. `updateChoiceSetPolicy()`의 HTTP 엔드포인트는 별도 작업. (이 `questionUuid` 폴백은 GitHub #104에서 Access Denied 원인으로 확인돼 `/execute`에서 제거됐다.)

## 교훈
(원본에 없음, 볼트 정리) 문제 유형 필드(`executionMode`, `choiceSetPolicy`)가 추가되면 서버 응답 DTO·프론트 타입·생성 경로 분기가 모두 따라왔는지 함께 확인한다.
