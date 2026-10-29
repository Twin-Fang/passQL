---
type: decision
id: DEC-0187
created: 2026-10-27
reviewed: null
topics: [ai]
status: active
supersedes: DEC-0029
superseded_by: null
related: ["[[ISS-0410-claude-api-provider-switch]]", "[[ISS-0410-claude-api-provider-switch-report]]", "[[DEC-0188-ai-connections-priority-fallback]]", "[[DEC-0029-python-ai-server-primary-gemini-fallback]]", "[[DEC-0122-remove-python-ai-stubs]]"]
---

# DEC-0187: AI 제공자는 모델 이름으로 고르고(`claude-*` → Claude), 기본 모델은 가장 싼 `claude-haiku-5-5`, Gemini 경로는 유지

## 문제 정의 (Context)
AI 호출이 Gemini 한 곳에 묶여 있어 Claude Max 플랜에 포함된 월 API 크레딧($100)을 쓸 방법이 없었다 (GitHub #688).

## 결정 (Decision)
- Spring `AiChatClient`와 AI 서버 `llm_client`가 같은 규칙으로 모델 이름이 `claude-`로 시작하면 Claude, 아니면 Gemini를 호출한다.
- 기본 모델은 가장 저렴한 Claude 모델 `claude-haiku-5-5`. 모든 프롬프트 모델과 `ai.default_model`을 이 값으로 바꿨다.
- Claude API 키는 Gemini 키와 같은 방식(암호화 저장, Redis 반영)으로 관리.
- Gemini 경로는 유지해 크레딧 소진 시 설정만 바꿔 되돌릴 수 있게 한다(이슈 본문).

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 플랜 포함 크레딧 사용, 설정만으로 Gemini 복귀 가능.

**부정**
- Claude 요청에 `temperature`·thinking 설정을 넣으면 실패(400 또는 빈 본문). 프롬프트 temperature는 Gemini에만 적용.

## 영향 범위 (Scope)
Spring `AiChatClient`·`ClaudeClient`·`GeminiClient`, AI 서버 `llm_client`·`claude_client`, 설정 `ai.claude_api_key`·`ai.model_override`·`ai.default_model`, 프롬프트 모델, 단가표, 호출 기록 출처 `CLAUDE_DIRECT`.

같은 날 GitHub #695가 `ai.model_override`·제공자별 키 설정을 제거하고 "AI 연결" 목록으로 옮겼다 — [[DEC-0188-ai-connections-priority-fallback]].

## 출처 (References)
- GitHub #688 이슈 본문 「해결 방안」, 리포트 댓글
- [[ISS-0410-claude-api-provider-switch]]
