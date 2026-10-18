import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/auth_session.dart';
import 'package:passql_app/core/push/push_permission_prompt_store.dart';
import 'package:passql_app/data/push/push_notification_service.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/providers/auth_provider.dart';
import 'package:passql_app/presentation/widgets/notification/notification_permission_prompter.dart';
import 'package:passql_app/presentation/widgets/notification/notification_permission_sheet.dart';
import 'package:passql_app/presentation/widgets/notification/study_result_seen_recorder.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

// 안내 대기(첫 표시 2초·복귀 0.8초)를 넉넉히 넘기는 시간
const _afterPromptDelay = Duration(seconds: 3);

/// 알림 권한 사전 안내 시점: 가입 직후 첫 진입에는 묻지 않고, 결과를 보고 돌아오면 1회
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PushPermissionPromptStore.resetProcessCacheForTest();
  });

  Future<void> pumpShell(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(_SignedInAuth.new),
          pushNotificationServiceProvider.overrideWithValue(
            PushNotificationService(
              messagingClient: FakePushMessagingClient(),
              pushTokenApi: FakePushTokenApi(),
            ),
          ),
        ],
        child: MaterialApp(
          theme: PassqlTheme.light,
          home: NotificationPermissionPrompter(
            child: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  // 풀이를 마친 결과 화면 진입 흉내
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const StudyResultSeenRecorder(
                        child: Scaffold(body: Text('결과')),
                      ),
                    ),
                  ),
                  child: const Text('풀기'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('가입 직후 첫 진입에는 안내하지 않는다', (tester) async {
    await pumpShell(tester);
    await tester.pump(_afterPromptDelay);
    await tester.pumpAndSettle();
    expect(find.byType(NotificationPermissionSheetBody), findsNothing);
  });

  testWidgets('결과 화면을 보고 탭 화면으로 돌아오면 한 번 안내한다', (tester) async {
    await pumpShell(tester);
    await tester.pump(_afterPromptDelay);
    await tester.pumpAndSettle();

    await tester.tap(find.text('풀기'));
    await tester.pumpAndSettle();
    expect(find.text('결과'), findsOneWidget);
    // 결과 화면에서는 안내하지 않음
    await tester.pump(_afterPromptDelay);
    expect(find.byType(NotificationPermissionSheetBody), findsNothing);

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    await tester.pump(_afterPromptDelay);
    await tester.pumpAndSettle();
    expect(find.byType(NotificationPermissionSheetBody), findsOneWidget);
  });

  testWidgets('두 번째 실행이면 첫 화면에서 안내한다', (tester) async {
    // 이전 실행에서 탭 화면을 이미 본 기기
    await const PushPermissionPromptStore().isMeaningfulMoment();
    PushPermissionPromptStore.resetProcessCacheForTest();

    await pumpShell(tester);
    await tester.pump(_afterPromptDelay);
    await tester.pumpAndSettle();
    expect(find.byType(NotificationPermissionSheetBody), findsOneWidget);
  });
}
