---
type: issue
id: ISS-0120
created: 2026-04-13
topics: [community, ops-infra]
symptoms: ["operator does not exist: character = uuid", "500", "GET /api/feedback/me", "CHAR(36)", V0_0_115__add_feedback_table.sql, Hibernate 6, "uuid 타입 불일치"]
root_cause: "V0_0_115가 feedback_uuid·member_uuid를 PostgreSQL uuid가 아닌 CHAR(36)으로 만들어 Hibernate 6의 uuid 바인딩과 타입이 어긋났다"
status: resolved
resolution: null
related: ["[[ISS-0113-feedback-api-implementation]]", "[[ISS-0119-flyway-migration-idempotency-rule]]"]
source: "https://github.com/Twin-Fang/passQL/issues/218"
---

# ISS-0120: feedback UUID 컬럼 `CHAR(36)` vs PostgreSQL `uuid` 불일치로 500

GitHub #218 (원본: 이슈 본문만. 라벨 긴급. 완료 댓글 없음).

## 증상
`GET /api/feedback/me` → HTTP 500.
```
ERROR: operator does not exist: character = uuid
Hint: No operator matches the given name and argument types.
      You might need to add explicit type casts.
```

## 재현 조건
`V0_0_115` 적용 DB에서 서버 실행 → `GET /api/feedback/me` 호출. 환경: Linux 운영 서버, Spring Boot 3.4.4 / Hibernate 6.6.11 / PostgreSQL.

## 조사 기록
- 2026-04-13: 이슈 등록. 원인 파일 `V0_0_115__add_feedback_table.sql`, 수정 마이그레이션 `V0_0_119__fix_feedback_uuid_column_types.sql`, 트러블슈팅 보고서 `.report/20260413_#200_feedback_uuid_CHAR36_PostgreSQL_타입불일치_500오류.md`가 관련 파일로 적혀 있다. GitHub #200 댓글(2026-04-13)이 "#218 해당 문제가 발견되어 수정중"이라고 적었다. 수정 완료 기록은 원본에 없다(completed로 닫힘).
- 같은 날 GitHub #217이 이 수정 마이그레이션 초안의 멱등성 문제를 다뤘다.

## 근본 원인
이슈 본문 기준: `V0_0_115`가 UUID 컬럼을 `CHAR(36)`으로 생성. Hibernate 6은 Java `UUID`를 PostgreSQL `uuid`로 바인딩하므로 `character = uuid` 비교 연산자가 없다.
