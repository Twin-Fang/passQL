---
type: issue
id: ISS-0016
created: 2026-04-08
topics: [ci-deploy]
symptoms: ["Vercel CLI 수동 배포", "vercel deploy --prod", "배포 누락", "deploy 브랜치"]
root_cause: "프론트 배포를 매번 Vercel CLI로 수동 실행해야 해 배포 누락 가능성이 있었다"
status: resolved
resolution: null
related: ["[[DEC-0021-vercel-git-integration-deploy-branch]]"]
source: "https://github.com/Twin-Fang/passQL/issues/19"
---

# ISS-0016: Vercel Git Integration 자동 배포 설정

GitHub #19 (원본: 이슈 본문. 댓글 없음).

## 증상
프론트 배포를 매번 Vercel CLI로 수동 실행해야 했다. `deploy` 브랜치 머지 후 별도로 `vercel deploy --prod`를 실행해야 해서 배포 누락 가능성이 있었다.

## 재현 조건
`deploy` 브랜치 머지 후 수동 배포를 하지 않으면 프론트가 배포되지 않음 (이슈 본문).

## 조사 기록
- 이슈 본문 체크리스트(작성 시점): Vercel 대시보드 → GitHub repo 연결 [x], 조직에 Vercel GitHub App 설치(All repositories) [x], Production Branch `deploy` [x], Root Directory `client` [x], deploy 브랜치 push 자동 배포 테스트 [ ]. 완료 댓글은 없다.

## 근본 원인
배포가 수동 CLI 단계에 의존 (이슈 본문).
