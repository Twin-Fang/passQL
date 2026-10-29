---
type: issue
id: ISS-0281
created: 2026-10-15
topics: [admin, ops-infra]
symptoms: [모니터링 화면, HealthIndicator 없음, Qdrant 상태, Redis 상태, resilience4j 서킷, getStats24h 메모리 로딩]
root_cause: "모니터링 화면에 실행 로그·5xx·Gemini 카운트만 있었고, `SubmissionService.getStats24h`가 24시간치 로그를 모두 메모리로 불러와 계산했다"
status: resolved
resolution: "[[ISS-0281-admin-monitor-health-circuit-cards-report]]"
related: ["[[ISS-0280-admin-dashboard-metrics-pending-cards]]"]
source: "https://github.com/Twin-Fang/passQL/issues/475"
---

# ISS-0281: 관리자 모니터링에 AI·Qdrant·Redis 상태와 서킷 상태 없음

GitHub #475 (원본: 이슈 본문, 구현 보고서 댓글).

## 증상
- 모니터링 화면에 실행 로그, 5xx, Gemini 카운트만 있음. HealthIndicator 구현 없음.
- `SubmissionService.getStats24h`가 24시간치 로그를 모두 메모리로 불러와 계산.
- 위치: `AdminMonitorController.java`, `SubmissionService.java:154`, `ai/src/apis/health_router.py:11`.

## 재현 조건
해당 없음(기능 추가).

## 조사 기록
- 2026-10-15: 제안 — AI 서버, Qdrant, Redis 헬스와 resilience4j 서킷 상태 카드, 24시간 통계를 집계 쿼리로.

## 근본 원인
frontmatter `root_cause`와 같음.
