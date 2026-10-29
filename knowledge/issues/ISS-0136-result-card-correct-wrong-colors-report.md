---
type: completion-report
id: ISS-0136
created: 2026-04-13
topics: [practice, design-system]
status: resolved
resolves: "[[ISS-0136-result-card-correct-wrong-colors]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/251"
---

# ISS-0136 완료 리포트: 결과 카드 정답/오답 색 분기, 다시 풀기 버튼 색 분기

GitHub #251 `## 개요` 리포트 댓글(2026-04-13) 기준.

## 해결 방법
- `client/src/pages/PracticeResult.tsx`: 카드·아코디언 구분선 정답 `bg-green-50 border-green-200` / 오답 `bg-red-50 border-red-200`, "정답"/"오답" 레이블 항상 표시, 신고 버튼·모달·토스트 코드 제거, 다시 풀기 버튼 카드 전체 너비(정답 `bg-green-500`, 오답 `bg-red-500`), 레이블 `"태그 목록으로"`.
- `client/src/components/PracticeFeedbackBar.tsx`: `isCorrect`에 따라 `feedback-bar-next--correct` / `feedback-bar-next--error`.
- 함께 변경: `client/src/components/MarkdownText.tsx` `MdInlineCode` `text-xs` → `text-sm`; `server/PQL-Web/src/main/resources/templates/admin/feedbacks.html` 상태 배지 `PENDING` → `대기중`, `REVIEWED` → `검토완료`, `APPLIED` → `적용됨`.

## 근본 원인 (확정)
해당 없음 (디자인 개선).

## 재발 방지
리포트 주의사항: 결과 카드 배경색이 디자인 시스템 토큰(`bg-surface-card`)을 벗어난 하드코딩 — 추후 토큰화 검토. 신고는 이제 풀이 중(`PracticeFeedbackBar`)에서만 가능.

## 교훈
논의 기록 없음.
