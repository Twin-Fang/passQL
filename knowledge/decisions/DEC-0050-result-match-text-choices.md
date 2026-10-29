---
type: decision
id: DEC-0050
created: 2026-04-11
reviewed: null
topics: [question-bank, practice, ai]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0063-result-match-policy]]", "[[ISS-0063-result-match-policy-report]]", "[[DEC-0049-ai-only-redefined-sql-equivalence]]"]
---

# DEC-0050: "실행 결과로 올바른 것은?" 유형은 `RESULT_MATCH` 정책 — 선택지는 결과 JSON(`kind = TEXT`), 검증은 `answerSql` 결과와 비교

## 문제 정의 (Context)
`AI_ONLY`를 SQL 동등성 유형으로 재정의하면서(#108) SQLD 핵심 유형인 실행 결과 예측 문제를 담을 정책이 필요했다 (GitHub #110).

## 결정 (Decision)
- `ChoiceSetPolicy`에 `RESULT_MATCH`를 추가한다.
- 선택지 body는 JSON 배열(`[{"NAME":"홍길동","DEPT_NAME":"개발팀"}, ...]`), `kind = TEXT`(기존 `ChoiceKind.TEXT` 활용).
- 생성: `answerSql` 실행 결과를 기준으로 AI가 정답 결과 1개 + 오답 결과 3개를 만든다.
- 검증: body JSON을 파싱해 `answerSql` 실행 결과와 문자열 비교한다(SQL 실행 방식 아님).
- 프론트: `kind === "TEXT"`면 컴팩트 결과 테이블로 렌더링하고 실행 버튼이 없다.

## 검토한 대안 (Alternatives)
- `AI_ONLY` 안에서 결과 텍스트 선택지를 쓰기: #108이 `AI_ONLY`를 SQL 선택지로 고정하며 별도 정책 분리를 택했다. 그 밖의 대안은 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 이슈 본문: 사용자가 SQL을 머릿속으로 실행해 결과를 예측하는 학습 목표에 맞는다.

**부정**
- 완료 댓글이 "테스트 미확인"이라고 적었다. JSON body가 SQL 실행 API로 넘어가지 않도록 프론트에서 `kind` 분기를 해야 한다(GitHub #112에서 `choices.filter(c => c.kind === "SQL")`로 처리).

## 영향 범위 (Scope)
`ChoiceSetPolicy`, `ChoiceSetGenerationService`, `SandboxValidator`, `ChoiceSetSaveService`, 프롬프트 `generate_choice_set_result_match`, 프론트 `ChoiceCard.tsx`, 등록 가이드 MD 2개.

## 출처 (References)
- GitHub #110 이슈 본문 「해결 방안」·「작업 내용」, 완료 댓글(2026-04-11)
- GitHub #108 리포트 주의사항
