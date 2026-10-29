---
type: issue
id: ISS-0023
created: 2026-04-08
topics: [home, practice]
symptoms: ["추천 문제", "/api/questions/recommendations", "랜덤 문제", "데일리 챌린지 제외", "ORDER BY RAND"]
root_cause: "데일리 챌린지 1문제 외에 가볍게 고를 추천 풀이 없었다 (기능 이슈)"
status: resolved
resolution: "[[ISS-0023-random-question-recommendations-api-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/27"
---

# ISS-0023: 랜덤 추천 문제 API (Question Recommendations)

GitHub #27 (원본: 이슈 본문과 댓글).

## 증상
데일리 챌린지 1문제 외에 "뭐 풀지 모르겠을 때" 고를 추천 풀이 필요했다. D3에는 화면 연결이 없지만 D5 홈 확장에서 바로 쓰도록 API를 먼저 만든다고 적었다.
제안: `GET /api/questions/recommendations?size=N`, 매 호출 랜덤 N개 활성 문제(기본 3, 최대 5), 오늘의 데일리 챌린지 문제 제외, 캐싱 없음.

## 재현 조건
해당 없음 (기능 이슈).

## 조사 기록
- 2026-04-08: `## 개요` 리포트 댓글 (아래 리포트).

## 근본 원인
해당 없음 (기능 이슈).
