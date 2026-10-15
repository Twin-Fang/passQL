import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/meta/app_config.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/pages/app_gate/force_update_page.dart';
import 'package:passql_app/presentation/pages/app_gate/maintenance_page.dart';
import 'package:passql_app/presentation/providers/app_config_providers.dart';
import 'package:passql_app/presentation/widgets/home/app_notice_banner.dart';

import '../../helpers/pump_app.dart';

/// 차단 화면·공지 배너 스모크: 라이트·다크에서 예외 없이 그리고 핵심 문구 노출 (#464)
void main() {
  const config = AppConfig(
    ios: AppPlatformVersionPolicy(
      minimumVersion: '2.0.0',
      storeUrl: 'https://apps.apple.com/app/id1',
    ),
    android: AppPlatformVersionPolicy(
      minimumVersion: '2.0.0',
      storeUrl: 'https://play.google.com/store',
    ),
    maintenance: AppMaintenanceStatus(
      isUnderMaintenance: true,
      message: '서버 이전 작업 중이에요',
    ),
  );

  Future<void> pumpGatePage(
    WidgetTester tester,
    Widget page,
    ThemeData theme,
  ) => pumpApp(
    tester,
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWith((_) async => config),
        currentAppVersionProvider.overrideWith((_) async => '1.0.0'),
      ],
      child: MaterialApp(theme: theme, home: page),
    ),
  );

  for (final (themeName, theme) in [
    ('라이트', PassqlTheme.light),
    ('다크', PassqlTheme.dark),
  ]) {
    testWidgets('강제 업데이트 화면 ($themeName)', (tester) async {
      await pumpGatePage(tester, const ForceUpdatePage(), theme);
      await tester.pumpAndSettle();
      expect(find.text('업데이트가 필요해요'), findsOneWidget);
      expect(find.text('업데이트하기'), findsOneWidget);
      expect(find.textContaining('필요 버전 2.0.0'), findsOneWidget);
    });

    testWidgets('점검 화면은 관리자 문구 표시 ($themeName)', (tester) async {
      await pumpGatePage(tester, const MaintenancePage(), theme);
      await tester.pumpAndSettle();
      expect(find.text('서비스 점검 중이에요'), findsOneWidget);
      expect(find.text('서버 이전 작업 중이에요'), findsOneWidget);
      expect(find.text('다시 확인'), findsOneWidget);
    });

    testWidgets('공지 배너: 탭하면 본문 시트, 닫기 콜백 ($themeName)', (tester) async {
      var isDismissed = false;
      await pumpApp(
        tester,
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: AppNoticeBanner(
              notice: const AppNotice(
                noticeUuid: 'n1',
                title: '추석 연휴 안내',
                body: '연휴 동안 답변이 늦어요.',
                isImportant: true,
              ),
              onDismiss: () => isDismissed = true,
            ),
          ),
        ),
      );
      expect(find.text('중요'), findsOneWidget);
      await tester.tap(find.text('추석 연휴 안내'));
      await tester.pumpAndSettle();
      expect(find.text('연휴 동안 답변이 늦어요.'), findsOneWidget);
      Navigator.of(tester.element(find.text('연휴 동안 답변이 늦어요.'))).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('공지 닫기'));
      expect(isDismissed, isTrue);
    });
  }
}
