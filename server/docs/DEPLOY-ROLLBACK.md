# 서버 롤백 배포 절차

워크플로: `.github/workflows/PROJECT-SPRING-SYNOLOGY-PASSQL-CICD.yaml` (#477)

## 이미지 태그

빌드마다 Docker Hub `passql-back-back-container`에 태그 3개를 push한다.

| 태그 | 예시 | 용도 |
|------|------|------|
| `{브랜치}` | `deploy` | 최신 빌드 (덮어씀) |
| `{version.yml 버전}` | `0.10.0` | 릴리스 버전 기준 롤백 |
| `sha-{커밋 7자리}` | `sha-1a2b3c4` | 정확한 커밋 기준 롤백 (일반 배포도 이 태그로 기동) |

같은 버전으로 두 번 배포하면 버전 태그는 나중 빌드로 덮인다. 정확히 되돌릴 때는 sha 태그를 쓴다.

## 롤백 방법

1. 되돌릴 태그 확인
   - Actions 실행 로그 `이미지 태그 계산` 단계의 `🏷️` 줄
   - 또는 NAS에서 지금 떠 있는 이미지: `docker ps --filter name=passql-back --format '{{.Names}} {{.Image}}'`
2. GitHub > Actions > `PROJECT-SPRING-SYNOLOGY-CICD` > Run workflow
3. `rollback_image_tag`에 태그 입력 후 실행 (비우면 일반 빌드·배포)
4. 빌드는 건너뛰고 기존 Blue-Green 절차(새 색 기동 > 헬스체크 > 구 색 정리)로 전환된다. 헬스체크 실패 시 구 색이 그대로 서비스한다.

## DB 주의

- Flyway 마이그레이션은 되돌리지 않는다. 옛 이미지는 DB의 더 높은 버전 이력을 무시하고 기동한다(`ignore-migration-patterns` 기본 `*:future`).
- 옛 코드가 새 스키마에서 동작하는지 확인한다. 컬럼 삭제·이름 변경·NOT NULL 추가가 들어간 릴리스는 이미지 롤백만으로 복구되지 않는다 > DB 백업 복원 검토.

## DB 백업 확인

NAS 작업 스케줄러가 `/volume1/projects/suh-project/bin/backup_postgres.sh <DB명>`을 돌려
`/volume1/projects/backup/postgres/<DB명>/<DB명>_yyyyMMdd_HHmmss.sql.gz`에 남긴다.

```bash
# 등록된 백업 작업 (cron > synoschedtask id)
sudo grep synoschedtask /etc/crontab
sudo grep -E '^(name|state)=' /usr/syno/etc/synoschedule.d/root/*.task
# 최근 백업 파일
sudo ls -lt /volume1/projects/backup/postgres/
```

2026-10-15 확인: 백업 작업은 romrom(활성)·tripgether(비활성)만 있고 passQL DB 백업 작업은 없음.
롤백 전에 수동 덤프를 남기거나 백업 작업을 먼저 등록한다.
