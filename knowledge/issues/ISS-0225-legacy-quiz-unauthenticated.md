---
type: issue
id: ISS-0225
created: 2026-10-07
topics: [security]
symptoms: ["/quiz/**", QuizController, "인증 없이 도달", "memberUuid 누락 400", securityMatcher, "학습 통계 오염"]
root_cause: "레거시 SSR `/quiz/**`가 어떤 보안 체인(`SecurityConfig`, `AdminSecurityConfig`)에도 포함되지 않았다"
status: resolved
resolution: "[[ISS-0225-legacy-quiz-unauthenticated-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/390"
---

# ISS-0225: `/quiz` 레거시 화면이 인증 없이 열려 있음

GitHub #390 (원본: 이슈 본문과 완료 댓글).

## 증상
레거시 SSR 화면 `/quiz/**`(`QuizController`)가 보안 체인에 없어 인증·CSRF 없이 컨트롤러까지 도달한다. 코드상 `POST /quiz/start?memberUuid=<회원 UUID>`로 남의 명의로 풀이 세션을 만들고 `/submit`으로 그 회원의 `Submission`을 저장할 수 있다(`QuizSessionService`) — 학습 통계 오염 경로. 웹·앱 어디서도 `/quiz`를 쓰지 않는다.

## 재현 조건
운영 E2E QA(2026-10-08, v0.0.245). `curl -X POST <API 서버>/quiz/start`(토큰 없음) → 401이 아니라 `MISSING_PARAMETER` 400. 실제 회원 명의 생성 요청은 보내지 않았다.

## 조사 기록
- 2026-10-07: `SecurityConfig`는 `/api/**`·`/actuator/**`·Swagger만, `AdminSecurityConfig`는 `/admin/**`만 덮는다.

## 근본 원인
`/quiz/**`가 어느 보안 체인의 매처에도 없었다.
