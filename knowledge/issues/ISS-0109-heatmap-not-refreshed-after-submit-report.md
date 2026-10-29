---
type: completion-report
id: ISS-0109
created: 2026-04-12
topics: [home, progress-stats]
status: resolved
resolves: "[[ISS-0109-heatmap-not-refreshed-after-submit]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/194"
---

# ISS-0109 완료 리포트: 제출 지점마다 heatmap·progress 쿼리 무효화

GitHub #194 `## 개요` 리포트 댓글(2026-04-12)과 완료 보고 댓글(2026-04-22) 기준. 두 댓글의 수정 내용 표기가 다르다(아래).

## 해결 방법
2026-04-12 리포트:
- `DailyChallenge.tsx`, `QuestionDetail.tsx`, `RecommendationPractice.tsx`: 제출 성공 시 `queryClient.invalidateQueries({ queryKey: ["heatmap"] })`, `queryClient.invalidateQueries({ queryKey: ["progress"] })`.
- `PracticeSet.tsx`: 마지막 문제 제출 시(`currentIndex + 1 >= totalQuestions`)에만 무효화. 매 문제마다 무효화하면 불필요한 API 호출이 반복되어서라고 리포트가 적었고, 중간 이탈 시 갱신하지 않는 것이 의도된 동작.

2026-04-22 완료 보고: "제출 완료 시점에 `invalidateQueries(['home'])` 추가", "이번 인증 시스템 도입(GitHub #121) 작업과 함께 처리". 두 기록 중 최종 코드가 어느 쪽인지는 원본에 적혀 있지 않다.

## 근본 원인 (확정)
TanStack Query의 heatmap/progress 캐시 무효화 누락.

## 재발 방지
리포트 주의사항: `heatmap` 쿼리 키는 `["heatmap", uuid, from, today]`지만 prefix 매칭이라 `["heatmap"]`으로 충분. `PracticeSet` 조건은 `submitAndAdvance` 호출 후 위치하므로 index 증가 전 값으로 비교.

## 교훈
(원본에 없음, 볼트 정리) 제출 후 다른 화면 수치가 늦게 바뀌면 제출 성공 콜백의 쿼리 무효화 목록부터 본다.
