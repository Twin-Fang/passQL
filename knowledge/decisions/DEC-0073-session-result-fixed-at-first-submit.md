---
type: decision
id: DEC-0073
created: 2026-04-13
reviewed: null
topics: [practice, progress-stats]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0129-review-overwrites-original-result]]", "[[ISS-0129-review-overwrites-original-result-report]]"]
---

# DEC-0073: 세션 결과는 최초 제출 기준으로 고정하고, 복습은 통계에만 반영한다

## 문제 정의 (Context)
결과 화면에서 "다시 풀기"로 복습해 맞추면 원래 오답이 정답으로 표시되는 버그(GitHub #235)가 있었다.

## 결정 (Decision)
결과 화면의 문제별 정오답은 최초 제출 시점을 기준으로 고정한다. 복습(다시 풀기)은 추가 학습으로 처리해 heatmap·progress 통계에만 반영하고 세션 결과는 바꾸지 않는다. 구현상 `results`는 `submitAndAdvance` 시점에 확정되며, 복습 제출은 `heatmap`, `progress`, `recommendations` 캐시 무효화만 한다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 결과 화면이 실제 세션 성적을 그대로 보여 준다.

**부정**
- 복습으로 맞춘 사실은 결과 화면에 드러나지 않는다("복습 완료" 뱃지는 미구현, 추후 별도 이슈 예정).

## 영향 범위 (Scope)
`client/src/stores/practiceStore.ts`(`markCorrect` 제거), `client/src/pages/RecommendationPractice.tsx`, `PracticeResult`.

## 출처 (References)
- GitHub #235 이슈 본문 "예상 동작", 리포트 댓글(2026-04-13)
