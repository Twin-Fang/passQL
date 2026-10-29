---
type: completion-report
id: ISS-0070
created: 2026-04-11
topics: [practice]
status: resolved
resolves: "[[ISS-0070-leave-warning-modal-during-solving]]"
related: ["[[DEC-0053-spa-only-leave-blocker]]"]
source: "https://github.com/Twin-Fang/passQL/issues/121"
---

# ISS-0070 완료 리포트: useBlocker + 공통 ConfirmModal로 세 화면 이탈 차단

GitHub #121 리포트 댓글 기준 (2026-04-11).

## 해결 방법
- `client/src/components/ConfirmModal.tsx` 신규: 모바일 바텀시트, 데스크톱 중앙 모달. ESC·오버레이 클릭으로 닫기.
- `PracticeSet.tsx`: `useBlocker(!shouldNavigateToResult)`. `DailyChallenge.tsx`: `useBlocker(!isLoading && feedback === null)`. `QuestionDetail.tsx`: `useBlocker(practiceMode !== true && !submitted)`, `submitted` state 추가.
- `blocker.state === "blocked"`를 모달 `isOpen`으로 쓰고 "계속 풀기" → `blocker.reset()`, "나가기" → `blocker.proceed()`.
- 파괴적 액션(나가기)은 Secondary(하단), 유지(계속 풀기)는 Primary(상단).

## 근본 원인 (확정)
해당 없음 (기능 추가).

## 재발 방지
리포트 주의사항:
- `useBlocker`는 SPA 내 라우팅만 막는다. 탭 닫기·새로고침(`beforeunload`)은 "과도한 UX 방해로 판단"해 의도적으로 제외.
- `PracticeSet`에서 `useEffect`가 조건부 return 뒤에 있어 훅 규칙 위반이 있었고 코드 리뷰에서 수정.
- `DailyChallenge` 오답 후 "다시 풀기"로 `feedback`이 null이 되면 blocker가 다시 켜진다 — 의도된 동작.

## 교훈
(원본에 없음, 볼트 정리) 이 이슈의 blocker 조건은 이후 데스크톱 모달 깨짐(GitHub #142)과 제출 중 오탐(GitHub #146)으로 두 번 수정됐다.
