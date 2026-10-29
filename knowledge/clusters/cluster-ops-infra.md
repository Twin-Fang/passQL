---
type: cluster
topic: ops-infra
created: 2026-10-29
members: 62
status: active
related: []
---

# 클러스터: ops-infra

## 이 주제는
운영 서버·로그·모니터링·DB·Flyway·인프라·성능

## 현재 상태 요약
(2026-10-29, 자동 생성) 활성 결정 20개, 열린 이슈 2개. 서술 요약은 아직 작성하지 않았다 — 아래 활성 결정 목록이 현재 기준이다.

## 활성 결정
- [[DEC-0010-spring-multimodule-layering]] — Spring 서버는 `PQL-Common` → `PQL-Domain-*` → `PQL-Application` → `PQL-Web` 단방향 멀티모듈
- [[DEC-0014-explicit-soft-delete-filter]] — 소프트 딜리트는 `@SQLDelete` 없이 `is_deleted` 컬럼 + `AndIsDeletedFalse` 메서드로 명시 필터링
- [[DEC-0019-never-edit-applied-migrations]] — 기존 Flyway 마이그레이션은 수정하지 않고 `version.yml` 기준 새 버전 파일로 추가, 시드는 멱등
- [[DEC-0023-uuid-primary-keys-all-tables]] — 모든 엔티티 PK를 UUID로 (전체 스키마 전면 전환)
- [[DEC-0036-cross-domain-delete-service-in-web]] — 문제·제출 도메인을 함께 지우는 삭제 오케스트레이션은 `PQL-Web`의 `AdminQuestionDeleteService`에 둔다
- [[DEC-0045-multi-domain-aggregation-in-application]] — 여러 도메인 Repository를 조합하는 집계 서비스는 `PQL-Application` 모듈에 둔다
- [[DEC-0047-execute-uses-temp-sandbox-db]] — `sandboxDbName`이 없는 문제의 `/execute`는 호출마다 `SandboxPool` 임시 DB를 만들어 실행하고 지운다
- [[DEC-0054-postgresql-sandbox-engine]] — Sandbox(와 앱 datasource) DB 엔진을 MariaDB에서 PostgreSQL로 전면 전환
- [[DEC-0072-idempotent-ddl-migrations]] — Flyway DDL 변경(ALTER·컬럼 추가/삭제/타입 변경)은 멱등하게 — 조건 확인 후 `DO $$` 블록에서 실행
- [[DEC-0092-container-restart-unless-stopped-in-workflow]] — 운영 백엔드·AI 컨테이너 재시작 정책은 `unless-stopped`로 통일하고 배포 워크플로우의 `docker run`에 고정한다
- [[DEC-0094-hourly-health-check-workflow]] — 운영 감시는 별도 서버 없이 1시간 주기 GitHub 워크플로우 헬스체크(`PASSQL-HEALTH-CHECK`)로 한다
- [[DEC-0102-fixed-error-messages-detail-in-logs]] — API 오류 메시지는 고정 문구만 내보내고 상세는 서버 로그에만 남긴다
- [[DEC-0104-log-4xx-warn-5xx-error]] — 4xx 처리는 WARN, 처리되지 않은 예외(500)·5xx `CustomException`만 ERROR로 기록
- [[DEC-0106-unified-error-body-for-security-errors]] — 401·403·404도 `{"errorCode","message"}`로 통일하고 인증 실패·접근 거부는 WARN 로그
- [[DEC-0111-traefik-blue-green-zero-downtime]] — 백엔드 배포는 시놀로지 기존 Traefik(8079) 경유 Blue-Green 무중단 방식으로 한다
- [[DEC-0128-prod-json-logs-activity-events]] — prod 로그는 JSON 한 줄, Docker `json-file` 20m×5 로테이션, 회원 행동 이벤트는 개인 내용 없이 6종
- [[DEC-0151-client-webp-compress-server-stream]] — 커뮤니티 사진은 폰에서 WebP로 압축하고, 서버는 검증만 해 기존 NAS MinIO 한 버킷에 저장·스트리밍한다
- [[DEC-0160-ai-call-log-tokens-cost-400-days]] — AI 비용은 `ai_call_log`의 모델·토큰 × 앱 설정 단가표로 추정하고, 호출 기록은 요약 테이블 없이 400일 보관한다
- [[DEC-0161-member-activity-hourly-online-in-memory]] — 방문자는 회원당 시간당 1행(`member_activity_hour`)으로 기록하고, 접속 중 수는 메모리에서 최근 5분 활동으로 센다
- [[DEC-0200-shared-sandbox-result-cache]] — 샌드박스 실행 결과는 `CachedSandboxExecutor` 한 곳에서 회원 간 공유 캐시(메모리 30분 > Redis 7일)로 재사용한다

## 대체된 결정 (역사)
- 없음

## 관련 이슈
- [[ISS-0357-choice-set-ai-server-half-failing]] (open, GitHub #575) — 선택지 생성 AI 서버 호출 절반 실패, 원인 조사
- [[ISS-0415-feedback-single-submit-attachments-diagnostics]] (open, GitHub #708) — 의견 보내기 개편 — 단건 전송, 이미지 첨부, 진단 정보와 로그
- [[ISS-0006-init-ai-and-spring-servers]] (resolved, GitHub #1) — AI 서버·Spring 서버 초기 프로젝트 구성
- [[ISS-0013-flyway-missing-tables-seed]] (resolved, GitHub #10) — Flyway V0_0_15 누락 테이블 및 초기 시드 데이터 추가
- [[ISS-0018-submission-table-question-active]] (resolved, GitHub #22) — Entity 스키마 보강 — submission 테이블, question.is_active
- [[ISS-0045-sandbox-pool-settings-hardcoded-yml]] (resolved, GitHub #75) — SandboxPool 동시 실행 슬롯·대기 시간이 yml 하드코딩이라 운영 중 조정 불가
- [[ISS-0050-sse-complete-hikaripool-self-invocation]] (resolved, GitHub #91) — 선택지 생성은 성공하는데 두 번째 문제부터 SSE `complete`가 오지 않아 화면 멈춤
- [[ISS-0059-execute-sandbox-db-access-denied]] (resolved, GitHub #104) — `/execute`가 `questionUuid`를 DB명으로 폴백해 Access Denied — 모든 문제의 실행 버튼 불능
- [[ISS-0071-sandbox-mariadb-to-postgresql]] (resolved, GitHub #122) — Sandbox DB 엔진 MariaDB → PostgreSQL 전면 전환
- [[ISS-0073-ai-server-401-env-file-missing]] (resolved, GitHub #125) — Python AI 서버 호출이 매번 401 Unauthorized
- [[ISS-0119-flyway-migration-idempotency-rule]] (resolved, GitHub #217) — Flyway 마이그레이션 SQL 멱등성 안전장치 규칙 정립
- [[ISS-0120-feedback-uuid-char36-type-mismatch]] (resolved, GitHub #218) — feedback UUID 컬럼 `CHAR(36)` vs PostgreSQL `uuid` 불일치로 500
- [[ISS-0139-ai-qdrant-env-prod-config]] (resolved, GitHub #256) — prod `passql-ai`가 `localhost`로 Qdrant에 접속해 연결 실패
- [[ISS-0140-e2e-db-user-data-truncate-doc]] (resolved, GitHub #259) — E2E 테스트용 DB 유저 데이터 초기화 절차가 없음
- [[ISS-0171-flyway-v0-0-184-mysql-syntax]] (resolved, GitHub #324) — Flyway `V0_0_184` MySQL 문법으로 PostgreSQL 부팅 실패
- [[ISS-0182-prod-container-down-restart-policy]] (resolved, GitHub #337) — 운영 서버 컨테이너 중단 복구 및 자동 재시작 설정
- [[ISS-0184-production-launch-criteria]] (resolved, GitHub #339) — 정식 서비스(production) 출시 기준 정립
- [[ISS-0195-legal-text-escaped-newlines]] (resolved, GitHub #350) — 약관 화면에 `\n` 글자가 그대로 보이고 조항이 한 덩어리로 표시됨
- [[ISS-0224-https-forward-headers-secure-cookie]] (resolved, GitHub #389) — HTTPS 전환 누락으로 관리자 로그인이 평문 제공되고 세션 쿠키에 `Secure`가 없음
- [[ISS-0227-unsupported-media-type-500-signature-leak]] (resolved, GitHub #393) — 미지원 Content-Type이 500으로 응답되고 오류 메시지에 내부 시그니처 노출
- [[ISS-0229-client-errors-logged-as-error]] (resolved, GitHub #395) — 클라이언트 오류(4xx)가 전부 ERROR로 기록돼 실제 장애 로그가 묻힘
- [[ISS-0233-web-robots-favicon-return-index-html]] (resolved, GitHub #400) — `robots.txt`·`favicon.ico` 요청에 index.html이 반환됨 (웹)
- [[ISS-0239-api-error-format-and-auth-failure-logs]] (resolved, GitHub #406) — API 에러 응답 형식이 세 가지로 섞여 있고 인증 실패가 로그에 남지 않음
- [[ISS-0246-backend-traefik-blue-green-deploy]] (resolved, GitHub #423) — 백엔드 배포 중 약 45초 502 — Traefik Blue-Green 무중단 배포 전환
- [[ISS-0248-ops-log-retention-request-trace]] (resolved, GitHub #436) — 운영 로그 — 배포 시 유실, 헬스체크 노이즈, 요청 추적 불가, ANSI 혼입
- [[ISS-0249-suh-logger-2-0-3-upgrade]] (resolved, GitHub #438) — suh-logger 요청 로그 블록에 ANSI가 남고 요청 ID가 붙지 않음
- [[ISS-0250-admin-monitor-server-errors-swagger-lock]] (resolved, GitHub #440) — 관리자 모니터링에 서버 오류 없음, 운영 Swagger 무인증 공개, 요청 요약 상태 오기록
- [[ISS-0270-maintenance-force-update-notices]] (resolved, GitHub #464) — 점검·강제/권장 업데이트·공지 수단이 없음
- [[ISS-0271-discord-failure-alert-webhook]] (resolved, GitHub #465) — Discord 장애 알림 웹훅 (취소)
- [[ISS-0272-crashlytics-global-error-handling]] (resolved, GitHub #466) — 앱 크래시·삼킨 API 실패를 알 방법이 없음
- [[ISS-0274-firebase-analytics-events]] (resolved, GitHub #468) — 앱 퍼널·잔존율 측정 수단 없음 (Firebase Analytics 도입)
- [[ISS-0279-app-setting-value-type-validation]] (resolved, GitHub #473) — 관리자 앱 설정 저장 시 값 타입 검증 없음
- [[ISS-0280-admin-dashboard-metrics-pending-cards]] (resolved, GitHub #474) — 관리자 대시보드 지표가 실제 의미와 다르고 미처리 건수가 없음
- [[ISS-0281-admin-monitor-health-circuit-cards]] (resolved, GitHub #475) — 관리자 모니터링에 AI·Qdrant·Redis 상태와 서킷 상태 없음
- [[ISS-0282-json-logs-rotation-activity-events]] (resolved, GitHub #476) — 서버 로그가 평문뿐이고 크기 제한·행동 이벤트 기록이 없음
- [[ISS-0296-passql-db-daily-backup]] (resolved, GitHub #490) — passQL DB 일일 자동 백업이 없음
- [[ISS-0302-app-server-web-performance]] (resolved, GitHub #497) — 앱·서버·웹 전반의 성능 저하 (감사 결과)
- [[ISS-0334-nas-secret-upload-path-missing]] (resolved, GitHub #544) — NAS 시크릿 업로드 — 앱 .env·AI env 구분 오류와 값형 시크릿 누락
- [[ISS-0344-admin-dashboard-stats-ai-cost]] (resolved, GitHub #557) — 관리자 대시보드 통계 그래프, 접속자 집계, AI 사용량과 비용
- [[ISS-0377-admin-monitoring-refresh-and-alerts]] (resolved, GitHub #622) — 관리자 모니터링 자동 새로고침이 꺼져 있고 장애 외부 알림·시계열이 없음
- [[ISS-0390-sql-validator-silent-default-fallback]] (resolved, GitHub #640) — `SqlSafetyValidator` 설정 조회 실패를 로그 없이 기본값으로 대체함
- [[ISS-0405-home-first-load-skeleton-wait]] (resolved, GitHub #676) — 홈 첫 로딩 대기 시간 단축 — 지난 데이터 먼저 보여 주기
