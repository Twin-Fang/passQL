import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:passql_app/presentation/widgets/app_shell.dart';

void main() {
  testWidgets('하단 탭은 글자 없이 아이콘만 보이고 접근성 라벨은 유지한다', (tester) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        ShellRoute(
          builder: (_, _, child) => AppShell(child: child),
          routes: [
            for (final p in ['/home', '/questions', '/stats', '/settings'])
              GoRoute(path: p, builder: (_, _) => const SizedBox()),
          ],
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    // 라벨 표시는 끄고(화면에 글자 없음), 탭 4개는 접근성 라벨로 남긴다
    final bar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(bar.showSelectedLabels, isFalse);
    expect(bar.showUnselectedLabels, isFalse);
    expect(bar.items.map((e) => e.label), ['홈', '문제', '통계', '설정']);
  });
}
