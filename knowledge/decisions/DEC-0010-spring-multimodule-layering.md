---
type: decision
id: DEC-0010
created: 2026-04-06
reviewed: null
topics: [ops-infra, dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0006-init-ai-and-spring-servers]]", "[[ISS-0006-init-ai-and-spring-servers-report]]"]
---

# DEC-0010: Spring 서버는 `PQL-Common` → `PQL-Domain-*` → `PQL-Application` → `PQL-Web` 단방향 멀티모듈

## 문제 정의 (Context)
GitHub #1에서 Spring 서버를 처음 구성했다.

## 결정 (Decision)
`PQL-Common` → `PQL-Domain-*` → `PQL-Application` → `PQL-Web` 순서로 의존성이 단방향으로 흐르는 멀티모듈 구조를 채택한다. 공통 인프라 의존성(Web, JPA, Security, Redis, Cache, Actuator, Flyway, Qdrant, Resilience4j)은 `PQL-Common`에 모은다. `PQL-Web`이 실행 모듈이다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 리포트: 공통 인프라 의존성을 `PQL-Common`에 모아 중복을 제거했다.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`server/settings.gradle`, `server/build.gradle`, 각 모듈 `build.gradle`.

## 출처 (References)
- GitHub #1 `## 개요` 리포트 댓글 「멀티모듈 계층 설계」 (2026-04-06)
- [[ISS-0006-init-ai-and-spring-servers]]
