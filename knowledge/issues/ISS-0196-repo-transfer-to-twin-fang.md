---
type: issue
id: ISS-0196
created: 2026-10-07
topics: [ci-deploy, dev-workflow]
symptoms: [레포 이전, passQL-Lab, Twin-Fang, 조직 시크릿 미이전, DOCKERHUB_USERNAME, 레포 주소 변경]
root_cause: "GitHub Transfer는 조직 시크릿을 옮기지 않아 새 레포에 다시 등록해야 했다"
status: resolved
resolution: "[[ISS-0196-repo-transfer-to-twin-fang-report]]"
related: ["[[DEC-0098-move-repo-to-twin-fang]]"]
source: "https://github.com/Twin-Fang/passQL/issues/351"
---

# ISS-0196: 레포 조직 이전 — passQL-Lab → Twin-Fang

GitHub #351 (원본: 이슈 본문과 댓글).

## 증상
레포를 passQL-Lab 조직에서 Twin-Fang 조직으로 옮기면서 CI/CD 시크릿, 코드 안의 레포 주소, 로컬 설정이 새 위치를 가리키도록 맞춰야 한다.

## 재현 조건
해당 없음 (작업 이슈).

## 조사 기록
- 2026-10-07: GitHub Transfer로 `passQL-Lab/passQL` → `Twin-Fang/passQL` 이전 (이슈·PR·릴리스·레포 시크릿 16개·환경 Preview/Production 유지 확인).
- 따라오지 않는 passQL-Lab 조직 시크릿 5개(`DOCKERHUB_USERNAME`/`TOKEN`, `SERVER_HOST`/`USER`/`PASSWORD`)를 새 레포 시크릿으로 등록 (`_GITHUB_PAT_TOKEN`은 Twin-Fang 조직 시크릿 사용).
- 코드 참조 변경: 서버 건의사항 이슈 링크(`application.yml`), 시크릿 등록 스크립트, `client/CLAUDE.md`. 로컬 git remote, projectops 설정 레포 목록 변경.

## 근본 원인
해당 없음 (작업 이슈). 조직 시크릿은 Transfer로 옮겨지지 않는다(원본 기록).
