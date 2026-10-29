---
type: completion-report
id: ISS-0075
created: 2026-04-11
topics: [practice, design-system]
status: resolved
resolves: "[[ISS-0075-fixed-bottom-action-buttons]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/131"
---

# ISS-0075 완료 리포트: 제출 버튼 `fixed bottom-0 inset-x-0 z-20`, z-index 계층 정립

GitHub #131 리포트 댓글 기준 (2026-04-11).

## 해결 방법
- `QuestionDetail.tsx`: 제출 버튼 래퍼를 스크롤 영역 밖 `fixed bottom-0 inset-x-0 z-20`으로, `pb-6 → pb-24`. DailyChallenge·PracticeSet은 이 수정만으로 해결.
- `AnswerFeedback.tsx`: 컨테이너 정답/오답 배경색 제거 → `bg-surface-page border-t border-border`, `h-[52px] → h-12`.
- `PracticeSet.tsx`: 제출 버튼 문구 `"다음 문제"` → `"확인하기"`(마지막 문제는 `"결과 보기"` 유지).
- z-index: PracticeFeedbackBar `z-30`이 제출 후 액션 버튼(`z-20`)을 덮는다.

## 근본 원인 (확정)
해당 없음 (UI 개선).

## 재발 방지
리포트 주의사항: `AnswerFeedback`(`max-w-180`)과 `QuestionDetail`(`max-w-120`)은 max-width가 다르게 유지된다. `PracticeFeedbackBar`는 변경하지 않았다.

## 교훈
원본에 적혀 있지 않다. (참고: 버튼 위 `border-t border-border`는 GitHub #135에서 다시 제거됐다.)
