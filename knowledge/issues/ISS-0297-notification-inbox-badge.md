---
type: issue
id: ISS-0297
created: 2026-10-16
topics: [notification, admin]
symptoms: [푸시가 앱 안에 남지 않음, 지난 알림 다시 보기 없음, 공지 배너 닫으면 사라짐, 새 알림 표시 없음, 앱 아이콘 숫자 badge]
root_cause: "푸시는 받는 순간에만 보이고 앱 안에 저장되지 않았으며, 공지는 홈 배너로만 보였다(알림함 부재)"
status: resolved
resolution: "[[ISS-0297-notification-inbox-badge-report]]"
related: ["[[DEC-0131-member-notification-inbox-single-entry]]", "[[DEC-0132-push-permission-pre-prompt-sheet]]"]
source: "https://github.com/Twin-Fang/passQL/issues/491"
---

# ISS-0297: 알림함이 없어 지난 알림·공지를 다시 볼 수 없고 새 알림 표시가 없음

GitHub #491 (원본: 이슈 본문, 설계안 댓글, 구현 보고서 댓글).

## 증상
- 푸시는 받는 순간에만 보이고 앱 안에 남지 않음. 지난 알림을 다시 볼 수 없음.
- 공지는 홈 배너로만 보이고, 닫으면 다시 볼 방법이 없음.
- 새 알림이 왔는지 앱 안과 앱 아이콘에서 알 수 없음.
- 위치: `server/.../push_send_history`, `app_notice`, `PushNotificationService`, `app/lib/core/push`, `app/lib/data/push`.

## 재현 조건
해당 없음(기능 추가).

## 조사 기록
- 2026-10-16 설계안 댓글: 결정 사항 표(탭, 보관 90일, 종 아이콘, 앱 아이콘 숫자, 자동 알림 `REPORT_RESOLVED`, 웹 브라우저 푸시 안 함), 알림 권한 흐름, IO·성능 설계, 관리자 기능, 하지 않는 것. 상세 설계 `docs/superpowers/specs/2026-10-16-notification-inbox-design.md`.
- 2026-10-16 구현 중: 회수 직후 재회수가 막히지 않던 버그를 로컬 확인 중 찾아 고치고 회귀 테스트 추가.

## 근본 원인
frontmatter `root_cause`와 같음.
