---
type: issue
id: ISS-0015
created: 2026-04-07
topics: [ai]
symptoms: [OllamaClient, "로컬 LLM 성능 부족", UnsupportedOperationException, "explainError 미구현", "diffExplain 미구현", GeminiClient]
root_cause: "AI 기능이 OllamaClient 단독이라 고난도 추론(문제 생성) 성능이 부족했고 핵심 메서드가 TODO 상태였다"
status: resolved
resolution: "[[ISS-0015-gemini-primary-ollama-fallback-report]]"
related: ["[[DEC-0020-gemini-flash-lite-primary-llm]]"]
source: "https://github.com/Twin-Fang/passQL/issues/16"
---

# ISS-0015: AI 클라이언트를 Gemini 2.0 Flash-Lite 기반으로 전환, Ollama Fallback 구조

GitHub #16 (원본: 이슈 본문과 댓글).

## 증상
- AI 기능 전체가 `OllamaClient`만 쓰도록 설계되어, 문제 생성 같은 고난도 추론에서 로컬 LLM 성능이 부족했다.
- `AiService`의 `explainError`, `diffExplain`이 `UnsupportedOperationException("TODO")` 상태였다.
- 상용 API 없이는 문제 생성 품질을 보장할 수 없다고 적었다.

## 재현 조건
해당 없음 (기능 개선 이슈).

## 조사 기록
- 2026-04-07: `## 개요` 리포트 댓글 (아래 리포트).

## 근본 원인
로컬 LLM(Ollama) 단독 구조의 성능 한계와 서비스 메서드 미구현 (이슈 본문).
