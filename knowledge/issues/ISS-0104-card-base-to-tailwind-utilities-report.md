---
type: completion-report
id: ISS-0104
created: 2026-04-12
topics: [design-system]
status: resolved
resolves: "[[ISS-0104-card-base-to-tailwind-utilities]]"
related: ["[[DEC-0066-css-variable-for-dynamic-styles]]"]
source: "https://github.com/Twin-Fang/passQL/issues/187"
---

# ISS-0104 완료 리포트: card-base 전수 교체·CSS 삭제, 인라인 style·hex 정리

GitHub #187 작업 리포트 댓글 기준 (2026-04-12, PR #197).

## 해결 방법
- 페이지·컴포넌트의 `card-base` 전수 교체. 기존 `!p-0`, `p-0`, `py-8`, `py-12` 오버라이드는 기본값 `p-4 sm:p-6`을 빼고 의도한 padding만 명시. `Home.tsx`는 rebase로 늘어난 카드 9곳 전체, `ErrorFallback.tsx` 추가 사용처도 교체.
- `src/styles/components.css`: `.card-base` 기본 블록과 `@media (min-width: 640px)` 반응형 블록 삭제.
- 인라인 style: `SqlPlayground.tsx` textarea 정적 값 5개 → 유틸리티(이후 main의 `sql-playground-textarea`로 재교체). 진행 바·차트 높이 같은 동적 값은 CSS 변수 패턴(`style={{ "--bar-w": ... }}` + `[width:var(--bar-w)]`) → [[DEC-0066-css-variable-for-dynamic-styles]].
- `AnswerFeedback.tsx` hex → 토큰: `bg-[#F3F4F6]` → `bg-surface-code`, `border-[#E5E7EB]` → `border-border`, `text-[#6B7280]` → `text-text-secondary`, `text-[#111827]` → `text-text-primary`.
- main rebase 충돌: GitHub #189(`rationale-card`, `ans-card-wrong/correct`)와 GitHub #191(`sql-playground-textarea`)은 main 버전 채택.
- 검증: `npm run build` 성공, `grep -rn "card-base" src/` 0건.

## 근본 원인 (확정)
커스텀 CSS 의존 잔존. 추가로 Tailwind v4 `@tailwindcss/vite`는 정적 스캔이라 런타임 템플릿 문자열(`w-[${barWidth}%]`) 클래스를 감지하지 못해 프로덕션 빌드에서 CSS가 누락됐다.

## 재발 방지
리포트 참고사항: `badge-topic`은 범위 외(유지). SchemaViewer, HeatmapCalendar 등의 인라인 style은 별도 이슈 필요. 팝오버 절대 좌표(`getBoundingClientRect` 기반)는 현행 유지.

## 교훈
(원본에 없음, 볼트 정리) 동적 값으로 만든 Tailwind 클래스가 개발에선 되고 프로덕션에서 사라지면 정적 스캔 한계를 의심하고 CSS 변수 패턴으로 바꾼다.
