---
type: issue
id: ISS-0083
created: 2026-04-12
topics: [practice]
symptoms: ["풀이를 그만할까요?", "제출 시 모달 오탐", useBlocker, DailyChallenge, submitting, "navigate(\"/\")"]
root_cause: "DailyChallenge useBlocker 조건에 제출 진행 상태가 없어 제출 API 호출 중에도 blocker가 켜져 있었다"
status: resolved
resolution: "[[ISS-0083-daily-challenge-submit-false-leave-modal-report]]"
related: ["[[ISS-0070-leave-warning-modal-during-solving]]", "[[ISS-0081-confirm-modal-desktop-layout-broken]]"]
source: "https://github.com/Twin-Fang/passQL/issues/146"
---

# ISS-0083: 데일리 챌린지 정답 제출 시 이탈 확인 모달이 잘못 표시

GitHub #146 (원본: 이슈 본문과 작업 댓글).

## 증상
데일리 챌린지에서 "제출하기"를 누르면 이탈하려는 것이 아닌데도 "풀이를 그만할까요?" 모달이 뜬다.

## 재현 조건
데일리 챌린지 진입 → 선택지 선택 → "제출하기".

## 조사 기록
- 2026-04-12: GitHub #142 마지막 댓글과 #144 특이사항에서 먼저 제기됨.
- 2026-04-12: 작업 댓글 — 기존 조건 `useBlocker(!isLoading && feedback === null)`. 제출 중에도 `feedback === null`이라 blocker가 켜져 있고, React Router 내부 처리 또는 오답 catch 블록의 `navigate("/")`가 이탈로 인식됐다.

## 근본 원인
blocker 조건이 제출 진행 상태를 고려하지 않았다.
