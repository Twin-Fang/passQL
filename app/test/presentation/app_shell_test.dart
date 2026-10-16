import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
            for (final p in ['/home', '/questions', '/stats', '/settings'])
              StatefulShellBranch(
                routes: [GoRoute(path: p, builder: (_, _) => Text(p))],
              ),
          ],
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(theme: PassqlTheme.light, routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PassqlTabBar), findsOneWidget);
    for (final label in ['홈', '문제', '통계', '설정']) {
      expect(find.text(label), findsNothing);
      expect(find.bySemanticsLabel(label), findsOneWidget);
    }
    await tester.tap(find.byIcon(CupertinoIcons.chart_bar));
    await tester.pumpAndSettle();
    expect(find.text('/stats'), findsOneWidget);
    // 다른 탭으로 가도 이전 탭 화면은 살아 있다(상태 유지)
    expect(find.text('/home', skipOffstage: false), findsOneWidget);
  });
}
