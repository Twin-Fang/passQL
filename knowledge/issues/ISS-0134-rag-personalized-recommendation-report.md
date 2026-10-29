---
type: completion-report
id: ISS-0134
created: 2026-04-13
topics: [home, ai]
status: resolved
resolves: "[[ISS-0134-rag-personalized-recommendation]]"
related: ["[[DEC-0077-rag-recommendation-with-random-fallback]]"]
source: "https://github.com/Twin-Fang/passQL/issues/248"
---

# ISS-0134 완료 리포트: 오답 벡터 기반 개인화 추천 + RANDOM 폴백

GitHub #248 `## 개요` 리포트 댓글(2026-04-13) 기준.

## 해결 방법
- Python `ai/src/services/qdrant_client.py`: `create_collection_if_not_exists(collection, vector_size)`(Cosine), `get_vector(collection, point_id)`, `search()`에 `must_not_ids`.
- Python `ai_service.py`: `_build_embed_text()`(토픽 경로 + 난이도 + 개념 태그 + stem 앞 300자를 `[TOPIC]/[DIFFICULTY]/[TAGS]/[STEM]` 구조로), `index_question()`, `index_questions_bulk()`(개별 실패 스킵), `recommend()`(최근 오답 최대 10개 벡터 단순 평균 → 코사인 검색, 최근 푼 200개 must_not 제외).
- `ai_router.py`: `POST /api/ai/index-question`, `POST /api/ai/index-questions-bulk`, `POST /api/ai/recommend`.
- Java `AiGatewayClient.java`: `indexQuestion()`, `indexQuestionsBulk()`, `recommend()` — 실패 시 null 반환.
- `QuestionGenerateService.java`: `indexQuestionAsync(Question)`를 `Thread.startVirtualThread()`로, 문제 저장 직후 호출. 실패는 warn 로그만.
- `SubmissionRepository.java`: `findRecentWrongQuestionUuids`, `findSolvedQuestionUuids`(`SOLVED_QUESTION_LIMIT = 200`).
- `PQL-Application`에 `RecommendationService.java` 신설 — `PQL-Domain-Question`이 `PQL-Domain-Submission`에 의존할 수 없어서. size 1-5 클램핑, AI 추천 후 빈 결과면 RANDOM.
- `QuestionController.java`: `@RequestParam(required = false) UUID memberUuid`.

## 근본 원인 (확정)
해당 없음 (기능 추가).

## 재발 방지
리포트 주의사항:
- 네이티브 쿼리 UUID 바인딩은 `CAST(:param AS uuid)` 사용, `::uuid` 금지(Hibernate 파라미터 파싱 오류 선례).
- 관리자 전체 재색인 엔드포인트는 Python에만 있고 Spring 관리자 트리거는 미구현 — 별도 이슈 필요.

## 교훈
(원본에 없음, 볼트 정리) 추천이 랜덤처럼 보이면 오답 기록 유무와 AI 서버 응답(폴백 경로)부터 확인한다.
