---
type: decision
id: DEC-0103
created: 2026-10-07
reviewed: null
topics: [security]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0228-cors-wildcard-origin-reflection]]", "[[ISS-0228-cors-wildcard-origin-reflection-report]]"]
---

# DEC-0103: API CORS 허용 Origin은 서비스 도메인만, `cors.allowed-origin-patterns` 설정으로 관리

GitHub #394 (원본: 이슈 본문 「해결 방안」과 완료 댓글).

## 문제 정의 (Context)
CORS가 `allowedOriginPatterns("*")` + `allowCredentials(true)`로 어떤 Origin이든 반사했다. 이슈는 "당장 악용 경로는 제한적이지만 허용 범위가 필요 이상으로 넓다"고 적었다.

## 결정 (Decision)
허용 Origin을 서비스 도메인(`https://passql.vercel.app`, Vercel 미리보기, 로컬 개발)으로 제한하고 설정값으로 뺀다. 설정 키 `cors.allowed-origin-patterns`, 기본값 passql.vercel.app, passql-*.vercel.app, localhost.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 임의 Origin preflight가 403으로 거부된다 (운영 실측).

**부정 / 조건**
- 모바일 앱은 Origin 헤더를 보내지 않아 영향 없음 (원본).
- (원본에 없음, 볼트 정리) 새 웹 도메인을 쓰려면 이 설정에 추가해야 한다.

## 영향 범위 (Scope)
서버 `SecurityConfig.corsConfigurationSource()`, 설정 `cors.allowed-origin-patterns`.

## 출처 (References)
- GitHub #394 이슈 본문, 완료 댓글(PR #407, v0.0.247)
- [[ISS-0228-cors-wildcard-origin-reflection]]
