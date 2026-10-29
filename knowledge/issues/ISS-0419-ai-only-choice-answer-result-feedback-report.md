---
type: completion-report
id: ISS-0419
created: 2026-10-27
topics: [ai, question-bank]
status: resolved
resolves: "[[ISS-0419-ai-only-choice-answer-result-feedback]]"
related: ["[[DEC-0197-provide-answer-sql-result-in-prompt]]"]
source: "https://github.com/Twin-Fang/passQL/issues/720"
---

# ISS-0419 완료 리포트: `{answer_result}` 기준 실행 결과와 보기별 실행 결과 피드백, `generate_choice_set` v6

GitHub #720 리포트 댓글 기준 (Spring Blue-Green 배포, Flyway `1.66.1`).

## 해결 방법
- `ChoiceSetGenerationService.generate`: 활성 프롬프트에 `{answer_result}`가 있으면 첫 시도에서 기준 SQL을 샌드박스로 1회 실행(`executeExpectedResult` 재사용). 실행 실패면 재시도 없이 실패로 저장. 실패한 시도마다 보기별 실행 결과 줄 — AI_ONLY는 "기준과 같음/다름" 표시, ODD_ONE_OUT은 기존 형식.
- `ChoiceSetGenerationRequestFactory`: `buildStandardRequest`가 기준 결과 치환과 AI_ONLY 재시도 피드백 블록, `hasAnswerResultPlaceholder` 추가, `toOddOneOutResultLines` → `toChoiceResultLines`로 일반화.
- `V1_66_1__choice_set_prompt_answer_result.sql`: `generate_choice_set` v6 — `[기준 SQL 실행 결과]` 구획, 기준 SQL을 그대로 보기에 넣지 못함, 함정 추가(`>`/`>=` 경계, `ELSE 0` 유무, 조인 키 컬럼 바꾸기, 아무 행도 걸러내지 않는 조건).
- 검증: 서버 전체 테스트 통과, 마이그레이션 2회 멱등, 운영 `generate_choice_set` v6(4096) 활성 확인.

## 근본 원인 (확정)
AI의 기준 결과 직접 계산 오류, 결과 없는 재시도 피드백.

## 재발 방지
- 기준 실행 결과는 템플릿에 `{answer_result}`가 있을 때만 들어간다. 관리자 화면에서 이 자리를 지우면 결과 제공이 조용히 꺼지고 성공률이 46% 수준으로 돌아간다.
- ODD_ONE_OUT은 같은 `generate()`를 지나지만 템플릿에 이 자리가 없어 동작이 그대로.
- 일반 SQL 문제가 6개뿐이라 실제 생성 기록으로 다시 확인할 필요.

## 교훈
(원본에 없음, 볼트 정리) LLM에게 계산시키던 값을 실제로 실행해 줄 수 있으면 프롬프트에 넣어 준다 — 생성 품질이 계산 능력에 묶이지 않는다.
