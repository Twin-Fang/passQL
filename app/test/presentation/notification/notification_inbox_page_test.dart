import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:passql_app/core/auth/auth_session.dart';
import 'package:passql_app/core/push/push_messaging_client.dart';
import 'package:passql_app/core/push/push_permission_prompt_store.dart';
import 'package:passql_app/core/utils/word_wrap.dart';
import 'package:passql_app/data/models/notification/notification_models.dart';
import 'package:passql_app/data/push/push_notification_service.dart';
import 'package:passql_app/data/sources/api_providers.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/pages/notification/notification_inbox_page.dart';
import 'package:passql_app/presentation/providers/auth_provider.dart';
import 'package:passql_app/presentation/widgets/notification/notification_permission_flow.dart';
import 'package:passql_app/presentation/widgets/notification/notification_permission_sheet.dart';
import 'package:passql_app/presentation/widgets/notification/notification_permission_texts.dart';
import 'package:passql_app/router/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fakes/fake_notification_api.dart';
import '../../helpers/fakes/fake_push.dart';

class _SignedInAuth extends AuthNotifier {
  @override
  Future<AuthSession?> build() async => const AuthSession(
    accessToken: 'a',
    refreshToken: 'r',
    memberUuid: 'm-1',
    nickname: '새찬',
  );
}

/// 알림함 화면 스모크(라이트·다크), 종 아이콘 배지, 권한 안내 시트 (#491)
void main() {
  late FakeNotificationApi api;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    api = FakeNotificationApi(
      generalItems: [
        fakeNotificationItem('g1'),
        fakeNotificationItem('g2', isRead: true),
      ],
      noticeItems: [
        fakeNotificationItem(
          'n1',
          category: NotificationCategory.notice,
          type: NotificationType.notice,
          isImportant: true,
        ),
      ],
    );
  });

  Future<void> pumpInbox(WidgetTester tester, ThemeData theme) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationApiProvider.overrideWithValue(api),
          authProvider.overrideWith(_SignedInAuth.new),
        ],
        child: MaterialApp.router(
          theme: theme,
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => const NotificationInboxPage(),
              ),
              // 공지 항목 이동 확인용 상세 자리
              GoRoute(
                path: AppRoutes.noticeDetailPattern,
                builder: (_, state) => Text(
                  '공지 상세 ${state.pathParameters[AppRoutes.noticeUuidParameter]}',
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final (name, theme) in [
    ('라이트', PassqlTheme.light),
    ('다크', PassqlTheme.dark),
  ]) {
    testWidgets('$name: 알림 탭 목록과 탭별 안 읽은 개수를 보여 준다', (tester) async {
      await pumpInbox(tester, theme);

      expect(find.text('제목 g1'), findsOneWidget);
      expect(find.text('제목 g2'), findsOneWidget);
      // 알림 탭 안 읽음 1개, 공지 탭 안 읽음 1개
      expect(find.text('1'), findsNWidgets(2));
    });
  }

  testWidgets('항목을 누르면 읽음 처리되고, 공지는 공지 상세로 이동한다', (tester) async {
    await pumpInbox(tester, PassqlTheme.light);

    await tester.tap(find.text('제목 g1'));
    await tester.pumpAndSettle();
    expect(api.readRequests, ['GENERAL:g1']);

    await tester.tap(find.text('공지'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('제목 n1'));
    await tester.pumpAndSettle();
    expect(api.readRequests, ['GENERAL:g1', 'NOTICE:n1']);
    expect(find.text('공지 상세 n1'), findsOneWidget);
  });

  testWidgets('모두 읽음을 누르면 탭 전체가 읽음 처리된다', (tester) async {
    await pumpInbox(tester, PassqlTheme.light);

    await tester.tap(find.text('알림 모두 읽음'));
    await tester.pumpAndSettle();

    expect(api.readAllRequests, ['GENERAL']);
  });

  testWidgets('목록 조회에 실패하면 다시 시도 버튼을 보여 준다', (tester) async {
    api.shouldFail = true;
    await pumpInbox(tester, PassqlTheme.light);

    expect(find.text('다시 시도'), findsOneWidget);
  });

  testWidgets('종 아이콘은 개수를 배지로 보이고 10 이상은 9+, 접근성 문구를 읽어 준다', (tester) async {
    Future<void> pumpBell(int unreadCount) => tester.pumpWidget(
      MaterialApp(
        theme: PassqlTheme.light,
        home: Scaffold(
          body: PassqlNotificationBellButton(
            unreadCount: unreadCount,
            onPressed: () {},
          ),
        ),
      ),
    );

    await pumpBell(3);
    expect(find.text('3'), findsOneWidget);
    expect(find.bySemanticsLabel('안읽은 알림 3개'), findsOneWidget);

    await pumpBell(12);
    expect(find.text('9+'), findsOneWidget);

    await pumpBell(0);
    expect(find.text('0'), findsNothing);
  });

  group('권한 안내 시트', () {
    late FakePushMessagingClient messagingClient;

    Future<void> pumpPromptLauncher(
      WidgetTester tester,
      void Function(Future<void> Function()) onReady,
    ) async {
      messagingClient = FakePushMessagingClient();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(_SignedInAuth.new),
            pushNotificationServiceProvider.overrideWithValue(
              PushNotificationService(
                messagingClient: messagingClient,
                pushTokenApi: FakePushTokenApi(),
              ),
            ),
          ],
          child: MaterialApp(
            theme: PassqlTheme.light,
            home: Consumer(
              builder: (context, ref, _) {
                onReady(() => runNotificationPermissionPrompt(context, ref));
                return const Scaffold();
              },
            ),
          ),
        ),
      );
    }

    testWidgets('"나중에"는 시스템 권한을 묻지 않는다', (tester) async {
      late Future<void> Function() prompt;
      await pumpPromptLauncher(tester, (launcher) => prompt = launcher);

      prompt();
      await tester.pumpAndSettle();
      // 시트 문장은 단어 단위 줄바꿈 문자열로 그려짐
      expect(
        find.text(keepWordsTogether(NotificationPermissionTexts.sheetTitle)),
        findsOneWidget,
      );
      expect(
        find.text(
          keepWordsTogether(NotificationPermissionTexts.optionalNotice),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('나중에'));
      await tester.pumpAndSettle();

      expect(messagingClient.permissionRequestCount, 0);
    });

    testWidgets('"알림 받기"를 눌러야 시스템 권한을 요청한다', (tester) async {
      late Future<void> Function() prompt;
      await pumpPromptLauncher(tester, (launcher) => prompt = launcher);

      prompt();
      await tester.pumpAndSettle();
      expect(messagingClient.permissionRequestCount, 0);
      await tester.tap(find.text('알림 받기'));
      await tester.pumpAndSettle();

      expect(messagingClient.permissionRequestCount, 1);
      expect(messagingClient.currentPermission, PushPermissionStatus.granted);
    });
    testWidgets('닫기 X 없이 바깥을 눌러 닫으면 "나중에"와 같이 7일 미룬다', (tester) async {
      late Future<void> Function() prompt;
      await pumpPromptLauncher(tester, (launcher) => prompt = launcher);

      prompt();
      await tester.pumpAndSettle();
      expect(find.byIcon(CupertinoIcons.xmark_circle_fill), findsNothing);
      expect(find.bySemanticsLabel('닫기'), findsNothing);
      // 시트 위쪽 바깥(어두운 배경) 탭
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationPermissionSheetBody), findsNothing);
      expect(messagingClient.permissionRequestCount, 0);
      expect(await const PushPermissionPromptStore().canPromptNow(), isFalse);
    });

    testWidgets('받는 소식 아이콘은 같은 크기·같은 색 타일이고 글자 시작선이 같다', (tester) async {
      late Future<void> Function() prompt;
      await pumpPromptLauncher(tester, (launcher) => prompt = launcher);

      prompt();
      await tester.pumpAndSettle();
      final tiles = find.byType(PassqlIconTile);
      expect(tiles, findsNWidgets(3));
      final tileSizes = {
        for (final element in tiles.evaluate())
          tester.getSize(find.byWidget(element.widget)),
      };
      expect(tileSizes, hasLength(1));
      final tileColors = {
        for (final tile in tester.widgetList<PassqlIconTile>(tiles)) tile.color,
      };
      expect(tileColors, {PassqlColors.light.accent});
      final textStarts = {
        for (final line in NotificationPermissionTexts.receivedNewsLines)
          tester.getTopLeft(find.text(keepWordsTogether(line))).dx,
      };
      expect(textStarts, hasLength(1));
    });

    testWidgets('작은 화면·큰 글자에서도 넘치지 않고 버튼이 보인다', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      late Future<void> Function() prompt;
      messagingClient = FakePushMessagingClient();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(_SignedInAuth.new),
            pushNotificationServiceProvider.overrideWithValue(
              PushNotificationService(
                messagingClient: messagingClient,
                pushTokenApi: FakePushTokenApi(),
              ),
            ),
          ],
          child: MaterialApp(
            theme: PassqlTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(
                  PassqlTextScaleLimit.maximumTextScaleFactor,
                ),
              ),
              child: child!,
            ),
            home: Consumer(
              builder: (context, ref, _) {
                prompt = () => runNotificationPermissionPrompt(context, ref);
                return const Scaffold();
              },
            ),
          ),
        ),
      );
      prompt();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('알림 받기'), findsOneWidget);
      expect(tester.getBottomLeft(find.text('나중에')).dy, lessThanOrEqualTo(568));
    });
  });
}
