---
type: completion-report
id: ISS-0278
created: 2026-10-15
topics: [admin]
status: resolved
resolves: "[[ISS-0278-report-resolver-always-null]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/472"
---

# ISS-0278 완료 리포트: 처리자를 관리자 세션 아이디로, `resolved_by_admin_username` 컬럼 추가

GitHub #472 구현 보고서 댓글 기준 (1차 통합 main `0bc1ed5`, 서버 0.11.0).

## 해결 방법
- 처리자를 로그인한 관리자 세션의 아이디에서 가져옴. 헤더 파라미터와 화면의 localStorage 코드 제거.
- 관리자는 회원이 아니라서 새 컬럼 `question_report.resolved_by_admin_username` 추가(마이그레이션 `V0_10_0`).
- 기존 `resolved_by`(UUID) 컬럼은 DB에 남기고 엔티티 연결만 끊음(지금까지 값은 전부 null).
- 검증: `AdminReportControllerTest` 통과, 서버 전체 96개 중 95개 통과. 운영 DB에 0.10.0 마이그레이션 성공 기록.

## 근본 원인 (확정)
클라이언트가 보낸 헤더를 처리자로 신뢰했고, 관리자 페이지에는 그 값이 없었다.

## 재발 방지
처리자는 서버 인증 주체에서만 가져온다. 원본에 별도 재발 방지 언급은 없다.

## 교훈
(원본에 없음, 볼트 정리) 행위자 식별을 클라이언트 헤더에 맡기지 말고 서버 세션·토큰의 인증 주체에서 읽는다.
