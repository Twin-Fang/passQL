---
type: completion-report
id: ISS-0251
created: 2026-10-08
topics: [ai, practice]
status: resolved
resolves: "[[ISS-0251-similar-questions-api-todo-500]]"
related: ["[[DEC-0113-similar-via-recommend-reuse]]"]
source: "https://github.com/Twin-Fang/passQL/issues/442"
---

# ISS-0251 완료 리포트: 기존 `recommend`를 재사용해 Spring에서 유사 문제 조합

GitHub #442 `## 개요` 리포트 댓글 기준 (v0.4.1, PR #443).

## 해결 방법
- `RecommendationService.findSimilar()`(신규): 기준 문제 1개를 쿼리 원본과 제외 목록에 함께 넣어 그 벡터로 검색하되 자기 자신은 제외. 문제 요약(`getRecommendationsByUuids`)과 점수를 합쳐 `SimilarQuestion` 반환. k는 1~5로 보정. 미색인·AI 실패는 빈 목록(200).
- `AiController`: 미구현 `AiService.getSimilar` 대신 위 메서드 호출. `AiControllerDocs` 보강.
- `RecommendationServiceSimilarTest` 3건.

## 근본 원인 (확정)
이슈 본문과 같음.

## 재발 방지
- 검증: 운영 AI 컨테이너에서 같은 요청 직접 실행(읽기 전용) — 색인 192건 중 유사 3건(0.81 / 0.788 / 0.76), 자기 자신 미포함. 운영 v0.4.1 비로그인 호출 401.
- 주의(원본): 로그인 상태 운영 호출은 확인 못 함. 이후 `recommend`를 바꾸면 유사 문제도 함께 바뀐다. `AiService.getSimilar`와 `OllamaClient`·`QdrantSearchClient`의 Java TODO 스텁은 남아 있음(사용처 없음).

## 교훈
(원본에 없음, 볼트 정리) 실패 시 섹션을 숨기는 UI는 서버 500을 가린다 — 섹션이 한 번도 안 보이면 API 응답 코드부터 본다.
