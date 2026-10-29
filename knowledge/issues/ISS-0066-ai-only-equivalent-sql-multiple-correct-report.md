---
type: completion-report
id: ISS-0066
created: 2026-04-11
topics: [ai, practice]
status: resolved
resolves: "[[ISS-0066-ai-only-equivalent-sql-multiple-correct]]"
related: ["[[DEC-0052-result-match-policy-equivalence-type]]"]
source: "https://github.com/Twin-Fang/passQL/issues/114"
---

# ISS-0066 완료 리포트: 동치 SQL 피드백 루프, 프롬프트 v3, RESULT_MATCH 정책 추가

GitHub #114 리포트 댓글 기준 (2026-04-11).

## 해결 방법
두 접근을 병행했다.
- 재시도 피드백 루프: `ChoiceSetGenerationService.java`가 MULTIPLE_CORRECT 실패 시 동치로 확인된 오답 SQL을 `equivalentSqls`에 누적해 다음 AI 요청에 "[재시도 피드백]" 섹션으로 붙인다(`collectEquivalentSqls()`).
- 프롬프트 v3: `V0_0_63__fix_ai_only_prompt_to_sql_equivalence.sql`이 `generate_choice_set` v2를 끄고 v3를 넣었다. AI_ONLY를 "기준 SQL과 동일 결과를 내는 SQL 찾기" 유형으로 명시하고 선택지 body를 SQL 쿼리로 강제. AI_ONLY EXECUTABLE 문제 stem을 "실행 결과로 올바른 것은?" → "동일한 실행 결과를 내는 SQL은?"으로 일괄 수정하고, 기존 선택지 세트를 삭제해 재생성을 유도(submission FK 해제 → item → set 순).
- `RESULT_MATCH` 정책: `ChoiceSetResolver.java`에 `generateResultMatch()` 분기, `ChoiceSetSaveService.saveResultMatch()`(`kind=TEXT`, `is_correct`는 JSON 비교 결과로 덮어씀), `SandboxValidator.validateResultMatch()`(Sandbox 재획득 없이 JSON 배열과 expected 결과 비교, `normalizeValue()`로 `Integer(1)`과 `Double(1.0)` 불일치 방지).
- 프론트: `client/src/components/ResultMatchTable.tsx` 신규 — RESULT_MATCH 선택지 body(JSON 배열 문자열)를 결과 테이블로 렌더링, 파싱 실패 시 원문 폴백.

## 근본 원인 (확정)
SQL 동치 유형에서는 AI가 틀리게 만든 SQL도 실행 결과가 정답과 같아질 수 있다(이슈 본문 진단과 동일).

## 재발 방지
리포트 주의사항: 피드백 루프는 3회 한도 안에서만 동작하며 근본 해결이 아니다. 해결이 어려우면 관리자 알림 또는 RESULT_MATCH 정책 수동 전환 검토가 필요하다. RESULT_MATCH 선택지는 SQL 실행 버튼이 필요 없어 `ChoiceCard`의 `isExecutable` prop으로 제어한다.

## 교훈
(원본에 없음, 볼트 정리) MULTIPLE_CORRECT가 같은 문제에서 반복되면 재시도 횟수보다 문제 유형이 동치 SQL을 허용하는지부터 본다. 후속 GitHub #126이 같은 증상을 프롬프트 v4로 다시 다뤘다.
