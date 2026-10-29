---
type: completion-report
id: ISS-0281
created: 2026-10-15
topics: [admin, ops-infra]
status: resolved
resolves: "[[ISS-0281-admin-monitor-health-circuit-cards]]"
related: ["[[ISS-0280-admin-dashboard-metrics-pending-cards]]"]
source: "https://github.com/Twin-Fang/passQL/issues/475"
---

# ISS-0281 완료 리포트: AI·Qdrant·Redis 상태 카드, 서킷 상태 표, 24시간 통계 DB 집계

GitHub #475 구현 보고서 댓글 기준 (3차 통합 main `c46b9e6`, 0.13.0).

## 해결 방법
- 상태 카드 3개(각 3초 제한, 동시 확인): AI 서버 `/health`, Qdrant(AI 서버 `index-status` 경유, 포인트 수), Redis PING.
- resilience4j 서킷 상태 표(상태, 실패율, 최근 창 호출, 차단된 호출).
- `SubmissionService.getStats24h`를 메모리 집계에서 DB 집계 쿼리 1회로.
- 검증: 서버 전체 108개 중 107개 통과. 운영에서 AI 서버 정상(6ms), Qdrant 192건, Redis PONG, 서킷 2개 CLOSED.

## 근본 원인 (확정)
이슈 본문과 같음 (상태 확인 수단 부재, 통계를 메모리에서 계산).

## 재발 방지
원본에 별도 언급 없음.

## 교훈
(원본에 없음, 볼트 정리) 운영 화면 통계가 느리면 전체 행을 불러와 애플리케이션에서 세는지부터 본다.
