import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/monitoring/analytics_event_names.dart';
import 'package:passql_app/core/monitoring/app_analytics.dart';
import 'package:passql_app/core/notification/notification_permission_prompt_result.dart';
import 'package:passql_app/core/push/push_permission_prompt_store.dart';
import 'package:passql_app/core/utils/relative_time.dart';
import 'package:passql_app/data/models/notification/notification_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fakes/fake_analytics_backend.dart';

/// 알림함 계약 파싱, 경과 시간 표기, 권한 안내 7일 규칙, 분석 이벤트 (#491)
void main() {
  test('서버 응답을 항목·커서·개수로 읽고 모르는 종류는 unknown 으로 둔다', () {
    final page = NotificationPage.fromJson({
      'items': [
        {
          'id': 'n1',
          'category': 'GENERAL',
          'type': 'REPORT_RESOLVED',
          'title': '처리됐어요',
          'body': '본문',
          'linkTarget': 'QUESTION_DETAIL',
          'linkQuestionUuid': 'q-1',
          'isRead': false,
          'createdAt': '2026-10-16T09:00:00',
          'isImportant': false,
        },
        {
          'id': 'n2',
          'category': 'NOTICE',
          'type': 'NEW_KIND',
          'title': '공지',
          'body': '',
          'isRead': true,
          'createdAt': '2026-10-15T09:00:00',
          'isImportant': true,
        },
      ],
      'nextCursor': 'abc',
    });

    expect(page.nextCursor, 'abc');
    expect(page.items.first.type, NotificationType.reportResolved);
    expect(page.items.first.linkQuestionUuid, 'q-1');
    expect(page.items.last.category, NotificationCategory.notice);
    expect(page.items.last.type, NotificationType.unknown);
    expect(page.items.last.isImportant, isTrue);

    final count = UnreadNotificationCount.fromJson({
      'general': 2,
      'notice': 1,
      'total': 3,
    });
    expect(count.of(NotificationCategory.general), 2);
    expect(count.of(NotificationCategory.notice), 1);
    expect(count.total, 3);
  });

  test('알림 시각은 방금, 분, 시간, 어제, 일, 날짜 순으로 표기한다', () {
    final now = DateTime(2026, 10, 16, 12);
    String format(Duration ago) =>
        formatNotificationElapsed(now.subtract(ago), now: now);

    expect(format(const Duration(seconds: 20)), '방금');
    expect(format(const Duration(minutes: 5)), '5분 전');
    expect(format(const Duration(hours: 3)), '3시간 전');
    expect(format(const Duration(hours: 30)), '어제');
    expect(format(const Duration(days: 3)), '3일 전');
    expect(format(const Duration(days: 20)), '9월 26일');
  });

  test('"나중에"를 고르면 7일 동안 안내하지 않고 7일 뒤에 다시 안내한다', () async {
    SharedPreferences.setMockInitialValues({});
    const store = PushPermissionPromptStore();
    final deferredAt = DateTime(2026, 10, 16);

    expect(await store.canPromptNow(now: deferredAt), isTrue);
    await store.deferPrompt(now: deferredAt);
    expect(
      await store.canPromptNow(now: deferredAt.add(const Duration(days: 6))),
      isFalse,
    );
    expect(
      await store.canPromptNow(now: deferredAt.add(const Duration(days: 7))),
      isTrue,
    );
  });

  test('알림함 분석 이벤트는 이름 상수와 허용된 값만 보낸다', () async {
    final backend = FakeAnalyticsBackend();
    final analytics = AppAnalytics(backend);

    await analytics.logNotificationInboxOpened('notice');
    await analytics.logNotificationItemOpened('REPORT_RESOLVED');
    await analytics.logNotificationPermissionPrompt(
      NotificationPermissionPromptResult.later,
    );

    expect(backend.loggedEvents.map((event) => event.$1).toList(), [
      AnalyticsEventNames.notificationInboxOpened,
      AnalyticsEventNames.notificationItemOpened,
      AnalyticsEventNames.notificationPermissionPrompt,
    ]);
    expect(backend.loggedEvents.map((event) => event.$2).toList(), [
      {AnalyticsParameterNames.inboxTab: 'notice'},
      {AnalyticsParameterNames.notificationType: 'REPORT_RESOLVED'},
      {AnalyticsParameterNames.promptResult: 'later'},
    ]);
  });
}
