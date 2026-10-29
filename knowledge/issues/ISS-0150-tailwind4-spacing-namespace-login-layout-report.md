---
type: completion-report
id: ISS-0150
created: 2026-04-22
topics: [design-system, auth-member]
status: resolved
resolves: "[[ISS-0150-tailwind4-spacing-namespace-login-layout]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/277"
---

# ISS-0150 완료 리포트: `--spacing-*`를 `:root`의 `--space-*`로 이동

GitHub #277 "변경 완료" 댓글(2026-04-22)과 이슈 본문의 수정 내용 기준. `## 개요` 형식 리포트는 없음.

## 해결 방법
`client/src/styles/tokens.css`: `@theme` 안의 `--spacing-*` 변수를 `@theme` 밖 `:root`의 `--space-*`로 이름을 바꿔 옮겼다(예: `--space-sm: 0.5rem`, `--space-lg: 1rem`).

## 근본 원인 (확정)
Tailwind 4 `@theme`의 `--spacing-*` 예약 네임스페이스 충돌.

## 재발 방지
원본에 적혀 있지 않다.

## 교훈
(원본에 없음, 볼트 정리) Tailwind 4에서 `max-w-*` 등 유틸리티 값이 이상하면 `@theme` 안 커스텀 변수가 예약 네임스페이스(`--spacing-*` 등)와 겹치는지부터 본다.
