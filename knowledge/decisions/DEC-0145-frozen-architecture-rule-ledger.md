---
type: decision
id: DEC-0145
created: 2026-10-17
reviewed: null
topics: [dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0317-architecture-audit-freeze-rules]]", "[[ISS-0317-architecture-audit-freeze-rules-report]]"]
---

# DEC-0145: 아키텍처 규칙은 `.rule` + 현재 위반 `.allow`로 동결하고, `.allow`에는 줄을 더하지 않는다

## 문제 정의 (Context)
4개 스택 감사에서 규칙 위반 49건이 나왔다 (GitHub #517).

## 결정 (Decision)
- 규칙 파일 `docs/architecture/rules/<id>.rule`, 현재 위반 고정 목록 `<id>.allow`. 각 스택 테스트가 판정한다(server ArchUnit 포함).
- 새 위반이 생기면 테스트가 실패한다. `.allow`에 줄을 더하지 않고 코드를 고친다.
- 위반을 고치면 목록에서 그 줄을 지운다(`ledger tighten`).
- client 규칙 테스트는 `npm test`와 `npm run build`에 연결한다.
- 동결 규칙 10개: server-no-raw-exception-message, server-controller-no-infra-injection, server-sandbox-acquire-single-entry, client-no-handwritten-api-type, client-no-arbitrary-size-class, client-no-direct-web-storage, app-core-no-data-sources, app-no-direct-shared-preferences, app-ad-request-single-entry, ai-no-sync-redis.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 기존 위반 49건 중 41건을 고치고 목록에서 제거했다.

**부정**
- 규칙 위반 시 Vercel 빌드가 실패한다.
- 공통 지점 파일을 옮기면 `.rule`의 `exclude`도 함께 고쳐야 한다.

## 영향 범위 (Scope)
`docs/architecture/rules/`, 4개 스택의 아키텍처 규칙 테스트, client 빌드.

## 출처 (References)
- GitHub #517 보고 댓글 (2026-10-17)
- [[ISS-0317-architecture-audit-freeze-rules]]
