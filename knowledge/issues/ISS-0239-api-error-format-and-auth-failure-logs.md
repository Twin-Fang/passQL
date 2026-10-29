---
type: issue
id: ISS-0239
created: 2026-10-07
topics: [security, ops-infra]
symptoms: ["에러 응답 형식 세 가지", "401 본문 없음", "{timestamp,status,error,path}", "없는 /api 경로 401", "인증 실패 로그 없음", X-Member-UUID, "/api/admin/** 죽은 규칙"]
root_cause: "인증 진입점·접근 거부·NoResourceFound가 Spring 기본 처리로 남아 비즈니스 오류와 형식이 달랐고, 인증 실패 로그가 없었다"
status: resolved
resolution: "[[ISS-0239-api-error-format-and-auth-failure-logs-report]]"
related: ["[[DEC-0106-unified-error-body-for-security-errors]]"]
source: "https://github.com/Twin-Fang/passQL/issues/406"
---

# ISS-0239: API 에러 응답 형식이 세 가지로 섞여 있고 인증 실패가 로그에 남지 않음

GitHub #406 (원본: 이슈 본문과 완료 댓글).

## 증상
- 에러 응답 형식 세 가지: `{"errorCode","message"}`(비즈니스 오류), Spring 기본 `{"timestamp","status","error","path"}`(없는 경로 404, 관리자 비인증 403), 본문 없는 401(`/api/**` 미인증 전부).
- 존재하지 않는 `/api/...` 경로가 404가 아니라 401.
- 401/403·관리자 로그인 실패가 로그에 남지 않아 비인증 스캔·무차별 대입을 추적할 수 없음.
- 신고 처리자를 클라이언트 헤더 `X-Member-UUID`로 받아 기록(`AdminReportController`) — 위조·누락 가능.
- `/api/admin/** hasRole("ADMIN")`은 대응 컨트롤러가 없는 죽은 규칙.

## 재현 조건
`curl -i <API 서버>/api/members/me` (미인증) → 본문 없는 401.

## 조사 기록
- 2026-10-07: 이슈 본문 — 클라이언트(웹·앱)의 401 처리 분기에 영향이 있어 함께 확인 후 진행.

## 근본 원인
보안 필터 단계의 오류가 공통 오류 형식을 거치지 않았다 (원본의 해결 방안에서 읽힘).
