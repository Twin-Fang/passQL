import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../logging/app_logger.dart';
import 'crash_reporter.dart';

/// Crashlytics 로 보내는 [CrashReporter] 구현
class FirebaseCrashReporter extends CrashReporter {
  const FirebaseCrashReporter(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> recordNonFatalError(
    Object error,
    StackTrace? stackTrace, {
    required String reason,
  }) {
    AppLogger.error('error', error, stackTrace);
    return _crashlytics.recordError(error, stackTrace, reason: reason);
  }

  @override
  Future<void> setMemberIdentifier(String? memberUuid) =>
      // Crashlytics 는 null 해제가 없어 빈 문자열로 지움
      _crashlytics.setUserIdentifier(memberUuid ?? '');
}

/// 크래시 수집 시작 (Firebase.initializeApp 뒤 1회)
/// 디버그 빌드 수집 끔 > 전역 수집기 교체 > Flutter·플랫폼 미처리 오류를 치명적 오류로 기록
Future<void> startFirebaseCrashReporting() async {
  final crashlytics = FirebaseCrashlytics.instance;
  await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
  CrashReporter.current = FirebaseCrashReporter(crashlytics);

  // 위젯 빌드·레이아웃 중 오류 (디버그 콘솔 출력은 유지)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLogger.error('error', details.exception, details.stack);
    crashlytics.recordFlutterFatalError(details);
  };
  // Flutter 밖 비동기 미처리 오류 (true: 처리 완료로 표시해 앱 종료 방지)
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    AppLogger.error('error', error, stackTrace);
    crashlytics.recordError(error, stackTrace, fatal: true);
    return true;
  };
}
