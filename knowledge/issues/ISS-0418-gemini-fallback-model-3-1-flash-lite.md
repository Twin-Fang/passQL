---
type: issue
id: ISS-0418
created: 2026-10-27
topics: [ai]
symptoms: ["Gemini 대체 모델 성공률 78%", gemini-2.5-flash-lite, "gemini-2.5-flash 404", "no longer available to new users", "SQL 결과 직접 계산 약함"]
root_cause: "2순위 Gemini 연결의 기본 모델 gemini-2.5-flash-lite가 SQL 결과 직접 계산에 약해 선택지 생성 성공률이 78%에 그쳤다"
status: resolved
resolution: "[[ISS-0418-gemini-fallback-model-3-1-flash-lite-report]]"
related: ["[[DEC-0196-gemini-fallback-3-1-flash-lite]]", "[[ISS-0416-choice-set-prompts-claude-gemini]]"]
source: "https://github.com/Twin-Fang/passQL/issues/719"
---

# ISS-0418: Gemini 대체 모델 `gemini-3.1-flash-lite`로 변경

GitHub #719 (원본: 이슈 본문과 댓글).

## 증상
- Claude Haiku가 실패할 때(429, 5xx, 크레딧 부족 등) 쓰는 2순위 Gemini 연결의 기본 모델이 `gemini-2.5-flash-lite`였다.
- SQL 결과를 직접 계산하는 데 약해 선택지 생성 성공률 78%("결과가 다른 것" 69%, 일반 SQL 42%, GitHub #710 비교).
- 상위 모델로 올리려 한 `gemini-2.5-flash`는 신규 사용자에게 막혀 호출 시 404("no longer available to new users").

## 재현 조건
2순위 Gemini 연결로 선택지 생성.

## 조사 기록
- 2026-10-27: 운영 실행형 문제 48개 x 2회(모델당 96건), 운영 프롬프트(`generate_choice_set` v5, `result_match` v2, `odd_one_out` v2)·출력 한도 4096·온도·재시도 피드백·최대 3회, 로컬 PostgreSQL에서 운영 채점 규칙 재현, 비용은 실제 토큰(thinking 포함)과 공식 가격표(2026-10-27 기준).
- Haiku 재확인(`claude-haiku-5-5`): 96%, 해설 정확도 100% — #710과 같음. 실패 4건은 일반 SQL 2문제에서 오답이 기준 SQL과 같은 결과를 내 정답 2~4개로 채점(재시도 피드백으로도 반복, 프롬프트 개선 후보).

## 근본 원인
대체 모델의 SQL 결과 계산 능력 부족(이슈 본문).
