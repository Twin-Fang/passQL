# 알림함 설계 (#491)

알림함: 지난 알림 보관, 새 알림 표시(앱·웹 종 아이콘, iOS 앱 아이콘 숫자), 알림·공지 두 탭, 관리자 관리
대상: 서버(Spring) · 관리자(Thymeleaf) · 앱(Flutter, iOS/Android) · 웹(React)

## 1. 확정 사항

| 항목 | 결정 |
|---|---|
| 탭 | `알림`(GENERAL) / `공지`(NOTICE) |
| 일반 알림 보관 | 90일 (app_setting 으로 관리자 변경 가능) |
| 종 아이콘 | 앱 홈 상단 오른쪽, 웹 상단 헤더 |
| 자동 알림 | 이번에 `REPORT_RESOLVED`(신고 처리 결과) 포함. `DAILY_SET_REMINDER` 는 종류만 정의 |
| 웹 브라우저 푸시 | 하지 않음 (알림함·종 아이콘만) |
| 실시간 | 하지 않음 (앱 복귀·푸시 수신·화면 진입 시 재조회) |

## 2. 데이터

### 2.1 `member_notification` (일반 알림, 회원별 1행)
| 컬럼 | 설명 |
|---|---|
| member_notification_uuid | PK |
| member_uuid | 받는 회원 |
| notification_type | `ADMIN_MESSAGE`, `REPORT_RESOLVED`, `DAILY_SET_REMINDER` |
| title, body | 제목(100), 본문(500) |
| link_target | 이동 화면 (#467 허용 목록과 같은 값), link_question_uuid |
| push_send_history_uuid | 관리자 발송에서 생긴 경우 원본 발송 (nullable) |
| read_at | 읽은 시각 (null = 안 읽음) |
| is_hidden | 관리자가 회수하면 true (목록·개수에서 제외) |
| created_at | 생성 시각 |

인덱스
- `(member_uuid, created_at desc)` 목록
- `(member_uuid) where read_at is null and is_hidden = false` 안 읽은 개수 (부분 인덱스)
- `(push_send_history_uuid)` 회수·읽음률 집계
- `(created_at)` 보관 기간 정리

### 2.2 `member_notice_read` (공지 읽음)
- PK `(member_uuid, app_notice_uuid)`, read_at
- 공지는 회원별로 복사하지 않음 (나중에 가입한 회원도 노출 중 공지를 봄)
- 앱 SharedPreferences·웹 localStorage 의 "닫은 공지" 저장은 제거하고 이 테이블로 통일

### 2.3 `push_send_history` 확장
- `delivery_mode`: `PUSH_AND_INBOX`(기본) / `INBOX_ONLY`
- `recipient_count`: 알림함에 만든 행 수
- `is_retracted`, `retracted_at`, `retracted_by`: 관리자 회수

### 2.4 마이그레이션
- `V0_10_40` ~ `V0_10_49` 대역만 사용. 기존 파일 수정 금지

## 3. 서버

### 3.1 공통 지점
| 클래스 | 책임 |
|---|---|
| `MemberNotificationService` | 알림 생성의 유일한 입구: `notifyMember(memberUuid, type, title, body, link)`, `notifyAllMembers(...)` > 저장 > 커밋 후 푸시 전달 요청 |
| `MemberNotificationQueryService` | 목록(커서), 안 읽은 개수, 읽음, 모두 읽음 |
| `PushNotificationService` (기존) | 전달만. 회원별 안 읽은 개수를 APNs `badge` 로 넣어 전송 |
| `NotificationRetentionScheduler` | 매일 새벽 보관 기간 지난 알림을 묶음 삭제 |

### 3.2 IO·성능
- 전체 발송 팬아웃: 활성 회원 UUID 를 1,000명씩 끊어 JDBC batch insert (`INSERT ... SELECT` 한 번이 가능하면 그쪽 우선). 요청 스레드에서 하지 않고 커밋 후 비동기 실행기에서 처리
- 푸시 전달: FCM `sendEach` 500건 단위. 회원별 badge 값이 달라 회원 단위 메시지. 안 읽은 개수는 발송 대상 회원을 한 번의 GROUP BY 쿼리로 계산(회원마다 쿼리 금지)
- 안 읽은 개수: 부분 인덱스 COUNT + 공지 수(노출 중 공지는 수 건)에서 읽은 공지 제외. 회원별 Caffeine 캐시 30초, 알림 생성·읽음 시 해당 회원 캐시 삭제 (전체 발송은 전체 캐시 삭제)
- 목록: 커서 페이지네이션 (`createdAt`, `uuid` 기준, 20건). OFFSET 금지
- 정리: 보관 기간 지난 행을 5,000건씩 반복 삭제
- 앱은 개수 API 를 화면마다 부르지 않음 (아래 4.3 갱신 시점만)

### 3.3 API (회원, 인증 필요)
| 메서드 | 경로 | 응답 |
|---|---|---|
| GET | `/api/members/me/notifications?category=GENERAL\|NOTICE&cursor=&size=20` | `{items:[{id, category, type, title, body, linkTarget, linkQuestionUuid, isRead, createdAt, isImportant?}], nextCursor}` |
| GET | `/api/members/me/notifications/unread-count` | `{general, notice, total}` |
| POST | `/api/members/me/notifications/{id}/read?category=` | 204 |
| POST | `/api/members/me/notifications/read-all?category=` | 204 |

- `category=NOTICE` 의 id 는 `app_notice_uuid`
- 제재 회원 필터·점검 모드 필터·요청 제한은 기존 규칙 그대로 적용

### 3.4 자동 알림
- 신고 처리(처리 완료·기각) 시 신고한 회원에게 `REPORT_RESOLVED` (app_setting `notification.report_resolved.enabled`, 기본 켜짐)
- `DAILY_SET_REMINDER` 는 enum·설정 키만 (`notification.daily_set_reminder.enabled` 기본 꺼짐), 발송은 후속

## 4. 앱 (Flutter)

### 4.1 화면·컴포넌트
| 이름 | 역할 |
|---|---|
| `PassqlNotificationBellButton` | 종 아이콘. 안 읽은 개수 > 0 이면 주황(`warning` 토큰) 점과 숫자, 10 이상 `9+`. 홈 `PassqlLargeTitleScrollView.trailing` 에 배치 |
| `NotificationInboxPage` | `알림 \| 공지` 세그먼트 탭, 탭별 안 읽은 개수, 항목 앞 주황 점, 모두 읽음, 당겨서 새로고침, 무한 스크롤(커서), 빈 상태 |
| `unreadNotificationCountProvider` | 안 읽은 개수 단일 출처 |
| `AppIconBadgeUpdater` | 개수 변경 시 앱 아이콘 숫자 반영 (iOS, 지원 런처의 Android), 0 이면 제거, 로그아웃 시 제거 |

- 항목 탭: 그 항목 읽음 > 공지는 본문 시트, 알림은 허용 목록 화면으로 이동
- 홈 공지 배너: 안 읽은 중요 공지만, 닫기 = 서버 읽음

### 4.2 알림 권한 (App Store 심사 기준)
- 앱 첫 실행·로그인 직후 시스템 권한 창을 바로 띄우지 않음
- 먼저 앱 자체 안내 시트(무엇을 받는지: 공지, 신고 결과, 학습 알림 / "나중에" 버튼)를 보여 주고, 사용자가 "알림 받기"를 누를 때만 시스템 권한 요청
- 안내 시점: 홈 첫 진입 후 한 번, 또는 설정·알림함에서 알림 켜기를 누를 때. "나중에"를 고르면 7일 동안 다시 묻지 않음
- 거부해도 모든 기능 사용 가능 (알림함은 권한과 무관하게 동작)
- 거부 상태에서 켜기를 누르면 기기 설정으로 이동 안내
- Android 13+ `POST_NOTIFICATIONS` 도 같은 흐름
- 안내 문구에 광고·마케팅 표현 넣지 않음 (마케팅 푸시를 보낼 경우 별도 동의가 필요하므로 이번 범위는 서비스 알림만)

### 4.3 갱신 시점
- 앱 시작, 앱 복귀(`AppLifecycleRefresher`), 푸시 수신(포그라운드), 알림함 진입·읽음 처리 후, 로그인 직후

## 5. 웹 (React)
- 상단 헤더에 종 아이콘(안 읽은 개수 배지), 클릭 시 알림함 페이지(`/notifications`, 알림·공지 탭)
- 브라우저 탭 제목에 안 읽은 개수 `(3) passQL`
- 공지 배너 닫기 = 서버 읽음 (localStorage 제거)
- 갱신 시점: 페이지 진입, 창 포커스 복귀, 읽음 처리 후

## 6. 관리자
| 화면 | 기능 |
|---|---|
| 푸시 발송(기존 `/admin/push`) | 전달 방식 `푸시 + 알림함` / `알림함만`, 발송 이력에 받은 회원 수·읽은 수·읽음률, 발송 회수(알림함에서 숨김) |
| 알림 설정 | 보관 기간(일), 자동 알림 켜기/끄기(신고 처리 결과, 오늘의 세트 리마인드 예약) |
| 회원 상세 | 그 회원의 알림 목록(읽음 여부), 푸시 토큰 수·수신 동의 |
| 공지(기존 `/admin/app-operation`) | 공지별 읽은 회원 수 |
| 감사 로그 | 발송·회수·설정 변경을 기존 `AdminAuditEvent` 로 기록 |

## 7. 이름 표
| 이름 | 뜻 |
|---|---|
| `MemberNotification` | 회원 한 명이 받은 일반 알림 한 건 |
| `MemberNoticeRead` | 회원이 읽은 공지 |
| `NotificationCategory.GENERAL/NOTICE` | 알림함 두 탭 |
| `MemberNotificationType` | 알림이 생긴 이유 |
| `NotificationDeliveryMode.PUSH_AND_INBOX/INBOX_ONLY` | 발송 시 푸시 여부 |
| `isRead`, `isHidden`, `isRetracted`, `hasUnreadNotification` | 상태 boolean |

## 8. 규칙 테스트
- 서버 ArchUnit: `MemberNotificationRepository` 는 알림 서비스 2개만 사용
- 앱: 앱 아이콘 숫자 패키지는 `core/notification` 안에서만 import, 화면에서 종 아이콘은 `PassqlNotificationBellButton` 만
- 웹: 안 읽은 개수는 hook 하나(`useUnreadNotificationCount`)에서만 조회

## 9. 하지 않는 것
- 웹 브라우저 푸시, 실시간(웹소켓·SSE)
- 푸시 열람률 집계 (Analytics 로 대체)
- 오늘의 세트 리마인드 실제 발송 (후속 이슈)
- 마케팅 푸시
