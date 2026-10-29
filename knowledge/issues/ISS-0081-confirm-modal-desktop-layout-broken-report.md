---
type: completion-report
id: ISS-0081
created: 2026-04-12
topics: [practice, design-system]
status: resolved
resolves: "[[ISS-0081-confirm-modal-desktop-layout-broken]]"
related: ["[[DEC-0057-confirm-modal-bottom-sheet-all-sizes]]"]
source: "https://github.com/Twin-Fang/passQL/issues/142"
---

# ISS-0081 완료 리포트: ConfirmModal 단일 바텀시트, PracticeSet 이탈 흐름 재구현

GitHub #142 리포트 댓글 기준 (2026-04-12).

## 해결 방법
- `src/components/ConfirmModal.tsx`: 카드의 `md:` 반응형 클래스 전체 제거, 모든 화면에서 `w-full rounded-t-2xl` 바텀시트. `document.body.style.overflow`는 이전 값을 저장 후 복원.
- `src/pages/PracticeSet.tsx`: Home 아이콘 → `ArrowLeft`(`aria-label="풀이 나가기"`), `onClick`을 `setExitModalOpen(true)`로. `exitConfirmed` state로 blocker를 끈 뒤 `useEffect`에서 `navigate("/")` — 같은 tick에 navigate하면 blocker가 아직 활성이라 차단된다.
- Tailwind 치환: `break-words` → `wrap-break-word`, `bg-[#F3F4F6]` → `bg-surface-code`.
- 검증: 데스크톱 바텀시트, 뒤로가기 모달 트리거, 이중 확인 없음, `npm run build` 타입 에러 없음.

## 근본 원인 (확정)
`md:` 클래스로 생긴 `max-width` 제약이 flex 아이템을 콘텐츠 너비로 수축시켰다. 뒤로가기 버튼은 blocker를 우회했다.

## 재발 방지
리포트 참고사항: 데스크톱 중앙 팝업이 필요하면 오버레이를 `flex items-center`로, 카드에 `max-w-sm mx-auto rounded-2xl` — 모바일/데스크톱 분기가 생기므로 별도 이슈로 논의 권장.

## 교훈
(원본에 없음, 볼트 정리) 이 이슈 마지막 댓글에서 제기된 DailyChallenge 제출 중 모달 오탐은 여기서 고쳐지지 않았고 GitHub #146에서 다뤘다.
