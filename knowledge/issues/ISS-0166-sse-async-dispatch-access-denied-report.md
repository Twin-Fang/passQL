---
type: completion-report
id: ISS-0166
created: 2026-04-26
topics: [security, ai]
status: resolved
resolves: "[[ISS-0166-sse-async-dispatch-access-denied]]"
related: ["[[DEC-0086-permit-async-dispatch-in-security]]"]
source: "https://github.com/Twin-Fang/passQL/issues/310"
---

# ISS-0166 완료 리포트: `SecurityConfig`에 ASYNC dispatch 허용 추가

GitHub #310 `## 개요` 리포트 댓글(2026-04-26) 기준.

## 해결 방법
`server/PQL-Web/src/main/java/com/passql/web/config/SecurityConfig.java`의 `authorizeHttpRequests` 최상단에 `.dispatcherTypeMatchers(DispatcherType.ASYNC).permitAll()` 추가, `jakarta.servlet.DispatcherType` import.
- 수정 전: SSE complete 전송(itemCount=4) → ASYNC dispatch에서 Access Denied → response already committed → 프론트 "선택지 생성에 실패했어요"
- 수정 후: ASYNC dispatch가 `permitAll()` 통과 → 선택지 4개 정상 표시

## 근본 원인 (확정)
ASYNC 타입 dispatch에 대한 허용 설정이 없어 `AuthorizationFilter`가 인증 정보 없음으로 판단했다.

## 재발 방지
리포트 주의사항: 이 설정은 `ASYNC` dispatcher 타입 전체에 적용되어 SSE 외 다른 async 엔드포인트에도 영향을 준다. 당시 ASYNC를 쓰는 엔드포인트는 `generate-choices`가 유일하다고 적음. 재배포(서버 재시작) 후 적용.

## 교훈
(원본에 없음, 볼트 정리) SSE가 서버에선 성공인데 클라이언트에서 실패하면 async dispatch 단계의 Security 필터 재통과를 확인한다.
