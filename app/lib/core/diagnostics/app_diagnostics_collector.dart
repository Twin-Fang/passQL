import 'dart:io' show Platform;
import 'dart:ui' as ui;

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../push/push_messaging_client.dart';
import '../utils/date_format.dart';
import 'ringer_mode_reader.dart';

/// 항목 하나 읽기 제한 시간 (플러그인 무응답이 전송을 막지 않게)
const Duration _itemReadTimeout = Duration(seconds: 3);

/// 의견 진단 정보 수집: app, device, system, meta 4그룹 JSON
/// 항목마다 개별 try/catch > 실패 시 null (collect 는 던지지 않음), 이메일·닉네임·토큰·위치는 수집 안 함
class AppDiagnosticsCollector {
  const AppDiagnosticsCollector({
    required this.memberUuid,
    required this.authProvider,
    required this.isPro,
    required this.themeMode,
    required this.choiceMode,
    required this.pushMessagingClient,
  });

  final String? memberUuid;
  final String? authProvider;
  final bool? isPro;
  final String? themeMode;
  final String? choiceMode;
  final PushMessagingClient pushMessagingClient;

  /// 진단 정보 수집: app > device > system > meta
  Future<Map<String, Object?>> collect({
    required BuildContext context,
    required String? previousRoute,
  }) async {
    // context 에서 읽는 값은 await 전에 확보
    final screenValues = _readScreenValues(context);
    // 독립 항목은 동시에 읽음 (최악 시간 = 항목 제한 시간 1회)
    final groups = await Future.wait([
      _collectApp(previousRoute),
      _readDeviceValues(),
      _collectSystem(),
    ]);
    return {
      'app': groups[0],
      'device': {...groups[1], ...screenValues},
      'system': groups[2],
      'meta': {'collectedAt': formatIso8601WithOffset(DateTime.now())},
    };
  }

  Future<Map<String, Object?>> _collectApp(String? previousRoute) async {
    final readResults = await Future.wait<Object?>([
      _readItem(PackageInfo.fromPlatform),
      _readItem(_readPushPermission),
      _readItem(_readHasPushToken),
    ]);
    final packageInfo = readResults[0] as PackageInfo?;
    return {
      'appVersion': packageInfo?.version,
      'buildNumber': packageInfo?.buildNumber,
      'installerStore': packageInfo?.installerStore,
      'memberUuid': memberUuid,
      'authProvider': authProvider,
      'isPro': isPro,
      'themeMode': themeMode,
      'choiceMode': choiceMode,
      'currentRoute': previousRoute,
      'pushPermission': readResults[1],
      'hasPushToken': readResults[2],
    };
  }

  /// 권한 포트 값 > 진단 값 (포트가 provisional 을 granted 로 합쳐 둠)
  Future<String> _readPushPermission() async {
    final status = await pushMessagingClient.readPermissionStatus();
    return switch (status) {
      PushPermissionStatus.granted => 'authorized',
      PushPermissionStatus.denied => 'denied',
      PushPermissionStatus.notDetermined => 'notDetermined',
    };
  }

  Future<bool> _readHasPushToken() async {
    final token = await pushMessagingClient.fetchToken();
    return token != null && token.isNotEmpty;
  }

  /// OS·기기 정보 (platform, osVersion, deviceModel, manufacturer, isPhysicalDevice)
  Future<Map<String, Object?>> _readDeviceValues() async {
    final deviceValues = await _readItem(() async {
      final deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final android = await deviceInfoPlugin.androidInfo;
        return <String, Object?>{
          'platform': 'android',
          'osVersion': android.version.release,
          'deviceModel': android.model,
          'manufacturer': android.manufacturer,
          'isPhysicalDevice': android.isPhysicalDevice,
        };
      }
      if (Platform.isIOS) {
        final ios = await deviceInfoPlugin.iosInfo;
        return <String, Object?>{
          'platform': 'ios',
          'osVersion': ios.systemVersion,
          'deviceModel': ios.utsname.machine,
          'manufacturer': 'Apple',
          'isPhysicalDevice': ios.isPhysicalDevice,
        };
      }
      return <String, Object?>{'platform': Platform.operatingSystem};
    });
    return {
      'platform': null,
      'osVersion': null,
      'deviceModel': null,
      'manufacturer': null,
      'isPhysicalDevice': null,
      ...?deviceValues,
    };
  }

  /// 화면·로캘 값 (locale, timeZone, 화면 픽셀, 배율, 글자 배율, 밝기)
  Map<String, Object?> _readScreenValues(BuildContext context) {
    final mediaQuery = _readItemSync(() => MediaQuery.of(context));
    final physicalSize = mediaQuery == null
        ? null
        : mediaQuery.size * mediaQuery.devicePixelRatio;
    return {
      'locale': _readItemSync(
        () => ui.PlatformDispatcher.instance.locale.toLanguageTag(),
      ),
      'timeZone': _readItemSync(() => DateTime.now().timeZoneName),
      'screenWidthPixels': physicalSize?.width.round(),
      'screenHeightPixels': physicalSize?.height.round(),
      'devicePixelRatio': mediaQuery?.devicePixelRatio,
      'textScaleFactor': _readItemSync(() => mediaQuery!.textScaler.scale(1.0)),
      'platformBrightness': mediaQuery?.platformBrightness.name,
    };
  }

  Future<Map<String, Object?>> _collectSystem() async {
    final readResults = await Future.wait<Object?>([
      _readItem(() => Battery().isInBatterySaveMode),
      _readItem(() => Battery().batteryLevel),
      _readItem(() async => (await Battery().batteryState).name),
      _readItem(_readNetworkType),
      _readItem<String?>(ringerModeReader),
    ]);
    return {
      'isBatterySaveMode': readResults[0],
      'batteryLevelPercent': readResults[1],
      'batteryState': readResults[2],
      'networkType': readResults[3],
      'ringerMode': readResults[4],
    };
  }

  /// 연결 종류 목록 > wifi, mobile, ethernet, none, other 중 하나
  Future<String> _readNetworkType() async {
    final results = await Connectivity().checkConnectivity();
    if (results.contains(ConnectivityResult.wifi)) return 'wifi';
    if (results.contains(ConnectivityResult.mobile)) return 'mobile';
    if (results.contains(ConnectivityResult.ethernet)) return 'ethernet';
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return 'none';
    }
    return 'other';
  }

  /// 비동기 항목 읽기 (실패·시간 초과 > null)
  Future<T?> _readItem<T>(Future<T> Function() read) async {
    try {
      return await read().timeout(_itemReadTimeout);
    } catch (_) {
      return null;
    }
  }

  /// 동기 항목 읽기 (실패 > null)
  T? _readItemSync<T>(T Function() read) {
    try {
      return read();
    } catch (_) {
      return null;
    }
  }
}
