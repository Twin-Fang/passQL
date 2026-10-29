---
type: issue
id: ISS-0056
created: 2026-04-11
topics: [question-bank, admin]
symptoms: ["sandboxStatus: FAIL", NVL, SYSDATE, "CONNECT BY", ROWNUM, "FROM DUAL", "Duplicate entry for key 'PRIMARY'", passql_sandbox, "lastIndexOf(\"/\")", "serverTimezone=Asia/Seoul", "/admin/questions/import/validate"]
root_cause: "Oracle 문법 치환·전환 처리가 없어 모든 Oracle 문법 문제가 FAIL이었고, SandboxPool이 JDBC URL 쿼리 파라미터 안의 '/'를 DB명 경계로 잘못 잡아 신규 sandbox DB 대신 기존 passql_sandbox DB에 연결했다"
status: resolved
resolution: "[[ISS-0056-oracle-dialect-bulk-import-sandbox-fail-report]]"
related: ["[[DEC-0046-oracle-sql-translate-or-concept-only]]"]
source: "https://github.com/Twin-Fang/passQL/issues/100"
---

# ISS-0056: SQLD 기출 벌크 임포트가 Oracle 방언과 Sandbox URL 파싱 버그로 대량 FAIL

GitHub #100 (원본: 이슈 본문(문제 JSON 예시 포함)과 댓글). 제목의 카테고리는 `[물건등록]`으로 적혀 있다.

## 증상
SQLD 기출 문제 JSON을 `/admin/questions/import/validate`로 검증하면 다수가 `FAIL`. 실패 메시지에 `NVL`, `SYSDATE`, `CONNECT BY`, `ROWNUM`, `FROM DUAL` 등 Oracle 전용 문법에 의한 MariaDB 실행 오류가 보인다. 1:1 치환 가능한 문법과 근본적으로 실행 불가한 문법이 구분되지 않는다. 수정 후에도 `DDL 적용 실패: Duplicate entry '10' for key 'PRIMARY'`가 15건 이상 이어졌다.

## 재현 조건
SQLD 기출 JSON 벌크 임포트 검증. 로컬 MariaDB에서 같은 SQL 직접 실행 시 같은 오류.

## 조사 기록
- 2026-04-11: 첫 리포트 — Oracle → MariaDB 2단계 처리 도입.
- 2026-04-11: "지속적인 문제 파악 원인을 파악합니다" 후 두 번째 리포트 — JDBC URL `jdbc:mariadb://127.0.0.1:3306/passql_sandbox?useSSL=false&characterEncoding=UTF-8&serverTimezone=Asia/Seoul`에서 `urlTemplate.lastIndexOf("/")`가 `Asia/Seoul`의 `/`를 가리켜 URL이 깨졌고, 드라이버가 기존 `passql_sandbox`에 연결해 PRIMARY KEY 충돌.
- 2026-04-11: "정상 작동 확인" 댓글.

## 근본 원인
방언 처리 부재와 `SandboxPool.createDataSource()`·`buildAdminDataSource()`의 URL 파싱 버그, 두 가지.
