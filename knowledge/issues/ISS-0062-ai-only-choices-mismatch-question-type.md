---
type: issue
id: ISS-0062
created: 2026-04-11
topics: [question-bank, ai, practice]
symptoms: [AI_ONLY, "실행 결과로 올바른 것은?", "선택지가 SQL 쿼리", "실행 버튼으로 정답 확인", "generate_choice_set v2", "문제 유형 불일치"]
root_cause: "AI_ONLY 지문은 실행 결과를 맞추는 문제인데 선택지 body는 SQL이라, 각 선택지를 실행해 보면 정답이 드러나는 설계 결함"
status: resolved
resolution: "[[ISS-0062-ai-only-choices-mismatch-question-type-report]]"
related: ["[[DEC-0049-ai-only-redefined-sql-equivalence]]", "[[ISS-0063-result-match-policy]]", "[[ISS-0061-schema-display-required-guide]]"]
source: "https://github.com/Twin-Fang/passQL/issues/108"
---

# ISS-0062: `AI_ONLY` 문제의 선택지가 SQL이라 "실행 결과로 올바른 것은?" 지문과 맞지 않음

GitHub #108 (원본: 이슈 본문과 댓글). `긴급` 라벨.

## 증상
`EXECUTABLE` + `AI_ONLY` 문제 지문은 "다음 SQL의 실행 결과로 올바른 것은?"인데 선택지 A~D가 SQL 쿼리다. 사용자는 각 선택지 실행 버튼을 눌러 결과를 보고 고르게 된다 — 이슈 본문: "퀴즈가 아니라 SQL 실행기 사용법 테스트에 불과".

## 재현 조건
`executionMode: EXECUTABLE`, `choiceSetPolicy: AI_ONLY` 문제 풀이 진입.

## 조사 기록
- 2026-04-11: 이슈 본문이 두 방향(실행 결과 예측 = 결과 텍스트 선택지, 동일 결과 SQL 찾기 = SQL 선택지)을 표로 제시. 프롬프트 키는 `generate_choice_set` v2.
- 2026-04-11: 리포트 댓글 — `AI_ONLY`를 "동일한 실행 결과를 내는 SQL"로 재정의. 같은 날 GitHub #107이 "#108에서 처리"로 취소됐다.

## 근본 원인
문제 유형(지문)과 선택지 형태가 정책 수준에서 정의되지 않았다.
