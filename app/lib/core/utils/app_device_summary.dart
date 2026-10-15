import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 문의 대응용 앱·기기 요약 1줄: "앱 0.10.0(277) · iOS 18.0 · iPhone16,2"
/// 플랫폼 정보를 못 읽으면(테스트·미지원 플랫폼) null
Future<String?> describeAppAndDevice() async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    final appVersionLabel =
        '앱 ${packageInfo.version}(${packageInfo.buildNumber})';
    final deviceLabel = await _describeDevice(DeviceInfoPlugin());
    return [appVersionLabel, ?deviceLabel].join(' · ');
  } catch (_) {
    return null;
  }
}

/// 플랫폼별 OS 버전·기기 모델 (Android: 제조사 모델, iOS: 기기 식별자)
Future<String?> _describeDevice(DeviceInfoPlugin deviceInfoPlugin) async {
  if (Platform.isAndroid) {
    final android = await deviceInfoPlugin.androidInfo;
    return 'Android ${android.version.release}(SDK ${android.version.sdkInt})'
        ' · ${android.manufacturer} ${android.model}';
  }
  if (Platform.isIOS) {
    final ios = await deviceInfoPlugin.iosInfo;
    return 'iOS ${ios.systemVersion} · ${ios.utsname.machine}';
  }
  return null;
}
