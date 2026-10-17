import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/storage/device_preferences.dart';
import '../../core/storage/storage_keys.dart';
import '../../core/utils/app_version.dart';
import '../../data/models/meta/app_config.dart';
import '../../data/sources/api_providers.dart';

/// 앱 시작 분기 3종: 정상, 강제 업데이트 차단, 점검 차단
enum AppLaunchGate { open, forceUpdate, maintenance }

/// 앱 시작 판정 결과: 분기 + 화면 문구·스토어 링크·권장 버전
@immutable
class AppLaunchDecision {
  const AppLaunchDecision({
    required this.gate,
    required this.currentVersion,
    required this.versionPolicy,
    required this.maintenanceMessage,
    required this.notices,
  });

  /// 설정을 못 받았을 때: 차단 없음
  const AppLaunchDecision.open({required this.currentVersion})
    : gate = AppLaunchGate.open,
      versionPolicy = const AppPlatformVersionPolicy(),
      maintenanceMessage = defaultMaintenanceMessage,
      notices = const [];

  // 관리자 문구가 비었을 때의 점검 문구
  static const String defaultMaintenanceMessage =
      '더 나은 서비스를 위해 점검하고 있어요.\n잠시 후 다시 이용해 주세요.';

  final AppLaunchGate gate;
  final String currentVersion;

  /// 현재 플랫폼(iOS·Android)의 버전 정책
  final AppPlatformVersionPolicy versionPolicy;
  final String maintenanceMessage;
  final List<AppNotice> notices;

  /// 권장 버전보다 낮으면 true (차단 중이면 false)
  bool get shouldRecommendUpdate =>
      gate == AppLaunchGate.open &&
      AppVersion.isLowerThan(currentVersion, versionPolicy.recommendedVersion);
}

/// 앱 시작 판정: 점검 > 최소 버전 미만 > 정상 순 (설정 없음 > 정상)
AppLaunchDecision decideAppLaunch({
  required AppConfig? config,
  required String currentVersion,
  required bool isIos,
}) {
  if (config == null) {
    return AppLaunchDecision.open(currentVersion: currentVersion);
  }
  final versionPolicy = isIos ? config.ios : config.android;
  final message = config.maintenance.message.trim();

  final AppLaunchGate gate;
  if (config.maintenance.isUnderMaintenance) {
    gate = AppLaunchGate.maintenance;
  } else if (AppVersion.isLowerThan(
    currentVersion,
    versionPolicy.minimumVersion,
  )) {
    gate = AppLaunchGate.forceUpdate;
  } else {
    gate = AppLaunchGate.open;
  }
  return AppLaunchDecision(
    gate: gate,
    currentVersion: currentVersion,
    versionPolicy: versionPolicy,
    maintenanceMessage: message.isEmpty
        ? AppLaunchDecision.defaultMaintenanceMessage
        : message,
    notices: config.notices,
  );
}

// 앱 시작 설정 조회 최대 대기 (첫 화면이 이 이상 늦어지지 않게)
const Duration _appConfigTimeout = Duration(seconds: 4);

/// 설치된 앱 버전 (x.y.z)
final currentAppVersionProvider = FutureProvider<String>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
});

/// 앱 시작 설정 1회 조회. 네트워크·서버 오류·시간 초과면 null (앱 사용을 막지 않음)
final appConfigProvider = FutureProvider<AppConfig?>((ref) async {
  try {
    return await ref
        .read(metaApiProvider)
        .getAppConfig()
        .timeout(_appConfigTimeout);
  } catch (error) {
    // 공개 API 라 인증 만료가 없음 > 모든 실패를 "설정 없음"으로 처리
    debugPrint('[app config] fetch failed, launch without gate : $error');
    return null;
  }
});

/// 앱 시작 판정 (설정 + 현재 버전 + 플랫폼)
final appLaunchDecisionProvider = FutureProvider<AppLaunchDecision>((
  ref,
) async {
  final config = await ref.watch(appConfigProvider.future);
  final currentVersion = await ref.watch(currentAppVersionProvider.future);
  return decideAppLaunch(
    config: config,
    currentVersion: currentVersion,
    isIos: defaultTargetPlatform == TargetPlatform.iOS,
  );
});

/// 권장 업데이트 안내를 띄울 권장 버전. 띄울 필요 없거나 이미 닫은 버전이면 null
final recommendedUpdateVersionToPromptProvider = FutureProvider<String?>((
  ref,
) async {
  final decision = await ref.watch(appLaunchDecisionProvider.future);
  if (!decision.shouldRecommendUpdate) return null;
  final recommendedVersion = decision.versionPolicy.recommendedVersion;
  final isAlreadyDismissed =
      await DevicePreferences.readString(
        StorageKeys.dismissedRecommendedVersion,
      ) ==
      recommendedVersion;
  return isAlreadyDismissed ? null : recommendedVersion;
});

/// 권장 업데이트 안내를 띄웠다고 기록 (업데이트·나중에 공통)
Future<void> saveRecommendedUpdatePrompted(String recommendedVersion) async {
  await DevicePreferences.writeString(
    StorageKeys.dismissedRecommendedVersion,
    recommendedVersion,
  );
}
