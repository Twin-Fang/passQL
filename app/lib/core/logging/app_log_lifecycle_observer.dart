import 'package:flutter/widgets.dart';

import 'app_logger.dart';

/// 앱 생명주기 로그 + 백그라운드 진입 시 즉시 flush (강제 종료 대비)
class AppLogLifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    AppLogger.info('lifecycle', state.name);
    if (state == AppLifecycleState.paused) AppLogger.flush();
  }
}
