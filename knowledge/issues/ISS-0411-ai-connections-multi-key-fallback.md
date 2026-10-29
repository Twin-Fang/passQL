---
type: issue
id: ISS-0411
created: 2026-10-27
topics: [ai, admin]
symptoms: ["AI 키 설정 흩어짐", "한 키 한도 초과 시 AI 전체 중단", "OpenAI 미지원", ai.model_override, "400 API_KEY_INVALID", ai_connection]
root_cause: "AI 키·모델 설정이 앱 설정 여러 줄에 흩어져 있고 제공자별 키가 하나뿐이라 한 키 실패가 AI 기능 전체를 멈췄다"
status: resolved
resolution: "[[ISS-0411-ai-connections-multi-key-fallback-report]]"
related: ["[[DEC-0188-ai-connections-priority-fallback]]", "[[ISS-0410-claude-api-provider-switch]]"]
source: "https://github.com/Twin-Fang/passQL/issues/695"
---

# ISS-0411: AI 연결 관리 — 다중 API 키, 우선순위, fallback

GitHub #695 (원본: 이슈 본문과 댓글).

## 증상
- AI 키·모델 설정이 `ai.gemini_api_key`, `ai.claude_api_key`, `ai.model_override`, `ai.default_model`, `ai.gemini_model`에 흩어져 어디서 무엇을 바꾸는지 불분명.
- 제공자별 키를 하나만 둘 수 있어 한 키가 사용량 초과·크레딧 부족이면 AI 기능 전체가 멈춤.
- OpenAI 미지원.

## 재현 조건
해당 없음 (기능 이슈).

## 조사 기록
- 이슈 본문 「하지 않는 것」: 연결별 월 예산 자동 차단, 요청 단위 부하 분산.
- 2026-10-27 로컬 실측: 1순위에 틀린 Claude 키 → `CLAUDE_401` 실패 후 2순위 `claude-passql-pro`가 응답(2.4초).
- 운영 실측: 기존 키 2개 이관, 연결 확인 Claude 283ms·Gemini 1,298ms, AI 서버 경유 프롬프트 테스트 2.2초.
- 실측 발견: Gemini는 무효 키에 401이 아니라 `400 API_KEY_INVALID`를 돌려준다 → 대체 판정 문구에 추가.

## 근본 원인
연결(키) 단위 관리와 대체 순서가 없었다.
