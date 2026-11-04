---
type: decision
id: DEC-0249
created: 2026-11-05
reviewed: null
topics: [practice, ai, question-bank]
status: active
supersedes: DEC-0050
superseded_by: null
related: ["[[ISS-0451-result-table-choices-fabricated-unvalidated-sets]]", "[[DEC-0052-result-match-policy-equivalence-type]]", "[[DEC-0250-never-store-unvalidated-sql-choice-sets]]"]
---

# DEC-0249: 결과 표 문제 보기는 AI가 쓴 보기 SQL의 실제 실행 결과로만 만든다

## 문제 정의 (Context)
결과 표 문제(RESULT_MATCH)는 AI가 오답 결과 표를 직접 써서, 실제 SQL로 나올 수 없는 보기(빈 결과, 근거 없는 숫자)가 저장·노출됐다 (GitHub #828, [[ISS-0451-result-table-choices-fabricated-unvalidated-sets]]).

## 결정 (Decision)
- AI는 결과 표가 아니라 보기 SQL 4개(정답 1 = 기준 SQL과 결과가 같은 SQL, 오답 3 = 수험생 오해를 재현하는 SQL)만 쓴다. 프롬프트는 SQL 보기 프롬프트(`generate_choice_set`)에 결과 표 유형 지시를 붙여 쓴다.
- 서버가 임시 샌드박스에서 기준 SQL과 보기 SQL을 실행하고, 실행 결과를 표 JSON(열 대문자, 숫자 끝자리 0 제거)으로 바꿔 `kind=TEXT` 보기로 저장한다.
- 판정(`ResultTableChoiceJudge`) 거부 6개: 실행 오류, 열 이름·순서 다름, 정답 0개, 정답 2개 이상, 오답끼리 같은 결과, 빈 결과 오답. 거부 사유와 실제 결과를 다음 시도 피드백으로 준다.
- 정답 보기 해설은 "문제의 SQL을 그대로 실행한 결과예요.", 오답 해설은 AI가 적은 오해 설명.
- 옛 프롬프트 `generate_choice_set_result_match`로 만든 세트는 오답 표가 실제 결과인지 확인할 수 없어 전수 검증에서 내린다.

## 검토한 대안 (Alternatives)
- AI가 쓴 결과 표를 더 엄격히 검사(빈 결과·중복만 거부): 근거 없는 숫자는 잡을 수 없어 버렸다.
- 오답 표를 규칙으로 변형(숫자 ±, 행 삭제): 수험생 오해와 무관한 함정이 되어 버렸다. 오답은 실제 SQLD 오해(NULL 집계, COUNT(*) vs COUNT(컬럼) 등)에서 나와야 헷갈린다.

## 결과 (Consequences)
**긍정**
- 모든 결과 표는 실제 실행 결과라 정답은 하나이고, 오답도 그럴듯한 실수의 결과다. 요청마다 다른 오해 조합을 고르게 지시해 같은 문제도 함정이 바뀐다.

**부정**
- 시도마다 샌드박스 실행 5회(기준 + 보기 4). 오답 3개가 모두 서로 다른 결과를 내야 해 재시도가 늘 수 있다.

## 영향 범위 (Scope)
`ChoiceSetGenerationService.generateResultMatch`, `ResultTableChoiceBuilder`, `ResultTableChoiceJudge`, `ChoiceSetGenerationRequestFactory`(결과 표 유형 지시), `ChoiceSetSaveService.saveResultMatch`.

## 출처 (References)
- GitHub #828 이슈 본문, PR #829 (2026-11-05)
- 이슈: [[ISS-0451-result-table-choices-fabricated-unvalidated-sets]]
