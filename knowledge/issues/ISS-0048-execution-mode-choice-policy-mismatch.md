---
type: issue
id: ISS-0048
created: 2026-04-11
topics: [practice, question-bank]
symptoms: [CONCEPT_ONLY, generate-choices, "빈 선택지 화면 고착", SANDBOX_SETUP_FAILED, "sandboxDbName null", "choiceSetPolicy 누락", ODD_ONE_OUT, ChoiceSetResolver]
root_cause: "executionMode·choiceSetPolicy별 처리 분기가 서버·클라이언트 양쪽에서 빠졌다 (CONCEPT_ONLY SSE 거부 없음, sandboxDbName null 폴백 없음, QuestionDetail에 choiceSetPolicy 없음)"
status: resolved
resolution: "[[ISS-0048-execution-mode-choice-policy-mismatch-report]]"
related: ["[[ISS-0059-execute-sandbox-db-access-denied]]", "[[DEC-0047-execute-uses-temp-sandbox-db]]"]
source: "https://github.com/Twin-Fang/passQL/issues/88"
---

# ISS-0048: `executionMode`·`choiceSetPolicy` 분기 누락으로 인한 4가지 버그

GitHub #88 (원본: 이슈 본문과 댓글).

## 증상
1. CONCEPT_ONLY 문제에서 프론트가 무조건 `generate-choices` SSE를 호출하고, 서버(`ChoiceSetResolver`)도 거부 없이 AI 생성으로 들어가 에러 → 빈 선택지 화면 고착.
2. `sandboxDbName`이 null인 레거시 문제에서 `/execute`가 `SANDBOX_SETUP_FAILED`. `SubmissionService.submit()`도 같은 문제.
3. `QuestionDetail` 응답에 `choiceSetPolicy` 필드가 없어 프론트가 정책별 분기를 못 한다.
4. DB에 `AI_ONLY`로 저장된 문제를 `ODD_ONE_OUT`처럼 운영해 두 번째 생성부터 실패.

## 재현 조건
CONCEPT_ONLY 문제 상세(`/questions/{uuid}`) 진입. 또는 `sandboxDbName` null인 EXECUTABLE 문제의 선택지 실행.

## 조사 기록
- 2026-04-11: 리포트 댓글로 일괄 수정.

## 근본 원인
문제 유형별 분기가 서버·클라이언트 모두에서 빠져 있었다.
