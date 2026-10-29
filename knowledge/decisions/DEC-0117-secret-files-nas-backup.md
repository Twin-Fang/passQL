---
type: decision
id: DEC-0117
created: 2026-10-15
reviewed: null
topics: [ci-deploy, security]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0258-github-secret-synology-backup]]", "[[ISS-0258-github-secret-synology-backup-report]]"]
---

# DEC-0117: GitHub Secret 파일은 main push마다 시놀로지에 백업하고, 새 키는 로컬·Secret·백업 블록을 한 번에 등록한다

## 문제 정의 (Context)
GitHub Secret은 값을 다시 읽을 수 없는데 서명 키·인증서 원본이 Secret에만 있었다 (GitHub #452).

## 결정 (Decision)
- `PROJECT-COMMON-SYNOLOGY-SECRET-FILE-UPLOAD.yaml`이 main push(또는 수동 실행) 때마다 파일형 Secret을 `(NAS 경로 생략)`에 최신본과 타임스탬프본으로 저장한다. `*_BASE64`는 원래 파일로 풀어 저장, 권한 600.
- 비밀번호·ID처럼 파일이 아닌 값은 백업 대상에서 뺀다.
- 키 보관 규칙: 새 키·인증 파일을 만들면 `~/Downloads` 사본, GitHub Secret 등록, `save_secret` 블록 추가까지 한 번에 처리한다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- Secret을 잃어도 NAS에서 원본 파일 복구 가능.

**부정**
- 원격 셸 한 줄 한계(약 128KB) 때문에 큰 바이너리 Secret을 더 늘리면 넘을 수 있다.
- 타임스탬프 폴더가 실행마다 쌓이고 자동 정리 로직이 없다.

## 영향 범위 (Scope)
`.github/workflows/PROJECT-COMMON-SYNOLOGY-SECRET-FILE-UPLOAD.yaml`, GitHub Secret 목록, 시놀로지 `github_secret/` 폴더. 이후 GitHub #456(App Distribution 서비스 계정), #467(APNs 인증서)도 이 워크플로에 추가됐다.

## 출처 (References)
- GitHub #452 이슈 본문, 구현 보고서 댓글 (2026-10-15)
