---
type: decision
id: DEC-0055
created: 2026-04-11
reviewed: null
topics: [ai, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0074-anti-equivalence-prompt-v4]]", "[[ISS-0074-anti-equivalence-prompt-v4-report]]"]
---

# DEC-0055: 3회 재시도 후에도 `MULTIPLE_CORRECT`면 AI의 `isCorrect` 판단으로 fallback 저장 (`sandbox_validation_passed=false`)

## 문제 정의 (Context)
EXECUTABLE + AI_ONLY 문제에서 동치 SQL 오답으로 `CHOICE_SET_VALIDATION_MULTIPLE_CORRECT`가 3회 내내 나면 사용자에게 선택지가 표시되지 않았다 (GitHub #126).

## 결정 (Decision)
"최후 방어선"으로, 3회 재시도 후에도 `MULTIPLE_CORRECT`로 실패하면 AI `isCorrect` 마킹을 믿고 저장한다(`saveWithAiCorrect()`, `sandboxValidationPassed=false`). 조건: AI `isCorrect=true`가 1~3개면 저장·표시, 4개(전부) 또는 0개면 에러. 프롬프트 v4와 Sandbox 검증은 그대로 둔다.

## 검토한 대안 (Alternatives)
논의 기록 없음. (리포트가 밝힌 근거: "동치 SQL 찾기" 유형은 샌드박스가 실행 결과가 같다는 것만 알고, AI는 의미론적으로 어떤 게 정답인지 안다. 정답이 여러 개여도 그중 하나를 고르면 정답 처리되므로 학습 목적상 문제없다.)

## 결과 (Consequences)
**긍정**
- 사용자에게 선택지를 최대한 보여준다.
- fallback 세트는 `sandbox_validation_passed=false`로 기록돼 품질 모니터링에 쓸 수 있다.

**부정**
- 해당 세트는 샌드박스 검증을 통과하지 않은 AI 판단 기반이다. 정답이 여러 개일 수 있다.

## 영향 범위 (Scope)
`ChoiceSetGenerationService.generate()` 최종 실패 분기, `ChoiceSetSaveService.saveWithAiCorrect()`, `question_choice_set.sandbox_validation_passed`.

## 출처 (References)
- GitHub #126 리포트 댓글 (2026-04-11)
- [[ISS-0074-anti-equivalence-prompt-v4]]
