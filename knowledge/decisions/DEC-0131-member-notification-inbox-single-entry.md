---
type: decision
id: DEC-0131
created: 2026-10-16
reviewed: null
topics: [notification, admin]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0297-notification-inbox-badge]]", "[[DEC-0132-push-permission-pre-prompt-sheet]]"]
---

# DEC-0131: 회원 알림함은 `알림`/`공지` 두 탭, 생성 입구는 `MemberNotificationService` 하나, 일반 알림 90일 보관, 웹 브라우저 푸시는 하지 않음

## 문제 정의 (Context)
푸시는 받는 순간에만 보이고 앱 안에 남지 않았고, 공지는 닫으면 다시 볼 수 없었으며, 새 알림 여부를 알 수 없었다 (GitHub #491).

## 결정 (Decision)
설계안 댓글 "결정 사항" 표와 구현 기준:
- 탭: `알림`(GENERAL) / `공지`(NOTICE).
- 일반 알림 보관 90일, 관리자 화면에서 변경(7~365일).
- 종 아이콘: 앱 홈 오른쪽 위, 웹 상단 헤더. 새 알림은 주황 점과 개수(10개 이상 `9+`), 웹은 탭 제목 `(2) passQL`.
- 앱 아이콘 숫자: 푸시 발송 때 회원별 안 읽은 개수를 badge로 함께 전송, 앱에서 읽으면 갱신.
- 자동 알림: 신고 처리 결과(`REPORT_RESOLVED`) 포함, 오늘의 세트 리마인드는 종류만 정의.
- 알림 생성은 `MemberNotificationService` 한 곳(ArchUnit으로 저장소 접근을 알림 서비스 2개로 제한). 전달 방식은 푸시+알림함 / 알림함만.
- 하지 않는 것: 웹 브라우저 푸시, 실시간(웹소켓), 푸시 열람 집계(Analytics로 대체), 오늘의 세트 리마인드 실제 발송, 마케팅 푸시.

## 검토한 대안 (Alternatives)
논의 기록 없음. ("하지 않는 것" 목록은 범위 제외로 적혀 있고, 제외 이유는 마케팅 푸시(별도 동의 필요)와 푸시 열람 집계(Analytics로 대체) 외에는 원본에 없다.)

## 결과 (Consequences)
**긍정**
- 지난 알림·공지를 다시 볼 수 있고 앱 안·아이콘에서 새 알림을 알 수 있다.

**부정**
- 회수는 알림함에서 숨길 뿐 이미 나간 푸시는 되돌리지 못한다.
- 첫 전체 발송은 활성 회원 수만큼 한 번에 저장된다.
- 웹 알림 항목 이동은 웹에 있는 화면만 지원.

## 영향 범위 (Scope)
서버 `member_notification`·`member_notice_read`·`push_send_history`(마이그레이션 `V0_10_40`, `V0_10_41`), `/api/members/me/notifications...`, 관리자 `/admin/push`, 앱 홈 종 아이콘·알림함·`app_badge_plus`, 웹 헤더 종 아이콘·`/notifications`.

## 출처 (References)
- GitHub #491 설계안 댓글(2026-10-16) "결정 사항", "하지 않는 것", 구현 보고서 댓글
- [[ISS-0297-notification-inbox-badge]]
