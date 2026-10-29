---
type: decision
id: DEC-0076
created: 2026-04-13
reviewed: null
topics: [question-bank, ai]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0133-markdown-guide-for-ai-content]]", "[[ISS-0133-markdown-guide-for-ai-content-report]]", "[[DEC-0074-shared-markdowntext-component]]"]
---

# DEC-0076: 문제 콘텐츠(stem·hint·rationale)는 마크다운 활용 규칙을 따른다

## 문제 정의 (Context)
프론트는 마크다운을 렌더링하는데 AI 생성 콘텐츠가 마크다운을 거의 쓰지 않아 SQL 키워드가 일반 텍스트로 보였다(GitHub #243).

## 결정 (Decision)
문제 등록 가이드와 AI 변환 프롬프트에 마크다운 활용 규칙을 둔다.
| 문법 | 용도 | 적용 필드 |
|---|---|---|
| 인라인 코드 | SQL 키워드, 함수명, 테이블/컬럼명 | stem, hint, rationale |
| `**굵은 텍스트**` | 핵심 개념, 정답 포인트 | hint, rationale |
| ` ```sql ``` ` | SQL 코드블록 | stem |

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음 (원본은 가독성 저하를 문제로만 적음).

**부정**
- DB `prompt_template`에는 반영되지 않았을 수 있다(리포트는 Flyway로 별도 처리 필요라고만 적음).

## 영향 범위 (Scope)
`server/PQL-Web/src/main/resources/static/docs/question-single-guide.md`, `question-bulk-guide.md`, 콘텐츠를 렌더링하는 `MarkdownText` 사용 화면.

## 출처 (References)
- GitHub #243 이슈 본문, 리포트 댓글(2026-04-13)
