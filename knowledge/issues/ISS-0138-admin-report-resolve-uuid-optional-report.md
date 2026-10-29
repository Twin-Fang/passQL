---
type: completion-report
id: ISS-0138
created: 2026-04-13
topics: [admin, question-bank]
status: resolved
resolves: "[[ISS-0138-admin-report-resolve-uuid-optional]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/254"
---

# ISS-0138 완료 리포트: resolve API의 `X-Member-UUID`를 선택 헤더로

GitHub #254 `## 개요` 리포트 댓글(2026-04-13) 기준.

## 해결 방법
- `server/PQL-Web/src/main/java/com/passql/web/controller/admin/AdminReportController.java`: `@RequestHeader("X-Member-UUID") UUID adminMemberUuid` → `@RequestHeader(value = "X-Member-UUID", required = false) UUID adminMemberUuid`. 없으면 `resolvedBy`는 null.
- `server/PQL-Web/src/main/resources/templates/admin/report-detail.html`: UUID 없을 때 차단하던 코드 제거, `adminMemberUuid`가 있을 때만 헤더 추가.

## 근본 원인 (확정)
필수 헤더 설정과 프론트 사전 차단.

## 재발 방지
리포트 주의사항: mock/개발 환경 편의를 위한 변경이며, 프로덕션에서는 별도 인증 미들웨어(Spring Security 등)로 관리자 접근을 보호해야 한다. `resolvedBy`가 null인 처리 건이 생길 수 있어 관리자 로그 조회 시 null 처리 필요.

## 교훈
논의 기록 없음.
