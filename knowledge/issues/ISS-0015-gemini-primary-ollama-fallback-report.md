---
type: completion-report
id: ISS-0015
created: 2026-04-07
topics: [ai]
status: resolved
resolves: "[[ISS-0015-gemini-primary-ollama-fallback]]"
related: ["[[DEC-0020-gemini-flash-lite-primary-llm]]", "[[DEC-0019-never-edit-applied-migrations]]"]
source: "https://github.com/Twin-Fang/passQL/issues/16"
---

# ISS-0015 완료 리포트: `GeminiClient`(chat / chatStructured) 신설, Ollama fallback, AI API 3종 노출

GitHub #16 `## 개요` 리포트 댓글(2026-04-07) 기준.

## 해결 방법
- `server/PQL-Domain-AI/src/main/java/com/passql/ai/client/GeminiClient.java`: Google GenAI SDK(`com.google.genai`) 사용. `chat(systemPrompt, userPrompt, temperature, maxTokens)` + 모델 명시 오버로드, `chatStructured`(`responseMimeType("application/json")` + `responseSchema`). 응답이 null/공백이면 `IllegalStateException`으로 fallback을 유도.
- 호출 흐름: `AiService` → `GeminiClient`(기본) → CircuitBreaker 발동 시 `OllamaClient`(fallback).
- `AiController`: `/api/ai/explain-error`, `/api/ai/diff-explain`, `/api/ai/similar/{questionId}`. 나머지 컨트롤러 Swagger 보완.
- `application.yml`: `flyway.validate-on-migrate: false` 추가 (마이그레이션 파일 수정 시 체크섬 충돌 방지).
- `V0_0_21__add_concept_tag_table.sql`: `question_concept_tag` + `app_setting`·`prompt_template`·`topic` 시드. 멱등성: 문자열 PK(`app_setting`, `topic`)는 `ON DUPLICATE KEY UPDATE`, AUTO_INCREMENT PK(`prompt_template`)는 `INSERT ... SELECT WHERE NOT EXISTS (key_name, version)`.
- `GeminiClientTest`: 실제 API 호출 통합 테스트(dev 프로파일).

## 근본 원인 (확정)
원본에 별도 기록 없음 (이슈 본문의 문제점 참조).

## 재발 방지
리포트 주의사항:
- `gemini.api-key`가 `application-dev.yml`에 평문으로 있어 prod는 환경변수 또는 Secret Manager로 교체해야 한다.
- `explainError`, `diffExplain`의 실제 프롬프트 조립은 후속 이슈 — 현재는 Controller → Service 연결 구조만.
- `validate-on-migrate: false`로 체크섬 검증이 생략되므로 운영 적용 전 주의.

## 교훈
원본에 적혀 있지 않다.
