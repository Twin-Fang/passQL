---
type: decision
id: DEC-0052
created: 2026-04-11
reviewed: null
topics: [ai, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0066-ai-only-equivalent-sql-multiple-correct]]", "[[ISS-0066-ai-only-equivalent-sql-multiple-correct-report]]"]
---

# DEC-0052: AI_ONLY EXECUTABLE 문제는 "동일 결과를 내는 SQL 찾기" 유형으로 재정의하고 `RESULT_MATCH` 선택지 정책을 추가

## 문제 정의 (Context)
AI_ONLY + EXECUTABLE 동치 유형 문제에서 `CHOICE_SET_VALIDATION_MULTIPLE_CORRECT`가 3회 재시도 내내 반복됐다 (GitHub #114).

## 결정 (Decision)
- `generate_choice_set` 프롬프트 v3: AI_ONLY를 "기준 SQL과 동일 결과를 내는 SQL 찾기" 유형으로 명시하고 선택지 body를 SQL로 강제. 해당 문제 stem을 "동일한 실행 결과를 내는 SQL은?"으로 일괄 수정(`V0_0_63__fix_ai_only_prompt_to_sql_equivalence.sql`).
- 재시도 시 동치로 확인된 오답 SQL을 금지 목록으로 다음 AI 요청에 전달.
- `RESULT_MATCH` 정책 추가: `answerSql`을 Sandbox에서 1회 실행한 결과 JSON을 AI에 주고, AI 선택지(결과 텍스트)를 JSON 비교로 검증. 리포트는 이를 동치 문제가 반복될 수 있는 EXECUTABLE 문제의 "폴백 정책"이라고 적었다.

## 검토한 대안 (Alternatives)
- 관리자 알림: 이슈 본문 기대 동작에 후보로 있었고 이번 수정에는 들어가지 않았다. 리포트 주의사항은 "관리자 알림 또는 RESULT_MATCH 정책 수동 전환 검토 필요"로 남겼다. 고르지 않은 이유는 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 동치 SQL 반복 실수를 금지 목록으로 억제(리포트 서술).

**부정**
- 피드백 루프는 3회 한도 안에서만 동작하며 근본 해결이 아니다(리포트 주의사항).
- 기존 AI_ONLY EXECUTABLE 문제의 선택지 세트를 삭제해 재생성을 유도했다(submission FK는 NULL 처리).

## 영향 범위 (Scope)
`ChoiceSetGenerationService`, `ChoiceSetResolver`, `ChoiceSetSaveService`, `SandboxValidator`, `prompt_template`(`generate_choice_set`), 프론트 `ResultMatchTable.tsx`·`ChoiceCard`.

## 출처 (References)
- GitHub #114 리포트 댓글 (2026-04-11)
- [[ISS-0066-ai-only-equivalent-sql-multiple-correct]]
