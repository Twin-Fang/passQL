---
type: issue
id: ISS-0157
created: 2026-04-25
topics: [design-system, question-bank]
symptoms: [StarRating, "별 3개", "난이도 5점 만점", "Array.from({ length: 3 })", "StarRating.tsx"]
root_cause: "`StarRating` 컴포넌트의 별 개수가 `Array.from({ length: 3 })`로 하드코딩됨"
status: resolved
resolution: "[[ISS-0157-star-rating-shows-three-stars-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/292"
---

# ISS-0157: `StarRating` 컴포넌트가 난이도 5점 만점을 별 3개로만 표시

GitHub #292 (원본: 이슈 본문과 구현 보고서 댓글).

## 증상
난이도는 5점 만점인데 별이 최대 3개까지만 표시된다. 난이도 4~5 문제가 3/3으로 꽉 찬 채 보여 정확한 난이도가 전달되지 않는다. 관련 파일 `client/src/components/StarRating.tsx`.

## 재현 조건
문제 목록(`/questions`) 또는 홈에서 난이도 4·5 문제 확인 → 별 3개 전부 채워짐.

## 조사 기록
- 2026-04-25: `StarRating.tsx:11`의 `{Array.from({ length: 3 }, (_, i) => (` 확인.

## 근본 원인
별 개수 하드코딩(`length: 3`).
