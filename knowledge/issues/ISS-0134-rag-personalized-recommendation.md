---
type: issue
id: ISS-0134
created: 2026-04-13
topics: [home, ai]
symptoms: ["GET /api/questions/recommendations", "ORDER BY RANDOM()", "랜덤 추천", Qdrant, bge-m3, "similar() 미구현", passql_questions]
root_cause: "추천 API가 `ORDER BY RANDOM()`만 쓰고 풀이 기록을 반영하지 않으며, 준비된 RAG 인프라가 연결되지 않음"
status: resolved
resolution: "[[ISS-0134-rag-personalized-recommendation-report]]"
related: ["[[DEC-0077-rag-recommendation-with-random-fallback]]"]
source: "https://github.com/Twin-Fang/passQL/issues/248"
---

# ISS-0134: 문제 추천이 완전 랜덤이라 풀이 기록이 반영되지 않음

GitHub #248 (원본: 이슈 본문과 리포트 댓글).

## 증상
`GET /api/questions/recommendations`가 `ORDER BY RANDOM()`으로만 추천한다. 오답·취약 토픽이 반영되지 않는다. Qdrant, Ollama bge-m3 임베딩 클라이언트가 준비돼 있지만 미연결이고, Python AI 서버 `similar()`는 `raise CustomError("아직 구현되지 않았습니다")` 상태.

## 재현 조건
해당 없음 (기능 추가).

## 조사 기록
- 2026-04-13: 설계 — 문제를 `stem + 토픽 + 난이도 + 개념태그`로 임베딩해 `passql_questions`에 적재, 오답·취약 토픽으로 쿼리 벡터 합성, 이미 푼 문제 제외, AI 서버 장애 시 RANDOM fallback.

## 근본 원인
해당 없음 (미구현 기능).
