---
type: completion-report
id: ISS-0487
created: 2026-11-07
topics: [ci-deploy, ops-infra, security]
status: resolved
resolves: "[[ISS-0487-synology-secret-upload-ssh-handshake-flaky]]"
related: ["[[ISS-0258-github-secret-synology-backup-report]]"]
source: "https://github.com/Twin-Fang/passQL/issues/950"
---

# ISS-0487 완료 리포트: 시크릿 업로드 SSH 끊김 시 최대 3회 재시도

GitHub #950 구현 보고서 댓글(2026-11-07) 기준.

## 해결 방법
`.github/workflows/PROJECT-COMMON-SYNOLOGY-SECRET-FILE-UPLOAD.yaml`:
- 1차 업로드에 `continue-on-error: true`를 건다. 실패하면 20초 뒤 2차, 다시 실패하면 40초 뒤 3차를 시도한다. 각 단계는 앞 단계의 `outcome == 'failure'`일 때만 실행된다. 3차에는 `continue-on-error`를 걸지 않아, 세 번 모두 실패할 때만 잡이 실패로 표시된다.
- 업로드 입력(약 250줄 스크립트)은 1차 단계의 `with: &secret_upload_inputs` 앵커 하나에만 둔다. 2·3차는 `with: *secret_upload_inputs`로 가져다 쓴다. 새 시크릿을 추가할 때도 1차 단계 한 곳만 고치면 된다.
- 재시도해도 안전한 이유: 스크립트는 같은 `TIMESTAMP` 경로에 덮어쓴다.

## 검증
- 수정 브랜치 수동 실행 run 42362983164 성공 (GitHub의 YAML 앵커 해석 확인).
- main 수동 실행 run 42340337174 성공, NAS `github_secret/backend·ai·app·web` 갱신을 직접 확인.
- 레포 시크릿 33개 모두 업로드 목록에 있음 (누락 없음).

## 남은 일
- 재시도는 증상을 줄일 뿐 공격을 막지 못한다. 같은 NAS로 SSH 배포하는 Spring CICD, PR 미리보기도 같은 영향을 받는다.
- NAS 조치(DSM 자동 차단, SSH 키 인증만 허용)는 사용자 판단으로 남겼다.
- 예전 위치의 `backend/.env`, `backend/ai.env`(10-18)가 NAS에 남아 있다. 지금 워크플로우는 이 파일들을 쓰지 않는다.
