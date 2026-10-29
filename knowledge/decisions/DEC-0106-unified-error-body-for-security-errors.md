---
type: decision
id: DEC-0106
created: 2026-10-08
reviewed: null
topics: [security, ops-infra]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0239-api-error-format-and-auth-failure-logs]]", "[[ISS-0239-api-error-format-and-auth-failure-logs-report]]", "[[DEC-0102-fixed-error-messages-detail-in-logs]]"]
---

# DEC-0106: 401·403·404도 `{"errorCode","message"}`로 통일하고 인증 실패·접근 거부는 WARN 로그

GitHub #406 (원본: 이슈 본문 「해결 방안」과 완료 댓글).

## 문제 정의 (Context)
API 에러 응답이 비즈니스 오류 `{"errorCode","message"}`, Spring 기본 `{"timestamp","status","error","path"}`, 본문 없는 401 세 가지로 섞여 있었고, 401/403·관리자 로그인 실패가 로그에 남지 않았다.

## 결정 (Decision)
- 401·403·404도 `{"errorCode","message"}`로 통일 (인증 진입점·접근 거부 처리기·NoResourceFound 처리). 결과: `/api/**` 미인증 401 `UNAUTHORIZED`, 권한 없음 403 `ACCESS_DENIED`, 컨트롤러 밖 오류 `{status,path,errorCode,message}`.
- 인증 실패·접근 거부는 WARN 로그(메서드·경로·IP). 관리자 로그인 실패는 IP·사유만, 아이디는 기록하지 않는다.
- 4xx 사용자 문구는 한국어로 둔다 (앱이 4xx 서버 문구를 그대로 보여주므로).

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 웹(`client.ts`)·앱(`auth_interceptor.dart`, `ErrorCodeMapper`)은 상태 코드로 분기해 호환된다 (원본).
- 비인증 스캔·무차별 대입을 로그로 추적할 수 있다 (이슈의 문제 제기 기준).

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
서버 `ApiSecurityErrorHandler`(로그 출처로 원본에 나옴), 인증 진입점·접근 거부 처리기, NoResourceFound 처리, `SecurityConfig`의 `/api/admin/**` 규칙 제거. 신고 처리자(`X-Member-UUID`) 문제는 범위 밖.

## 출처 (References)
- GitHub #406 이슈 본문, 완료 댓글(v0.0.251, PR #416, 2026-10-08)
- [[ISS-0239-api-error-format-and-auth-failure-logs]]
