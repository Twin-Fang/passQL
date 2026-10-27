import 'package:flutter/widgets.dart';

import 'app_logger.dart';

/// 화면 이동 로그: push, pop, replace + 경로 패턴 (go_router 이름, 파라미터 값 제외)
class AppLogRouteObserver extends NavigatorObserver {
  static const String _logTag = 'route';

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      AppLogger.info(_logTag, 'push ${route.settings.name}');

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      AppLogger.info(_logTag, 'pop ${route.settings.name}');

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      AppLogger.info(_logTag, 'replace ${newRoute?.settings.name}');
}
