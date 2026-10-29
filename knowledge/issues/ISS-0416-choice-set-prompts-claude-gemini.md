---
type: issue
id: ISS-0416
created: 2026-10-27
topics: [ai, question-bank]
symptoms: ["Claude Haiku 전환 후 선택지 생성 실패 증가", "stop_reason=max_tokens", "빈 JSON", "결과표 고르기 정답 2개", "행 순서만 바꾼 오답", generate_choice_set_odd_one_out, "별칭만 다른 SQL"]
root_cause: "선택지 생성 프롬프트 3종이 Gemini 기준으로만 맞춰져 있었고, 출력 한도 1536 토큰·결과표 고르기 재시도 피드백 부재·ODD_ONE_OUT 전용 프롬프트 미사용이 겹쳤다"
status: resolved
resolution: "[[ISS-0416-choice-set-prompts-claude-gemini-report]]"
related: ["[[DEC-0193-choice-set-prompts-benchmarked-adoption]]", "[[ISS-0414-odd-one-out-choice-generation-fails]]", "[[ISS-0412-ai-explanation-quality-cost-optimization]]"]
source: "https://github.com/Twin-Fang/passQL/issues/710"
---

# ISS-0416: 선택지 생성 프롬프트 Claude·Gemini 공통 개선

GitHub #710 (원본: 이슈 본문과 댓글).

## 증상
- 선택지 생성 프롬프트 3종(일반 SQL, 결과가 다른 것, 결과표 고르기)이 Gemini 기준으로만 맞춰져 있어 Claude Haiku 전환 후 실패가 늘었다.
- 출력 한도 1536 토큰: 결과표가 긴 문제에서 Claude 응답이 잘려 빈 JSON(`stop_reason=max_tokens`) > 호출 실패.
- 결과표 고르기: 오답을 행 순서만 바꿔 만들면 채점상 정답 2개, 재시도 피드백이 없어 같은 실수 반복.
- 결과가 다른 것: 전용 프롬프트(`generate_choice_set_odd_one_out`)가 운영 DB에만 있고 코드에서 안 씀, 별칭만 다른 SQL도 다른 결과로 채점.

## 재현 조건
`claude-haiku-5-5`로 실행형 문제 선택지 생성(특히 결과표가 긴 결과표 고르기 문제).

## 조사 기록
- 2026-10-27: 운영 실행형 문제 48개(일반 SQL 6, 결과가 다른 것 18, 결과표 고르기 24) x `claude-haiku-5-5`·`gemini-2.5-flash-lite` x 2회, 운영 Spring 흐름 그대로(로컬 PostgreSQL에서 `SandboxValidator`·`ResultMatchChoiceValidator` 재현, 최대 3회). 개선안 v1~v3와 결과가 다른 것 3안을 비교.
- 실측 원인: 결과표 고르기 Claude 호출 오류 11건은 `max_tokens` 초과로 도구 입력이 빈 객체, 정답 2개는 채점이 행 순서를 무시하기 때문, Gemini 재시도 반복은 온도를 0.3으로 낮추면 같은 답을 내기 때문.

## 근본 원인
프롬프트가 한 모델 기준으로만 조율되어 있었고 출력 한도가 짧았다.
