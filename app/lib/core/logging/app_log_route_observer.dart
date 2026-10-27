import 'package:flutter/widgets.dart';

import 'app_logger.dart';

/// 화면 이동 로그: push, pop, replace + 경로 패턴 (go_router 이름, 파라미터 값 제외)
/// 이름 없는 라우트(다이얼로그·시트)는 기록하지 않음
class AppLogRouteObserver extends NavigatorObserver {
  static const String _logTag = 'route';

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _log('push', route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _log('pop', route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _log('replace', newRoute);

  void _log(String action, Route<dynamic>? route) {
    final routeName = route?.settings.name;
    if (routeName == null) return;
    AppLogger.info(_logTag, '$action $routeName');
  }
}
