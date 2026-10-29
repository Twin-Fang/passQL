---
type: decision
id: DEC-0045
created: 2026-04-11
reviewed: null
topics: [admin, ops-infra]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0054-admin-dashboard]]", "[[ISS-0054-admin-dashboard-report]]", "[[DEC-0036-cross-domain-delete-service-in-web]]"]
---

# DEC-0045: 여러 도메인 Repository를 조합하는 집계 서비스는 `PQL-Application` 모듈에 둔다

## 문제 정의 (Context)
관리자 대시보드 통계는 Member·Question·Submission·Meta 네 도메인의 Repository를 함께 써야 했다 (GitHub #97).

## 결정 (Decision)
`AdminDashboardService`를 `PQL-Application` 모듈에 두고 `collect()` 단일 진입점으로 집계한다. 원본: "기존 `HomeService` 패턴을 따라" 배치.

## 검토한 대안 (Alternatives)
- 단일 도메인 서비스 안에 집계 로직을 넣기: 리포트는 "도메인 경계가 무너지므로" 쓰지 않았다고 적었다.

## 결과 (Consequences)
**긍정**
- 도메인 모듈 경계를 유지한다.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`server/PQL-Application/.../service/AdminDashboardService.java`, `DashboardStats`, `AdminDashboardController`. 볼트의 기존 결정 DEC-0010(`PQL-Common` → `PQL-Domain-*` → `PQL-Application` → `PQL-Web` 단방향 멀티모듈)과 같은 방향이다. 앞선 GitHub #58은 비슷한 크로스 도메인 삭제 서비스를 `PQL-Web`에 두었다([[DEC-0036-cross-domain-delete-service-in-web]]).

## 출처 (References)
- GitHub #97 이슈 본문 「해결 방안」, `## 개요` 리포트 댓글 「다중 도메인 집계 — Application 레이어 분리」(2026-04-11)
