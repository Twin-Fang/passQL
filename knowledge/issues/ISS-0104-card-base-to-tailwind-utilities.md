---
type: issue
id: ISS-0104
created: 2026-04-12
topics: [design-system]
symptoms: [card-base, components.css, "인라인 style", "하드코딩 hex", "w-[${value}%]", "Tailwind v4 동적 클래스 누락"]
root_cause: "GitHub #183 이후에도 card-base 커스텀 클래스가 15곳 남아 있었다"
status: resolved
resolution: "[[ISS-0104-card-base-to-tailwind-utilities-report]]"
related: ["[[DEC-0066-css-variable-for-dynamic-styles]]"]
source: "https://github.com/Twin-Fang/passQL/issues/187"
---

# ISS-0104: 남은 `card-base` 커스텀 CSS를 Tailwind 유틸리티로 교체

GitHub #187 (원본: 이슈 본문, 스크린샷·작업 리포트 댓글).

## 증상
`Questions.tsx`(GitHub #183) 이후 `card-base`가 15곳 잔존 — 페이지 `QuestionDetail.tsx` 2, `AnswerFeedback.tsx` 3, `Stats.tsx` 2, `Settings.tsx` 1, `Home.tsx` 1, 컴포넌트 `SqlPlayground.tsx`, `StatsBarChart.tsx`, `StatsAnalysisCard.tsx` 2, `StatsTopicList.tsx`, `StatsRadarChart.tsx`.

## 재현 조건
해당 없음 (리팩토링).

## 조사 기록
- 2026-04-12: 이슈 등록. `card-base` → `bg-surface-card border border-border rounded-2xl p-4 sm:p-6`, 교체 후 `.card-base` 블록 삭제.
- 작업 중 코드 리뷰에서 인라인 `style={{ }}` 위반과 하드코딩 hex 색상이 함께 지적됨.
- PR #197 머지 후 CodeRabbit이 CSS 변수 패턴도 인라인 style 위반이라 재지적 → `w-[${value}%]`로 바꿨다가(커밋 `7c65169`) 프로덕션 빌드에서 CSS 누락 확인 → 복원(커밋 `4c6aedc`).

## 근본 원인
커스텀 CSS 클래스 잔존.
