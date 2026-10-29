---
type: decision
id: DEC-0029
created: 2026-04-09
reviewed: null
topics: [ai]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0029-realtime-ai-choice-set-prefetch]]", "[[DEC-0020-gemini-flash-lite-primary-llm]]"]
---

# DEC-0029: AI 호출은 Spring → Python AI Server(Gemini 2.5 flash-lite)가 메인, Spring `GeminiClient` 직접 호출이 fallback, Ollama는 embedding 전용

## 문제 정의 (Context)
GitHub #39에서 선택지 세트 생성과 관리자 AI 문제 등록의 AI 호출 경로를 정했다.

## 결정 (Decision)
- 메인: Spring → Python AI Server → Gemini API (`gemini-2.5-flash-lite`).
- Fallback: Python AI Server 다운 시 Spring 내장 `GeminiClient` 직접 호출 (`@CircuitBreaker`).
- Gemini 완전 실패 시 에러 응답 + 관리자 토스트 (관리자 설계 댓글의 우선순위 표).
- Ollama는 embedding 전용으로 한정한다.
- 구조화 응답은 `chatStructured()`(JSON Schema)로 JSON 파싱 실패를 막는다 (관리자 설계 댓글).

## 검토한 대안 (Alternatives)
논의 기록 없음.
(원본 기록) GitHub #16은 Spring `GeminiClient`(Gemini 2.0 Flash-Lite)를 기본, Ollama를 fallback·경량 작업용으로 두었다 — [[DEC-0020-gemini-flash-lite-primary-llm]]. #39는 그 결정을 대체한다고 명시하지 않았고, 바꾼 이유도 적지 않았다.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`PQL-Domain-AI` `AiGatewayClient`·`GeminiClient`, `ai/src/services/gemini_client.py`, `ai/src/routers/ai_router.py`(`/api/ai/generate-question`, `/api/ai/test-prompt`), Ollama 사용처.

## 출처 (References)
- GitHub #39 이슈 본문 「AI 호출 경로」, 구현 계획·관리자 설계 댓글 (2026-04-09)
