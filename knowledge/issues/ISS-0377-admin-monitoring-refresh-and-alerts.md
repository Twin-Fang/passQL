---
type: issue
id: ISS-0377
created: 2026-10-24
topics: ["admin", "ops-infra"]
symptoms: ["모니터링 자동 새로고침 주석 처리", "monitor.html", "장애 외부 알림 없음", "Slack 알림", "오류율 지연 시계열"]
root_cause: "자동 새로고침 코드가 주석 처리돼 있었고(`monitor.html:205-206`), 외부 장애 알림 기능이 없었다"
status: resolved
resolution: null
related: ["[[ISS-0366-admin-question-quality-metrics-report]]"]
source: "https://github.com/Twin-Fang/passQL/issues/622"
---

# ISS-0377: 관리자 모니터링 자동 새로고침이 꺼져 있고 장애 외부 알림·시계열이 없음

GitHub #622 (원본: 이슈 본문; 완료 내용은 GitHub #611 통합 리포트 댓글).

## 증상
자동 새로고침이 주석 처리돼 있다(`monitor.html:205-206`). 장애 시 외부 알림이 없어 화면을 열어야만 알 수 있다. 기간·상태 필터와 시계열 추이가 없다.

## 재현 조건
해당 없음 (기능 이슈).

## 조사 기록
- 2026-10-24: 관리자 화면만으로 운영(DB 직접 조회 없이)하기 위한 관리자 개선 묶음(GitHub #611~#631) 중 하나로 등록. 공통 조건: 관리자 변경 작업은 기존 `AdminAuditLogService`로 감사 로그, 서버 API 변경 시 `api-contract/openapi.json` 갱신까지 한 커밋.
- 작업 범위: 자동 새로고침 복구, 기간·상태·URI 필터, 장애 알림(Slack 또는 메일), 오류율·지연 시계열.
- 2026-10-24: GitHub #611 통합 구현 보고서(PR #634, 운영 배포) 결과 — 모니터링 자동 새로고침, 필터, 시계열, Slack 알림 완료(Slack 실발송 미검증). 이 이슈 자체에는 완료 댓글이 없어 완료 리포트는 #611 쪽에 있다.

## 근본 원인
자동 새로고침은 주석 처리 상태였다(`monitor.html:205-206`). 왜 주석 처리됐는지는 원본에 적혀 있지 않다. 외부 알림·필터·시계열은 기능 미구현.
