---
type: completion-report
id: ISS-0280
created: 2026-10-15
topics: [admin, ops-infra]
status: resolved
resolves: "[[ISS-0280-admin-dashboard-metrics-pending-cards]]"
related: ["[[ISS-0281-admin-monitor-health-circuit-cards]]"]
source: "https://github.com/Twin-Fang/passQL/issues/474"
---

# ISS-0280 완료 리포트: `ai_call_log` DB 집계, 지표 이름 정정, 미처리 건수 카드 4개

GitHub #474 구현 보고서 댓글 기준 (3차 통합 main `c46b9e6`, 0.13.0).

## 해결 방법
- AI 서버 호출을 `AiGatewayClient.postToPython` 한 곳에서 `ai_call_log`에 기록(전용 단일 스레드 비동기, 대기열 넘치면 버림, 30일 보관). 배포해도 값 유지(마이그레이션 `V0_10_13`).
- "에러율"을 "SQL 실행 실패율 (문법 오류 포함)"으로 이름·설명 수정.
- 카드 4개 추가(누르면 해당 목록으로): 서버 5xx, AI 서버 실패, 미처리 신고, 미처리 건의.
- 검증: `AiCallStatsTest`, 서버 전체 108개 중 107개 통과. 배포 Spring run `38820038302` 성공, 운영 대시보드 등 200·콘솔 오류 0.

## 근본 원인 (확정)
이슈 본문과 같음.

## 재발 방지
원본에 별도 언급 없음.

## 교훈
(원본에 없음, 볼트 정리) 메모리 카운터 지표는 배포마다 초기화된다. 누적 지표는 DB에 남긴다.
