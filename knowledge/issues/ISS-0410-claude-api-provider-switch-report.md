---
type: completion-report
id: ISS-0410
created: 2026-10-27
topics: [ai, admin]
status: resolved
resolves: "[[ISS-0410-claude-api-provider-switch]]"
related: ["[[DEC-0187-claude-provider-by-model-prefix]]"]
source: "https://github.com/Twin-Fang/passQL/issues/688"
---

# ISS-0410 완료 리포트: 모델 이름으로 Claude·Gemini 선택, 기본 `claude-haiku-5-5`

GitHub #688 리포트 댓글 기준.

## 해결 방법
- Spring `AiChatClient`(직접 LLM 호출 단일 진입점)와 AI 서버 `llm_client`가 같은 규칙으로 `claude-`로 시작하는 모델은 Claude, 아니면 Gemini를 호출.
- Claude는 Messages API. JSON 응답은 도구 1개를 강제 호출하게 해 그 입력값을 응답으로 사용. Gemini 형식 응답 스키마(대문자 type, nullable)는 호출 시 JSON Schema로 변환.
- 설정: `ai.claude_api_key`(암호문, 재배포 없이 반영), `ai.model_override`(값을 넣으면 모든 AI 호출에 일괄 적용). 모든 프롬프트 모델과 `ai.default_model`을 `claude-haiku-5-5`로. 단가표에 Haiku 5.5·Sonnet 5.5, 호출 기록 출처에 `CLAUDE_DIRECT`.
- 실측 수정: `temperature` 제거, `thinking: disabled`.

## 근본 원인 (확정)
제공자 선택 구조 부재.

## 재발 방지
- Claude 요청에 `temperature`나 thinking 설정을 다시 넣으면 400이 나거나 본문이 비어 실패한다. 프롬프트의 temperature 값은 Gemini에만 적용.
- `explain_error`, `diff_explain`처럼 사용자 템플릿이 빈 프롬프트는 관리자 프롬프트 테스트에서 실행 불가(기존 동작).
- 검증: Spring 전체 테스트 통과(제공자 선택·일괄 모델·스키마 변환 테스트 추가). AI 서버 테스트는 `test_app_version_comes_from_package_metadata` 1건 환경 문제로 실패.
- 후속(리포트): 제공자별 키 여러 개, 초과 시 다음 API로 넘어가는 순서, OpenAI 지원 → GitHub #695.

## 교훈
(원본에 없음, 볼트 정리) 새 LLM 모델로 바꿨는데 400이나 빈 본문이 나오면 그 모델이 거부하는 파라미터(temperature)와 기본 thinking 토큰 소비부터 확인한다.
