---
type: decision
id: DEC-0031
created: 2026-04-09
reviewed: null
topics: [dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0030-frontend-api-field-mismatch]]", "[[ISS-0030-frontend-api-field-mismatch-report]]"]
---

# DEC-0031: 프론트는 백엔드(Spring) API 스펙만 따르고, AI 서버 snake_case → camelCase 변환은 백엔드 프록시 책임

## 문제 정의 (Context)
프론트가 AI 서버(FastAPI) 스펙을 직접 따르다 백엔드 프록시 스펙과 어긋나 AI 호출이 실패했다 (GitHub #41).

## 결정 (Decision)
snake_case → camelCase 변환은 백엔드 프록시 책임이므로 프론트는 백엔드 스펙만 따른다. 백엔드가 지원하지 않는 필드·엔드포인트(`choiceSetId`, `generateChoices`)는 프론트에서 제거한다.

## 검토한 대안 (Alternatives)
- 프론트가 AI 서버 스펙(snake_case)을 직접 따르는 기존 방식: 백엔드 스펙과 불일치해 대체.

## 결과 (Consequences)
**긍정**
- 이슈 본문·리포트: API 호출 실패 방지.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`client/src/types/api.ts`, `client/src/api/ai.ts`, `client/src/api/questions.ts`, `api-guide.md`의 AI 요청 body 표.

## 출처 (References)
- GitHub #41 이슈 본문 「해결 방안」, 작업 보고 댓글 (2026-04-09)
