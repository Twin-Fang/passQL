---
type: decision
id: DEC-0156
created: 2026-10-18
reviewed: null
topics: [ci-deploy]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0332-changelog-not-updated-on-deploy]]", "[[ISS-0332-changelog-not-updated-on-deploy-report]]"]
---

# DEC-0156: CHANGELOG는 자체 워크플로 대신 projectops 표준 `RELEASE-CHANGELOG`로, 배포 PR 방향은 `deploy → main`

## 문제 정의 (Context)
projectops 업데이트 뒤 `RELEASE-CHANGELOG`가 base=main·head=deploy PR에서만 동작하는데 passQL은 deploy에 직접 push해 CHANGELOG가 7월부터 멈췄다 (GitHub #542).

## 결정 (Decision)
- 직접 만든 워크플로를 추가하지 않고 projectops 표준을 따른다(템플릿 4.62.0).
- 배포 방향은 `deploy → main`(사용자 선택). main을 deploy에 병합·push해 배포를 시작하고, 이어서 `deploy → main` 배포 PR을 만들어 `RELEASE-CHANGELOG`가 버전 확정·CHANGELOG 갱신 후 automerge 한다.
- 릴리스 head 가드는 `deploy`로 고정한다(템플릿 기본 `develop`과 다름).

## 검토한 대안 (Alternatives)
- deploy push 때 `before..sha` 커밋으로 CHANGELOG를 갱신해 main에 `[skip ci]`로 남기는 자체 워크플로(이슈 본문 제안): 택하지 않음. 원본 이유 — 설치 도구가 관리하는 파일이라 이후 업데이트와 충돌하지 않게 projectops 표준을 따름.
- 템플릿 기본 방향(develop → main): 원본 — 템플릿 기본과 다르지만 현재 통지·배포 구조를 바꾸지 않고 동작해서 `deploy → main`.

## 결과 (Consequences)
**긍정**
- main에 v1.24.3이 7월 이후 처음 기록됐다.

**부정**
- 템플릿을 다시 갱신하면 head 가드가 `develop`으로 돌아갈 수 있어 매번 확인해야 한다.
- 배포 PR은 deploy push 뒤에 만들어야 한다.

## 영향 범위 (Scope)
`.github/workflows/`의 `RELEASE-CHANGELOG`, `CHANGELOG.md/json`, 배포 절차(`/projectops:pro-changelog-deploy`). `deploy` 브랜치 push를 배포 트리거로 둔 기존 결정 DEC-0009와 같은 구조 위에서 동작.

## 출처 (References)
- GitHub #542 이슈 본문, 보고 댓글 "왜 이렇게 했나" (2026-10-18)
- [[ISS-0332-changelog-not-updated-on-deploy]]
