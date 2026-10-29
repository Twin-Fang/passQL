---
type: decision
id: DEC-0118
created: 2026-10-15
reviewed: null
topics: [dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0264-architecture-audit-commonization-refactor]]", "[[ISS-0264-architecture-audit-commonization-refactor-report]]", "[[ISS-0265-brand-assets-single-source]]", "[[ISS-0266-server-error-code-unify-archunit]]", "[[ISS-0267-app-component-layer-passql-rename]]", "[[ISS-0268-web-brand-color-token-lint]]", "[[ISS-0269-ai-stub-removal-settings-unify]]", "[[DEC-0124-brand-folder-generated-assets]]"]
---

# DEC-0118: 소유자 코딩 규칙 — 단일 원본, 3개째 공통화, 직관적 이름, 규칙은 테스트로 강제

## 문제 정의 (Context)
같은 대상이 스택·플랫폼마다 사본이라 한 곳을 고치면 나머지가 빠지는 일이 반복됐다 (GitHub #458, #453 로고 누락).

## 결정 (Decision)
소유자 코딩 규칙에 맞춰 묶음별로 공통화한다.
- 단일 원본
- 같은 것이 3개째 생기면 공통화
- 이름은 길어도 직관적으로, boolean은 `is` 접두사
- 규칙은 테스트로 강제 (앱 `test/architecture`, 서버 ArchUnit, AI import 규칙, 웹 ESLint, 브랜드 `--check`)
- 주석은 한 줄 요약·블록 머리글 (하위 이슈 #459~#463 본문)
- 묶음마다 설계안을 제안하고 승인을 받은 뒤 하위 이슈로 구현. 리팩터링은 동작을 바꾸지 않고 구조만 바꾼다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음. (원본: 규칙 테스트가 이번 구조를 지킨다.)

**부정**
- 규칙 테스트가 실패하면 예외를 늘리기 전에 공통 지점을 먼저 써야 한다(원본 주의사항). 그 밖의 비용은 논의 기록 없음.

## 영향 범위 (Scope)
4개 스택 전체(`client/`, `server/`, `ai/`, `app/`), `brand/`, `.claude/rules` 등 규칙 문서.

## 출처 (References)
- GitHub #458 이슈 본문 「해결 방안」, 통합 구현 보고서 주의사항 (2026-10-15)
- GitHub #459~#463 이슈 본문 「기준」
