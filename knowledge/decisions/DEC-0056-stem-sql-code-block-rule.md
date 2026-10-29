---
type: decision
id: DEC-0056
created: 2026-04-12
reviewed: null
topics: [question-bank, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0080-stem-markdown-schema-toggle]]", "[[ISS-0080-stem-markdown-schema-toggle-report]]"]
---

# DEC-0056: SQL이 들어간 문제 stem은 ```sql 코드 블록으로 쓴다 — 새 문제 생성 규칙이며 기존 예시는 수동으로 바꾼다

## 문제 정의 (Context)
stem을 마크다운으로 렌더링하게 되면서(GitHub #140) 문제 등록 가이드의 stem 예시가 `"...\n\nSELECT A.NAME..."`처럼 코드 블록 없이 쓰여 있었다. 기존 예시까지 바꾸는지, 새 규칙만 추가하는지 확인이 필요했다.

## 결정 (Decision)
- SQL이 포함된 stem은 반드시 ```sql 코드 블록으로 감싼다. `\n\nSELECT ...` 방식 금지 → `\n\n```sql\nSELECT ...\n```` 방식.
- 이 규칙은 문제 생성 시 고려하는 가이드라인이며 마이그레이션 가이드라인이 아니다. 기존 예시는 수동으로 바꾼다.
- 규칙을 `question-register-guide.md`, `question-bulk-guide.md`, 두 가이드 모달(`question-register.html`, `questions.html`), `server/CLAUDE.md` 체크리스트에 함께 넣는다.

## 검토한 대안 (Alternatives)
- 기존 예시 전부를 마크다운 형식으로 일괄 변환: 확인 질문에 대한 답이 "기존예시는 수동으로 바꿀꺼고 이제 새규칙을 추가할때 가이드라인"이었다. 그 이상의 이유는 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 화면에서 SQL이 코드 블록으로 표시된다(설계 댓글).

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
관리자 문제 등록 가이드 MD 2개와 가이드 모달 2개, `server/CLAUDE.md`, 문제 생성(단건·대량) 시 stem 작성.

## 출처 (References)
- GitHub #140 댓글 (2026-04-12, 가이드 수정 설계와 확인 답변)
- [[ISS-0080-stem-markdown-schema-toggle]]
