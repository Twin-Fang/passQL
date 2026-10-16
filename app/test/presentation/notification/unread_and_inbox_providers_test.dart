import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/auth_session.dart';
import 'package:passql_app/core/notification/app_icon_badge_updater.dart';
import 'package:passql_app/data/models/notification/notification_models.dart';
import 'package:passql_app/data/sources/api_providers.dart';
import 'package:passql_app/presentation/providers/app_icon_badge_sync.dart';
import 'package:passql_app/presentation/providers/auth_provider.dart';
import 'package:passql_app/presentation/providers/notification_inbox_providers.dart';
import 'package:passql_app/presentation/providers/unread_notification_providers.dart';

import '../../helpers/fakes/fake_notification_api.dart';

/// 반영 요청된 앱 아이콘 숫자를 모으는 가짜 갱신기
class _RecordingIconBadgeUpdater extends AppIconBadgeUpdater {
  final updatedCounts = <int>[];

  @override
  Future<void> update(int unreadCount) async => updatedCounts.add(unreadCount);
}

class _SignedInAuth extends AuthNotifier {
  @override
  Future<AuthSession?> build() async => const AuthSession(
    accessToken: 'a',
    refreshToken: 'r',
    memberUuid: 'm-1',
    nickname: '새찬',
  );
}

/// 안 읽은 개수 단일 출처, 알림함 목록(커서·읽음), 홈 공지 배너 (#491)
void main() {
  late FakeNotificationApi api;

  ProviderContainer signedInContainer() {
    final container = ProviderContainer(
      overrides: [
        notificationApiProvider.overrideWithValue(api),
        authProvider.overrideWith(_SignedInAuth.new),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    api = FakeNotificationApi(
      generalItems: [
        for (var index = 0; index < 5; index++)
          fakeNotificationItem('g$index', isRead: index >= 2),
      ],
      noticeItems: [
        fakeNotificationItem(
          'n1',
          category: NotificationCategory.notice,
          type: NotificationType.notice,
          isImportant: true,
        ),
        fakeNotificationItem(
          'n2',
          category: NotificationCategory.notice,
          type: NotificationType.notice,
        ),
      ],
      pageSize: 2,
    );
  });

  test('로그인하면 안 읽은 개수를 조회하고 실패해도 이전 값을 유지한다', () async {
    final container = signedInContainer();
    await container.read(authProvider.future);
    container.listen(unreadNotificationCountProvider, (_, _) {});
    await Future<void>.delayed(Duration.zero);

    expect(container.read(unreadNotificationCountProvider).total, 4);

    api.shouldFail = true;
    await container.read(unreadNotificationCountProvider.notifier).refresh();
    expect(container.read(unreadNotificationCountProvider).total, 4);
  });

  test('동시에 여러 번 갱신해도 서버에는 한 번만 요청한다', () async {
    final container = signedInContainer();
    await container.read(authProvider.future);
    final notifier = container.read(unreadNotificationCountProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    final requestCountBefore = api.unreadCountRequestCount;

    await Future.wait([notifier.refresh(), notifier.refresh()]);

    expect(api.unreadCountRequestCount, requestCountBefore + 1);
  });

  test('목록은 커서로 이어 붙이고 읽음 처리하면 화면과 개수가 함께 줄어든다', () async {
    final container = signedInContainer();
    await container.read(authProvider.future);
    const general = NotificationCategory.general;
    final inboxProvider = notificationInboxProvider(general);
    container.listen(inboxProvider, (_, _) {});
    container.listen(unreadNotificationCountProvider, (_, _) {});
    await container.read(inboxProvider.future);

    expect(container.read(inboxProvider).value!.items, hasLength(2));
    await container.read(inboxProvider.notifier).loadMore();
    await container.read(inboxProvider.notifier).loadMore();
    expect(container.read(inboxProvider).value!.items, hasLength(5));
    expect(container.read(inboxProvider).value!.hasMore, isFalse);

    await container.read(inboxProvider.notifier).markRead('g0');
    final items = container.read(inboxProvider).value!.items;
    expect(items.first.isRead, isTrue);
    expect(api.readRequests, ['GENERAL:g0']);
    expect(container.read(unreadNotificationCountProvider).general, 1);

    await container.read(inboxProvider.notifier).markAllRead();
    expect(
      container.read(inboxProvider).value!.items.every((i) => i.isRead),
      isTrue,
    );
    expect(api.readAllRequests, ['GENERAL']);
    expect(container.read(unreadNotificationCountProvider).general, 0);
  });

  test('홈 배너는 안 읽은 중요 공지만 보이고 닫으면 읽음 처리된다', () async {
    final container = signedInContainer();
    await container.read(authProvider.future);
    const notice = NotificationCategory.notice;
    final inboxProvider = notificationInboxProvider(notice);
    container.listen(inboxProvider, (_, _) {});
    container.listen(homeNoticeProvider, (_, _) {});
    container.listen(unreadNotificationCountProvider, (_, _) {});
    await container.read(inboxProvider.future);

    expect(container.read(homeNoticeProvider)?.noticeUuid, 'n1');

    // 서버가 실패해도 화면에서는 바로 닫힘 (낙관적 처리)
    await container.read(inboxProvider.notifier).markRead('n1');
    expect(container.read(homeNoticeProvider), isNull);
    expect(api.readRequests, ['NOTICE:n1']);
  });

  test('개수가 바뀌면 앱 아이콘 숫자에 반영한다', () async {
    final iconBadgeUpdater = _RecordingIconBadgeUpdater();
    AppIconBadgeUpdater.current = iconBadgeUpdater;
    addTearDown(
      () => AppIconBadgeUpdater.current = const NoopAppIconBadgeUpdater(),
    );
    final container = signedInContainer();
    await container.read(authProvider.future);
    startAppIconBadgeSync(container);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(iconBadgeUpdater.updatedCounts, [4]);
  });
}
