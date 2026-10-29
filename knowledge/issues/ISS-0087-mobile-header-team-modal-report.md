---
type: completion-report
id: ISS-0087
created: 2026-04-12
topics: [home, design-system]
status: resolved
resolves: "[[ISS-0087-mobile-header-team-modal]]"
related: ["[[DEC-0061-no-inline-style-rule]]"]
source: "https://github.com/Twin-Fang/passQL/issues/157"
---

# ISS-0087 완료 리포트: MobileHeader·TeamModal 추가, 모달은 createPortal로 body에 마운트

GitHub #157 리포트 댓글 기준 (2026-04-12).

## 해결 방법
- `client/src/components/MobileHeader.tsx`: 좌측 로고, 우측 팀 아이콘 버튼(`Users`). 모달 상태는 부모 `AppLayout`이 관리하고 콜백(`onTeamClick`)으로 전달.
- `client/src/components/TeamModal.tsx`: 팀명 "콜레라 (Cold Red Rice Team)", 멤버별 이름·GitHub 링크·역할 뱃지(Mock 하드코딩). `createPortal(JSX, document.body)`로 마운트.
- `client/src/styles/components.css`: `.modal-overlay` / `.modal-card`(`position: fixed`, `inset: 0`, `z-index: 9999`).
- `client/CLAUDE.md`: 인라인 `style` 속성 절대 금지 규칙 추가.

## 근본 원인 (확정)
해당 없음 (기능 추가). 구현 중 `fixed inset-0`이 레이아웃 컨테이너 안에 갇히는 문제를 portal로 해결.

## 재발 방지
리포트 주의사항: 팀 정보는 Mock 하드코딩. 역할 뱃지 색(`bg-blue-50 text-blue-600` 등)은 디자인 토큰 미사용 — 추후 토큰화 권장. `createPortal` + `.modal-overlay` 구조는 다른 중앙 고정 모달에도 재사용 가능.

## 교훈
리포트 서술: 모달이 부모의 `overflow`·`transform`·stacking context에 갇히면 `createPortal`로 `document.body`에 마운트한다.
