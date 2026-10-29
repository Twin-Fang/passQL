---
type: issue
id: ISS-0258
created: 2026-10-15
topics: [ci-deploy, security]
symptoms: [GitHub Secret 값 재조회 불가, Secret 파일 백업 없음, ".p8 재다운로드 불가", PROJECT-COMMON-SECRET-FILE-UPLOAD, "my-project"]
root_cause: "서명 키·서비스 계정·설정 파일이 GitHub Secret에만 있고, 기존 백업 워크플로는 백엔드 파일 3개만 백업했다"
status: resolved
resolution: "[[ISS-0258-github-secret-synology-backup-report]]"
related: ["[[DEC-0117-secret-files-nas-backup]]", "[[ISS-0257-ios-review-reject-apple-sign-in]]"]
source: "https://github.com/Twin-Fang/passQL/issues/452"
---

# ISS-0258: GitHub Secret 파일의 원본 백업이 없어 잃으면 복구 불가

GitHub #452 (원본: 이슈 본문과 구현 보고서 댓글).

## 증상
서명 키, 서비스 계정, 설정 파일이 GitHub Secret에만 있고 원본 백업은 흩어져 있다. Secret은 값을 다시 읽을 수 없어 로컬 사본을 잃으면 복구할 수 없다. Apple `.p8` 키처럼 다시 받을 수 없는 파일도 있다(GitHub #451의 Sign in with Apple 키). `PROJECT-COMMON-SECRET-FILE-UPLOAD.yaml` 템플릿은 커밋되지 않았고 프로젝트명이 기본값(`my-project`), 백업 대상도 2개뿐.

## 재현 조건
해당 없음 (운영 위험).

## 조사 기록
- 2026-10-15: 구현 보고서 기준 실제로 쓰던 워크플로는 `PROJECT-COMMON-SYNOLOGY-SECRET-FILE-UPLOAD.yaml`이며 백엔드 파일 3개만 백업. 기존 메타데이터 목록에 업로드된 `FIREBASE_SERVICE_ACCOUNT_JSON`이 빠져 있었다.

## 근본 원인
frontmatter `root_cause`와 같음.
