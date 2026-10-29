---
type: completion-report
id: ISS-0092
created: 2026-04-12
topics: [design-system, home]
status: resolved
resolves: "[[ISS-0092-home-daisyui-pilot]]"
related: ["[[DEC-0063-daisyui-incremental-adoption]]"]
source: "https://github.com/Twin-Fang/passQL/issues/167"
---

# ISS-0092 완료 리포트: Home.tsx daisyUI 전환, base 색상 매핑, useStagger style 제거

GitHub #167 작업 댓글 기준 (2026-04-12).

## 해결 방법
- `src/styles/theme.css`: `--color-base-100` → `#FFFFFF`(카드 표면), `--color-base-200` → `#FAFAFA`(페이지 배경). `base-300` = `#E5E7EB`(테두리).
- `src/pages/Home.tsx`: `card-base` → daisyUI `card`, 수동 pulse → `skeleton`, 재시도 버튼 → `btn btn-xs btn-outline btn-primary`, 연속 학습 뱃지 → `badge badge-warning`.
- `src/hooks/useStagger.ts`: `{ className, style }` → `{ className: 'animate-stagger [--stagger-delay:${n}ms]' }` — Tailwind 4 임의 CSS 변수 구문으로 `style` prop 제거(인라인 style 금지 규칙 준수).
- 오늘의 문제 완료 카드: `border-l-4` 초록선 → `bg-[#F3F4F6] border border-border rounded-xl` + `✓ 완료` dimmed(굵은 좌측선이 `rounded-xl`을 깨뜨리고 시맨틱 카드 패턴을 오용해서).
- 회귀 수정: `badge-topic` 색 오염 복원, 카드 `bg-white` 명시, 추천 카드 `flex-row` 정렬.

## 근본 원인 (확정)
해당 없음 (기능 개선).

## 재발 방지
참고사항: 이번 작업은 Home.tsx 한정, 다른 페이지는 후속 이슈에서 순차 적용 예정. `card-base`는 다른 컴포넌트가 참조할 수 있어 `components.css`에서 즉시 삭제하지 않음. daisyUI `card`는 기본 `overflow-hidden` — clipping 확인 필요. `useStagger` 반환 타입 변경으로 `CategoryCards.tsx`·`Settings.tsx`·`Stats.tsx`의 `style` 스프레드도 수정 필요.

## 교훈
(원본에 없음, 볼트 정리) daisyUI 클래스로 바꾼 뒤에는 기존 전용 클래스(`badge-topic` 등)의 색이 daisyUI 기본값에 덮이지 않았는지 시각 회귀를 확인한다.
