---
type: completion-report
id: ISS-0416
created: 2026-10-27
topics: [ai, question-bank]
status: resolved
resolves: "[[ISS-0416-choice-set-prompts-claude-gemini]]"
related: ["[[DEC-0193-choice-set-prompts-benchmarked-adoption]]"]
source: "https://github.com/Twin-Fang/passQL/issues/710"
---

# ISS-0416 완료 리포트: 선택지 프롬프트 새 버전, `max_tokens` 4096, 결과표 고르기 재시도 피드백

GitHub #710 리포트 댓글 기준 (Spring Blue-Green 배포 성공, Flyway `1.63.4`).

## 해결 방법
- `V1_63_4__choice_set_prompts_claude_gemini.sql`:
  - `generate_choice_set` v5 — `<task>` `<rules>` `<equivalent_traps>` `<self_check>` 구획 구조, 샘플 데이터에서 아무 행도 바꾸지 않는 조건은 오답에 쓰지 않음, rationale 첫 줄에 계산한 결과.
  - `generate_choice_set_result_match` v2 — 행 순서·키 순서·숫자 표기만 다른 표는 오답 금지, 정답 표는 실행 결과 그대로.
  - 세 프롬프트 모두 `max_tokens` 1536 > 4096(`generate_choice_set_odd_one_out` v2 포함). 모델 `claude-haiku-5-5`, 온도는 기존 값.
- `ChoiceSetGenerationService` / `ChoiceSetGenerationRequestFactory`: 결과표 고르기도 재시도 피드백(정답 표 2개 이상이면 겹친 보기 key, 0개이면 정답 표를 그대로 옮기라는 지시).
- 결과(3회 안 성공률): 일반 SQL Haiku 33% > 67%, Gemini 58% > 58%; 결과가 다른 것(#699 v2 유지) Haiku 100%, Gemini 78%; 결과표 고르기 Haiku 88% > 100%, Gemini 96% > 90%; 해설 일치율 Haiku 91% > 97%, Gemini 79% > 84%.

## 근본 원인 (확정)
Gemini 기준 프롬프트, 짧은 출력 한도, 결과표 고르기 피드백 부재.

## 재발 방지
- 일반 SQL 유형은 운영 문제가 6개뿐이라 수치가 흔들린다(67%).
- Gemini flash-lite는 SQL 결과 직접 계산이 약해 "결과가 다른 것"에서 78% 근처. 대체 모델로 자주 쓰이면 `gemini-2.5-flash` 같은 상위 모델이 필요할 수 있다.
- 관리자 화면에서 프롬프트를 고칠 때 "결과 비교는 행 순서를 무시한다", "오답은 실제로 결과가 달라야 한다" 규칙을 지우면 실패율이 다시 오른다.
- "결과가 다른 것" 프롬프트를 바꿀 때 #699 v2의 "오답 하나는 기준 SQL 그대로, 위험한 변형은 정답에만" 규칙을 유지(Gemini 64% > 78%에 가장 큰 영향).
- 검증: 서버 전체 테스트 통과, 마이그레이션 로컬 2회 적용 멱등. 배포 후 사용자 생성 기록은 아직 없음, 운영 AI 서버 직접 호출은 하지 않음.

## 교훈
(원본에 없음, 볼트 정리) LLM 주 모델을 바꾸면 프롬프트·출력 한도·온도를 운영 검증 로직 그대로 두 모델에 다시 재 보고 채택한다.
