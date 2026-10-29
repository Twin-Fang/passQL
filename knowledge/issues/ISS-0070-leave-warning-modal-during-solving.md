---
type: issue
id: ISS-0070
created: 2026-04-11
topics: [practice]
symptoms: ["풀이 중 이탈", "경고 없음", "풀이 기록 유실", PracticeSet, DailyChallenge, QuestionDetail, useBlocker]
root_cause: "기능 추가 — 풀이 화면에 이탈 차단이 없어 PracticeSet 중간 이탈 시 세션 기록이 유실"
status: resolved
resolution: "[[ISS-0070-leave-warning-modal-during-solving-report]]"
related: ["[[DEC-0053-spa-only-leave-blocker]]", "[[ISS-0081-confirm-modal-desktop-layout-broken]]", "[[ISS-0083-daily-challenge-submit-false-leave-modal]]"]
source: "https://github.com/Twin-Fang/passQL/issues/121"
---

# ISS-0070: 문제 풀이 중 이탈 시 경고 모달 구현

GitHub #121 (원본: 이슈 본문과 리포트 댓글).

## 증상
`PracticeSet`, `DailyChallenge`, `QuestionDetail` 풀이 중 사이드바 메뉴·상단 Home 버튼·브라우저 뒤로가기 등 모든 경로로 경고 없이 이동된다. `PracticeSet`은 마지막 문제까지 끝내야 세션 기록이 저장되므로 중간 이탈 시 기록이 유실된다.

## 재현 조건
해당 없음 (기능 추가).

## 조사 기록
- 2026-04-11: 이슈 본문이 공통 `ConfirmModal`(모바일 바텀시트 / 데스크톱 중앙 모달), React Router DOM v7 `useBlocker`, 화면별 차단·해제 시점, 모달 문구("풀이를 그만할까요?", "지금 나가면 현재 풀이 기록이 저장되지 않아요.", 확인 "나가기", 취소 "계속 풀기")를 제안.

## 근본 원인
해당 없음 (기능 추가).
