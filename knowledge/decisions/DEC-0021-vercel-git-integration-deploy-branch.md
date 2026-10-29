---
type: decision
id: DEC-0021
created: 2026-04-08
reviewed: null
topics: [ci-deploy]
status: superseded
supersedes: null
superseded_by: DEC-0060
related: ["[[ISS-0016-vercel-git-auto-deploy]]", "[[DEC-0060-vercel-server-side-build-deploy]]"]
---

# DEC-0021: 프론트는 GitHub Actions 없이 Vercel Git Integration으로 `deploy` 브랜치 push 시 자동 배포

## 문제 정의 (Context)
프론트 배포가 Vercel CLI 수동 실행이라 누락 가능성이 있었다 (GitHub #19).

## 결정 (Decision)
Vercel Git Integration으로 `deploy` 브랜치 push 시 자동 배포한다. GitHub Actions 없이 Vercel 대시보드 설정만으로 구현한다. Production Branch는 `deploy`, Root Directory는 `client`.

## 검토한 대안 (Alternatives)
- GitHub Actions로 배포: 쓰지 않기로 함("GitHub Actions 없이"). 이유는 원본에 적혀 있지 않다.
- 기존 Vercel CLI 수동 배포: 배포 누락 가능성 때문에 대체.

## 결과 (Consequences)
**긍정**
- 배포 누락 가능성 제거 (이슈 본문의 목적).

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
Vercel 프로젝트 설정(외부 대시보드), `client/`.

## 출처 (References)
- GitHub #19 이슈 본문
