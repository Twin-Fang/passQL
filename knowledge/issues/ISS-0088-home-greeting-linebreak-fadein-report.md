---
type: completion-report
id: ISS-0088
created: 2026-04-12
topics: [home]
status: resolved
resolves: "[[ISS-0088-home-greeting-linebreak-fadein]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/158"
---

# ISS-0088 완료 리포트: 백엔드 `\n` 구분자, `parseGreetingLines()`, `greetingIn` 애니메이션

GitHub #158 리포트 댓글 기준 (2026-04-12).

## 해결 방법
- `GreetingService.java`: messageType 4개(GENERAL, COUNTDOWN, URGENT, EXAM_DAY) 템플릿 전체에 `\n` 삽입.
- `client/src/pages/Home.tsx`: `parseGreetingLines(message, nickname)` — `\n` split 후 `{nickname}`을 `<span>`(`--color-brand`, `1.15em`)으로 치환. 리포트는 "백엔드 플레이스홀더 계약을 그대로 활용해 프론트 비즈니스 로직을 최소화"했다고 적었다.
- `client/src/styles/components.css`: `greetingIn` keyframe, `.animate-greeting`, `.animate-greeting-delayed`(80ms).
- 하위 호환: `\n`이 없으면 한 줄로, greeting 데이터가 없으면 기존 `displayName` fallback.

## 근본 원인 (확정)
해당 없음 (기능 개선).

## 재발 방지
리포트 주의사항: `parseGreetingLines`는 한 줄에 `{nickname}` 1개만 처리 — 여러 개면 마지막 세그먼트 이후가 유실될 수 있다. `urgentMessages` 세 번째(`D-N! {nickname}님\n...`)는 줄바꿈 위치 조정 검토.

## 교훈
원본에 적혀 있지 않다. (참고: `animate-greeting` 클래스는 GitHub #162에서 `useStagger`로 대체·제거됐다.)
