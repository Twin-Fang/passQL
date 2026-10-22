import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/widgets/app_shell.dart';

void main() {
  testWidgets('하단 탭은 아이콘 아래 라벨 5개를 보이고 선택 상태·접근성 라벨은 한 번만 읽는다', (tester) async {
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
            for (final p in [
              '/home',
              '/questions',
              '/community',
              '/stats',
              '/settings',
            ])
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
    for (final label in ['홈', '문제', '토론', '기록', 'MY']) {
      // 보이는 라벨 1개 + 시맨틱 라벨 1개 (이중 낭독 없음)
      expect(find.text(label), findsOneWidget);
      expect(find.bySemanticsLabel(label), findsOneWidget);
    }
    expect(find.text('통계'), findsNothing);
    expect(find.text('설정'), findsNothing);
    // 선택된 탭(홈)만 selected 시맨틱
    expect(
      tester.getSemantics(find.bySemanticsLabel('홈')),
      matchesSemantics(
        label: '홈',
        isSelected: true,
        hasSelectedState: true,
        isButton: true,
        hasTapAction: true,
        hasEnabledState: true,
        isEnabled: true,
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('문제')),
      matchesSemantics(
        label: '문제',
        isSelected: false,
        hasSelectedState: true,
        isButton: true,
        hasTapAction: true,
        hasEnabledState: true,
        isEnabled: true,
      ),
    );
    // 탭 바 높이는 라벨 포함 규격(49) + 하단 여백
    expect(
      tester.getSize(find.byType(PassqlTabBar)).height,
      greaterThanOrEqualTo(PassqlSize.tabBar),
    );
    // 5개 탭이 같은 폭으로 나뉨 (토론 탭 #543)
    expect(find.byType(PassqlPressable), findsNWidgets(5));
    await tester.tap(find.text('토론'));
    await tester.pumpAndSettle();
    expect(find.text('/community'), findsOneWidget);
    await tester.tap(find.text('기록'));
    await tester.pumpAndSettle();
    expect(find.text('/stats'), findsOneWidget);
    // 다른 탭으로 가도 이전 탭 화면은 살아 있다(상태 유지)
    expect(find.text('/home', skipOffstage: false), findsOneWidget);
  });

  testWidgets('글자 1.4배에서도 탭 라벨이 잘리지 않고 한 줄에 들어간다', (tester) async {
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
            for (final p in [
              '/home',
              '/questions',
              '/community',
              '/stats',
              '/settings',
            ])
              StatefulShellBranch(
                routes: [GoRoute(path: p, builder: (_, _) => Text(p))],
              ),
          ],
        ),
      ],
    );
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: PassqlTheme.light,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.4)),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final tabBarRect = tester.getRect(find.byType(PassqlTabBar));
    for (final label in ['홈', '문제', '토론', '기록', 'MY']) {
      final labelRect = tester.getRect(find.text(label));
      expect(
        tabBarRect.contains(labelRect.topLeft) &&
            tabBarRect.contains(labelRect.bottomRight),
        isTrue,
        reason: label,
      );
    }
  });
}
