---
type: decision
id: DEC-0197
created: 2026-10-27
reviewed: null
topics: [ai, question-bank]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0419-ai-only-choice-answer-result-feedback]]", "[[ISS-0419-ai-only-choice-answer-result-feedback-report]]"]
---

# DEC-0197: 일반 SQL(AI_ONLY) 선택지 생성은 기준 SQL을 샌드박스로 실행한 결과를 프롬프트에 주고, 재시도에는 보기별 실제 실행 결과와 "기준과 같음/다름"을 준다

## 문제 정의 (Context)
AI가 기준 SQL의 실행 결과를 직접 계산하다 틀려 결과가 같은 SQL을 오답으로 넣었고, 재시도 피드백은 동치 SQL 목록만 줘 같은 실수가 반복됐다. Haiku 성공률 46% (GitHub #720).

## 결정 (Decision)
- 기준 SQL 실행 결과를 프롬프트에 넣는다. 샌드박스에서 1회 실행하고 결과표 고르기 유형과 같은 방식(이슈 본문).
- 활성 프롬프트에 `{answer_result}` 자리가 있을 때만 실행해 넣는다 — 이전 프롬프트에는 영향 없음.
- 재시도 시 직전 시도의 보기별 실제 실행 결과와 "기준과 같음/다름" 표시를 넣는다.
- `generate_choice_set` v6: 기준 SQL을 그대로 보기에 넣지 않고, 결과가 같아지는 함정 목록 확대, 결과가 확실히 바뀌는 변형 예시.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- Haiku 46%(11/24) → 96%(23/24), Gemini 96% 유지.

**부정**
- 템플릿에서 `{answer_result}`를 지우면 결과 제공이 조용히 꺼진다.
- 표본 6문제라 수치가 흔들릴 수 있다.

## 영향 범위 (Scope)
`ChoiceSetGenerationService`, `ChoiceSetGenerationRequestFactory`, `V1_66_1__choice_set_prompt_answer_result.sql`, 관리자 프롬프트 관리 화면.

## 출처 (References)
- GitHub #720 이슈 본문 「해결 방안」, 리포트 댓글
- [[ISS-0419-ai-only-choice-answer-result-feedback]]
