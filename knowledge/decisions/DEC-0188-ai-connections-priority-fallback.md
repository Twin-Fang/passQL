---
type: decision
id: DEC-0188
created: 2026-10-27
reviewed: null
topics: [ai, admin]
status: active
supersedes: DEC-0133
superseded_by: null
related: ["[[ISS-0411-ai-connections-multi-key-fallback]]", "[[ISS-0411-ai-connections-multi-key-fallback-report]]", "[[DEC-0187-claude-provider-by-model-prefix]]", "[[DEC-0133-encrypted-gemini-key-single-source]]", "[[DEC-0122-remove-python-ai-stubs]]"]
---

# DEC-0188: AI 키는 관리자 "AI 연결" 목록(제공자+키+기본 모델+우선순위)으로 관리하고, 한도·키·서버 오류면 다음 연결로 넘어가며 요청 형식 400은 즉시 실패

## 문제 정의 (Context)
AI 키·모델 설정이 앱 설정 여러 줄에 흩어져 있고, 제공자별 키가 하나뿐이라 한 키가 한도 초과·크레딧 부족이면 AI 기능 전체가 멈췄다. OpenAI는 미지원 (GitHub #695).

## 결정 (Decision)
- 연결 = 제공자(Gemini, Claude, OpenAI) + 이름 + API 키(암호화) + 기본 모델 + 우선순위 + 사용 여부. 같은 제공자 키 여러 개 가능. 테이블 `ai_connection`, Redis `passql:ai:connections` 공유, AI 서버도 같은 목록·규칙 사용.
- 대체 순서: 우선순위 1번부터. 응답 없음, 401, 402, 403, 404, 429, 5xx, 크레딧 부족·한도·무효 키 문구가 있는 400이면 다음 연결로. 그 외 400은 즉시 실패 — 다른 연결로 보내도 같은 이유로 실패하기 때문(리포트).
- 기능별 모델: 프롬프트 모델의 제공자 연결에서 그 모델로 먼저, 나머지는 각 연결 기본 모델.
- 정리: `ai.model_override`·제공자별 키 설정(`ai.claude_api_key`, `ai.gemini_api_key`) 제거, `ai.gemini_model`·`ai.default_model` 정리. 기존 키는 이관(1순위 Claude, 2순위 Gemini).

## 검토한 대안 (Alternatives)
- 하지 않기로 한 것(이슈 본문): 연결별 월 예산 자동 차단, 요청 단위 부하 분산. 이유는 원본에 없음.
- 그 외 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 한 키가 실패해도 다음 연결로 응답(로컬 실측 `CLAUDE_401` → 2순위 응답).

**부정**
- 대체 규칙이 Spring(`AiFallbackPolicy`, `AiCallAttemptPlanner`)과 AI 서버(`llm_client.py`) 두 곳에 있어 함께 바꿔야 한다.
- 연결 목록 30초 캐시로 다른 인스턴스 변경은 최대 30초 늦게 반영.

## 영향 범위 (Scope)
관리자 AI 연결·프롬프트 관리 화면, Spring `AiChatClient`, AI 서버 `llm_client`, `ai_connection`, `ai_call_log.connection_name`, 대시보드·모니터링의 키 상태 표시, `app_setting`의 `ai.*` 키.

## 출처 (References)
- GitHub #695 이슈 본문, 리포트 댓글
- [[ISS-0411-ai-connections-multi-key-fallback]], [[DEC-0187-claude-provider-by-model-prefix]](같은 날 도입한 `ai.model_override`·제공자별 키를 이 결정이 정리)
