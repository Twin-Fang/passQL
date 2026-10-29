---
type: completion-report
id: ISS-0086
created: 2026-04-12
topics: [ci-deploy]
status: resolved
resolves: "[[ISS-0086-deploy-branch-vercel-build-failure]]"
related: ["[[DEC-0060-vercel-server-side-build-deploy]]"]
source: "https://github.com/Twin-Fang/passQL/issues/152"
---

# ISS-0086 완료 리포트: 워크플로를 `vercel deploy --prod --yes` 한 줄로 단순화

GitHub #152 작업 댓글 기준 (2026-04-12).

## 해결 방법
`.github/workflows/Vercel-deploy.yml`에서 Setup Node.js, `npm ci`, Verify Vercel Secrets, `vercel pull`, `vercel build --prod`(재시도 3회), `vercel deploy --prebuilt`(재시도 3회)를 제거. 최종: Checkout → Install Vercel CLI → `vercel deploy --prod --yes --token=...` → Deployment Summary. 재시도 로직은 `vercel build` 실패 대응용이라 함께 제거.
검증: 로컬에서 `vercel deploy --prod --yes` 실행 성공, Production URL 정상 응답.

## 근본 원인 (확정)
`vercel build`가 runner에서 shell spawn 환경 불일치로 실패했다. `vercel deploy`는 Vercel 서버에서 빌드하므로 이 문제가 없다.

## 재발 방지
참고사항: `vercel.json`에 넣었던 `nodeVersion: 22.x`는 지원하지 않는 속성이라 제거. `.vercel/project.json`의 `nodeVersion: 24.x`는 서버 빌드 방식에서 무관.

## 교훈
(원본에 없음, 볼트 정리) deploy 브랜치 빌드 실패는 먼저 main/feature 변경이 deploy에 반영됐는지 확인한다.
