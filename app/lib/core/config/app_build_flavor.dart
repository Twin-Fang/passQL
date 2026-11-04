import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 빌드 종류 (#809): 개발용 빌드 판정(컴파일타임 APP_FLAVOR), 개발자 도구 노출 판정
/// 개발용 = --dart-define=APP_FLAVOR=dev (워크플로 빌드 프로파일 test, .github/config/build-profile.json)
abstract final class AppBuildFlavor {
  static const String _flavor = String.fromEnvironment('APP_FLAVOR');

  // .env: 개발자 도구 표시 ('true' 일 때만, 디버그·개발용 빌드에서만 의미 있음)
  static const String showDevToolsEnvKey = 'APP_SHOW_DEV_TOOLS';

  /// 개발용 빌드인가 (.env 로는 바꿀 수 없음)
  static bool get isDevBuild => _flavor == 'dev';

  /// 개발 장치를 쓸 수 있는 빌드: 디버그 또는 개발용 (운영 빌드는 false)
  static bool get canUseDevTools => kDebugMode || isDevBuild;

  /// 개발자 도구를 그릴지 (빌드 + .env 두 층 모두 켜져야 함)
  static bool get shouldShowDevTools => isDevToolsVisible(
    canUseDevTools: canUseDevTools,
    showDevToolsEnvValue: _readEnvOrNull(showDevToolsEnvKey),
  );

  /// 판정: 개발 장치 빌드 AND .env 값 'true' (운영 빌드는 .env 값과 무관하게 false)
  static bool isDevToolsVisible({
    required bool canUseDevTools,
    required String? showDevToolsEnvValue,
  }) =>
      canUseDevTools && showDevToolsEnvValue?.trim().toLowerCase() == 'true';

  // .env 미로드(테스트 등)는 꺼짐
  static String? _readEnvOrNull(String key) {
    try {
      return dotenv.maybeGet(key);
    } catch (_) {
      return null;
    }
  }
}
