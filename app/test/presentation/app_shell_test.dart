import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/widgets/app_shell.dart';

void main() {
  testWidgets('하단 탭은 글자 없이 아이콘만 보이고 접근성 라벨은 유지한다', (tester) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute(
          builder: (_, _, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          navigatorContainerBuilder: (_, navigationShell, children) =>
              AppTabFadeStack(
                currentIndex: navigationShell.currentIndex,
                children: children,
              ),
          branches: [
            for (final p in ['/home', '/questions', '/community', '/stats', '/settings'])
              StatefulShellBranch(
                routes: [GoRoute(path: p, builder: (_, _) => Text(p))],
              ),
          ],
        ),
      ],
    );
    // 탭 쉘의 광고 자리가 provider 를 읽음 (호스트 테스트는 광고 꺼짐)
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: PassqlTheme.light,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PassqlTabBar), findsOneWidget);
    for (final label in ['홈', '문제', '토론', '통계', '설정']) {
      expect(find.text(label), findsNothing);
      expect(find.bySemanticsLabel(label), findsOneWidget);
    }
    // 5개 탭이 같은 폭으로 나뉨 (토론 탭 #543)
    expect(find.byType(PassqlPressable), findsNWidgets(5));
    await tester.tap(find.byIcon(CupertinoIcons.chat_bubble_2));
    await tester.pumpAndSettle();
    expect(find.text('/community'), findsOneWidget);
    await tester.tap(find.byIcon(CupertinoIcons.chart_bar));
    await tester.pumpAndSettle();
    expect(find.text('/stats'), findsOneWidget);
    // 다른 탭으로 가도 이전 탭 화면은 살아 있다(상태 유지)
    expect(find.text('/home', skipOffstage: false), findsOneWidget);
  });
}
