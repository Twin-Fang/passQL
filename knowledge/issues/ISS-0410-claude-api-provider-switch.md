---
type: issue
id: ISS-0410
created: 2026-10-27
topics: [ai, admin]
symptoms: ["Gemini 단일 제공자", "Claude 크레딧 미사용", ai.gemini_api_key, "Claude 400 temperature", "Claude 응답 본문 비어 있음", "thinking max_tokens"]
root_cause: "AI 호출이 Gemini 한 곳에 묶여 있었고 키·모델·단가 설정이 Gemini 전용이었다"
status: resolved
resolution: "[[ISS-0410-claude-api-provider-switch-report]]"
related: ["[[DEC-0187-claude-provider-by-model-prefix]]", "[[ISS-0411-ai-connections-multi-key-fallback]]"]
source: "https://github.com/Twin-Fang/passQL/issues/688"
---

# ISS-0410: Claude API provider 전환 지원 (AI)

GitHub #688 (원본: 이슈 본문과 댓글).

## 증상
- AI 호출(문제 생성, 해설, 선택지 해설, 코멘트)이 Gemini 한 곳에만 묶여 있다.
- Claude Max 플랜에 포함된 월 API 크레딧($100)을 passQL에서 쓸 방법이 없다.
- 키·모델·비용 단가가 Gemini 전용 설정(`ai.gemini_api_key`, `ai.gemini_model`)으로만 존재.

## 재현 조건
해당 없음 (기능 이슈).

## 조사 기록
- 2026-10-27 실측에서 발견해 고친 문제(리포트):
  - 모든 Claude 호출이 400: `claude-haiku-5-5`는 `temperature` 파라미터를 받지 않음(deprecated) → 요청에서 제거.
  - 응답 본문이 비어 실패: Haiku 5.5가 기본으로 thinking을 해서 그 토큰이 `max_tokens`를 먼저 씀 → `thinking: disabled`.
- 운영 실측: 관리자 프롬프트 테스트(`ai_comment`, `claude-haiku-5-5`) 성공(2,601ms).

## 근본 원인
제공자 선택 구조가 없었다(기능 부재).
