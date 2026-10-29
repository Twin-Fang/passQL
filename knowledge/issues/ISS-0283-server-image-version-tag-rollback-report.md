---
type: completion-report
id: ISS-0283
created: 2026-10-15
topics: [ci-deploy]
status: resolved
resolves: "[[ISS-0283-server-image-version-tag-rollback]]"
related: ["[[DEC-0129-image-sha-tags-rollback-dispatch]]", "[[ISS-0296-passql-db-daily-backup]]"]
source: "https://github.com/Twin-Fang/passQL/issues/477"
---

# ISS-0283 완료 리포트: 이미지 태그 3개 push와 `rollback_image_tag` 롤백 배포

GitHub #477 구현 보고서 댓글 기준 (1차 통합 main `0bc1ed5`, 서버 0.11.0).

## 해결 방법
- 이미지 태그 3개 push: `{브랜치}`, `{version.yml 버전}`, `sha-{7자리}`. 일반 배포도 sha 태그로 컨테이너 기동.
- `workflow_dispatch` 입력 `rollback_image_tag`: 값이 있으면 빌드를 건너뛰고 그 태그로 Blue-Green 배포(기존 헬스체크·전환 재사용). 입력은 docker 태그 문법으로 검증.
- `server/docs/DEPLOY-ROLLBACK.md`: 롤백 방법, DB 주의사항, 백업 확인.
- NAS에 passQL DB 백업이 없던 것은 GitHub #490에서 일일 백업으로 등록.
- 롤백 방법(원본): Actions에서 `PROJECT-SPRING-SYNOLOGY-CICD`를 Run workflow → `rollback_image_tag`에 태그 입력(예: `0.11.0`, `sha-13fce91`) → 헬스체크 실패 시 기존 컨테이너가 계속 서비스.
- 검증: `actionlint` 경고 없음. 운영 컨테이너가 `passql-back-back-container:sha-13fce91`로 기동.

## 근본 원인 (확정)
이슈 본문과 같음.

## 재발 방지
주의(원본): 롤백해도 Flyway 마이그레이션은 되돌려지지 않으므로 롤백 전에 GitHub #490 백업을 확인한다. 롤백은 이 변경 이후 빌드된 태그로만 할 수 있다.

## 교훈
(원본에 없음, 볼트 정리) 롤백 경로는 이미지만으로 끝나지 않는다. 스키마 변경이 있었던 배포는 DB 백업 확인이 먼저다.
