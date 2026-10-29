---
type: completion-report
id: ISS-0248
created: 2026-10-08
topics: [ops-infra, ci-deploy]
status: resolved
resolves: "[[ISS-0248-ops-log-retention-request-trace]]"
related: ["[[ISS-0249-suh-logger-2-0-3-upgrade]]"]
source: "https://github.com/Twin-Fang/passQL/issues/436"
---

# ISS-0248 완료 리포트: 배포 시 구 컨테이너 로그 보관, 요청 ID(`rid|mid`) 추적, 헬스체크 로그 제외

GitHub #436 `## 개요` 리포트 댓글 기준 (v0.3.0, PR #437). 정정 댓글 반영.

## 해결 방법
- 배포 워크플로: `PROJECT-SPRING-SYNOLOGY-PASSQL-CICD.yaml`에 `archive_logs()` — 구 색 `docker rm -f` 직전 `docker logs` → `(NAS 경로 생략)`에 gz 보관, 30일 지난 파일 삭제. `PROJECT-PYTHON-AI-CICD.yaml`도 같은 처리(`(NAS 경로 생략)`). 보관 실패해도 경고만 남기고 배포 계속.
- 서버: `RequestTraceFilter`(신규, 최우선) — 요청 ID를 MDC `rid`와 응답 헤더 `X-Request-Id`에, `/api`·`/admin` 요청 종료 시 `[req] METHOD URI -> status (ms)` 한 줄(5xx는 WARN). `JwtAuthenticationFilter`가 인증 성공 시 MDC `mid`(회원 UUID 앞 8자리).
- `application.yml`: `logging.pattern.level: "%5p [%X{rid:--}|%X{mid:--}]"`, `spring.output.ansi.enabled: never`, suh-logger `exclude-patterns`에 `actuator/health`.
- 들어온 `X-Request-Id`는 `[A-Za-z0-9-]{8,64}`만 받는다(줄바꿈으로 가짜 로그 줄을 만드는 공격 방지). MDC는 `finally`에서 비운다(Tomcat 스레드 재사용).

## 근본 원인 (확정)
이슈 본문과 같음. 남은 ANSI·`[rid|mid]` 미적용은 suh-logger 2.0.1의 직접 출력 때문이며 정정 댓글에 따라 GitHub #438(2.0.3 업그레이드)에서 처리.

## 재발 방지
운영 실측(v0.3.0): `passql-back-blue-20261008-122715.log.gz`(23KB), `passql-ai-20261008-122359.log.gz` 생성, `X-Request-Id` 반환·이어받기(`qa-436-check-01`), 배포 후 `actuator/health` 로그 0건. 주의(원본): `mid`는 실제 로그인 요청으로 운영 확인 못 함(단위 테스트만), 컨테이너가 스스로 재시작되는 경우는 보관하지 않음, 로컬 dev Postgres에 밀린 마이그레이션 5개가 적용됨(운영 DB 무관).

## 교훈
- 정정 댓글(원본): "라이브러리 수정 필요" 판단은 틀렸고 라이브러리 최신 버전이 이미 해결해 있었다.
- (원본에 없음, 볼트 정리) 외부 라이브러리 동작이 설정을 무시하면 고치기 전에 최신 릴리스에서 이미 바뀌었는지부터 본다.
