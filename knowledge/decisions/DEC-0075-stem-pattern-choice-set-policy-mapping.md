---
type: decision
id: DEC-0075
created: 2026-04-13
reviewed: null
topics: [question-bank]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0132-result-match-registered-as-ai-only]]", "[[ISS-0132-result-match-registered-as-ai-only-report]]"]
---

# DEC-0075: stem 패턴별 `choiceSetPolicy` 매핑 (`AI_ONLY` / `RESULT_MATCH` / `ODD_ONE_OUT`)

## 문제 정의 (Context)
"실행 결과로 올바른 것은?" 문제가 `AI_ONLY`로 등록돼 선택지가 SQL 쿼리로 생성되는 버그(GitHub #242). 등록 가이드와 AI 변환 프롬프트가 정책을 혼동하고 있었다.

## 결정 (Decision)
| stem 패턴 | choiceSetPolicy | 선택지 형태 |
|---|---|---|
| "다음 SQL과 동일한 실행 결과를 내는 SQL은?" | `AI_ONLY` | SQL 쿼리 |
| "다음 SQL의 실행 결과로 올바른 것은?" | `RESULT_MATCH` | 결과 테이블 (JSON 배열) |
| "다음 중 SQL 실행 결과가 다른 것은?" | `ODD_ONE_OUT` | SQL 쿼리 |

`AI_ONLY`는 "동일한 실행 결과를 내는 SQL은?" 유형에만 쓴다. 이 매핑을 등록 가이드 문서와 AI 변환 프롬프트에 명시한다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 리포트: 가이드 MD를 AI에 제공하면 stem-choiceSetPolicy 매핑이 정확하게 동작.

**부정**
- 기존에 잘못 등록된 문제는 정책 변경과 선택지 재생성을 따로 해야 한다.

## 영향 범위 (Scope)
`server/PQL-Web/src/main/resources/static/docs/question-single-guide.md`, `question-bulk-guide.md`(가이드·AI 변환 프롬프트), 문제 등록 흐름.

## 출처 (References)
- GitHub #242 이슈 본문 "예상 동작", 리포트 댓글(2026-04-13)
