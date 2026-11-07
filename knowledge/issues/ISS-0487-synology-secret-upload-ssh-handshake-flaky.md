---
type: issue
id: ISS-0487
created: 2026-11-07
topics: [ci-deploy, ops-infra, security]
symptoms: ["ssh: handshake failed: EOF", "connection reset by peer", "appleboy/ssh-action", PROJECT-COMMON-SYNOLOGY-SECRET-FILE-UPLOAD, "NAS SSH 2022", "SSH 무차별 대입", "간헐 실패"]
root_cause: "NAS SSH(2022) 무차별 대입 시도가 시간당 약 100건에서 약 1,900건으로 급증해, sshd가 인증 전 연결을 끊으면서 GitHub Actions 정상 접속도 끊김"
status: resolved
resolution: "[[ISS-0487-synology-secret-upload-ssh-handshake-flaky-report]]"
related: ["[[ISS-0258-github-secret-synology-backup]]"]
source: "https://github.com/Twin-Fang/passQL/issues/950"
---

# ISS-0487: 시놀로지 시크릿 업로드 워크플로우 SSH 핸드셰이크 간헐 실패

GitHub #950 (https://github.com/Twin-Fang/passQL/issues/950).

## 증상
- main push로 실행되는 `PROJECT-COMMON-SYNOLOGY-SECRET-FILE-UPLOAD`가 2026-11-07에 3번 실패함(13:00, 13:37, 18:47 KST). 그 전 10-29~11-06 사이에는 65번 실행 중 실패가 0번이었음.
- 실패한 단계는 업로드 스크립트가 시작되기 전인 SSH 연결 단계: `ssh: handshake failed: EOF`, `... read: connection reset by peer`.
- 워크플로우 파일은 10월 이후 바뀌지 않았음.

## 근본 원인
NAS `auth.log` 시간별 집계 결과, 존재하지 않는 계정으로 로그인하려는 실패가 평소 시간당 60~130건이었다. 2026-11-07 07시(KST)부터는 약 1,900건으로 급증했다. 여러 해외 IP가 계정 이름을 바꿔 가며 시도하는 무차별 대입이다. 인증 전 동시 접속이 많아지면 sshd가 새 연결을 무작위로 끊는데, 이때 GitHub Actions의 정상 접속도 함께 끊긴다. main 병합 순간에는 PR 미리보기 정리 워크플로우도 같은 NAS에 동시에 접속하므로 끊길 확률이 더 높아진다.

## 재현 조건
SSH 공격이 이어지는 동안 main push로 NAS SSH 접속. 연결마다 무작위로 끊기므로 매번 재현되지는 않는다.
