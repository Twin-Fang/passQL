---
type: issue
id: ISS-0127
created: 2026-04-13
topics: [ci-deploy]
symptoms: [Vercel-deploy.yml, "빌드 검증 없음", "tsc 오류 배포", "vite build 오류", "Actions Success 표시", "무음 배포 실패"]
root_cause: "`Vercel-deploy.yml`이 빌드 검증 없이 바로 `vercel deploy`를 실행함"
status: resolved
resolution: "[[ISS-0127-vercel-deploy-build-check-step-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/230"
---

# ISS-0127: Vercel 배포 워크플로우에 빌드 검증 단계가 없음

GitHub #230 (원본: 이슈 본문과 댓글).

## 증상
`deploy` 브랜치 push 시 실행되는 `.github/workflows/Vercel-deploy.yml`이 빌드 검증 없이 `vercel deploy`를 실행한다. TypeScript 컴파일 오류나 Vite 빌드 오류가 있어도 GitHub Actions는 Success로 표시되고, 오류 있는 코드가 배포되거나 배포가 무음으로 실패한다.

## 재현 조건
`deploy` 브랜치에 빌드가 깨지는 코드를 push.

## 조사 기록
- 2026-04-13: 제안 — 배포 전 `npm ci` → `npm run build` (`tsc && vite build`) 단계 추가, 실패 시 배포 중단, `Build (TypeScript + Vite)` 스텝에서 오류 확인, 실패 시 Step Summary 안내.

## 근본 원인
워크플로우에 빌드 단계가 없었다.
