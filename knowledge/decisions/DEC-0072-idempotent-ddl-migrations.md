---
type: decision
id: DEC-0072
created: 2026-04-13
reviewed: null
topics: [ops-infra, dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0119-flyway-migration-idempotency-rule]]", "[[ISS-0125-question-report-api-quality-fixes-report]]"]
---

# DEC-0072: Flyway DDL 변경(ALTER·컬럼 추가/삭제/타입 변경)은 멱등하게 — 조건 확인 후 `DO $$` 블록에서 실행

## 문제 정의 (Context)
`V0_0_119__fix_feedback_uuid_column_types.sql` 초안이 안전장치 없는 `ALTER COLUMN ... TYPE UUID`였다. 이미 `uuid`이거나 컬럼이 없으면 오류가 날 수 있고, 같은 패턴이 반복됐다 (GitHub #217).

## 결정 (Decision)
이슈 본문의 규칙:
- DDL 변경(`ALTER`, 컬럼 추가/삭제/타입변경)은 반드시 멱등성을 보장한다.
- 타입 변환은 `DO $$ BEGIN ... END $$;` PL/pgSQL 블록에서 `information_schema.columns`로 현재 타입을 확인하고 조건부 실행(`IF EXISTS ... THEN ... END IF`).
- `server/CLAUDE.md` DB 스키마 규칙과 작업 체크리스트에 "마이그레이션 SQL이 멱등성을 갖는가?" 추가.
이슈는 completed로 닫혔고 댓글은 "유의해서 구현해야합니다"뿐이다. `CLAUDE.md` 반영 여부는 원본에 적혀 있지 않다. 이후 GitHub #227의 `V0_0_126`이 `DO $$` + `IF NOT EXISTS`로 작성됐다.
시드 INSERT 멱등성과 기존 마이그레이션 수정 금지는 기존 결정 DEC-0019에 있고, 이 결정은 그것을 DDL로 넓힌다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 환경마다 스키마 상태가 달라도 마이그레이션이 실패하지 않는다(이슈 본문).

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`server/PQL-Web/src/main/resources/db/migration/`의 신규 마이그레이션 전체, `server/CLAUDE.md`.

## 출처 (References)
- GitHub #217 이슈 본문·댓글 (2026-04-13), GitHub #227 리포트(`V0_0_126`)
- [[ISS-0119-flyway-migration-idempotency-rule]]
