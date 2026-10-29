---
type: completion-report
id: ISS-0071
created: 2026-04-11
topics: [ops-infra, practice]
status: resolved
resolves: "[[ISS-0071-sandbox-mariadb-to-postgresql]]"
related: ["[[DEC-0054-postgresql-sandbox-engine]]"]
source: "https://github.com/Twin-Fang/passQL/issues/122"
---

# ISS-0071 완료 리포트: PostgreSQL 전환, UUID native 타입, JSONB 바인딩

GitHub #122 리포트 댓글과 "포팅완료 / 정상 기동 확인" 댓글 기준 (2026-04-11).

## 해결 방법
- 의존성: `server/PQL-Common/build.gradle` `mariadb-java-client` + `flyway-mysql` → `org.postgresql:postgresql` + `org.flywaydb:flyway-database-postgresql`.
- `SandboxPool.java`: 드라이버 `org.postgresql.Driver`, `CREATE/DROP DATABASE`를 `autoCommit=true`로 실행(PG 필수), admin DB `mysql` → `postgres`. `SandboxDataSourceConfig.java` 드라이버 교체.
- `Dialect.java`에 `POSTGRESQL`, `QuestionGenerateService` 기본값 `Dialect.POSTGRESQL`. `translateOracleToMariaDb()` → `translateOracleToPostgres()`(NVL → COALESCE, SYSDATE → NOW()), `detectOracleOnlySyntax()`에서 FULL OUTER JOIN 제거. `AdminQuestionController` 호출 3곳 수정.
- Entity: Hibernate 6 `UUIDJdbcType`이 PG native `uuid`를 기대해 `@Column(columnDefinition = "CHAR(36)")` 전체 제거. JSONB 필드 5곳에 `@JdbcTypeCode(SqlTypes.JSON)` 추가(`column is of type jsonb but expression is of type character varying` 해소).
- Flyway: 기존 마이그레이션 V0_0_11 ~ V0_0_64를 PG 호환으로 직접 변환(`TINYINT(1)` → `BOOLEAN`, `AUTO_INCREMENT` → `GENERATED ALWAYS AS IDENTITY`, `JSON` → `JSONB`, `ON DUPLICATE KEY UPDATE` → `ON CONFLICT DO UPDATE` 등, `V0_0_12`의 `VARUUID` 오타 수정). 신규 `V0_0_70__convert_uuid_char_to_native.sql`(FK 17개 DROP → `ALTER COLUMN ... TYPE uuid USING col::uuid` 40개 → FK 재등록), `V0_0_69__add_sandbox_sql_max_length_setting.sql`.
- 서버 초기 설정: `passql_app` DB, `sqld_runner` 유저 `CREATEDB` 권한.

## 근본 원인 (확정)
MariaDB가 SQLD 범위 표준 SQL을 지원하지 않았다. 전환 중 UUID 타입 정합성과 JSONB 바인딩 문제가 추가로 드러났다.

## 재발 방지
리포트 주의사항:
- 기존 마이그레이션(V0_0_11 ~ V0_0_64)을 직접 수정했으므로 이미 적용된 DB는 Flyway 체크섬 오류가 난다 — DB 초기화 또는 `flyway repair` 필요.
- `V0_0_70`은 신규 DB에서는 no-op.
- `sqld_runner`에 `CREATEDB` 권한 필요.

## 교훈
리포트 서술: `@Column(columnDefinition = "JSONB")`는 DDL 힌트일 뿐 바인딩 타입에 영향이 없다 — Hibernate 6에서 `String` → `jsonb`는 `@JdbcTypeCode(SqlTypes.JSON)`가 필요하다.
