---
type: decision
id: DEC-0098
created: 2026-10-07
reviewed: null
topics: [ci-deploy, dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0196-repo-transfer-to-twin-fang]]", "[[ISS-0196-repo-transfer-to-twin-fang-report]]"]
---

# DEC-0098: 레포를 `Twin-Fang/passQL`로 옮기고, 구 passQL-Lab 조직은 백업 후 삭제

## 문제 정의 (Context)
레포가 passQL-Lab 조직에 있었다. 옮겨야 한다는 것만 적혀 있고 이유는 원본에 없다 (GitHub #351).

## 결정 (Decision)
- GitHub Transfer로 `passQL-Lab/passQL` → `Twin-Fang/passQL`로 이전한다.
- 따라오지 않는 조직 시크릿 5개는 새 레포 시크릿으로 등록하고, `_GITHUB_PAT_TOKEN`은 Twin-Fang 조직 시크릿을 쓴다.
- passQL-Lab에 남은 구 앱 레포 `passQL-app`은 모노레포 `app/`으로 이미 옮겨 불필요하다. git 기록 전체를 로컬 미러로 백업한 뒤 사용자가 조직째 삭제하기로 했다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 이슈·PR·릴리스·레포 시크릿 16개·환경이 유지됐고, 이전 후 첫 deploy(run 37550276843)가 성공했다.

**부정**
- 조직 시크릿 재등록, 코드·스크립트·문서·로컬 remote·projectops 설정의 레포 주소 변경이 필요했다.

## 영향 범위 (Scope)
GitHub 레포 위치, Actions 시크릿, 서버 `application.yml`(건의사항 이슈 링크), 시크릿 등록 스크립트, `client/CLAUDE.md`, projectops 설정, 로컬 git remote.

## 출처 (References)
- GitHub #351 이슈 본문, 댓글 「배포 검증 완료」·「완료」(2026-10-07)
