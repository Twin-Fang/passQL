---
type: issue
id: ISS-0138
created: 2026-04-13
topics: [admin, question-bank]
symptoms: ["관리자 UUID를 찾을 수 없습니다", X-Member-UUID, "400 Bad Request", resolveReport, "/admin/report", report-detail.html, AdminReportController]
root_cause: "신고 resolve API가 `X-Member-UUID` 헤더를 필수로 요구하고, 프론트가 `localStorage` memberUuid가 없으면 요청을 차단"
status: resolved
resolution: "[[ISS-0138-admin-report-resolve-uuid-optional-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/254"
---

# ISS-0138: 관리자 신고 처리(resolve)가 UUID 없으면 막힘

GitHub #254 (원본: 이슈 본문과 리포트 댓글).

## 증상
`/admin/report` 신고 상세에서 처리 버튼을 누르면 `localStorage`에 `memberUuid`가 없을 때 "관리자 UUID를 찾을 수 없습니다"로 요청이 차단된다. 헤더 없이 서버를 직접 호출하면 `400 Bad Request`. 이슈 본문: mock 환경에서는 로그인 여부와 관계없이 모든 기능이 동작해야 한다.

## 재현 조건
`http://localhost:8080/admin/report` → 신고 상세 → 처리 클릭, `localStorage`에 `memberUuid` 없음. macOS / Chrome / Desktop.

## 조사 기록
- 2026-04-13: 관련 파일 `AdminReportController.java`, `report-detail.html`. 같은 증상 문구가 GitHub #234 QA 댓글에도 나온다.

## 근본 원인
`@RequestHeader("X-Member-UUID")` 필수 설정과 프론트의 사전 차단 로직.
