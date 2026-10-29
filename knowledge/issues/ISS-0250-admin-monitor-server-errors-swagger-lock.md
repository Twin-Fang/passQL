---
type: issue
id: ISS-0250
created: 2026-10-08
topics: [admin, ops-infra, security]
symptoms: [서버 오류 안 보임, 5xx, 미구현 AI 카드 -1, "/docs/swagger 공개", "/docs/api-docs", SecurityFilterChain, "[req] 요약 200 오기록", RequestTraceFilter]
root_cause: "모니터링이 SQL 실행 로그만 보여 줬고, `/docs/**`가 어떤 SecurityFilterChain에도 매칭되지 않았으며, 예외 전파 시 요청 요약이 현재 응답 상태(200)로 찍혔다"
status: resolved
resolution: "[[ISS-0250-admin-monitor-server-errors-swagger-lock-report]]"
related: ["[[ISS-0248-ops-log-retention-request-trace]]"]
source: "https://github.com/Twin-Fang/passQL/issues/440"
---

# ISS-0250: 관리자 모니터링에 서버 오류 없음, 운영 Swagger 무인증 공개, 요청 요약 상태 오기록

GitHub #440 (원본: 이슈 본문과 리포트 댓글).

## 증상
2026-10-08 점검:
1. 관리자 모니터링은 SQL 실행 로그만 보여 준다. 5xx·처리되지 않은 예외는 컨테이너 로그를 직접 grep 해야 한다.
2. AI 호출 카드 3개(explain_error·diff_explain·similar)가 "미구현"(-1)으로 고정. Gemini 카운터는 인메모리라 배포마다 0이 되는데 화면에 설명이 없다.
3. 운영 Swagger(`/docs/swagger`, `/docs/api-docs`)가 인증 없이 공개 — `/docs/**`가 어떤 SecurityFilterChain에도 매칭되지 않는다. `SecurityConfig`의 `/swagger-ui/**`, `/v3/api-docs/**`는 실제 경로가 아니다(죽은 설정).
4. GitHub #436 요청 요약 버그 — 예외가 필터 밖으로 전파되면 `[req]` 요약이 실제(500)와 달리 현재 응답 상태(200)로 찍힌다.

## 재현 조건
비로그인으로 `/docs/swagger` 접근(3번), 필터 밖으로 예외가 전파되는 요청(4번).

## 조사 기록
- 2026-10-08: 위 점검 결과로 이슈 작성.

## 근본 원인
frontmatter `root_cause`와 같음. 추가로 "AI 호출 · 최근 24시간" 라벨은 실제로는 배포 이후 누적값이었다(리포트).
