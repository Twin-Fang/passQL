---
type: completion-report
id: ISS-0115
created: 2026-04-13
topics: [dev-workflow]
status: resolved
resolves: "[[ISS-0115-developer-mode-easter-egg-unlock]]"
related: ["[[DEC-0068-dev-mode-hidden-easter-egg]]"]
source: "https://github.com/Twin-Fang/passQL/issues/208"
---

# ISS-0115 완료 리포트: 버전 row 5회 클릭 잠금 해제, `/dev` 전용 페이지와 route guard

GitHub #208 작업 리포트 댓글 기준 (2026-04-13).

## 해결 방법
- `src/components/SettingsRow.tsx`: `onClick?: () => void` prop.
- `src/pages/Settings.tsx`: `clickCountRef` + `clickResetTimerRef`로 2초 debounce 카운터. 3회 "개발자 모드까지 2번 남았습니다", 4회 "…1번 남았습니다", 5회 `sessionStorage.setItem("devUnlocked", "1")` + "개발자 모드" row 노출. 초기값 `useState(() => sessionStorage.getItem("devUnlocked") === "1")`. 기존 개발자 도구 섹션 제거.
- `src/pages/DevPage.tsx`(신규): localStorage 초기화 2단계 확인(1차 "진짜요?" + 인라인 경고, 3초 후 복원, 2차 `localStorage.clear()` + `sessionStorage.clear()` 후 `window.location.href = "/"`).
- `src/App.tsx`: `DevGuard`(sessionStorage 확인, 없으면 `/settings`로 redirect), `/dev`를 AppLayout 밖에 등록.
- 설계 선택: [[DEC-0068-dev-mode-hidden-easter-egg]].

## 근본 원인 (확정)
개발자 기능 노출 조건 부재. 구현 중 버그: `overflow-hidden` + flex 충돌로 카드 너비 0px, `fixed` 요소의 `w-full`로 `translateX(-50vw)` 계산 오류, `DevPage` import 전 `DevGuard` 정의, `devUnlocked` 초기값 항상 `false`.

## 재발 방지
검증: 5회 클릭 잠금 해제, 재진입 시 row 유지, `/dev` 직접 입력 시 `/settings` 리다이렉트, 초기화 후 홈 리다이렉트·데이터 삭제 확인.

## 교훈
(원본에 없음, 볼트 정리) React state만으로 둔 잠금 상태는 페이지 이동 시 사라진다 — 유지 범위에 맞는 저장소(sessionStorage 등)로 초기값을 복원한다.
