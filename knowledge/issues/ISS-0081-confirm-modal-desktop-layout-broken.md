---
type: issue
id: ISS-0081
created: 2026-04-12
topics: [practice, design-system]
symptoms: ["풀이를 그만할까요?", ConfirmModal, "데스크톱 레이아웃 깨짐", "텍스트 세로 나열", "md: 반응형 클래스", "모달 미트리거", "이중 확인", useBlocker]
root_cause: "ConfirmModal 카드의 md: 클래스가 flex items-end 오버레이 안에서 카드를 콘텐츠 너비로 수축시켰고, PracticeSet 뒤로가기가 navigate 직접 호출이라 모달을 우회했다"
status: resolved
resolution: "[[ISS-0081-confirm-modal-desktop-layout-broken-report]]"
related: ["[[DEC-0057-confirm-modal-bottom-sheet-all-sizes]]", "[[ISS-0070-leave-warning-modal-during-solving]]", "[[ISS-0083-daily-challenge-submit-false-leave-modal]]"]
source: "https://github.com/Twin-Fang/passQL/issues/142"
---

# ISS-0081: "풀이를 그만할까요?" 확인 모달이 데스크톱에서 깨짐

GitHub #142 (원본: 이슈 본문, 리포트 댓글, 후속 분석 댓글).

## 증상
데스크톱에서 모달 너비가 극도로 좁아지고 텍스트가 한 글자씩 세로로 나열되며 버튼("계속 풀기", "나가기")이 작게 세로로 쌓인다. 모바일은 바텀시트로 정상.

## 재현 조건
데스크톱 브라우저에서 문제 풀이 진입 → 뒤로가기(←) 클릭.

## 조사 기록
- 2026-04-12: 리포트 — 레이아웃 원인 외에 `PracticeSet` 뒤로가기 버튼이 `navigate("/")` 직접 호출이라 피드백 화면에서 모달을 거치지 않는 버그, "나가기" 후 `navigate("/")`가 다시 차단돼 두 번 확인해야 하는 버그도 수정.
- 2026-04-12: 후속 댓글 — `DailyChallenge`에서 "제출하기" 클릭 시 blocker가 모달을 오탐한다는 분석과 `isSubmitting` 조건 추가 제안. 이 이슈 안에서 처리됐다는 기록은 없고, GitHub #146으로 이어졌다.

## 근본 원인
`ConfirmModal` 카드의 `md:max-w-sm` 등 `md:` 클래스가 `flex items-end justify-center` 오버레이 안에서 카드를 수축시켰다.
