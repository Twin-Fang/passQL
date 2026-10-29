---
type: completion-report
id: ISS-0171
created: 2026-10-07
topics: [ops-infra]
status: resolved
resolves: "[[ISS-0171-flyway-v0-0-184-mysql-syntax]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/324"
---

# ISS-0171 완료 리포트: `V0_0_184__daily_set.sql`을 PostgreSQL 방언으로 수정

GitHub #324 이슈 본문 "해결 방안"과 2026-10-07 댓글 기준. `## 개요` 형식 리포트는 없음.

## 해결 방법
`V0_0_184__daily_set.sql`을 PostgreSQL 방언으로 전면 수정(이슈 본문):
- `DROP INDEX IF EXISTS` → `DROP CONSTRAINT IF EXISTS`(UNIQUE 제약이므로)
- `ADD COLUMN ... AFTER` → `AFTER` 절 제거
- `ADD CONSTRAINT IF NOT EXISTS` → `DO $$ ... pg_constraint 존재 확인 ... $$` 멱등 블록
- `DATETIME(6)` → `TIMESTAMP(6)`, `CHAR(36)` → `UUID`
- 테이블 내 `UNIQUE KEY`/`INDEX` → `CONSTRAINT ... UNIQUE` + 별도 `CREATE INDEX`

로컬 PostgreSQL에서 트랜잭션 dry-run(BEGIN → 실행 → ROLLBACK)으로 전 문장 통과 검증. 2026-10-07 댓글: 현재 파일은 PostgreSQL 문법(`DROP CONSTRAINT IF EXISTS`, `ADD COLUMN IF NOT EXISTS`)이고 운영 서버가 이 마이그레이션 이후 정상 기동 중(health 200, 2026-10-07 배포 확인).

## 근본 원인 (확정)
마이그레이션 파일 하나가 MySQL 방언으로 작성됐다.

## 재발 방지
원본에 적혀 있지 않다.

## 교훈
(원본에 없음, 볼트 정리) 새 마이그레이션은 머지 전에 PostgreSQL에서 dry-run(BEGIN → 실행 → ROLLBACK)으로 확인한다.
