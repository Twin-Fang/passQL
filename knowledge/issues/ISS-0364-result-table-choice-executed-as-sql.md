---
type: issue
id: ISS-0364
created: 2026-10-24
topics: [practice]
symptoms: ["실행 오류", PSQLException, "syntax error at or near \"[\"", "결과표 보기", RESULT_MATCH, "kind=TEXT", SubmissionService, "SQL 실행 배지", "버튼처럼 보임"]
root_cause: "SubmissionService.submit이 EXECUTABLE 문제의 보기를 kind 확인 없이 SQL로 실행해 결과표 JSON이 문법 오류를 냈다"
status: resolved
resolution: "[[ISS-0364-result-table-choice-executed-as-sql-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/607"
---

# ISS-0364: 결과표 보기 문제 채점 시 실행 오류가 뜨는 문제와 SQL 실행 배지 오해

GitHub #607 (원본: 이슈 본문과 댓글).

## 증상
- 보기가 결과표(JSON)인 "다음 SQL의 실행 결과로 올바른 것은?" 유형에서 정답을 맞혀도 채점 결과 화면에 `실행 오류 PSQLException: syntax error at or near "["`. 정답 카드도 결과표가 아니라 JSON 문자열 코드 블록.
- 문제 화면 머리의 `▶ SQL 실행`은 버튼이 아니라 문제 유형 배지인데 재생 아이콘 때문에 버튼으로 보이고, 눌러도 아무 일이 없어 "실행이 안 된다"고 느낀다.

## 재현 조건
`EXECUTABLE` + 결과표 보기(`kind=TEXT`, 본문 `[{"R1":160,...}]`) 문제 제출.

## 조사 기록
- 2026-10-24 운영 DB 전수 조사(읽기 전용): `EXECUTABLE` 70개 중 결과표 보기 문제 11개(활성 5개, 모두 2026-04-14 시스템 생성, 전부 `RESULT_MATCH`). 활성 5개 중 하나가 SQL 함수 문제(ROUND/FLOOR). `EXECUTABLE` + `kind=SQL` 보기 문제 11개, `CONCEPT_ONLY`는 영향 없음.

## 근본 원인
선택지 생성·검증(`ResultMatchChoiceValidator`)과 AI 해설 근거 수집(`ChoiceSetExecutionEvidenceCollector`)은 이미 `kind`로 구분했는데, 제출 채점 경로만 빠져 있었다(서버 코드 누락).
