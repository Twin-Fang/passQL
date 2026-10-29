---
type: issue
id: ISS-0313
created: 2026-10-16
topics: [question-bank, practice]
symptoms: [출제 경향 미반영, 중복 개념형 문제, WITH RECURSIVE 범위 밖, Oracle 전용 문법, AI 보기 정답 오류, 8eefc3e3, CURATED_ONLY 미구현]
root_cause: "문제 풀이 2026년 4월 생성분뿐이고, Oracle 전용 문법 문제는 샌드박스에서 검증되지 않는데 실전 모드에서 AI가 매번 보기를 새로 만들어 계산형 정답이 틀어짐"
status: resolved
resolution: "[[ISS-0313-sqld-2026-trend-curated-choices-report]]"
related: ["[[DEC-0141-curated-only-oracle-verified-choices]]", "[[DEC-0142-encrypt-sqld-research-materials]]"]
source: "https://github.com/Twin-Fang/passQL/issues/511"
---

# ISS-0313: SQLD 2026 출제 경향 반영 — 문제 풀 정리, 보기 고정, 수집 자료 암호화

GitHub #511 (원본: 이슈 본문과 댓글).

## 증상
- 운영 활성 192문항이 전부 2026년 4월 생성분이라 61·62회 경향(61회 합격률 26%, 2과목 40문항 중 30여 문항이 결과 추적형)을 따라가지 못한다.
- 같은 주제 개념형 문제가 2~4개씩 중복, 범위 밖 문제(`WITH RECURSIVE`) 존재.
- 매 회차 나오는 유형(정규식 REGEXP_*, ROWNUM·Top-N, MERGE·INSERT FIRST·ROLE 전파, 1과목 상황형)이 0문항.
- Oracle 전용 문법 문제는 샌드박스(MariaDB/PostgreSQL)에서 검증되지 않아 개념형이 되고, 실전 모드에서 AI가 매번 보기를 새로 만들어 계산형 정답이 틀어진다. 실제 사례 `8eefc3e3`(CONNECT BY + WHERE COUNT): AI 보기 세트가 정답을 3으로 표시, 실제 정답 2, 해설 모순.
- 보기를 고정하는 `CURATED_ONLY` 정책이 구현되지 않았다.

## 재현 조건
Oracle 전용 문법 계산형 문제를 실전 모드로 풀 때 AI 생성 보기의 정답 표시가 실제와 다를 수 있다(`8eefc3e3`).

## 조사 기록
- 2026-10-16: 58~62회 복원 문항표·카페 후기·저자 분석 수집, 중복 21 + 범위 밖 1 비활성화(이슈 본문 시점).
- 2026-10-16: 1차 보고 — `CURATED_ONLY`, Oracle 검증 하네스, 자료 암호화 구현·배포.
- 2026-10-17: 3차 양산 등록, 로컬 사용자 풀이 실측, `member.auth_provider` 기본값 제거 후속.

## 근본 원인
문제 풀 노후화, 그리고 Oracle 전용 문법 문제에 대해 검증된 고정 보기 경로가 없었다.
