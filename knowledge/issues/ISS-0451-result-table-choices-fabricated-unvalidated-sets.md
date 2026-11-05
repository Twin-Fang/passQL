---
type: issue
id: ISS-0451
created: 2026-11-05
topics: [practice, ai, question-bank]
symptoms: ["결과 표 오답 지어냄", "결과 없음 0행 보기", "근거 없는 합계", "선택지 잘못됨", "정답률 0%", "직접 실행해보기 결과 JSON", "SELECT 또는 WITH 구문만 허용됩니다", "검증 실패 세트 노출", "AI 정답 판단 저장", "같은 세트 반복 노출", "프리페치 정책 무시", RESULT_MATCH, saveWithAiCorrect, sandboxValidationPassed, generate_choice_set_result_match, PrefetchService]
root_cause: "결과 표 문제(RESULT_MATCH)는 AI가 오답 결과 표 JSON을 직접 써서 실제 SQL 실행 결과가 아닌 보기(빈 결과, 근거 없는 숫자)가 저장됐고, SQL 보기는 3회 검증 실패 시 AI 정답 표시를 믿고 저장(DEC-0055), 프리페치는 정책과 무관하게 SQL 보기를 생성했으며, 제출 응답이 결과 표 정답의 SQL을 비워 앱이 결과 JSON을 직접 실행 칸에 넣었다"
status: resolved
resolution: "[[ISS-0451-result-table-choices-fabricated-unvalidated-sets-report]]"
related: ["[[ISS-0451-result-table-choices-fabricated-unvalidated-sets-report]]", "[[DEC-0249-result-table-choices-from-executed-sql]]", "[[DEC-0250-never-store-unvalidated-sql-choice-sets]]", "[[DEC-0251-practice-reuse-random-validated-sets]]", "[[DEC-0050-result-match-text-choices]]", "[[DEC-0055-multiple-correct-ai-fallback-save]]", "[[DEC-0087-choice-generation-practice-real-mode]]"]
source: "https://github.com/Twin-Fang/passQL/issues/828"
---

# ISS-0451: 결과 표 문제 오답을 AI가 지어냄, 미검증 세트 저장, 직접 실행해보기에 결과 JSON

GitHub #828 이슈 본문 기준. 원본 사본: `_sources/issues/ISS-0451-result-table-choices-fabricated-unvalidated-sets.md` (로컬 전용). 완료 리포트: [[ISS-0451-result-table-choices-fabricated-unvalidated-sets-report]]

## 증상
- 2026-11-05 오늘의 세트 그룹함수 문제("다음 SQL의 실행 결과로 올바른 것은?", `SELECT DEPT_ID, COUNT(*), SUM(SAL) ... GROUP BY DEPT_ID`)의 보기 중 C "결과 없음 0행"(데이터가 있는 표에 GROUP BY), D "TOTAL 3000"(어떤 실수 SQL로도 안 나오는 값). 정답 A는 맞음.
- 같은 세트(2026-10-18 AI_RUNTIME 1개)가 연습 모드 재사용으로 모든 회원에게 반복. 풀이 3회, 정답률 0%, 신고 1건.
- 오답 제출 후 "직접 실행해보기 > 정답에서" 칸에 SQL 대신 결과 JSON이 들어가 실행하면 "SELECT 또는 WITH 구문만 허용됩니다".
- 사용자 요구: 오답 선택지가 절대 나오면 안 됨, 정답은 100%, 오답은 엄청 헷갈리게 하되 매번 새롭게.

## 재현 조건
결과 표 문제를 연습 모드로 풀기 > 보기 확인 > 오답 제출 > 직접 실행해보기 실행.

## 근본 원인
1. RESULT_MATCH 생성은 AI가 결과 표 JSON 4개를 직접 쓰고, 검증은 "정답 표가 1개인가"만 봤다. 오답 표가 실제 실행 결과인지, 빈 결과인지, 열이 같은지는 검사하지 않았다 ([[DEC-0050-result-match-text-choices]]).
2. SQL 보기는 3회 모두 MULTIPLE_CORRECT면 AI 정답 표시로 저장했다(`saveWithAiCorrect`, [[DEC-0055-multiple-correct-ai-fallback-save]]). 연습 모드 재사용은 검증 여부를 보지 않았다.
3. `PrefetchService`가 정책과 무관하게 SQL 보기 생성(`generate`)만 불러 결과 표 문제에 SQL 보기 세트를 만들 수 있었다.
4. 제출 응답은 결과 표(TEXT) 정답이면 `correctSql`을 null로, 앱은 그 자리를 정답 보기 본문(JSON)으로 채웠다.
