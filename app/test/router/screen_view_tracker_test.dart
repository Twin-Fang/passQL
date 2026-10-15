import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:passql_app/core/monitoring/app_analytics.dart';
import 'package:passql_app/router/app_routes.dart';
import 'package:passql_app/router/screen_view_tracker.dart';

import '../helpers/fakes/fake_analytics_backend.dart';

/// 실제 라우트 패턴만 같은 최소 라우터 (화면은 빈 위젯)
GoRouter _buildRouter() => GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(path: AppRoutes.home, builder: (_, _) => const SizedBox()),
    GoRoute(
      path: AppRoutes.questionDetailPattern,
      builder: (_, _) => const SizedBox(),
      routes: [
        GoRoute(
          path: AppRoutes.resultSubPath,
          builder: (_, _) => const SizedBox(),
        ),
      ],
    ),
  ],
);

void main() {
  testWidgets('go·push·pop 마다 라우트 패턴 기준 화면 이름을 기록한다 (UUID 미포함)', (
    tester,
  ) async {
    final backend = FakeAnalyticsBackend();
    final router = _buildRouter();
    trackScreenViews(router, analytics: AppAnalytics(backend));
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    router.go(AppRoutes.questionDetail('11111111-aaaa'));
    await tester.pumpAndSettle();
    router.push(AppRoutes.questionResult('11111111-aaaa'));
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();

    expect(backend.loggedScreenNames, [
      'home',
      'question_detail',
      'question_result',
      'question_detail',
    ]);
  });
}
