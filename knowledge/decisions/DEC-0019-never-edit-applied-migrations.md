---
type: decision
id: DEC-0019
created: 2026-04-07
reviewed: null
topics: [ops-infra]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0013-flyway-missing-tables-seed]]", "[[ISS-0015-gemini-primary-ollama-fallback-report]]"]
---

# DEC-0019: 기존 Flyway 마이그레이션은 수정하지 않고 `version.yml` 기준 새 버전 파일로 추가, 시드는 멱등

## 문제 정의 (Context)
누락 테이블과 시드를 추가해야 했다 (GitHub #10). `hibernate.ddl-auto: update`를 병행하는 상태였다.

## 결정 (Decision)
- 기존 마이그레이션 파일은 절대 수정하지 않고 `version.yml` 기준 새 버전 파일로 추가한다. 파일명은 `V{version}__{설명}.sql`(점은 언더스코어).
- 시드 INSERT는 대상 테이블이 존재할 때만 실행되도록 가드한다 (`information_schema.tables` 분기 또는 `INSERT ... ON DUPLICATE KEY`로 멱등성).
- 누락 테이블은 `CREATE TABLE IF NOT EXISTS`로 만들어 `ddl-auto: update`와 충돌하지 않게 한다.
- Entity 컬럼/제약과 마이그레이션 SQL을 1:1로 맞춘다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 이슈 본문: 재기동 시 중복 적재 없이 정상 부팅(멱등성).

**부정**
- 논의 기록 없음.
- (원본 기록) GitHub #16 리포트는 이후 `flyway.validate-on-migrate: false`를 "마이그레이션 파일 수정 시 체크섬 충돌 방지" 목적으로 추가했고, 체크섬 검증이 생략되므로 운영 적용 전 주의가 필요하다고 적었다.

## 영향 범위 (Scope)
`server/PQL-Web/src/main/resources/db/migration/`, `version.yml`, `server/CLAUDE.md` 마이그레이션 이력 표.

## 출처 (References)
- GitHub #10 이슈 본문 「현재 문제점」·「해결 방안」·「선행 의존」
- GitHub #16 `## 개요` 리포트 댓글 「설정」·「주의사항」
