---
type: completion-report
id: ISS-0258
created: 2026-10-15
topics: [ci-deploy, security]
status: resolved
resolves: "[[ISS-0258-github-secret-synology-backup]]"
related: ["[[DEC-0117-secret-files-nas-backup]]"]
source: "https://github.com/Twin-Fang/passQL/issues/452"
---

# ISS-0258 완료 리포트: Secret 파일 12개를 main push마다 시놀로지에 백업

GitHub #452 구현 보고서 댓글(2026-10-15) 기준.

## 해결 방법
`.github/workflows/PROJECT-COMMON-SYNOLOGY-SECRET-FILE-UPLOAD.yaml`:
- Secret당 heredoc 3번 반복을 `save_secret` 함수 하나로 묶음(새 Secret은 3줄 블록 추가).
- `ROLE: backend` 하나 대신 함수 인자로 `backend` / `app` 폴더 선택(기존 `github_secret/backend/` 경로 유지).
- `*_BASE64` Secret은 줄바꿈·공백 제거 후 `base64 -d`로 원래 바이너리로 저장. 모든 파일 `chmod 600`.
- `cicd-gitignore-file.json`을 실제로 저장된 파일만 역할별로 기록.
- 신규 Secret `APPLE_SIWA_KEY_P8` 등록. 백업 대상 12개(backend 4: `APPLICATION_PROD_YML`, `FIREBASE_SERVICE_ACCOUNT_JSON`, `AI_ENV_FILE`, `ENV_FILE` / app 8: `APPLE_SIWA_KEY_P8`, `APP_STORE_CONNECT_API_KEY_BASE64`, `APPLE_CERTIFICATE_BASE64`, `APPLE_PROVISIONING_PROFILE_BASE64`, `GOOGLE_SERVICE_INFO_PLIST_BASE64`, `GOOGLE_SERVICES_JSON`, `RELEASE_KEYSTORE_BASE64`, `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_BASE64`). 파일이 아닌 Secret(`*_PASSWORD`, `*_KEY_ID`, `DOCKERHUB_*`, `VERCEL_*` 등)은 제외.

## 근본 원인 (확정)
이슈 노트와 같음.

## 재발 방지
- 검증: 로컬에서 가짜 Secret으로 스크립트 실행(빈 Secret 2개 스킵, 0~255 바이트 바이너리 `cmp` 일치), Actions run `38667207566` 성공(`저장된 파일 12개`, 스킵 0), 시놀로지 `(NAS 경로 생략)`에 12개·`-rw-------`·타임스탬프 폴더 `2026-10-15_10-43-50` 확인.
- 주의(원본): Secret 값이 ssh-action script 문자열에 들어가 원격 셸 한 줄 한계(약 128KB)가 있음(현재 약 40KB). heredoc 종료 문자열 `__SUH_SECRET_EOF__`는 YAML 들여쓰기(12칸)에 맞춰야 함. `GOOGLE_SERVICES_JSON`은 이름에 `_BASE64`가 없어 원문 저장. main push마다 타임스탬프 폴더가 쌓이고 자동 정리 없음.

## 교훈
원본 키 보관 규칙: 새 키·인증 파일을 만들면 `~/Downloads` 사본, GitHub Secret 등록, 이 워크플로의 `save_secret` 블록 추가까지 한 번에 처리한다.
