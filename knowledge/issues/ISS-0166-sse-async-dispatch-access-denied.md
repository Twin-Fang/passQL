---
type: issue
id: ISS-0166
created: 2026-04-26
topics: [security, ai]
symptoms: [AuthorizationDeniedException, "Access Denied", "response is already committed", "async dispatch", SseEmitter, DispatcherType.ASYNC, "선택지 생성에 실패했어요", ERR_HTTP2_PROTOCOL_ERROR, generate-choices]
root_cause: "`SecurityConfig`에 `dispatcherTypeMatchers(DispatcherType.ASYNC).permitAll()`이 없어 SSE 종료 후 ASYNC dispatch가 인증 정보 없이 Filter Chain을 재통과하다 Access Denied"
status: resolved
resolution: "[[ISS-0166-sse-async-dispatch-access-denied-report]]"
related: ["[[DEC-0086-permit-async-dispatch-in-security]]"]
source: "https://github.com/Twin-Fang/passQL/issues/310"
---

# ISS-0166: SSE async dispatch에서 Spring Security Access Denied로 선택지 생성 실패

GitHub #310 (원본: 이슈 본문, 로그 댓글, 리포트 댓글). 라벨 `긴급`.

## 증상
오늘의 문제(`/daily-challenge`) 진입 시 AI 선택지 생성 SSE 스트림에서 "선택지 생성에 실패했어요"가 표시된다. 백엔드는 SSE `complete` 이벤트를 정상 전송했지만 Tomcat async dispatch 단계에서 예외:
```
AuthorizationDeniedException: Access Denied (AuthorizationFilter.java:99)
Unable to handle the Spring Security Exception because the response is already committed.
발생 위치: AsyncContextImpl$AsyncRunnable.run (Tomcat async dispatch)
```
브라우저: `POST .../api/questions/{questionUuid}/generate-choices net::ERR_HTTP2_PROTOCOL_ERROR 200 (OK)`.

## 재현 조건
`/daily-challenge` 진입 → 선택지 생성 SSE 시작 대기 → 에러 메시지. 환경: Spring Security 6.4.4, 내장 Tomcat, `SseEmitter`.

## 조사 기록
- 2026-04-26: 운영 로그 확인 — 프리페치 MISS 후 런타임 생성, AI 응답(choiceCount=4)·샌드박스 검증까지 정상 진행된 뒤 ASYNC dispatch에서 `AuthorizationDeniedException`. (로그 원문의 회원 식별자 등은 옮기지 않음)

## 근본 원인
`SseEmitter`는 Tomcat async context를 쓰고, `complete` 후 `AsyncContext.dispatch()`가 Security Filter Chain을 다시 통과한다. 이때 요청 타입이 `ASYNC`이고 인증 정보가 없어 Access Denied가 나며, 응답이 이미 커밋되어 에러 처리도 불가능했다.
