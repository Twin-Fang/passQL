---
type: decision
id: DEC-0120
created: 2026-10-15
reviewed: null
topics: [design-system, dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0264-architecture-audit-commonization-refactor]]", "[[ISS-0267-app-component-layer-passql-rename]]", "[[ISS-0267-app-component-layer-passql-rename-report]]"]
---

# DEC-0120: 앱 디자인 시스템 접두사 `Pq`를 `Passql...`로 풀어 쓴다

## 문제 정의 (Context)
`Pq` 접두사의 뜻이 불분명했다 (GitHub #458, #461).

## 결정 (Decision)
소유자 결정(2026-10-15): `Pq` 접두사를 `Passql...`로 풀어 쓴다(예: `PqColors` → `PassqlColors`). 구현(#461): `Pq*` → `Passql*`, 파일명을 주된 타입명에 맞춤, `context.passqlColors`로 색 접근 통일.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 이름에서 뜻이 바로 보인다(#461 개요의 문제 제기).

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`app/lib/presentation/design/` 컴포넌트·토큰 전체와 사용처, `Design.md`.

## 출처 (References)
- GitHub #458 소유자 결정 댓글 3번 (2026-10-15), GitHub #461 구현 보고서
