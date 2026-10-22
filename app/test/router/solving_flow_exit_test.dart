import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:passql_app/router/app_routes.dart';
import 'package:passql_app/router/solving_flow_exit.dart';

// 실제 라우터와 같은 모양: 탭 루트(홈·문제) + 루트 풀스크린 흐름 라우트
GoRouter _buildRouter(String initialLocation) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(path: AppRoutes.home, builder: (_, _) => const Text('홈 탭')),
    GoRoute(path: AppRoutes.questions, builder: (_, _) => const Text('문제 탭')),
    GoRoute(
      path: AppRoutes.questionChapter,
      builder: (_, _) => const Text('챕터'),
    ),
    GoRoute(
      path: AppRoutes.chapterResult,
      builder: (context, _) => _ExitButton(label: '챕터 결과'),
    ),
    GoRoute(path: AppRoutes.dailySet, builder: (_, _) => const Text('세트')),
    GoRoute(
      path: AppRoutes.dailySetResult,
      builder: (_, _) => _ExitButton(label: '세트 결과'),
    ),
    GoRoute(
      path: AppRoutes.questionDetailPattern,
      builder: (_, _) => const Text('문제 상세'),
      routes: [
        GoRoute(
          path: AppRoutes.resultSubPath,
          builder: (_, _) => _ExitButton(label: '문제 결과'),
        ),
      ],
    ),
  ],
);

class _ExitButton extends StatelessWidget {
  const _ExitButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(label),
      TextButton(
        onPressed: () => leaveSolvingFlow(context),
        child: const Text('나가기'),
      ),
    ],
  );
}

Future<GoRouter> _pumpRouter(
  WidgetTester tester,
  String initialLocation,
) async {
  final router = _buildRouter(initialLocation);
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
  return router;
}

Future<void> _tapExit(WidgetTester tester) async {
  await tester.tap(find.text('나가기'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('문제 탭에서 챕터를 풀고 결과를 닫으면 문제 탭으로 돌아간다', (tester) async {
    final router = await _pumpRouter(tester, AppRoutes.questions);
    router.push(AppRoutes.questionChapter);
    await tester.pumpAndSettle();
    // 챕터 완료: 챕터 화면 자리를 결과로 교체
    router.pushReplacement(AppRoutes.chapterResult);
    await tester.pumpAndSettle();

    await _tapExit(tester);

    expect(find.text('문제 탭'), findsOneWidget);
    expect(find.text('챕터'), findsNothing);
  });

  testWidgets('문제 탭에서 문제 상세 > 결과로 들어와도 결과를 닫으면 한 번에 문제 탭으로 간다', (tester) async {
    final router = await _pumpRouter(tester, AppRoutes.questions);
    router.push(AppRoutes.questionDetail('abc'));
    await tester.pumpAndSettle();
    router.push(AppRoutes.questionResult('abc'));
    await tester.pumpAndSettle();

    await _tapExit(tester);

    expect(find.text('문제 탭'), findsOneWidget);
    expect(find.text('문제 상세'), findsNothing);
    // 라우터 상태도 시작 화면 경로로 맞춰졌는지
    expect(router.state.matchedLocation, AppRoutes.questions);
  });

  testWidgets('홈에서 오늘의 세트를 풀고 결과를 닫으면 홈으로 돌아간다', (tester) async {
    final router = await _pumpRouter(tester, AppRoutes.home);
    router.push(AppRoutes.dailySet);
    await tester.pumpAndSettle();
    router.pushReplacement(AppRoutes.dailySetResult);
    await tester.pumpAndSettle();

    await _tapExit(tester);

    expect(find.text('홈 탭'), findsOneWidget);
  });

  testWidgets('딥링크로 결과가 바로 열렸으면(돌아갈 화면 없음) 홈으로 간다', (tester) async {
    await _pumpRouter(tester, AppRoutes.dailySetResult);

    await _tapExit(tester);

    expect(find.text('홈 탭'), findsOneWidget);
  });

  testWidgets('문제 상세 > 결과가 스택의 전부이면 홈으로 간다', (tester) async {
    await _pumpRouter(tester, AppRoutes.questionResult('abc'));

    await _tapExit(tester);

    expect(find.text('홈 탭'), findsOneWidget);
  });

  _defineShellRouteCases();
}

// 실제 앱처럼 탭 루트를 StatefulShellRoute 로 감싸고, 풀이 흐름은 루트 내비게이터에 올린다
final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter _buildShellRouter(String initialLocation) => GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: initialLocation,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => Scaffold(body: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: AppRoutes.home, builder: (_, _) => const Text('홈 탭')),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.questions,
              builder: (_, _) => const Text('문제 탭'),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.wrongNotes,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, _) => const Text('오답 노트'),
    ),
    // 실제 챕터 화면처럼 시스템 뒤로가기를 막은 화면
    GoRoute(
      path: AppRoutes.questionChapter,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, _) =>
          const PopScope(canPop: false, child: _ExitButton(label: '챕터')),
    ),
    GoRoute(
      path: AppRoutes.questionDetailPattern,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, _) => const Text('문제 상세'),
      routes: [
        GoRoute(
          path: AppRoutes.resultSubPath,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (_, _) => const _ExitButton(label: '문제 결과'),
        ),
      ],
    ),
  ],
);

Future<GoRouter> _pumpShellRouter(
  WidgetTester tester,
  String initialLocation,
) async {
  final router = _buildShellRouter(initialLocation);
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
  return router;
}

void _defineShellRouteCases() {
  group('탭 셸(StatefulShellRoute) 구조', () {
    testWidgets('문제 탭 > 상세 > 결과를 닫으면 문제 탭으로 돌아온다', (tester) async {
      final router = await _pumpShellRouter(tester, AppRoutes.home);
      router.go(AppRoutes.questions);
      await tester.pumpAndSettle();
      router.push(AppRoutes.questionDetail('a'));
      await tester.pumpAndSettle();
      router.push(AppRoutes.questionResult('a'));
      await tester.pumpAndSettle();

      await _tapExit(tester);

      expect(find.text('문제 탭'), findsOneWidget);
      expect(router.state.matchedLocation, AppRoutes.questions);
    });

    testWidgets('오답 노트 > 상세 > 결과를 닫으면 오답 노트로 돌아온다', (tester) async {
      final router = await _pumpShellRouter(tester, AppRoutes.questions);
      router.push(AppRoutes.wrongNotes);
      await tester.pumpAndSettle();
      router.push(AppRoutes.questionDetail('a'));
      await tester.pumpAndSettle();
      router.push(AppRoutes.questionResult('a'));
      await tester.pumpAndSettle();

      await _tapExit(tester);

      expect(find.text('오답 노트'), findsOneWidget);
      expect(router.state.matchedLocation, AppRoutes.wrongNotes);
    });

    testWidgets('뒤로가기를 막은(PopScope) 챕터도 나가기로 문제 탭에 돌아온다', (tester) async {
      final router = await _pumpShellRouter(tester, AppRoutes.questions);
      router.push('${AppRoutes.questionChapter}?topic=X');
      await tester.pumpAndSettle();

      await _tapExit(tester);

      expect(find.text('문제 탭'), findsOneWidget);
      expect(find.text('챕터'), findsNothing);
      expect(router.state.matchedLocation, AppRoutes.questions);
    });
  });
}
