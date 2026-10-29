---
type: issue
id: ISS-0095
created: 2026-04-12
topics: [home]
symptoms: ["추천 문제 고정", "새로고침 버튼", refetchRecommendations, isFetching, animate-refresh-once, animate-card-in, "spinning 고착"]
root_cause: "기능 추가 — 페이지를 새로 고치지 않으면 같은 추천 문제 3개가 고정 표시"
status: resolved
resolution: "[[ISS-0095-recommend-refresh-button-fadein-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/174"
---

# ISS-0095: AI 추천문제 새로고침 버튼 및 카드 페이드인 애니메이션

GitHub #174 (원본: 이슈 본문과 리포트 댓글).

## 증상
홈 AI 추천문제가 마음에 들지 않아도 다른 문제를 요청할 수 없고, 새로고침 전까지 같은 3개가 고정된다.

## 재현 조건
해당 없음 (기능 추가).

## 조사 기록
- 2026-04-12: 이슈 본문 제안 — 섹션 헤더 우측 새로고침 버튼, `GET /questions/recommendations` 재호출, 아이콘 360도 1회전, 새 카드 순차 페이드인, 로딩 중 중복 클릭 방지.

## 근본 원인
해당 없음 (기능 추가).
