---
type: completion-report
id: ISS-0140
created: 2026-04-13
topics: [ops-infra, dev-workflow]
status: resolved
resolves: "[[ISS-0140-e2e-db-user-data-truncate-doc]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/259"
---

# ISS-0140 완료 리포트: 유저 데이터 15개 테이블 TRUNCATE, seed 테이블 보존

GitHub #259 `## 개요` 리포트 댓글(2026-04-13) 기준.

## 해결 방법
로컬 PostgreSQL(`passql_app`, 22개 테이블)에서 유저 생성 데이터만 초기화했다.
- seed 판별: 마이그레이션 SQL에서 `INSERT INTO` 대상 추출 → `app_setting`, `prompt_template`, `topic`, `exam_schedule`. 추가 보존: `subtopic`, `concept_tag`(관리자 등록 기준 데이터), `flyway_schema_history`.
- TRUNCATE 대상 15개: `member`, `member_suspend_history`, `submission`, `execution_log`, `quiz_session`, `feedback`, `question`, `question_choice`, `question_choice_set`, `question_choice_set_item`, `question_concept_tag`, `question_report`, `question_report_category`, `concept_doc`, `daily_challenge`. 한 번의 `TRUNCATE TABLE ... CASCADE;`.
- 검증: `pg_stat_user_tables`의 `n_live_tup`로 15개 모두 `row_count = 0` 확인.

## 근본 원인 (확정)
해당 없음 (문서 부재).

## 재발 방지
리포트 주의사항: prod 적용 시 반드시 백업 후 실행. `CASCADE`는 15개 외 연관 테이블도 지울 수 있어 새 테이블 추가 시 대상 목록 재검토. seed 테이블은 절대 포함하지 않는다.

## 교훈
논의 기록 없음.
