---
type: decision
id: DEC-0129
created: 2026-10-15
reviewed: null
topics: [ci-deploy]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0283-server-image-version-tag-rollback]]", "[[ISS-0296-passql-db-daily-backup]]"]
---

# DEC-0129: 서버 이미지는 브랜치·버전·`sha-` 태그 3개로 push하고, 롤백은 `rollback_image_tag` 입력으로 기존 Blue-Green 재사용

## 문제 정의 (Context)
이미지 태그가 브랜치 이름 하나라 배포마다 덮어써서 이전 버전으로 되돌릴 이미지가 없었다 (GitHub #477).

## 결정 (Decision)
- 이미지 태그 3개 push: `{브랜치}`, `{version.yml 버전}`, `sha-{7자리}`. 일반 배포도 sha 태그로 기동.
- `workflow_dispatch` 입력 `rollback_image_tag`가 있으면 빌드 없이 그 태그로 Blue-Green 배포(헬스체크·전환 재사용).
- 절차는 `server/docs/DEPLOY-ROLLBACK.md`.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 헬스체크 실패 시 기존 컨테이너가 계속 서비스하는 Blue-Green 흐름을 롤백에도 그대로 쓴다.

**부정**
- 롤백해도 Flyway 마이그레이션은 되돌려지지 않는다(DB 백업 GitHub #490 확인 필요).
- 이 변경 이전에 빌드된 이미지로는 롤백할 수 없다.

## 영향 범위 (Scope)
`.github/workflows/PROJECT-SPRING-SYNOLOGY-PASSQL-CICD.yaml`, `server/docs/DEPLOY-ROLLBACK.md`, 운영 컨테이너 이미지 태그.

## 출처 (References)
- GitHub #477 이슈 본문, 구현 보고서 댓글(2026-10-15)
- [[ISS-0283-server-image-version-tag-rollback]]
