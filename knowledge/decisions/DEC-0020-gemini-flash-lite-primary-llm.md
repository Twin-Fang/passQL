---
type: decision
id: DEC-0020
created: 2026-04-07
reviewed: null
topics: [ai]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0015-gemini-primary-ollama-fallback]]", "[[ISS-0015-gemini-primary-ollama-fallback-report]]", "[[DEC-0029-python-ai-server-primary-gemini-fallback]]"]
---

# DEC-0020: 기본 LLM을 Gemini 2.0 Flash-Lite로, Ollama는 fallback·경량 작업용

## 문제 정의 (Context)
AI 기능이 `OllamaClient` 단독이라 문제 생성 등 고난도 추론에서 로컬 LLM 성능이 부족했고, 상용 API 없이는 문제 생성 품질을 보장할 수 없다고 판단했다 (GitHub #16).

## 결정 (Decision)
- 기본 LLM 클라이언트를 Gemini 2.0 Flash-Lite(`gemini-2.0-flash-lite`)로 교체한다.
- 기존 `OllamaClient`는 fallback으로 둔다 (CircuitBreaker 연계: Gemini 실패 → Ollama → 최종 실패 메시지).
- 역할 분리(이슈 본문): Gemini는 문제 생성·`explainError`·`diffExplain` 등 고품질 응답, Ollama는 간단한 개념 질의(개념 태그 유사도, 힌트 요청 등 경량 작업).
- 설정 키 `gemini.api-key`, `gemini.base-url`, `gemini.model`(기본 `gemini-2.0-flash-lite`).

## 검토한 대안 (Alternatives)
- Ollama 단독 유지: 고난도 추론 성능 부족으로 기본 경로에서 내림 (이슈 본문).
- 다른 상용 모델과의 비교는 논의 기록 없음. 선택 근거로 "입력 $0.075/1M tokens, 출력 $0.30/1M tokens로 최저가 상용 모델"만 적혀 있다.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음 (기대 효과는 문제 생성 품질 확보로 이슈 본문에 적힘).

**부정**
- 리포트: `gemini.api-key`가 dev 설정에 평문 — prod는 환경변수/Secret Manager 필요.

## 영향 범위 (Scope)
`PQL-Domain-AI` `GeminiClient`, `OllamaClient`, `AiService`, `application-dev.yml`·`application-prod.yml`.
(원본 기록) 이후 GitHub #39 이슈 본문은 AI 호출 경로를 "Spring → Python AI Server(Gemini 2.5 flash-lite), fallback Spring `GeminiClient`, Ollama는 embedding 전용"으로 적었다 — [[DEC-0029-python-ai-server-primary-gemini-fallback]]. #39는 이 결정을 대체한다고 명시하지 않았다.

## 출처 (References)
- GitHub #16 이슈 본문 「해결 방안」, `## 개요` 리포트 댓글 (2026-04-07)
