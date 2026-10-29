---
type: issue
id: ISS-0066
created: 2026-04-11
topics: [ai, practice]
symptoms: [CHOICE_SET_VALIDATION_MULTIPLE_CORRECT, "correctCount=2", "최대 재시도 초과", AI_ONLY, EXECUTABLE, "SQL 동치", generate-choices, "선택지 생성 실패"]
root_cause: "SQL 동치 유형에서 AI가 의도적으로 만든 오답 SQL도 샌드박스 실행 결과가 정답과 같아 재시도로는 풀리지 않는 구조적 문제"
status: resolved
resolution: "[[ISS-0066-ai-only-equivalent-sql-multiple-correct-report]]"
related: ["[[DEC-0052-result-match-policy-equivalence-type]]", "[[ISS-0074-anti-equivalence-prompt-v4]]"]
source: "https://github.com/Twin-Fang/passQL/issues/114"
---

# ISS-0066: AI_ONLY 정책의 SQL 동치 유형 문제에서 MULTIPLE_CORRECT가 3회 재시도 내내 반복

GitHub #114 (원본: 이슈 본문과 리포트 댓글).

## 증상
`choiceSetPolicy=AI_ONLY` + `executionMode=EXECUTABLE` 조합의 "동일한 실행 결과를 내는 SQL은?" 유형 문제에서, AI가 만든 오답 선택지가 정답 SQL과 같은 실행 결과를 내 `CHOICE_SET_VALIDATION_MULTIPLE_CORRECT`가 최대 재시도(3회) 내내 반복된다. 로그는 매 회 `correctCount=2`, 마지막에 `[choice-gen] 최대 재시도 초과`. 사용자에게는 선택지 생성 실패 에러가 반환된다.

## 재현 조건
`choiceSetPolicy=AI_ONLY`, `executionMode=EXECUTABLE`인 SQL 동치 유형 문제(예: stem "다음 SQL과 동일한 실행 결과를 내는 SQL은? (Self Join 유형)", 문제 UUID `fc143893-2e86-4071-9e9f-a96c0ef2d745`)에서 `POST /api/questions/{questionUuid}/generate-choices` SSE 호출.

## 조사 기록
- 2026-04-11: 이슈 본문은 SQL 동치 특성상 재시도로 해결되지 않는 구조적 문제라고 진단. 기대 동작으로 정답 1개 세트 생성, 또는 `RESULT_MATCH` 정책 폴백·관리자 알림을 적었다.

## 근본 원인
AI가 틀리게 의도한 SQL도 샌드박스 실행 결과가 정답과 동일하게 나올 수 있다. 관련 파일: `ChoiceSetGenerationService.java`, `SandboxValidator.java`, `ChoiceSetResolver.java`.
