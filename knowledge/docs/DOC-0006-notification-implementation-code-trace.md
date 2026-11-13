---
type: doc
id: DOC-0006
doc_type: design
authority: internal
created: 2026-11-13
reviewed: null
source: "https://github.com/Twin-Fang/passQL/tree/118159a8"
topics: [notification]
topics_ref: [admin, question-bank]
decisions: []
status: active
supersedes: null
superseded_by: null
related: ["[[DEC-0131-member-notification-inbox-single-entry]]", "[[DEC-0132-push-permission-pre-prompt-sheet]]", "[[DEC-0304-first-launch-notification-prompt-after-welcome]]", "[[DEC-0293-exam-schedule-rule-based-auto-sync]]", "[[DOC-0002-auth-member-implementation-code-trace]]", "[[DOC-0007-question-bank-implementation-code-trace]]"]
---

# DOC-0006: 푸시 알림 구현 코드 추적 — 서버·앱

## 요약
2026-11-13 main(`118159a8`, v1.120.0) 코드를 직접 따라가 정리한 알림 지도다. 알림 생성 입구는 `MemberNotificationService` 하나이고, 알림함 저장이 먼저, 푸시 전달은 커밋 뒤 `NotificationDispatcher`가 전용 실행기에서 비동기로 한다. 푸시는 FCM `sendEach`로 500개씩 보내고 기기마다 안 읽은 개수(배지)를 붙인다. 알림 종류는 회원 1명 알림(신고 처리 결과, 의견 상태 변경), 관리자 발송(전체·세그먼트·예약·테스트), 재방문·시험 일정 자동 알림 세 갈래다. 코드가 바뀌면 이 문서는 낡으므로, 인용 전에 파일이 아직 있는지 확인한다.

## 핵심 내용 · 논점

### 스택별 역할
| 스택 | 역할 | 주요 위치 |
|---|---|---|
| 서버 | 알림함 저장, 푸시 전달, 자동 알림 규칙, 예약 발송, 보관 기간 정리, 수신 설정 | `PQL-Application/.../notification/`(`MemberNotificationService`, `NotificationDispatcher`, `NotificationDispatchEvent`, `AutoNotificationService`, `AutoNotificationTargetQueryRepository`, `ExamNotificationOccasionFinder`, `MemberNotificationPreferenceService`, `NotificationSettingService`, `UnreadNotificationCountCache`), `PQL-Domain-Member/.../service/PushNotificationService`, `.../push/FirebasePushMessageSender`, `PQL-Web/.../scheduler/`(`PushScheduleScheduler`, `AutoNotificationScheduler`, `NotificationRetentionScheduler`) |
| 앱 | 권한 안내, 토큰 등록, 수신·탭 이동, 알림함, 앱 아이콘 배지 | `app/lib/data/push/push_notification_service.dart`, `core/push/`(`firebase_push_messaging_client`, `push_link`, `push_permission_prompt_store`), `core/notification/app_icon_badge_updater.dart` |

### 기기 등록
- 앱 `PushNotificationService`: 로그인 회원 기기 등록(권한은 읽기만, 시스템 창 없음) > FCM 토큰 > `PUT /api/members/me/push-token`(`MemberPushTokenService.registerToken`) > 토큰 갱신 구독(바뀌면 재등록, 수신 동의는 서버 값 유지).
- 로그아웃 직전 `DELETE /api/members/me/push-token`. 탈퇴는 서버가 그 회원 토큰을 전부 지운다([[DOC-0002-auth-member-implementation-code-trace]]).
- 권한 요청은 앱 안내 시트에서 사용자가 고른 뒤에만. `push_permission_prompt_store`: "나중에" 뒤 7일간 다시 묻지 않음. 처음 켤 때는 홈 환영 안내 직후에 안내([[DEC-0304-first-launch-notification-prompt-after-welcome]]).

### 회원 1명 알림
1. `MemberNotificationService.notifyMember`(한 트랜잭션): 알림함 저장 > 안 읽은 개수 캐시 삭제 > `NotificationDispatchEvent` 발행.
2. 호출부: `QuestionReportService.notifyReporterOfResult`(신고 처리·기각, 설정 `notification.report_resolved.enabled` 꺼짐이면 생략, [[DOC-0007-question-bank-implementation-code-trace]]), `FeedbackAdminService.notifyStatusChanged`(의견 상태 변경, `PENDING`은 알림 없음).

### 커밋 뒤 전달 (`NotificationDispatcher`)
- `@Async` + `@TransactionalEventListener(AFTER_COMMIT)`. 실패는 로그만(요청 결과에 영향 없음).
- 전체·세그먼트 알림은 여기서 알림함 저장(팬아웃)을 먼저 한다(`isFanoutRequired`).
- `deliverPush`: 대상 기기(세그먼트면 `PushAudienceResolver.findDevices`, 아니면 `PushNotificationService.findDevices` = 푸시 수신 동의 기기) > 회원별 배지 수(전체 발송만 전체 회원 GROUP BY 1회) > `toPushMessage`(제목·본문·이동 데이터) > `deliver` > 관리자 발송이면 결과 기록.
- `PushNotificationService.deliver`: 기기별 배지 부착 > 발송 > 실패 기기 기록(발송 이력이 있을 때) > 만료 토큰 삭제 > 결과 집계.
- `FirebasePushMessageSender.send`: 500개 묶음 `sendEach`, 묶음 전체 실패면 그 묶음 토큰을 실패로 기록하고 다음 묶음 계속. Android 채널·우선순위, iOS 소리·앱 아이콘 숫자.

### 관리자 발송·예약
- `sendAdminMessage`: `PushNotificationService.acceptSend`(대상·이동·미접속 일수·예약 시각 검증 > 이력 저장) > 즉시면 저장·전달, 예약이면 대기.
- `PushScheduleScheduler`(매분) > `dispatchDueScheduledSends`: 건별 선점 > 발송, 한 건 실패가 다른 건을 막지 않는다. 회수·예약 취소는 감사 로그.

### 자동 알림 (재방문·시험 일정)
- `AutoNotificationScheduler`(매시 정각) > `AutoNotificationService`: 규칙별 발송 시각이면 대상 조회(`AutoNotificationTargetQueryRepository.findTargetMemberUuids`) > 회원당 하루 상한(설정, 기본 1건) 선점(`tryClaim`) > 알림함 저장·푸시 > 발송 기록에 알림 연결(열람·복귀 통계).
- 수신 설정 3그룹(`member_notification_preference`: 학습 알림, 복귀 알림, 시험 D-day)은 이 대상 쿼리에서만 제외 조건으로 쓴다(설정 행이 없으면 수신).
- 시험 규칙은 `ExamNotificationOccasionFinder.findTodayOccasion`이 오늘이 발송일(D-30·7·1, 접수·수험표·발표 등)인지와 치환 값을 정한다. 새 연도 공개는 `markDispatched`로 한 번만.

### 알림함·정리
- `/api/members/me/notifications`: 목록, `unread-count`(회원별 30초 캐시), 읽음 1건·전체, 수신 설정 조회·변경.
- `NotificationRetentionScheduler`(매일 04:20) > 보관 기간 지난 일반 알림 정리(설정 `notification.retention_days`, 기본 90일).

### 앱 수신·탭 이동
- 알림 data 키는 서버 `PushDataKeys`와 1:1(`push_link.dart`). 탭 이동 허용 목록 6종 `PushLinkTarget`: `HOME`, `DAILY_SET`, `QUESTIONS`, `QUESTION_DETAIL`(문제 UUID 필수), `STATS`, `EXAM_SCHEDULE`. 목록 밖이면 이동하지 않는다.
- iOS 포그라운드는 시스템 배너를 끄고 앱 안 토스트로 대신한다.

## 추출된 결정
없음. 이미 구현된 내용을 지도로 옮긴 문서라 새 결정은 만들지 않았다. 관련 결정은 `related`에 연결했다.

W4 대조(구현 vs 활성 결정): DEC-0131(생성 입구 `MemberNotificationService` 하나, 웹 푸시 없음), DEC-0132(안내 시트 뒤에만 시스템 창, "나중에" 7일), DEC-0304(처음 켤 때 환영 안내 뒤 안내)와 코드가 일치했다. 충돌 없음. 결정 본문은 읽지 않고 클러스터 한 줄 요약과 대조했다. DEC-0131의 "일반 알림 90일 보관"은 `NotificationRetentionScheduler` 기본값 90일과 일치한다(운영 설정값은 확인하지 않음).

## 열린 질문
- **수신 설정 범위**: 종류별 수신 설정 3그룹은 자동 알림 대상 쿼리에만 적용된다. 신고 처리 결과·의견 상태 변경·관리자 발송은 이 설정과 무관하고, 기기 단위 수신 동의(푸시 토큰)만 본다. 의도인지 기록은 찾지 못했다.
- **비동기 전달 실패**: `NotificationDispatcher`가 실패를 로그로만 남겨, 자동 알림·회원 1명 알림은 재전송이 없다. 관리자 발송만 실패 기기를 기록한다.

## 원본 참조
- 코드 기준: main `118159a8` (2026-11-13, v1.120.0). 원문은 코드 자체이며 별도 텍스트 원본은 없다.
