---
type: decision
id: DEC-0077
created: 2026-04-13
reviewed: null
topics: [home, ai]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0134-rag-personalized-recommendation]]", "[[ISS-0134-rag-personalized-recommendation-report]]"]
---

# DEC-0077: 문제 추천은 Qdrant 벡터 검색 기반 개인화, 신호 집계는 Java·검색은 Python, 실패 시 RANDOM 폴백

## 문제 정의 (Context)
추천 API가 `ORDER BY RANDOM()`만 쓰고 풀이 기록을 반영하지 않았다. RAG 인프라(Qdrant, bge-m3)는 준비돼 있었다(GitHub #248).

## 결정 (Decision)
이슈 본문 "설계 원칙"과 리포트 기준:
- 사용자 신호(오답 UUID, 풀이 UUID)는 Java가 DB에서 집계해 Python에 전달한다. Python은 임베딩 생성과 Qdrant 검색만 하고 DB에 직접 접근하지 않는다.
- Qdrant 컬렉션 `passql_questions`를 기존 `passql_concepts`와 분리한다.
- 쿼리 벡터는 최근 오답(최대 10개) 벡터의 단순 평균, 최근 푼 문제(200개)는 제외.
- 오답 없음·AI 서버 장애·결과 없음이면 기존 RANDOM 추천으로 폴백한다.
- 두 도메인을 조합하는 `RecommendationService`는 `PQL-Application` 레이어에 둔다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 리포트: 모든 예외 경로에서 RANDOM으로 폴백해 가용성 보장. 색인은 VirtualThread 비동기라 문제 등록 응답 속도에 영향 없음.

**부정**
- 색인 실패는 warn 로그만 남는다. 전체 재색인의 Spring 관리자 트리거는 미구현.

## 영향 범위 (Scope)
`ai/src/services/qdrant_client.py`, `ai_service.py`, `ai_router.py`, `AiGatewayClient.java`, `QuestionGenerateService.java`, `SubmissionRepository.java`, `RecommendationService.java`, `QuestionController.java`.

## 출처 (References)
- GitHub #248 이슈 본문 "설계 원칙", 리포트 댓글(2026-04-13)
