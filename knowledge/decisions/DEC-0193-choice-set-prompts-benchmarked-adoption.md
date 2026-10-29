---
type: decision
id: DEC-0193
created: 2026-10-27
reviewed: null
topics: [ai, question-bank]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0416-choice-set-prompts-claude-gemini]]", "[[ISS-0416-choice-set-prompts-claude-gemini-report]]"]
---

# DEC-0193: 선택지 생성 프롬프트는 운영 문제 x Haiku·Gemini 비교 결과로 채택 — 결과가 다른 것은 #699 v2 유지, `max_tokens` 4096, Gemini 온도 유지

## 문제 정의 (Context)
선택지 생성 프롬프트 3종이 Gemini 기준으로만 맞춰져 있어 Claude Haiku 전환 후 실패가 늘었다 (GitHub #710).

## 결정 (Decision)
- 운영 문제 48개 x 모델 2종(`claude-haiku-5-5`, `gemini-2.5-flash-lite`) x 2회를 운영 검증 로직 그대로 비교한 개선 프롬프트를 적용한다(이슈 본문).
- `generate_choice_set` v5, `generate_choice_set_result_match` v2 적용. 세 프롬프트 모두 `max_tokens` 4096.
- "결과가 다른 것"은 GitHub #699의 v2 프롬프트를 유지하고 출력 한도만 올린다.
- 온도는 기존 값을 유지한다(Claude는 온도를 쓰지 않음).

## 검토한 대안 (Alternatives)
- 결과가 다른 것: #699 v2, 이 이슈 안, 둘을 합친 안 3가지를 비교. v2(Haiku 100%, Gemini 78%)가 합친 안(100%, 81%)과 차이가 없어 v2 유지(리포트).
- Gemini 온도 0.3: 재시도마다 같은 답을 내서 버림(리포트 「실측에서 찾은 원인」).
- `max_tokens` 1536 유지: 결과표가 긴 문제에서 응답이 잘려 버림. 비용은 실제 출력 토큰만큼만 나간다고 적음.

## 결과 (Consequences)
**긍정**
- Haiku 일반 SQL 33% > 67%, 결과표 고르기 88% > 100%, 해설 일치율 91% > 97%.

**부정**
- Gemini 결과표 고르기 96% > 90%로 소폭 하락. Gemini는 결과가 다른 것 78% 근처.
- 일반 SQL 표본 6개라 수치가 흔들림.

## 영향 범위 (Scope)
`V1_63_4__choice_set_prompts_claude_gemini.sql`, `ChoiceSetGenerationService`, `ChoiceSetGenerationRequestFactory`, 관리자 프롬프트 관리 화면.

## 출처 (References)
- GitHub #710 이슈 본문, 리포트 댓글
- [[ISS-0416-choice-set-prompts-claude-gemini]]
