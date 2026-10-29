---
type: issue
id: ISS-0119
created: 2026-04-13
topics: [ops-infra, dev-workflow]
symptoms: [Flyway, "멱등성", "ALTER COLUMN TYPE", V0_0_119__fix_feedback_uuid_column_types.sql, information_schema.columns, "DO $$"]
root_cause: "마이그레이션 DDL 변경을 안전장치 없이 작성하는 패턴이 반복됐고 CLAUDE.md에 타입 변환 ALTER 작성 가이드가 없었다"
status: resolved
resolution: null
related: ["[[DEC-0072-idempotent-ddl-migrations]]", "[[ISS-0120-feedback-uuid-char36-type-mismatch]]"]
source: "https://github.com/Twin-Fang/passQL/issues/217"
---

# ISS-0119: Flyway 마이그레이션 SQL 멱등성 안전장치 규칙 정립

GitHub #217 (원본: 이슈 본문과 댓글 하나 "유의해서 구현해야합니다").

## 증상
`V0_0_119__fix_feedback_uuid_column_types.sql` 초안이 안전장치 없이 `ALTER TABLE feedback ALTER COLUMN ... TYPE UUID`를 썼다. 이미 `uuid`인 환경이나 컬럼이 없는 환경에서 오류 가능. 신규 마이그레이션에서 멱등성 없는 DDL이 반복되고, `CLAUDE.md` DB 스키마 규칙에 타입 변환 `ALTER` 가이드가 없다.

## 재현 조건
이미 `uuid` 타입이거나 컬럼이 없는 DB에서 해당 마이그레이션 실행.

## 조사 기록
- 2026-04-13: 이슈 등록(GitHub #218 수정 마이그레이션 작성 중). 댓글 "유의해서 구현해야합니다". `CLAUDE.md` 반영 여부와 완료 내용은 원본에 적혀 있지 않다(completed로 닫힘).

## 근본 원인
DDL 멱등성 규칙 부재.
