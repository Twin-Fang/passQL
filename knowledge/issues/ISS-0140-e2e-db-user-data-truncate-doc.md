---
type: issue
id: ISS-0140
created: 2026-04-13
topics: [ops-infra, dev-workflow]
symptoms: ["E2E DB 초기화", TRUNCATE, "seed 데이터 보존", passql_app, "TRUNCATE 대상 판단"]
root_cause: "E2E 전 DB 초기화 표준 절차와 TRUNCATE/보존 테이블 기준이 문서화되지 않음"
status: resolved
resolution: "[[ISS-0140-e2e-db-user-data-truncate-doc-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/259"
---

# ISS-0140: E2E 테스트용 DB 유저 데이터 초기화 절차가 없음

GitHub #259 (원본: 이슈 본문과 리포트 댓글).

## 증상
E2E 전체 테스트 전에 로컬/prod DB를 초기화하는 표준 절차가 없다. 어떤 테이블을 비우고 어떤 seed 테이블을 보존할지 기준이 없어, 새 테이블이 생길 때마다 수동 판단해야 한다.

## 재현 조건
해당 없음 (문서화).

## 조사 기록
- 2026-04-13: 참조 문서 `.report/` `20260413_#E2E_로컬_DB_유저데이터_TRUNCATE_분석_및_SQL문서.md`.

## 근본 원인
해당 없음 (문서 부재).
