---
type: issue
id: ISS-0075
created: 2026-04-11
topics: [practice, design-system]
symptoms: ["제출 버튼 위치 불일치", "fixed bottom", PracticeFeedbackBar, AnswerFeedback, z-index, "스크롤 영역 내부 버튼"]
root_cause: "QuestionDetail 제출 버튼이 스크롤 영역 안에 있어 fixed bottom인 PracticeFeedbackBar와 동시에 존재하고, 화면마다 버튼 컨테이너 스타일이 달랐다"
status: resolved
resolution: "[[ISS-0075-fixed-bottom-action-buttons-report]]"
related: ["[[ISS-0078-schema-viewer-ui-rounded-unify]]"]
source: "https://github.com/Twin-Fang/passQL/issues/131"
---

# ISS-0075: 제출·액션 버튼 fixed bottom 전 화면 통일

GitHub #131 (원본: 이슈 본문과 리포트 댓글).

## 증상
`QuestionDetail`(단독·practiceMode)과 이를 쓰는 `DailyChallenge`·`PracticeSet`의 제출 버튼은 스크롤 영역 안에 있고, `AnswerFeedback`·`PracticeFeedbackBar`는 fixed bottom이다. 제출 후 피드백바와 제출 버튼이 동시에 존재하고 z-index·배경·테두리가 통일돼 있지 않다.

## 재현 조건
해당 없음 (UI 개선 요청).

## 조사 기록
- 2026-04-11: 이슈 본문이 `fixed bottom-0 inset-x-0`, 스크롤 `pb-24`, 제출 버튼 `z-20` / PracticeFeedbackBar `z-30`, 컨테이너 `bg-surface-page border-t border-border`를 제안.

## 근본 원인
해당 없음 (UI 개선).
