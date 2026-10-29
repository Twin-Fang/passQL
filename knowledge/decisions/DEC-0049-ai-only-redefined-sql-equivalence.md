---
type: decision
id: DEC-0049
created: 2026-04-11
reviewed: null
topics: [question-bank, ai, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0062-ai-only-choices-mismatch-question-type]]", "[[ISS-0062-ai-only-choices-mismatch-question-type-report]]", "[[DEC-0050-result-match-text-choices]]"]
---

# DEC-0049: `AI_ONLY` 정책은 "주어진 SQL과 동일한 실행 결과를 내는 SQL 고르기"로 재정의한다

## 문제 정의 (Context)
`AI_ONLY` 지문은 "실행 결과로 올바른 것은?"인데 선택지는 SQL이라, 선택지를 실행해 보면 정답이 드러났다. 리포트는 방치하면 학습 효과가 없어진다고 적었다 (GitHub #108).

## 결정 (Decision)
| 구분 | 변경 전 | 변경 후 |
|---|---|---|
| 지문 패턴 | "다음 SQL의 실행 결과로 올바른 것은?" | "다음 SQL과 동일한 실행 결과를 내는 SQL은?" |
| 선택지 body | (의도치 않게) 실행 결과 텍스트 혼입 | 반드시 실행 가능한 SQL 쿼리 |
| 정답 | `answerSql` 실행 결과와 일치하는 1개 | `answerSql`과 동일한 결과를 내는 다른 SQL 1개 |

프롬프트 `generate_choice_set` v3, 기존 AI_ONLY EXECUTABLE 문제의 `stem` 일괄 수정, 기존 선택지 세트 삭제.

## 검토한 대안 (Alternatives)
- "실행 결과 예측" 방향(선택지 = 결과 테이블 텍스트): 이슈 본문이 두 방향 중 하나로 제시. `AI_ONLY`에는 택하지 않고, 필요하면 별도 `RESULT_MATCH` 정책으로 분리한다고 리포트가 적었다(→ [[DEC-0050-result-match-text-choices]]). `AI_ONLY`를 SQL 동등성 쪽으로 정한 이유는 원본에 적혀 있지 않다.

## 결과 (Consequences)
**긍정**
- 지문과 선택지 형태가 일치한다.

**부정**
- 기존 AI_ONLY EXECUTABLE 문제의 선택지 세트가 삭제되고 다음 요청 때 재생성된다.
- AI가 여전히 실행 결과 텍스트를 반환할 수 있어 Sandbox 검증 강화가 필요하다(리포트).

## 영향 범위 (Scope)
`V0_0_63__fix_ai_only_prompt_to_sql_equivalence.sql`, `generate_choice_set` 프롬프트, `question.stem`, `question_choice_set(_item)`, 등록 가이드 MD 2개. 볼트의 기존 결정 DEC-0028은 MVP 정책을 `AI_ONLY` 단일 모드로 정했는데, 이 결정은 그 `AI_ONLY`의 문제 유형을 정의한다.

## 출처 (References)
- GitHub #108 이슈 본문 「올바른 구조 (두 가지 방향)」, `## 개요` 리포트 댓글 「정책 재정의 방향」·「주의사항」(2026-04-11)
