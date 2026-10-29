---
type: issue
id: ISS-0280
created: 2026-10-15
topics: [admin, ops-infra]
symptoms: [대시보드 AI 호출 수, Gemini 메모리 카운터, "배포 시 0 초기화", 에러율 오해, "미처리 신고 건수 없음", dashboard.html]
root_cause: "AI 호출 수가 Gemini 메모리 카운터라 실제 AI 게이트웨이 호출을 세지 않고 배포 시 초기화됐고, 에러율은 회원 SQL 실행 실패율이었다"
status: resolved
resolution: "[[ISS-0280-admin-dashboard-metrics-pending-cards-report]]"
related: ["[[ISS-0281-admin-monitor-health-circuit-cards]]"]
source: "https://github.com/Twin-Fang/passQL/issues/474"
---

# ISS-0280: 관리자 대시보드 지표가 실제 의미와 다르고 미처리 건수가 없음

GitHub #474 (원본: 이슈 본문, 구현 보고서 댓글).

## 증상
- AI 호출 수가 Gemini 메모리 카운터라 실제 AI 게이트웨이 호출을 세지 않고 배포 시 0으로 초기화.
- 카드 문구 "마지막 배포 이후 누적"과 "오늘 AI 선택지 생성"이 모순.
- 에러율이 회원 SQL 실행 실패율이라 오답도 포함. 미처리 신고/건의 건수 없음.
- 위치: `server/PQL-Web/.../AdminDashboardController.java:41`, `templates/admin/dashboard.html:66,72`.

## 재현 조건
해당 없음(기능 개선).

## 조사 기록
- 2026-10-15: 제안 — AI 호출 성공/실패/지연을 DB에 집계, 서버 5xx·AI 실패·미처리 신고/건의 카드 추가, 지표 이름을 실제 의미로.

## 근본 원인
frontmatter `root_cause`와 같음.
