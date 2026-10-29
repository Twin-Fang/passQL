---
type: issue
id: ISS-0278
created: 2026-10-15
topics: [admin]
symptoms: [신고 처리자 null, X-Member-UUID, localStorage memberUuid, report-detail.html, AdminReportController, resolved_by]
root_cause: "신고 상세 화면이 관리자 페이지에 없는 localStorage 회원 UUID를 `X-Member-UUID` 헤더로 보냈고, 서버는 그 헤더를 그대로 신뢰했다"
status: resolved
resolution: "[[ISS-0278-report-resolver-always-null-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/472"
---

# ISS-0278: 관리자 신고 처리자가 항상 null로 저장

GitHub #472 (원본: 이슈 본문, 구현 보고서 댓글).

## 증상
신고 처리 시 처리자가 항상 null. `report-detail.html`이 localStorage `memberUuid`를 `X-Member-UUID` 헤더로 보내는데 관리자 페이지에는 이 값이 없고, `AdminReportController`가 헤더를 그대로 신뢰한다.
위치: `server/PQL-Web/.../templates/admin/report-detail.html:248,262`, `AdminReportController.java:64`.

## 재현 조건
관리자 화면에서 신고를 처리하면 항상 발생.

## 조사 기록
- 2026-10-15: 예상 동작 — 처리자를 서버의 인증 주체(로그인한 관리자)에서 가져오고 헤더 파라미터 제거.

## 근본 원인
frontmatter `root_cause`와 같음.
