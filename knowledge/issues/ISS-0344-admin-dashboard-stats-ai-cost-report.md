---
type: completion-report
id: ISS-0344
created: 2026-10-20
topics: [admin, ai, ops-infra]
status: resolved
resolves: "[[ISS-0344-admin-dashboard-stats-ai-cost]]"
related: ["[[DEC-0160-ai-call-log-tokens-cost-400-days]]", "[[DEC-0161-member-activity-hourly-online-in-memory]]"]
source: "https://github.com/Twin-Fang/passQL/issues/557"
---

# ISS-0344 완료 리포트: 대시보드 9개 블록, 회원 활동·Gemini 직접 호출 수집, 토큰 기반 비용 추정

GitHub #557 리포트 댓글(`## 개요`, 2026-10-20)과 운영 실측 댓글(2026-10-21) 기준. PR #571.

## 해결 방법
- 수집: `V1_26_0__admin_dashboard_statistics.sql` — `member_activity_hour` 테이블, `ai_call_log` 컬럼 4개(`call_source`, `model_name`, `prompt_token_count`, `completion_token_count`), 단가표 `ai.model_price_table`·월 예산 `ai.monthly_budget_usd` 시드. `MemberActivityInterceptor`가 인증된 `/api/**` 요청을 기록, `MemberActivityRecorder`가 메모리에서 최근 5분 온라인 수를 세고 DB에는 회원당 시간당 1행만 비동기 기록(400일 보관). 메모리 정리 10분마다, DB 정리 매일 04:40.
- `GeminiClient`: 직접 호출을 `generateWithinCallLimit` 한 곳에서 모두 기록(호출 자리 부족 포함). 출력 토큰 = candidates + thoughts. 실패 원인 429 `GEMINI_QUOTA_EXCEEDED`, 401·403 `GEMINI_PERMISSION_DENIED`. `checkApiKeyHealth()`(models.get, 5분 캐시, 3초 제한). 대체 경로(Python 실패 > Gemini)는 두 건으로 남는다.
- `AiGatewayClient` 등이 Python 응답 메타데이터에서 모델·토큰을 채움. `AiCallLogService` 보관 30일 > 400일. `AiCostCalculator`(단가 매칭: 정확 일치 > 가장 긴 접두 일치, 단가표 30초 캐시). `SystemHealthService`에 "Gemini API" 추가.
- 집계·API: `AdminStatisticsQueryRepository`·`AdminAiStatisticsQueryRepository`(NamedParameterJdbcTemplate, PostgreSQL native SQL), `StatisticsTimeAxis`(빈 날 0 채움), `AdminDashboardApiController`(8개), `AdminStatisticsApiController`(2개), 토론 게시글 관리(필터 3개, LIKE 와일드카드 이스케이프).
- 화면: `static/js/admin/admin-chart.js`(차트 공통 단일 원본), `dashboard.html` 블록 9개(블록마다 따로 fetch, KPI 30초 갱신·탭 숨김 시 정지), `community-posts.html`, `statistics.html`, `layout.html` 사이드바 그룹 5개(개요, 회원·커뮤니티, 콘텐츠, AI, 운영).
- 단가(공식 가격 페이지, 2026-10-20 확인): gemini-2.5-flash-lite $0.10 / $0.40, gemini-3.5-flash-lite $0.30 / $2.50.

## 근본 원인 (확정)
방문 이력과 Gemini 직접 호출이 수집되지 않았고 모델·토큰 컬럼이 없었다.

## 재발 방지
- 운영 실측(2026-10-21): deploy `7c521827`, Flyway `1.31.0` 적용 확인, 단가표·예산 시드 확인, 9개 블록 실데이터 표시·콘솔 오류 0. 배포 전 AI 호출 283건은 모델 "미기록"으로 묶임. 방문자·접속 중은 배포 후 약 1시간 회원 `/api` 요청 0건이라 0, 로컬에서 회원 JWT로 `/api/meta/topics` 2회 요청 > `member_activity_hour` 1행 기록 확인.
- 주의: 온라인 수는 메모리 기준(단일 인스턴스 전제). 활동 기록 대기열이 넘치면 버린다(방문 1건 누락 허용). 토큰·비용은 배포 시점부터. 사이드바가 900px 높이에서 스크롤된다.
- 검증 환경 참고: 키를 넣지 않으면 dev 통합 테스트 18건이 `passql.setting-encryption-key` 미설정으로 실패(기존 환경 문제).

## 교훈
(원본에 없음, 볼트 정리) 새 AI 호출 경로를 추가할 때는 `ai_call_log` 기록 지점을 거치는지 확인해야 사용량·비용 집계에서 빠지지 않는다.
