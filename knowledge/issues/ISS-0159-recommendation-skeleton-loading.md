---
type: issue
id: ISS-0159
created: 2026-04-25
topics: [home]
symptoms: ["AI 추천문제 섹션 숨김", "스켈레톤 누락", CLS, "레이아웃 점프", useRecommendations, isLoading]
root_cause: "추천문제 섹션만 로딩 중 스켈레톤 없이 섹션 전체를 숨김"
status: resolved
resolution: "[[ISS-0159-recommendation-skeleton-loading-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/301"
---

# ISS-0159: 홈 AI 추천문제 초기 로딩 중 섹션이 숨겨져 레이아웃 점프

GitHub #301 (원본: 이슈 본문과 구현 완료 보고 댓글). 기능 개선 이슈.

## 증상
홈 진입 시 AI 추천문제 섹션이 데이터 로딩 중 완전히 숨겨져 영역이 비어 보이고 레이아웃 점프(CLS)가 생긴다. 학습 현황·합격 준비도는 스켈레톤이 있지만 추천문제만 누락.

## 재현 조건
해당 없음 (홈 진입 시 초기 로딩 구간).

## 조사 기록
- 2026-04-25: 제안 — `useRecommendations()`의 `isLoading`일 때 카드 3개 스켈레톤, 새로고침(`isFetching`) 시 기존 카드 유지, 에러 시 섹션 숨김 유지.

## 근본 원인
렌더링 조건이 로딩 상태를 고려하지 않았다.
