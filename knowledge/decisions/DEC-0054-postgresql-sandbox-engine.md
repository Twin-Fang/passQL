---
type: decision
id: DEC-0054
created: 2026-04-11
reviewed: null
topics: [ops-infra, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0071-sandbox-mariadb-to-postgresql]]", "[[ISS-0071-sandbox-mariadb-to-postgresql-report]]", "[[DEC-0019-never-edit-applied-migrations]]"]
---

# DEC-0054: Sandbox(와 앱 datasource) DB 엔진을 MariaDB에서 PostgreSQL로 전면 전환

## 문제 정의 (Context)
MariaDB가 `FULL OUTER JOIN`, `INTERSECT`, `EXCEPT` 등 SQLD 범위 표준 SQL을 지원하지 않아 선택지 생성 시 `CHOICE_SET_VALIDATION_NO_CORRECT`가 반복됐고, `FULL OUTER JOIN`을 `CONCEPT_ONLY`로 강제 전환하는 우회 로직이 있었다 (GitHub #122).

## 결정 (Decision)
Sandbox 실행 엔진을 PostgreSQL로 바꾼다. 의존성·`application-prod.yml`/`application-dev.yml`의 datasource·sandbox URL과 드라이버를 PostgreSQL로 바꾸고 Flyway 마이그레이션 전체를 PG 문법으로 변환한다. Oracle 전용 문법(`CONNECT BY`, `ROWNUM`, `DECODE`, `PIVOT`) 감지 로직은 유지하고 `FULL OUTER JOIN`만 감지 목록에서 뺀다.

## 검토한 대안 (Alternatives)
- MariaDB 유지 + `CONCEPT_ONLY` 강제 전환 우회: 이슈 본문은 "근본 해결이 필요"하다고 적었다. 그 밖의 엔진 후보 비교는 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- PostgreSQL은 `FULL OUTER JOIN`, `INTERSECT`, `EXCEPT`, `GROUPING SETS`, 윈도우 함수를 지원(이슈 본문).

**부정**
- 기존 마이그레이션(V0_0_11 ~ V0_0_64)을 직접 수정해, 이미 적용된 DB는 Flyway 체크섬 오류 → DB 초기화 또는 `flyway repair` 필요.
- UUID(`CHAR(36)` → native `uuid`, `V0_0_70`)와 JSONB 바인딩(`@JdbcTypeCode(SqlTypes.JSON)`) 정비가 함께 필요했다.
- `sqld_runner` 유저에 `CREATEDB` 권한 필요.

## 영향 범위 (Scope)
`PQL-Common/build.gradle`, `SandboxPool`, `SandboxDataSourceConfig`, `Dialect`, `QuestionGenerateService`, `QuestionImportExportService`, `AdminQuestionController`, 전체 Entity(UUID·JSONB), `db/migration` 전체, 운영 PostgreSQL 서버 설정.

## 출처 (References)
- GitHub #122 이슈 본문, 리포트 댓글, "포팅완료 / 정상 기동 확인" 댓글 (2026-04-11)
- [[ISS-0071-sandbox-mariadb-to-postgresql]]
