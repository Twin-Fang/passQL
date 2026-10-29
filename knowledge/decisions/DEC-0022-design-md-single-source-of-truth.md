---
type: decision
id: DEC-0022
created: 2026-04-08
reviewed: null
topics: [design-system]
status: superseded
supersedes: null
superseded_by: DEC-0121
related: ["[[ISS-0017-design-md-light-design-system]]", "[[ISS-0017-design-md-light-design-system-report]]", "[[DEC-0121-unified-brand-color]]"]
---

# DEC-0022: 라이트 모드 `Design.md`를 디자인 단일 원본으로, tokens.css → 컴포넌트 CSS가 따른다

## 문제 정의 (Context)
`Design.md`가 Linear 다크 모드 그대로라 실제 구현(라이트 모드)과 불일치했다 (GitHub #20).

## 결정 (Decision)
`Design.md`(문서)를 single source of truth로 두고, `tokens.css`(CSS 변수) → `components.css`·`typography.css`가 동일한 값을 참조하도록 맞춘다. 기준은 라이트 모드(Pretendard, `#FAFAFA`, `#4F46E5`, `#E5E7EB`), 그림자 없이 배경색 차이로 elevation 표현.

## 검토한 대안 (Alternatives)
논의 기록 없음. (기존 Linear 다크 모드 Design.md는 실제 구현과 불일치해 교체됨.)

## 결과 (Consequences)
**긍정**
- 이슈 본문: 디자인 시스템 문서와 실제 코드의 single source of truth 확보.

**부정**
- 다크 모드 미지원 — 필요 시 Design.md에 다크 토큰 섹션 추가 필요 (리포트 참고사항).

## 영향 범위 (Scope)
`.claude/rules/Design.md`, `client/src/styles/tokens.css`, `components.css`, `typography.css`.

## 출처 (References)
- GitHub #20 이슈 본문, 작업 보고 댓글 「디자인 토큰 동기화 구조」 (2026-04-08)
