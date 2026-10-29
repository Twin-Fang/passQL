---
type: completion-report
id: ISS-0101
created: 2026-04-12
topics: [design-system]
status: resolved
resolves: "[[ISS-0101-questions-page-tailwind-utilities]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/183"
---

# ISS-0101 완료 리포트: card-base·filter-dropdown 교체, filter-dropdown CSS 삭제

GitHub #183 작업 리포트 댓글 기준 (2026-04-12).

## 해결 방법
- `src/pages/Questions.tsx`: `card-base` 4곳 → `bg-surface-card border border-border rounded-2xl p-4 sm:p-6`.
- 난이도 필터 버튼 `filter-dropdown` / `filter-dropdown--active` → `inline-flex items-center gap-1.5 h-10 px-4 border border-border rounded-full text-sm bg-surface-card` + 조건부 `border-brand bg-brand-light`(JSX 템플릿 리터럴).
- `src/styles/components.css`: `.filter-dropdown`, `.filter-dropdown:hover`, `.filter-dropdown--active` 3블록 삭제.
- `badge-topic`은 유지.

## 근본 원인 (확정)
커스텀 CSS 의존. 리포트가 밝힌 이유: "커스텀 CSS 의존성 제거로 스타일 추적 단순화".

## 재발 방지
`card-base`는 `QuestionDetail`, `Stats` 등 12곳에 남아 별도 이슈(GitHub #187)로 처리 예정.

## 교훈
논의 기록 없음.
