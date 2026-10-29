---
type: decision
id: DEC-0061
created: 2026-04-12
reviewed: null
topics: [design-system, dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0087-mobile-header-team-modal]]", "[[ISS-0087-mobile-header-team-modal-report]]", "[[ISS-0090-practice-result-screen-redesign]]", "[[ISS-0092-home-daisyui-pilot]]"]
---

# DEC-0061: 프론트에서 인라인 `style` 속성 절대 금지 — Tailwind 유틸리티 또는 `components.css` 커스텀 클래스만

## 문제 정의 (Context)
GitHub #157 작업 중 `client/CLAUDE.md`에 규칙을 추가했다. 규칙을 추가한 이유는 원본에 적혀 있지 않다.

## 결정 (Decision)
인라인 `style` 속성을 절대 쓰지 않는다. Tailwind 유틸리티 클래스 또는 `components.css` 커스텀 클래스만 쓴다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- 동적 값은 우회가 필요하다. 이후 이슈에서 CSS 커스텀 프로퍼티(`--step-offset`, GitHub #161)와 Tailwind 4 임의 변수 클래스(`[--stagger-delay:Nms]`, GitHub #167)로 처리했다.

## 영향 범위 (Scope)
`client/CLAUDE.md`, `client/src` 전체 컴포넌트, `client/src/styles/components.css`.

## 출처 (References)
- GitHub #157 리포트 댓글 (2026-04-12)
- [[ISS-0087-mobile-header-team-modal]]
