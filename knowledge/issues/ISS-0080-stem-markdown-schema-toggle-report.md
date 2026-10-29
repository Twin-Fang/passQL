---
type: completion-report
id: ISS-0080
created: 2026-04-12
topics: [practice, question-bank]
status: resolved
resolves: "[[ISS-0080-stem-markdown-schema-toggle]]"
related: ["[[DEC-0056-stem-sql-code-block-rule]]"]
source: "https://github.com/Twin-Fang/passQL/issues/140"
---

# ISS-0080 완료 리포트: stem 마크다운 렌더링 적용, 등록 가이드에 코드 블록 규칙 추가

GitHub #140 "Stable 적용 완료" 댓글과 가이드 수정 설계 댓글 기준 (2026-04-12). `## 개요` 형식 리포트는 없음.

## 해결 방법
- 프론트: 이슈 본문 작업 내용 — `QuestionDetail.tsx`에 `react-markdown` 적용, `SchemaViewer.tsx` 토글(기본 접힘). "Stable 적용 완료" 댓글로 반영 확인.
- 관리자 가이드: `static/docs/question-register-guide.md`, `static/docs/question-bulk-guide.md`의 stem 작성 규칙, `templates/admin/question-register.html`·`templates/admin/questions.html` 가이드 모달, `server/CLAUDE.md` 체크리스트에 "SQL이 포함된 stem은 ```sql 코드 블록으로 감싼다" 규칙 추가 설계. 마지막 댓글은 "최신 가이드로 수정후 문제 생성 부탁드립니다".

## 근본 원인 (확정)
해당 없음 (기능 개선).

## 재발 방지
설계 댓글의 `server/CLAUDE.md` 체크리스트 항목: stem 규칙을 바꾸면 두 가이드 MD와 가이드 모달도 함께 수정했는가.

## 교훈
원본에 적혀 있지 않다. (참고: 스키마 기본 접힘은 GitHub #144에서 기본 펼침으로 바뀌었다.)
