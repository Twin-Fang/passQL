import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logging/app_logger.dart';

/// 잠금화면 > 앱 이동 경로 (네이티브 LockScreenRoutes.kt 와 같은 값)
abstract final class LockScreenRoutes {
  static const String creditReward = 'credit_reward';
  static const String passSheet = 'pass_sheet';
  static const String settings = 'settings_lock_screen';
  static const String _questionPrefix = 'question:';

  static String question(String questionUuid) =>
      '$_questionPrefix$questionUuid';

  /// `question:<uuid>` 이면 uuid, 아니면 null
  static String? questionUuidOf(String route) =>
      route.startsWith(_questionPrefix)
      ? route.substring(_questionPrefix.length)
      : null;
}

/// 잠금화면 권한 4개: 필수 3개(다른 앱 위에 표시, 알림, 배터리 최적화 제외) + 삼성 기기 여부(절전 예외 권장)
@immutable
class LockScreenPermissionStatus {
  const LockScreenPermissionStatus({
    required this.canDrawOverlays,
    required this.hasNotificationPermission,
    required this.isIgnoringBatteryOptimizations,
    required this.isSamsung,
  });

  static const LockScreenPermissionStatus none = LockScreenPermissionStatus(
    canDrawOverlays: false,
    hasNotificationPermission: false,
    isIgnoringBatteryOptimizations: false,
    isSamsung: false,
  );

  final bool canDrawOverlays;
  final bool hasNotificationPermission;
  final bool isIgnoringBatteryOptimizations;
  final bool isSamsung;

  /// 필수 3개 모두 켜짐 (켜기·"권한 필요" 판정 기준)
  bool get hasRequiredPermissions =>
      canDrawOverlays &&
      hasNotificationPermission &&
      isIgnoringBatteryOptimizations;

  factory LockScreenPermissionStatus.fromMap(Map<Object?, Object?> map) =>
      LockScreenPermissionStatus(
        canDrawOverlays: map['canDrawOverlays'] == true,
        hasNotificationPermission: map['hasNotificationPermission'] == true,
        isIgnoringBatteryOptimizations:
            map['isIgnoringBatteryOptimizations'] == true,
        isSamsung: map['isSamsung'] == true,
      );
}

/// 잠금화면 설정 (원본은 네이티브 SharedPreferences)
@immutable
class LockScreenSettings {
  const LockScreenSettings({
    required this.isEnabled,
    required this.intervalMinutes,
    required this.isExecutableExcluded,
    required this.isFreshChoiceMode,
  });

  static const LockScreenSettings disabled = LockScreenSettings(
    isEnabled: false,
    intervalMinutes: 30,
    isExecutableExcluded: false,
    isFreshChoiceMode: false,
  );

  final bool isEnabled;

  /// 마지막 표시 후 최소 간격 (분, 0 = 매번)
  final int intervalMinutes;

  /// true = 객관식만
  final bool isExecutableExcluded;

  /// 선택지 방식: true = AI로 새로 만들기, false = 기본(준비된 세트). 앱 보기 방식 설정과 별개
  final bool isFreshChoiceMode;

  factory LockScreenSettings.fromMap(Map<Object?, Object?> map) =>
      LockScreenSettings(
        isEnabled: map['isEnabled'] == true,
        intervalMinutes:
            (map['intervalMinutes'] as int?) ?? disabled.intervalMinutes,
        isExecutableExcluded: map['isExecutableExcluded'] == true,
        isFreshChoiceMode: map['isFreshChoiceMode'] == true,
      );
}

/// 네이티브 잠금화면 채널(passql/lock_screen) 래퍼: Android 전용, 그 외 플랫폼은 아무것도 하지 않음
/// 네이티브 > Dart 신호 2개: 잠금화면 표시(잠금 엔진), 이동 경로(앱 엔진)
class LockScreenBridge {
  LockScreenBridge({MethodChannel? channel, bool? isSupported})
    : _channel = channel ?? const MethodChannel(_channelName),
      isLockScreenSupported =
          isSupported ??
          (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    if (isLockScreenSupported) _channel.setMethodCallHandler(_onNativeCall);
  }

  static const String _channelName = 'passql/lock_screen';

  final MethodChannel _channel;

  /// 잠금화면 기능을 쓸 수 있는 플랫폼 (Android)
  final bool isLockScreenSupported;

  final StreamController<void> _shownController =
      StreamController<void>.broadcast();
  final StreamController<String> _routeController =
      StreamController<String>.broadcast();

  /// 잠금화면이 새로 보임 (잠금 엔진만)
  Stream<void> get shownSignals => _shownController.stream;

  /// 잠금화면·알림에서 앱을 연 경로 (앱이 이미 떠 있을 때)
  Stream<String> get openedRoutes => _routeController.stream;

  Future<dynamic> _onNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'onShown':
        _shownController.add(null);
      case 'openRoute':
        final route = call.arguments;
        if (route is String) _routeController.add(route);
    }
  }

  Future<LockScreenPermissionStatus> getPermissionStatus() async {
    final map = await _invoke<Map<Object?, Object?>>('getPermissionStatus');
    return map == null
        ? LockScreenPermissionStatus.none
        : LockScreenPermissionStatus.fromMap(map);
  }

  Future<LockScreenSettings> getSettings() async {
    final map = await _invoke<Map<Object?, Object?>>('getSettings');
    return map == null
        ? LockScreenSettings.disabled
        : LockScreenSettings.fromMap(map);
  }

  Future<void> openOverlaySettings() => _invoke<void>('openOverlaySettings');
  Future<void> openNotificationSettings() =>
      _invoke<void>('openNotificationSettings');
  Future<void> openBatteryOptimizationSettings() =>
      _invoke<void>('openBatteryOptimizationSettings');
  Future<void> openSamsungPowerSettings() =>
      _invoke<void>('openSamsungPowerSettings');

  /// 켜기: 필수 권한 3개가 없으면 네이티브가 거부 > false
  Future<bool> enable({
    required int intervalMinutes,
    required bool isExecutableExcluded,
  }) async =>
      await _invoke<bool>('enable', {
        'intervalMinutes': intervalMinutes,
        'isExecutableExcluded': isExecutableExcluded,
      }) ??
      false;

  Future<void> disable() => _invoke<void>('disable');

  Future<void> updateSettings({
    int? intervalMinutes,
    bool? isExecutableExcluded,
    bool? isFreshChoiceMode,
  }) => _invoke<void>('updateSettings', {
    'intervalMinutes': ?intervalMinutes,
    'isExecutableExcluded': ?isExecutableExcluded,
    'isFreshChoiceMode': ?isFreshChoiceMode,
  });

  /// 오늘 크레딧 소진 화면을 보였음 > 그날은 안 띄움
  Future<void> markExhaustedToday() => _invoke<void>('markExhaustedToday');

  /// 상태 알림 본문 갱신 ([remainingCredits] null = 크레딧 미적용)
  Future<void> updateStatus({
    required int solvedTodayCount,
    required int? remainingCredits,
    required bool isPro,
  }) => _invoke<void>('updateStatus', {
    'solvedTodayCount': solvedTodayCount,
    'remainingCredits': remainingCredits,
    'isPro': isPro,
  });

  /// Dart 준비 전에 온 표시 요청 (잠금 엔진 시작 때 1회)
  Future<bool> consumePendingShow() async =>
      await _invoke<bool>('consumePendingShow') ?? false;

  /// 앱이 꺼진 상태에서 열린 경로 (앱 엔진 시작 때 1회)
  Future<String?> takePendingRoute() => _invoke<String>('takePendingRoute');

  /// 잠금화면 닫기 (잠금은 그대로)
  Future<void> dismiss() => _invoke<void>('dismiss');

  /// 잠금 해제만
  Future<void> unlock() => _invoke<void>('unlock');

  /// 잠금 해제 후 앱에서 [route] 열기
  Future<void> unlockAndOpen(String route) =>
      _invoke<void>('unlockAndOpen', {'route': route});

  /// 채널 호출 (미지원 플랫폼 null, 채널 오류는 로그만 남기고 null)
  Future<T?> _invoke<T>(
    String method, [
    Map<String, Object?>? arguments,
  ]) async {
    if (!isLockScreenSupported) return null;
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (error) {
      AppLogger.warn('lock screen', '$method failed : ${error.code}');
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}

/// 앱 전역 잠금화면 채널 (테스트는 가짜로 교체)
final lockScreenBridgeProvider = Provider<LockScreenBridge>(
  (ref) => LockScreenBridge(),
);
