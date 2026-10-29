---
type: decision
id: DEC-0086
created: 2026-04-26
reviewed: null
topics: [security, ai]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0166-sse-async-dispatch-access-denied]]", "[[ISS-0166-sse-async-dispatch-access-denied-report]]"]
---

# DEC-0086: Spring Security에서 `DispatcherType.ASYNC`는 인증 재검사 없이 `permitAll()`

## 문제 정의 (Context)
SSE(`SseEmitter`) 선택지 생성이 끝난 뒤 Tomcat ASYNC dispatch가 Security Filter Chain을 재통과하면서 Access Denied가 나 선택지 생성이 실패로 보였다 (GitHub #310).

## 결정 (Decision)
`SecurityConfig`의 `authorizeHttpRequests` 맨 앞에 `.dispatcherTypeMatchers(DispatcherType.ASYNC).permitAll()`을 둔다. 근거(코드 주석·리포트): "ASYNC dispatch는 최초 REQUEST에서 JWT 인증이 이미 완료됐으므로 재검사 불필요", "최초 `REQUEST` 단계에서 JWT 인증이 완료된 상태이므로 보안상 문제가 없다".

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- SSE `complete` 후 선택지가 정상 표시된다.

**부정**
- `ASYNC` dispatcher 타입 전체에 적용되므로 SSE 외 다른 async 엔드포인트에도 영향을 준다(당시 ASYNC 사용 엔드포인트는 `generate-choices`뿐).

## 영향 범위 (Scope)
`server/PQL-Web/src/main/java/com/passql/web/config/SecurityConfig.java`, SSE/async 엔드포인트 전체.

## 출처 (References)
- GitHub #310 이슈 본문, 리포트 댓글(2026-04-26) "해결 방식"·"주의사항"
