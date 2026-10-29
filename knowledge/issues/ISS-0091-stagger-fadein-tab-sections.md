---
type: issue
id: ISS-0091
created: 2026-04-12
topics: [home, design-system]
symptoms: ["섹션 애니메이션 없음", "탭 전환감 없음", useStagger, "Outlet key", staggerIn, animate-greeting]
root_cause: "기능 추가 — 홈은 그리팅만 페이드인되고 나머지 섹션·다른 탭은 애니메이션이 없었다"
status: resolved
resolution: null
related: ["[[ISS-0088-home-greeting-linebreak-fadein]]", "[[ISS-0092-home-daisyui-pilot]]"]
source: "https://github.com/Twin-Fang/passQL/issues/162"
---

# ISS-0091: 홈 및 탭 전환 시 섹션별 스태거 페이드인 애니메이션

GitHub #162 (원본: 이슈 본문과 영상·참고 HTML 댓글).

## 증상
홈 진입 시 `animate-greeting` / `animate-greeting-delayed`로 그리팅만 페이드인되고 오늘의 문제·학습현황·합격 준비도·AI 추천문제는 즉시 노출. AI문제(CategoryCards)·통계·설정 탭은 애니메이션이 없고 탭 전환감이 없다.

## 재현 조건
해당 없음 (기능 추가).

## 조사 기록
- 2026-04-12: 이슈 본문 제안 — `useStagger(count)` 훅(`50ms × index` delay, 300ms ease-out, CSS 변수 `--stagger-delay`로 inline style 없이), `AppLayout`의 `<Outlet key={location.pathname} />`, `animate-greeting` 제거, 페이지별 섹션 분해, `@keyframes staggerIn`.
- 2026-04-12: 댓글은 시연 영상 2건과 참고 HTML(`stagger-style.html`)뿐이다. 완료를 적은 댓글은 없다. (참고: GitHub #167 작업 댓글이 이미 존재하는 `useStagger` 훅의 반환값을 고쳤다고 적었다.)

## 근본 원인
해당 없음 (기능 추가).
