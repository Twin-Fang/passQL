---
type: issue
id: ISS-0086
created: 2026-04-12
topics: [ci-deploy]
symptoms: ["error TS6133", "'FileText' is declared but its value is never read", "Deploy to Vercel", "deploy 브랜치", "spawn sh ENOENT", "vercel build"]
root_cause: "deploy 브랜치에 미사용 import가 남아 tsc 실패, 머지 후에는 Actions runner에서 vercel build가 spawn sh ENOENT로 실패"
status: resolved
resolution: "[[ISS-0086-deploy-branch-vercel-build-failure-report]]"
related: ["[[DEC-0060-vercel-server-side-build-deploy]]"]
source: "https://github.com/Twin-Fang/passQL/issues/152"
---

# ISS-0086: deploy 브랜치 Vercel 빌드 실패

GitHub #152 (원본: 이슈 본문과 작업 댓글).

## 증상
`deploy` 브랜치 push 시 GitHub Actions `Deploy to Vercel` 워크플로 Build 스텝 실패:
`error TS6133: 'FileText' is declared but its value is never read.` (`src/components/AppLayout.tsx(2,16)`), exit code 2.

## 재현 조건
`deploy` 브랜치에 커밋 push → `Deploy to Vercel` 실행.

## 조사 기록
- 2026-04-12: 1차 — `AppLayout.tsx`의 미사용 `FileText` import. main에서 `Sparkles`로 바뀐 변경이 deploy에 미반영.
- 2026-04-12: 2차 — feature 브랜치 머지 후 `vercel build --prod`가 runner에서 `spawn sh ENOENT`로 실패.

## 근본 원인
브랜치 간 변경 미반영(1차)과 Actions runner에서의 Vercel CLI 빌드 환경 제약(2차).
