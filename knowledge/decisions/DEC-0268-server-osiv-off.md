---
type: decision
id: DEC-0268
created: 2026-11-07
reviewed: null
topics: [ops-infra]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0467-server-audit-llm-limit-osiv-choice-set-cache]]", "[[ISS-0467-server-audit-llm-limit-osiv-choice-set-cache-report]]", "[[ISS-0302-app-server-web-performance]]"]
---

# DEC-0268: 서버는 Open-Session-In-View 를 끄고, 응답 DTO 는 서비스 안에서 만든다

## 문제 정의 (Context)
`application.yml` 에 OSIV 설정이 없어 기본값(켜짐)이었다. 그래서 LLM·샌드박스를 호출하는 동안에도 요청 전체가 DB 커넥션을 쥐어, #497 에서 외부 호출을 트랜잭션 밖으로 뺀 분리([[ISS-0302-app-server-web-performance]])가 무력했다. 동시 요청 몇 건으로 커넥션 풀이 고갈될 수 있었다 (GitHub #879, [[ISS-0467-server-audit-llm-limit-osiv-choice-set-cache]]).

## 결정 (Decision)
- 서버 `spring.jpa.open-in-view: false` (`PQL-Web` `application.yml`).
- 컨트롤러·응답 변환에서 지연 로딩 연관을 건드리지 않는다. 응답 DTO 는 서비스(트랜잭션) 안에서 만든다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- LLM·샌드박스 호출 동안 커넥션을 쥐지 않아 #497 트랜잭션 분리가 실제로 효과를 낸다.

**부정**
- 트랜잭션 밖에서 지연 로딩 연관을 읽으면 `LazyInitializationException` 이 난다 (리포트 「주의할 점」).

## 영향 범위 (Scope)
서버 `PQL-Web` `application.yml`, 모든 컨트롤러·응답 변환 코드(지연 로딩 접근 금지), 서비스 계층의 응답 DTO 조립.

## 출처 (References)
- GitHub #879 이슈 본문·리포트 댓글 (2026-11-07)
