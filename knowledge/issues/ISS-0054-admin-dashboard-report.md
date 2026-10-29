---
type: completion-report
id: ISS-0054
created: 2026-04-11
topics: [admin]
status: resolved
resolves: "[[ISS-0054-admin-dashboard]]"
related: ["[[DEC-0045-multi-domain-aggregation-in-application]]"]
source: "https://github.com/Twin-Fang/passQL/issues/97"
---

# ISS-0054 완료 리포트: `AdminDashboardController`·`AdminDashboardService`와 대시보드 보강

GitHub #97 `## 개요` 리포트 댓글(2026-04-11) 기준. 같은 날 "Stable 적용 완료" 댓글.

## 해결 방법
- `PQL-Application`: `DashboardStats` record(문제·회원·제출·실행 통계, 중첩 `TopicQuestionCount`), `AdminDashboardService.collect()`(Question·Member·Submission·ExecutionLog·Topic 리포지토리 조합).
- `PQL-Web`: `AdminDashboardController`(`GET /admin`, `GET /admin/`, 최근 실행 로그 20건), `RootController`(`GET /` → `redirect:/admin`).
- `SubmissionRepository.countBySubmittedAtAfter(LocalDateTime since)` — `findAll()` 대신 단일 COUNT.
- `dashboard.html`: 회원 통계 카드 3개, 토픽별 문제 분포 막대(매핑 실패 시 UUID 앞 8자리), Swagger(`/docs/swagger`) 빠른 링크. `layout.html` 사이드바에 Swagger 링크.

## 근본 원인 (확정)
대시보드 라우팅·집계 서비스 미구현.

## 재발 방지
리포트 주의사항: 활성 문제 수는 `findByIsActiveTrue().size()`, 회원 통계는 `memberRepository.findAll()` 후 스트림 필터 — 데이터가 커지면 count 쿼리로 바꿔야 한다. `aiCallCount`는 항상 `0`.

## 교훈
논의 기록 없음.
