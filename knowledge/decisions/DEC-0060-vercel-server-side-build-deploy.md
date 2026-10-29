---
type: decision
id: DEC-0060
created: 2026-04-12
reviewed: null
topics: [ci-deploy]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0086-deploy-branch-vercel-build-failure]]", "[[ISS-0086-deploy-branch-vercel-build-failure-report]]"]
---

# DEC-0060: Vercel 배포 워크플로는 runner에서 빌드하지 않고 `vercel deploy --prod --yes`로 Vercel 서버 빌드에 맡긴다

## 문제 정의 (Context)
`deploy` 브랜치의 GitHub Actions Vercel 워크플로가 runner에서 `vercel build --prod` 단계에서 `spawn sh ENOENT`로 실패했다 (GitHub #152).

## 결정 (Decision)
`.github/workflows/Vercel-deploy.yml`에서 Node 설치·`npm ci`·`vercel pull`·`vercel build`·`--prebuilt` 배포와 재시도 로직을 모두 빼고, Vercel CLI 설치 후 `vercel deploy --prod --yes --token=...` 한 줄로 배포한다. 빌드는 Vercel 인프라에서 한다.

## 검토한 대안 (Alternatives)
- 기존 runner 빌드(`vercel build --prod` + `vercel deploy --prebuilt`, 재시도 3회): `spawn sh ENOENT`로 실패해 제거. 그 밖의 대안은 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 로컬 빌드 환경 의존성이 없어지고 `spawn sh` 문제가 생기지 않는다. 프로젝트 설정 `nodeVersion: 24.x` 충돌도 우회됐다.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`.github/workflows/Vercel-deploy.yml`, `vercel.json`.

## 출처 (References)
- GitHub #152 작업 댓글 (2026-04-12)
- [[ISS-0086-deploy-branch-vercel-build-failure]]
