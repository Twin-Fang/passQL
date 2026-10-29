---
type: issue
id: ISS-0296
created: 2026-10-15
topics: [ops-infra]
symptoms: [passQL DB 백업 없음, passql_app, NAS 작업 스케줄러, backup_postgres.sh, Flyway 롤백 불가]
root_cause: "NAS 작업 스케줄러에 다른 프로젝트 백업만 있고 passQL DB(`passql_app`) 백업이 없었다"
status: resolved
resolution: "[[ISS-0296-passql-db-daily-backup-report]]"
related: ["[[ISS-0283-server-image-version-tag-rollback]]", "[[DEC-0129-image-sha-tags-rollback-dispatch]]"]
source: "https://github.com/Twin-Fang/passQL/issues/490"
---

# ISS-0296: passQL DB 일일 자동 백업이 없음

GitHub #490 (원본: 이슈 본문, 처리 결과 댓글).

## 증상
- NAS 작업 스케줄러에 romrom, tripgether 백업만 있고 passQL DB(`passql_app`) 백업이 없었음.
- 롤백(GitHub #477)해도 Flyway 마이그레이션은 되돌려지지 않아, 백업 없이 데이터 복구 수단이 없음.

## 재현 조건
해당 없음(운영 공백).

## 조사 기록
- 2026-10-15: 제안 — 기존 공용 스크립트 `(NAS 경로 생략)`를 `passql_app`으로 실행하는 예약 작업, 매일 03:15(romrom 03:00, mongo 03:30 사이), root 실행, 30일 보관, 실패 시 메일 알림, 저장 위치 `(NAS 경로 생략)`.

## 근본 원인
frontmatter `root_cause`와 같음.
