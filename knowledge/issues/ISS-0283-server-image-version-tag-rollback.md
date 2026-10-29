---
type: issue
id: ISS-0283
created: 2026-10-15
topics: [ci-deploy]
symptoms: [이미지 태그 덮어쓰기, 브랜치 이름 태그, 롤백 불가, 이전 버전 이미지 없음]
root_cause: "이미지 태그가 브랜치 이름 하나라 배포마다 같은 태그를 덮어써 이전 버전으로 되돌릴 이미지가 없었다"
status: resolved
resolution: "[[ISS-0283-server-image-version-tag-rollback-report]]"
related: ["[[DEC-0129-image-sha-tags-rollback-dispatch]]", "[[ISS-0296-passql-db-daily-backup]]"]
source: "https://github.com/Twin-Fang/passQL/issues/477"
---

# ISS-0283: 서버 이미지 태그가 덮어써져 롤백할 이미지가 없음

GitHub #477 (원본: 이슈 본문, 구현 보고서 댓글).

## 증상
이미지 태그가 브랜치 이름이라 배포마다 같은 태그를 덮어씀. 이전 버전으로 되돌릴 이미지가 없음.
위치: `.github/workflows/PROJECT-SPRING-SYNOLOGY-PASSQL-CICD.yaml:100,118`.

## 재현 조건
배포 후 이전 버전으로 되돌려야 할 때.

## 조사 기록
- 2026-10-15: 제안 — 버전, sha 태그를 함께 push, 이전 태그로 재배포하는 `workflow_dispatch` 입력과 절차 문서화, DB 백업 절차 확인.

## 근본 원인
frontmatter `root_cause`와 같음.
