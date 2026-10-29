---
type: issue
id: ISS-0136
created: 2026-04-13
topics: [practice, design-system]
symptoms: [PracticeResult, "정답 오답 카드 구분 불분명", "다시 풀기 버튼", PracticeFeedbackBar, feedback-bar-next--error, "카테고리 목록으로"]
root_cause: "결과 카드의 정답/오답 시각 구분이 불분명하고 정답 카드에서는 다시 풀기에 접근할 수 없음"
status: resolved
resolution: "[[ISS-0136-result-card-correct-wrong-colors-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/251"
---

# ISS-0136: 결과 화면 정답/오답 카드 구분이 불분명

GitHub #251 (원본: 이슈 본문과 댓글).

## 증상
`PracticeResult.tsx` 결과 카드에서 정답/오답 구분이 약하고, 정답 카드는 아코디언이 열리지 않아 `다시 풀기`에 접근할 수 없다. 레이블은 오답에만 표시. 하단 버튼 레이블이 "카테고리 목록으로".

## 재현 조건
해당 없음 (디자인 개선).

## 조사 기록
- 2026-04-13: 요청 — 정답 `bg-green-50`/`border-green-200`, 오답 `bg-red-50`/`border-red-200`, `다시 풀기` 버튼 정답 초록(`feedback-bar-next--correct`, `#22C55E`)·오답 빨강(`feedback-bar-next--error`, `#EF4444`), 레이블 "태그 목록으로", 결과 카드 신고 버튼 제거("결과 화면에서 불필요").

## 근본 원인
해당 없음 (디자인 개선).
