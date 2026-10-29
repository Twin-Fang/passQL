---
type: issue
id: ISS-0013
created: 2026-04-07
topics: [ops-infra]
symptoms: [Flyway, "member 테이블 누락", question_concept_tag, "시드 데이터 없음", app_setting, prompt_template, "ddl-auto update"]
root_cause: "기존 마이그레이션(`V0_0_11`, `V0_0_12`)에 `member`·`question_concept_tag` 테이블과 운영 시드가 없었다"
status: resolved
resolution: "[[ISS-0013-flyway-missing-tables-seed-report]]"
related: ["[[DEC-0019-never-edit-applied-migrations]]", "[[DEC-0012-nickname-via-suh-random-engine]]"]
source: "https://github.com/Twin-Fang/passQL/issues/10"
---

# ISS-0013: Flyway V0_0_15 누락 테이블 및 초기 시드 데이터 추가

GitHub #10 (원본: 이슈 본문과 댓글).

## 증상
`V0_0_11__init_schema.sql`, `V0_0_12__add_submission_tables.sql`에 `member` 테이블과 `question_concept_tag`가 없었다. `app_setting`, `prompt_template`, `topic` 시드가 없어 빈 DB로는 정상 동작이 불가능했다. `hibernate.ddl-auto: update`를 병행하지만 핵심 테이블·제약·시드는 Flyway로 명시 관리해야 한다고 적었다.
제안: `version.yml` 현재 버전(`0.0.15`) 기준 새 파일(`V0_0_15__add_member_and_concept_tag_tables.sql`, `V0_0_15__seed_initial_data.sql`), `CREATE TABLE IF NOT EXISTS`, 시드 INSERT는 대상 테이블 존재 가드 또는 `ON DUPLICATE KEY`로 멱등. `app_setting` 13개(PRD 12개 + `exam.target_date = 2026-05-31`, `ratelimit.execute.per_minute` = `90`), `prompt_template` 3종 v1(`explain_error`, `diff_explain`, `similar`), `topic` 8~10개. `nickname_word` 테이블/시드는 불필요(라이브러리 일원화).

## 재현 조건
빈 DB로 부팅 → 시드가 없어 정상 동작 불가 (이슈 본문).

## 조사 기록
- 2026-04-08: "Stable 적용 완료" 댓글.

## 근본 원인
초기 마이그레이션에 해당 테이블과 시드가 빠져 있었다 (이슈 본문). 왜 빠졌는지는 원본에 적혀 있지 않다.
