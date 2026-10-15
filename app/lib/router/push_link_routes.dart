import 'dart:async';

import 'package:go_router/go_router.dart';

import '../core/push/push_link.dart';
import 'app_routes.dart';

/// 알림 이동 정보 > 앱 경로 (허용 목록 5종만, 그 외 경로 없음)
String toPushLinkLocation(PushLink link) => switch (link.target) {
  PushLinkTarget.home => AppRoutes.home,
  PushLinkTarget.dailySet => AppRoutes.dailySet,
  PushLinkTarget.questions => AppRoutes.questions,
  PushLinkTarget.questionDetail => AppRoutes.questionDetail(link.questionUuid!),
  PushLinkTarget.stats => AppRoutes.stats,
};

/// 알림 탭 이동: 탭 루트는 바로 이동, 풀스크린은 홈 위에 쌓음 (뒤로 가기 > 홈)
/// 홈이 아니면 홈 이동이 반영된 뒤 push (먼저 push 하면 늦게 끝난 go 가 덮어씀)
Future<void> openPushLink(GoRouter router, PushLink link) async {
  final location = toPushLinkLocation(link);
  if (AppRoutes.tabRoots.contains(location)) {
    router.go(location);
    return;
  }
  if (router.state.matchedLocation != AppRoutes.home) {
    final homeApplied = _waitForNextRouteChange(router);
    router.go(AppRoutes.home);
    await homeApplied;
  }
  router.push(location);
}

// 경로 반영 대기 상한 (반영 알림이 없을 때 대비)
const Duration _routeChangeTimeout = Duration(seconds: 1);

/// 라우터의 다음 경로 반영 알림까지 대기
Future<void> _waitForNextRouteChange(GoRouter router) {
  final completer = Completer<void>();
  void onRouteChanged() {
    if (!completer.isCompleted) completer.complete();
  }

  router.routerDelegate.addListener(onRouteChanged);
  return completer.future
      .timeout(_routeChangeTimeout, onTimeout: () {})
      .whenComplete(() => router.routerDelegate.removeListener(onRouteChanged));
}
