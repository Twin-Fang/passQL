---
type: issue
id: ISS-0228
created: 2026-10-07
topics: [security]
symptoms: [CORS, "allowedOriginPatterns(\"*\")", "allowCredentials(true)", "Origin 반사", "access-control-allow-origin: https://evil.example", corsConfigurationSource]
root_cause: "CORS 설정이 `allowedOriginPatterns(\"*\")` + `allowCredentials(true)`라 어떤 Origin이든 그대로 반사했다"
status: resolved
resolution: "[[ISS-0228-cors-wildcard-origin-reflection-report]]"
related: ["[[DEC-0103-cors-service-domain-allowlist]]"]
source: "https://github.com/Twin-Fang/passQL/issues/394"
---

# ISS-0228: CORS가 모든 Origin을 반사함 — 서비스 도메인으로 제한

GitHub #394 (원본: 이슈 본문과 완료 댓글).

## 증상
API CORS 설정이 `allowedOriginPatterns("*")` + `allowCredentials(true)`라 어떤 Origin이든 그대로 반사한다. 인증이 Bearer 헤더라 당장 악용 경로는 제한적이지만 허용 범위가 필요 이상으로 넓다(원본 표현).

## 재현 조건
`curl -s -D- -o/dev/null -X OPTIONS <API 서버>/api/members/me -H "Origin: https://evil.example" -H "Access-Control-Request-Method: DELETE"` → 200, `access-control-allow-origin: https://evil.example`, `access-control-allow-credentials: true`.

## 조사 기록
- 2026-10-07: 대상 `SecurityConfig.corsConfigurationSource()`.

## 근본 원인
허용 Origin이 와일드카드였다.
