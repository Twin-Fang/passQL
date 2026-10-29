---
type: issue
id: ISS-0064
created: 2026-04-11
topics: [practice]
symptoms: ["추천 문제 플로우 UI 불일치", AnswerFeedback, "A/B/C/D 뱃지", correctKey, "다음 문제 버튼", PracticeSet, DailyChallenge, "중첩 button"]
root_cause: "GitHub #106에서 DailyChallenge·PracticeSet 플로우를 통일했으나 홈 추천 문제 경로(QuestionDetail → AnswerFeedback)에는 같은 기준이 적용되지 않았다"
status: resolved
resolution: "[[ISS-0064-recommended-flow-ui-unify-report]]"
related: ["[[DEC-0051-no-auto-execute-review-after-submit]]", "[[ISS-0060-daily-challenge-result-ux]]", "[[DEC-0048-daily-challenge-wrong-answer-not-submitted]]"]
source: "https://github.com/Twin-Fang/passQL/issues/112"
---

# ISS-0064: 추천 문제 풀기 플로우 UI가 PracticeSet·DailyChallenge와 불일치

GitHub #112 (원본: 이슈 본문과 댓글).

## 증상
홈 추천 문제 클릭 시 들어가는 QuestionDetail → AnswerFeedback 플로우가 PracticeSet·DailyChallenge와 구조가 다르다. 비교 블록의 A/B/C/D 뱃지, 오답 헤더의 `correctKey` 알파벳 노출, 하단 "다음 문제" 버튼, 제각각인 제출 버튼 스타일.

## 재현 조건
홈 → 추천 문제 → 풀이 → 결과.

## 조사 기록
- 2026-04-11: 작업 댓글 — 같은 작업에서 `ChoiceCard`의 중첩 `<button>` HTML 위반, RESULT_MATCH 선택지(JSON body)가 execute API로 넘어갈 수 있는 버그, 실행 실패를 조용히 무시하던 UX 버그도 수정.

## 근본 원인
플로우별 UI 통일이 추천 문제 경로에 적용되지 않았다.
