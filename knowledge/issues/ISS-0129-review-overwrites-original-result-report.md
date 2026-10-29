---
type: completion-report
id: ISS-0129
created: 2026-04-13
topics: [practice]
status: resolved
resolves: "[[ISS-0129-review-overwrites-original-result]]"
related: ["[[DEC-0073-session-result-fixed-at-first-submit]]"]
source: "https://github.com/Twin-Fang/passQL/issues/235"
---

# ISS-0129 완료 리포트: `markCorrect` 액션 제거

GitHub #235 `## 개요` 리포트 댓글(2026-04-13) 기준.

## 해결 방법
- `client/src/stores/practiceStore.ts`: `markCorrect` 액션과 `PracticeActions` 인터페이스 정의 제거.
- `client/src/pages/RecommendationPractice.tsx`: `markCorrect` import·호출 제거, `useCallback` 의존성 배열에서 제거.
- 세션 결과(`results`)는 `submitAndAdvance` 시점에 확정되고 이후 바뀌지 않는다. 복습 제출은 `heatmap`, `progress`, `recommendations` 캐시 무효화만 한다.

## 근본 원인 (확정)
`markCorrect(questionUuid)`가 store `results`의 `isCorrect`를 덮어썼다.

## 재발 방지
`markCorrect`를 참조하는 다른 코드가 없음을 전체 탐색으로 확인. 결과 화면의 "복습 완료" 뱃지는 미구현, 추후 별도 이슈 예정(원본).

## 교훈
(원본에 없음, 볼트 정리) 결과 화면 정오답이 바뀌면 세션 결과 store를 덮어쓰는 액션이 있는지부터 본다.
