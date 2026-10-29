---
type: issue
id: ISS-0054
created: 2026-04-11
topics: [admin]
symptoms: ["/admin 404", AdminDashboardController, dashboard.html, "빈 화면", "핵심 지표 부재"]
root_cause: "/admin을 라우팅할 AdminDashboardController와 데이터를 공급할 서비스가 없었다"
status: resolved
resolution: "[[ISS-0054-admin-dashboard-report]]"
related: ["[[DEC-0045-multi-domain-aggregation-in-application]]"]
source: "https://github.com/Twin-Fang/passQL/issues/97"
---

# ISS-0054: `/admin` 진입 시 404 — 관리자 대시보드 컨트롤러·서비스 부재

GitHub #97 (원본: 이슈 본문과 댓글).

## 증상
`/admin` 진입 시 `AdminDashboardController`가 없어 404. `dashboard.html`은 있으나 데이터를 공급하는 서비스·컨트롤러가 없어 사실상 빈 화면. 핵심 지표(전체 문제 수, 오늘 제출 수, 에러율 등)와 회원 현황, 주요 메뉴 진입점이 없다.

## 재현 조건
관리자 로그인 후 `/admin` 접속.

## 조사 기록
- 2026-04-11: 스크린샷, 리포트 댓글, "Stable 적용 완료" 댓글.

## 근본 원인
대시보드 라우팅과 집계 서비스가 구현되지 않았다.
