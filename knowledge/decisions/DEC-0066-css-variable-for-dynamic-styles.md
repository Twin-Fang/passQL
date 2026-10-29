---
type: decision
id: DEC-0066
created: 2026-04-12
reviewed: null
topics: [design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0104-card-base-to-tailwind-utilities]]", "[[ISS-0104-card-base-to-tailwind-utilities-report]]"]
---

# DEC-0066: 런타임 동적 스타일 값은 CSS 변수 주입 패턴으로 — 인라인 style 금지 규칙의 예외

## 문제 정의 (Context)
프로젝트에 인라인 `style={{ }}` 금지 규칙이 있다. 진행 바 너비·차트 높이처럼 런타임에 정해지는 값은 Tailwind arbitrary value만으로 표현할 수 없었다. PR #197 머지 후 CodeRabbit이 CSS 변수 패턴도 규칙 위반이라고 재지적했다 (GitHub #187).

## 결정 (Decision)
동적 값은 `style={{ "--var": value }}` + `[prop:var(--var)]` 패턴(예: `[width:var(--bar-w)]`, `[height:var(--chart-h)]`)으로 처리하고, 이를 인라인 style 금지 규칙의 예외로 간주한다. 리포트 결론: "CSS 변수 주입 패턴은 Tailwind에서 동적 값을 다루는 공식 권장 방식." 정적 값은 유틸리티 클래스로 옮긴다. 팝오버 절대 좌표(`top`, `left`)는 현행 유지.

## 검토한 대안 (Alternatives)
- `w-[${value}%]` 템플릿 문자열 arbitrary value: 커밋 `7c65169`로 시도. Tailwind v4 `@tailwindcss/vite`가 정적 스캔이라 런타임 문자열을 감지하지 못해 프로덕션 빌드에서 클래스가 누락 → 커밋 `4c6aedc`로 되돌림.
- 정적 값까지 포함한 인라인 `style={{ }}` 유지: 규칙 위반으로 코드 리뷰에서 지적되어 정적 값은 유틸리티로 옮김.

## 결과 (Consequences)
**긍정**
- 동적 값이 프로덕션 빌드에서도 적용된다.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
웹 `Home.tsx`·`Stats.tsx`·`StatsTopicList.tsx` 진행 바, `StatsBarChart.tsx` 높이, 이후 동적 스타일이 필요한 모든 컴포넌트.

## 출처 (References)
- GitHub #187 작업 리포트 「PR 머지 후 CodeRabbit 재지적 및 revert」 (2026-04-12)
- [[ISS-0104-card-base-to-tailwind-utilities]]
