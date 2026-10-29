---
type: completion-report
id: ISS-0296
created: 2026-10-15
topics: [ops-infra]
status: resolved
resolves: "[[ISS-0296-passql-db-daily-backup]]"
related: ["[[ISS-0283-server-image-version-tag-rollback]]", "[[DEC-0129-image-sha-tags-rollback-dispatch]]"]
source: "https://github.com/Twin-Fang/passQL/issues/490"
---

# ISS-0296 완료 리포트: NAS 예약 작업 `backup-postgres-passql` 등록(매일 03:15, 30일 보관)

GitHub #490 처리 결과 댓글 기준 (2026-10-15).

## 해결 방법
- NAS 작업 스케줄러에 `backup-postgres-passql`(id 7) 추가: `backup_postgres.sh passql_app`, root, 매일 03:15, 30일 보관, 오류 시 메일 알림. 다음 실행 2026-10-16 03:15.
- 검증: 수동 1회 실행 성공 `passql_app_20261015_170412.sql.gz`(약 165KB), gzip 무결성 검사 통과, 테이블 25개·데이터(COPY) 25개 포함, `member`·`question` 데이터 확인.
- 복구 방법(원본): `zcat passql_app_YYYYMMDD_HHMMSS.sql.gz | sudo docker exec -i postgres psql -U <user> -d <복구용 DB>`.

## 근본 원인 (확정)
이슈 본문과 같음.

## 재발 방지
원본: 운영 DB에 바로 덮어쓰지 말고 복구용 DB에 먼저 풀어 확인한다.

## 교훈
(원본에 없음, 볼트 정리) 롤백 절차를 만들 때 DB 백업이 실제로 돌고 있는지 함께 확인한다.
