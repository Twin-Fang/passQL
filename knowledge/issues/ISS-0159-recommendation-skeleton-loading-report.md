---
type: completion-report
id: ISS-0159
created: 2026-04-26
topics: [home]
status: resolved
resolves: "[[ISS-0159-recommendation-skeleton-loading]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/301"
---

# ISS-0159 완료 리포트: 추천문제 초기 로딩에 스켈레톤 카드 3개 표시

GitHub #301 구현 완료 보고 댓글(2026-04-26) 기준.

## 해결 방법
- `useRecommendations`에서 `isLoading` 노출, 로딩 중에도 섹션 표시.
- `recommendationsLoading`이 true면 `h-[72px] rounded-2xl` 스켈레톤 카드 3개.
- 새로고침(`isFetching`) 중에는 기존 카드 유지(깜빡임 방지).
- 커밋 `b48daf2`(GitHub #298 무한 호출 수정과 함께 구현).

## 근본 원인 (확정)
로딩 중 섹션 전체를 숨기는 렌더링 조건.

## 재발 방지
원본에 적혀 있지 않다.

## 교훈
(원본에 없음, 볼트 정리) 초기 로딩(`isLoading`)과 재조회(`isFetching`)를 구분해 스켈레톤은 초기 로딩에만 쓴다.
