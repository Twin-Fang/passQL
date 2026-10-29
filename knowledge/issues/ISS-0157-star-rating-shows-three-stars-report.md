---
type: completion-report
id: ISS-0157
created: 2026-04-25
topics: [design-system, question-bank]
status: resolved
resolves: "[[ISS-0157-star-rating-shows-three-stars]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/292"
---

# ISS-0157 완료 리포트: 별 개수를 5개로 수정

GitHub #292 구현 보고서 댓글(2026-04-25) 기준.

## 해결 방법
`client/src/components/StarRating.tsx`에서 `Array.from({ length: 3 })` → `Array.from({ length: 5 })`. 난이도 1~5 전체 범위가 표시된다.

## 근본 원인 (확정)
`Array.from({ length: 3 })` 하드코딩으로 난이도 4~5 문제에서 별이 잘렸다.

## 재발 방지
원본에 적혀 있지 않다.

## 교훈
(원본에 없음, 볼트 정리) 등급·점수 표시가 잘리면 최대값 하드코딩부터 본다.
