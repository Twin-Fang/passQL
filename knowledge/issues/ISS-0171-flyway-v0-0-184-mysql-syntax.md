---
type: issue
id: ISS-0171
created: 2026-06-16
topics: [ops-infra]
symptoms: [Flyway, "V0_0_184__daily_set.sql", PSQLException, "syntax error at or near \"IF\"", flywayInitializer, "부팅 실패", "MySQL 문법", "DROP INDEX IF EXISTS"]
root_cause: "`V0_0_184__daily_set.sql`이 MySQL 방언으로 작성되어 PostgreSQL에서 문법 오류, Flyway 단계에서 부팅 실패"
status: resolved
resolution: "[[ISS-0171-flyway-v0-0-184-mysql-syntax-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/324"
---

# ISS-0171: Flyway `V0_0_184` MySQL 문법으로 PostgreSQL 부팅 실패

GitHub #324 (원본: 이슈 본문과 2026-10-07 댓글).

## 증상
Spring Boot 부팅이 `flywayInitializer` 빈 생성 단계에서 실패한다.
```
ERROR o.f.core.internal.command.DbMigrate : Migration of schema "public" to version "0.0.184 - daily set" failed!
Caused by: org.postgresql.util.PSQLException: ERROR: syntax error at or near "IF"
  Position: 103
Location : db/migration/V0_0_184__daily_set.sql
```

## 재현 조건
로컬/dev 프로필 기동 → Flyway가 `0.0.184 - daily set` 마이그레이션 시도 → `ALTER TABLE ... DROP INDEX IF EXISTS` 파싱 오류. 환경: PostgreSQL 18.1, Spring Boot 3.4.4, Flyway 10.20.1.

## 조사 기록
- 2026-06-16: MySQL 방언 구문 목록 — `ALTER TABLE ... DROP INDEX IF EXISTS`, `ADD COLUMN ... AFTER xxx`, `ADD CONSTRAINT IF NOT EXISTS`, `DATETIME(6)`, `CHAR(36)` UUID(프로젝트는 V0_0_70에서 네이티브 `UUID`로 통일), 테이블 내부 `UNIQUE KEY`/`INDEX`.
- 기대: `daily_challenge`의 날짜 단독 유니크를 `(challenge_date, sort_order)` 복합 유니크로 교체, `daily_set_submission` 테이블 생성.
- 2026-10-02: 운영 502 장애 조사에서 #324는 수정 커밋이 이미 main에 있어 그 장애 원인이 아니라고 확인(GitHub #337).

## 근본 원인
운영 DB는 PostgreSQL이고 다른 마이그레이션은 모두 PostgreSQL 방언인데 이 파일만 MySQL 방언으로 작성됐다.
