---
type: issue
id: ISS-0150
created: 2026-04-22
topics: [design-system, auth-member]
symptoms: ["max-w-sm 0.5rem", "로그인 카드 극도로 좁음", "텍스트 세로 한 글자씩", "@theme --spacing-*", tokens.css, "Tailwind 4", "max-width: var(--spacing-sm)"]
root_cause: "`tokens.css`의 `@theme` 안 `--spacing-*` 커스텀 변수가 Tailwind 4 spacing 스케일 네임스페이스와 겹쳐 `max-w-*` 값을 덮어씀"
status: resolved
resolution: "[[ISS-0150-tailwind4-spacing-namespace-login-layout-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/277"
---

# ISS-0150: Tailwind 4 `@theme --spacing-*` 충돌로 로그인 페이지 레이아웃 파괴

GitHub #277 (원본: 이슈 본문과 댓글).

## 증상
`/login`에서 로그인 카드가 극도로 좁아지고 텍스트가 한 글자씩 세로로 출력된다. DevTools: `.max-w-sm { max-width: var(--spacing-sm); }` (= `0.5rem`). 영향: `max-w-sm`, `max-w-md`, `max-w-lg` 등 모든 `max-w-*`. 로컬호스트와 Vercel 배포 모두 동일.

## 재현 조건
`client/src/styles/tokens.css`의 `@theme {}` 안에 `--spacing-sm: 0.5rem` 같은 변수가 있고, `className="w-full max-w-sm"` 요소가 있는 페이지 접속.

## 조사 기록
- 2026-04-22: Tailwind 4는 `@theme` 안의 `--spacing-*`를 자체 spacing 스케일로 예약한다.

## 근본 원인
커스텀 변수 이름이 Tailwind 4 예약 네임스페이스와 겹쳤다.
