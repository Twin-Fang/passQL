---
type: cluster
topic: notification
created: 2026-10-29
members: 17
status: active
related: []
---

# 클러스터: notification

## 이 주제는
푸시·알림

## 현재 상태 요약
(2026-10-29, 자동 생성) 활성 결정 3개, 열린 이슈 3개. 서술 요약은 아직 작성하지 않았다 — 아래 활성 결정 목록이 현재 기준이다.

## 활성 결정
- [[DEC-0131-member-notification-inbox-single-entry]] — 회원 알림함은 `알림`/`공지` 두 탭, 생성 입구는 `MemberNotificationService` 하나, 일반 알림 90일 보관, 웹 브라우저 푸시는 하지 않음
- [[DEC-0132-push-permission-pre-prompt-sheet]] — 알림 권한은 앱 안내 시트 뒤 "알림 받기"를 눌렀을 때만 시스템 창으로 요청, "나중에"는 7일간 다시 묻지 않음
- [[DEC-0149-contextual-notification-permission-prompt]] — 알림 권한 안내 시트는 가입 직후가 아니라 결과 화면을 본 뒤 탭 복귀 시나 두 번째 실행부터 띄운다

## 대체된 결정 (역사)
- 없음
- [[DEC-0216-count-badge-contrast-exception]] — 안 읽은 개수 배지는 iOS 시스템 빨강 + 흰 숫자 (DEC-0168 조건부 예외)

## 관련 이슈
- [[ISS-0431-app-home-top-bell-notice-banner]] (resolved, GitHub #756) — 홈 알림 아이콘 색과 공지 배너 개편
- [[ISS-0273-fcm-push-notifications]] (open, GitHub #467) — FCM 푸시 알림 (토큰 등록, 발송 화면, 앱 수신)
- [[ISS-0396-duolingo-style-return-notifications]] (open, GitHub #649) — 듀오링고식 재방문 알림·부가 기능 설계와 관리자 제어
- [[ISS-0398-per-type-notification-preferences]] (open, GitHub #653) — 알림 종류별 수신 설정 (앱 설정 화면 + 서버 저장)
- [[ISS-0270-maintenance-force-update-notices]] (resolved, GitHub #464) — 점검·강제/권장 업데이트·공지 수단이 없음
- [[ISS-0271-discord-failure-alert-webhook]] (resolved, GitHub #465) — Discord 장애 알림 웹훅 (취소)
- [[ISS-0297-notification-inbox-badge]] (resolved, GitHub #491) — 알림함이 없어 지난 알림·공지를 다시 볼 수 없고 새 알림 표시가 없음
- [[ISS-0320-ads-cards-notification-sheet-home]] (resolved, GitHub #522) — 하단 상시 광고 제거, 광고 카드화, 알림 권한 시트와 홈 카드 정리
- [[ISS-0325-notice-detail-list-screens]] (resolved, GitHub #529) — 공지사항 상세·목록 화면 (바텀시트 대체)
- [[ISS-0331-community-comments-push-share]] (resolved, GitHub #540) — 커뮤니티 댓글·푸시 알림·공유 링크·게시판 확장 (#525 후속)
- [[ISS-0384-admin-push-segments-scheduling]] (resolved, GitHub #629) — 관리자 푸시 대상이 전체/회원 지정뿐이고 예약·템플릿·테스트 발송·통계가 없음
- [[ISS-0385-admin-notice-maintenance-ops]] (resolved, GitHub #630) — 관리자 공지는 비활성화만 되고 점검 예약·읽음률·설정 이력·푸시 연동이 없음
- [[ISS-0399-auto-notification-preview-days]] (resolved, GitHub #656) — 자동 알림 관리자 미리보기가 규칙의 일수를 반영하지 않음
