---
type: issue
id: ISS-0326
created: 2026-10-18
topics: [home, design-system]
symptoms: [환영 문구 잘림, "합격에 가까…", 알림 종 혼자 떠 있음, 로고 없음, 캡처 검수 단계 없음]
root_cause: "환영 문구가 한 줄 큰 제목이라 잘리고, 상단에 로고 없이 알림 종만 있었으며, 캡처를 눈으로 검수하는 단계가 없었다"
status: resolved
resolution: "[[ISS-0326-home-top-bar-redesign-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/530"
---

# ISS-0326: 홈 상단 재설계 — 로고·알림 버튼 상단 바, 잘리는 환영 문구

GitHub #530 (원본: 이슈 본문과 댓글).

## 증상
홈 상단 디자인이 어색하다(사용자 지적). 환영 문구가 한 줄 큰 제목이라 "오늘도 한 문제씩, 합격에 가까…"로 잘린다. 오른쪽 위 알림 종이 맥락 없이 혼자 떠 있다. 화면에 passQL 로고가 없다. 캡처를 눈으로 검수하는 단계가 없어 이런 화면이 그대로 나갔다.

## 재현 조건
앱 홈 진입.

## 조사 기록
- 2026-10-18: PR #534(GitHub #529와 공동) 머지.
- 2026-10-26: iOS 시뮬레이터(iPhone 16 Pro)에서 남은 확인 항목 점검.

## 근본 원인
이슈 본문의 증상 서술 그대로.
