---
type: decision
id: DEC-0113
created: 2026-10-08
reviewed: null
topics: [ai, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0251-similar-questions-api-todo-500]]", "[[ISS-0251-similar-questions-api-todo-500-report]]", "[[DEC-0122-remove-python-ai-stubs]]"]
---

# DEC-0113: 유사 문제는 AI 서버를 새로 만들지 않고 기존 `POST /api/ai/recommend`를 Spring에서 조합해 쓴다

## 문제 정의 (Context)
`GET /api/ai/similar/{questionUuid}`가 미구현(TODO)이라 매번 500이었다. Python AI 서버 `similar`도 미구현 (GitHub #442).

## 결정 (Decision)
AI 서버의 기존 `POST /api/ai/recommend`(오답 벡터 평균으로 검색, `must_not` 제외)를 재사용한다. 기준 문제 하나를 "오답 목록"과 "제외 목록"에 함께 넣어 그 문제의 벡터로 검색하되 자기 자신은 뺀다. AI 서버 변경 없이 Spring `RecommendationService`에서 조합한다. AI 서버나 Qdrant 실패 시 500 대신 빈 목록.

## 검토한 대안 (Alternatives)
- AI 서버에 `similar`를 새로 구현: 원본은 "AI 서버를 새로 만들지 않고"라고만 적었고 탈락 이유는 적혀 있지 않다.

## 결과 (Consequences)
**긍정**
- AI 서버 변경 없이 복구.

**부정**
- 유사 문제가 "최근 오답 기반 추천"과 같은 AI 서버 경로를 쓰므로 `recommend`를 바꾸면 유사 문제도 함께 바뀐다(원본 주의사항).

## 영향 범위 (Scope)
서버 `RecommendationService`, `AiController`, AI 서버 `recommend`, 웹 `AnswerFeedback.tsx`, 앱 `similar_questions_section.dart`.

## 출처 (References)
- GitHub #442 이슈 본문 「해결 방향」, 리포트 댓글 (2026-10-08)
