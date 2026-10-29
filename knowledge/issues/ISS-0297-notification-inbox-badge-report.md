---
type: completion-report
id: ISS-0297
created: 2026-10-16
topics: [notification, admin]
status: resolved
resolves: "[[ISS-0297-notification-inbox-badge]]"
related: ["[[DEC-0131-member-notification-inbox-single-entry]]", "[[DEC-0132-push-permission-pre-prompt-sheet]]"]
source: "https://github.com/Twin-Fang/passQL/issues/491"
---

# ISS-0297 완료 리포트: 서버·관리자·앱·웹 알림함(알림·공지 탭), 종 아이콘, 앱 아이콘 숫자

GitHub #491 구현 보고서 댓글 기준 (Spring `38831495404`, Vercel `38831495461`). 설계는 `server/docs/NOTIFICATION-INBOX-DESIGN.md`.

## 해결 방법
- 서버: 테이블 `member_notification`, `member_notice_read`, `push_send_history` 확장(전달 방식, 받은 회원 수, 회수). 마이그레이션 `V0_10_40`, `V0_10_41`. 생성 입구 `MemberNotificationService` 하나, 조회·읽음 `MemberNotificationQueryService`, 보관 정리 스케줄러(매일 04:20, 5,000건씩, 기본 90일). API: 목록(커서), 안 읽은 개수, 항목 읽음, 모두 읽음(`/api/members/me/notifications...`). 신고 처리 완료·기각 시 `REPORT_RESOLVED` 알림(설정으로 끄기 가능). ArchUnit: 알림 저장소는 알림 서비스 2개만 사용.
- 성능: 전체 발송은 커밋 후 전용 비동기 실행기에서 `INSERT ... SELECT` 한 번. 푸시는 회원별 안 읽은 개수를 badge로 함께 전송(GROUP BY 1회, FCM 500건 단위). 안 읽은 개수는 부분 인덱스와 회원별 30초 캐시, 목록은 커서(OFFSET 없음).
- 관리자 `/admin/push`("알림 발송"): 발송(푸시+알림함 / 알림함만), 발송 이력(받은 회원 수, 읽은 수, 읽음률, 회수), 알림 설정(보관 기간 7~365일, 자동 알림 켜기/끄기). 회원 상세 알림 탭, 공지별 읽은 회원 수. 발송·회수는 감사 로그.
- 앱: 홈 종 아이콘(주황 점과 개수, 10개 이상 `9+`), `알림 | 공지` 탭, 모두 읽음, 커서 무한 스크롤, 앱 아이콘 숫자(`app_badge_plus`, `core/notification`에서만 사용), 알림 권한 안내 시트, 홈 공지 배너 "닫기"를 서버 읽음으로.
- 웹: 상단 종 아이콘·드롭다운(최근 5건), `/notifications`, 탭 제목 `(3) passQL`, 안 읽은 개수는 hook 하나에서만 조회(폴링 없음).
- 검증: 서버 134개 중 133개 통과, 앱 테스트 318개, 웹 vitest 36개. 운영 DB `0.10.40`, `0.10.41` 적용, 알림 API 무인증 401, 관리자 화면 200·콘솔 오류 0.

## 근본 원인 (확정)
기능 공백(이슈 본문과 같음).

## 재발 방지
주의(원본):
- 앱 아이콘 숫자와 푸시 수신은 실기기 확인 필요(시뮬레이터에서 권한 허용 불가).
- 회수는 알림함에서 숨길 뿐 이미 나간 푸시는 되돌리지 못한다.
- 첫 전체 발송은 활성 회원 수만큼 한 번에 저장되므로 회원이 많아지면 비수기에 하는 편이 안전하다.
- 홈·웹 배너는 공지 탭 첫 페이지(20건) 안의 안 읽은 중요 공지만 보여 준다.
- 웹 알림 항목 이동은 웹에 있는 화면(홈, 오늘의 세트, 문제, 통계)만 지원.
- 오늘의 세트 리마인드는 종류와 설정 키만 있고 실제 발송은 후속 과제.

## 교훈
원본에 없음.
