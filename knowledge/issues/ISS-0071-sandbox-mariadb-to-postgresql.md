---
type: issue
id: ISS-0071
created: 2026-04-11
topics: [ops-infra, practice]
symptoms: [CHOICE_SET_VALIDATION_NO_CORRECT, "FULL OUTER JOIN", INTERSECT, EXCEPT, MariaDB, detectOracleOnlySyntax, CONCEPT_ONLY]
root_cause: "Sandbox 엔진 MariaDB가 FULL OUTER JOIN 등 SQLD 범위 표준 SQL을 지원하지 않아 선택지 검증이 반복 실패"
status: resolved
resolution: "[[ISS-0071-sandbox-mariadb-to-postgresql-report]]"
related: ["[[DEC-0054-postgresql-sandbox-engine]]"]
source: "https://github.com/Twin-Fang/passQL/issues/122"
---

# ISS-0071: Sandbox DB 엔진 MariaDB → PostgreSQL 전면 전환

GitHub #122 (원본: 이슈 본문과 댓글).

## 증상
Sandbox가 MariaDB라 `FULL OUTER JOIN` 등 표준 SQL을 지원하지 않아 선택지 생성 시 `CHOICE_SET_VALIDATION_NO_CORRECT`가 반복된다. `FULL OUTER JOIN`, `INTERSECT`, `EXCEPT` 등 SQLD 범위 문법을 포함한 선택지를 실행할 수 없어 해당 유형 문제 생성이 불가능. `detectOracleOnlySyntax`가 `FULL OUTER JOIN`을 감지해 `CONCEPT_ONLY`로 강제 전환하는 우회 로직이 있었다.

## 재현 조건
`FULL OUTER JOIN` 등 MariaDB 미지원 문법이 들어간 EXECUTABLE 문제의 선택지 생성.

## 조사 기록
- 2026-04-11: 이슈 본문 — PostgreSQL은 `FULL OUTER JOIN`, `INTERSECT`, `EXCEPT`, `GROUPING SETS`, 윈도우 함수를 지원. Oracle 전용 문법(`CONNECT BY`, `ROWNUM`, `DECODE`, `PIVOT`)은 PG도 미지원이라 감지 로직은 유지하고 `FULL OUTER JOIN`만 목록에서 제거.
- 2026-04-11: "포팅완료 / 정상 기동 확인" 댓글.

## 근본 원인
Sandbox 엔진(MariaDB)의 표준 SQL 지원 범위가 SQLD 출제 범위보다 좁았다.
