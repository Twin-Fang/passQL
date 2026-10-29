---
type: completion-report
id: ISS-0062
created: 2026-04-11
topics: [question-bank, ai, practice]
status: resolved
resolves: "[[ISS-0062-ai-only-choices-mismatch-question-type]]"
related: ["[[DEC-0049-ai-only-redefined-sql-equivalence]]"]
source: "https://github.com/Twin-Fang/passQL/issues/108"
---

# ISS-0062 완료 리포트: `AI_ONLY`를 "동일 결과 SQL 찾기"로 재정의 — 프롬프트 v3와 기존 데이터 정리

GitHub #108 `## 개요` 리포트 댓글(2026-04-11) 기준.

## 해결 방법
`V0_0_63__fix_ai_only_prompt_to_sql_equivalence.sql` 4단계:
1. `generate_choice_set` v2 비활성화
2. v3 삽입 — system_prompt에 "각 선택지의 body 필드는 반드시 MariaDB에서 실행 가능한 SELECT SQL 쿼리" + 금지 예시. 유저 프롬프트는 "기준 SQL과 동일한 실행 결과를 내는 SQL(정답 1개) + 다른 결과를 내는 SQL(오답 3개)".
3. 기존 AI_ONLY EXECUTABLE 문제 `stem` 일괄 `UPDATE question`
4. 기존 AI_ONLY EXECUTABLE 선택지 세트 삭제(`choice_set_item` → `choice_set`) — 다음 요청 시 v3로 재생성 유도

`question-bulk-guide.md`, `question-register-guide.md`의 AI_ONLY 설명·예시를 새 지문 패턴으로 수정.

## 근본 원인 (확정)
이슈 노트와 같다.

## 재발 방지
리포트 주의사항: "실행 결과 예측" 유형이 필요하면 별도 `RESULT_MATCH` 정책으로 분리(GitHub #110). v3 이후에도 AI가 간헐적으로 실행 결과 텍스트를 반환할 경우를 대비한 Sandbox 검증 강화 필요(GitHub #103 흐름).

## 교훈
(원본에 없음, 볼트 정리) 선택지 정책을 추가·변경할 때는 지문 패턴, 선택지 body 형태, 정답 판정 기준을 한 세트로 정의한다.
