---
type: issue
id: ISS-0129
created: 2026-04-13
topics: [practice]
symptoms: ["다시 풀기", "오답이 정답으로 표시", markCorrect, practiceStore, PracticeResult, RecommendationPractice, "결과 화면 초록색"]
root_cause: "복습 정답 제출 시 `markCorrect(questionUuid)`가 store `results`의 `isCorrect`를 `true`로 덮어씀"
status: resolved
resolution: "[[ISS-0129-review-overwrites-original-result-report]]"
related: ["[[DEC-0073-session-result-fixed-at-first-submit]]"]
source: "https://github.com/Twin-Fang/passQL/issues/235"
---

# ISS-0129: 복습에서 맞추면 결과 화면의 틀린 문제가 맞은 문제로 바뀜

GitHub #235 (원본: 이슈 본문과 리포트 댓글).

## 증상
연습 세트 완료 후 결과 화면에서 틀린 문제를 "다시 풀기"로 복습해 맞춘 뒤 돌아오면, 원래 틀린 문제가 초록색(맞은 문제)으로 표시된다.

## 재현 조건
1. 연습 세트를 일부 오답으로 완료
2. `PracticeResult`에서 틀린 문제 카드 "다시 풀기"
3. `RecommendationPractice`에서 정답 제출
4. "돌아가기"로 결과 화면 복귀 → 초록색 표시

## 조사 기록
- 2026-04-13: 원인 코드 `client/src/pages/RecommendationPractice.tsx`의 `markCorrect()` 호출부, `client/src/stores/practiceStore.ts`의 `markCorrect` 액션.

## 근본 원인
복습 제출이 세션 결과 store 값을 덮어쓰는 구조. `PracticeResult`는 이 store 값으로 정오답 색을 렌더링한다.
