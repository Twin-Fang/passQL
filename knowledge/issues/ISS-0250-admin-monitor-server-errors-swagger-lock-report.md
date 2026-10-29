---
type: completion-report
id: ISS-0250
created: 2026-10-08
topics: [admin, ops-infra, security]
status: resolved
resolves: "[[ISS-0250-admin-monitor-server-errors-swagger-lock]]"
related: ["[[ISS-0248-ops-log-retention-request-trace]]"]
source: "https://github.com/Twin-Fang/passQL/issues/440"
---

# ISS-0250 완료 리포트: `server_error_log` 기록·모니터링 표, Swagger 관리자 전용, 예외 전파 시 500 요약

GitHub #440 `## 개요` 리포트 댓글 기준 (v0.4.0, PR #441).

## 해결 방법
- 오류 기록: `ServerErrorLog` 엔티티(발생 시각·요청 ID·회원 8자리·메서드·URI·상태·원인), `ServerErrorLogService`(REQUIRES_NEW, 저장 실패 시 WARN만, URI 500자·원인 2000자 자르기), `ServerErrorLogCleanupScheduler`(매일 04시 KST 30일 지난 행 삭제), `V0_3_2__server_error_log.sql`. `GlobalExceptionHandler`가 5xx `CustomException`의 `errorCode: message`를 요청 속성 `passql.error.detail`로 넘김.
- `RequestTraceFilter`: 예외 전파 시 500으로 요약·기록 후 재던짐, 5xx 응답 기록.
- 관리자 화면 `monitor.html`: 카드 "AI 호출(최근 24시간)" → "서버 오류(최근 24시간, 5xx)", "최근 서버 오류" 표(24h 건수 + 최근 50건), 가짜 예시 행 5개·미구현 AI 카드 3개 삭제. `dashboard.html`에 "마지막 배포 이후 누적".
- 보안: `AdminSecurityConfig` `securityMatcher("/admin/**", "/docs/**")`, `SecurityConfig`의 죽은 `/swagger-ui/**`, `/v3/api-docs/**` 매처·permitAll 삭제.

## 근본 원인 (확정)
이슈 본문과 같음.

## 재발 방지
- 테스트: `RequestTraceFilterTest` 6/6, `ServerErrorLogServiceTest` 2/2, `ErrorFormatTest` 3/3.
- 운영(v0.4.0): Flyway `0.3.2` 적용, 비로그인 `/docs/api-docs` → 302 `/admin/login`, 관리자 로그인 후 Swagger UI 200(API 37개), `/admin/monitor` "미구현" 0건.
- 주의(원본): 운영에서 실제 5xx 기록은 아직 확인 못 함(단위 테스트만). `/api/**`, `/admin/**`만 기록하고 헬스체크 5xx는 기록하지 않음. 예외 메시지가 그대로 저장되므로 메시지에 개인정보를 넣는 예외는 만들지 않는다.

## 교훈
(원본에 없음, 볼트 정리) 새 경로(`/docs/**` 등)를 열면 어떤 SecurityFilterChain에 매칭되는지 확인한다 — 어디에도 안 걸리면 무인증 공개가 된다.
