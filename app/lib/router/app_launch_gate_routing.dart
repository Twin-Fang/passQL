import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/logging/app_logger.dart';
import '../core/network/service_maintenance_signal.dart';
import '../presentation/providers/app_config_providers.dart';
import 'app_routes.dart';

/// 앱 시작 판정 > 라우터 차단 화면 분기: 점검·강제 업데이트면 해당 화면 고정, 풀리면 홈
abstract final class AppLaunchGateRouting {
  /// 현재 분기. 값이 바뀌면 라우터가 redirect 를 다시 평가
  static final ValueNotifier<AppLaunchGate> gate = ValueNotifier(
    AppLaunchGate.open,
  );

  // 분기 > 고정할 화면 경로 (정상은 없음)
  static const Map<AppLaunchGate, String> _locationByGate = {
    AppLaunchGate.forceUpdate: AppRoutes.forceUpdate,
    AppLaunchGate.maintenance: AppRoutes.maintenance,
  };

  /// 차단 중이면 차단 화면, 차단이 풀렸는데 차단 화면이면 홈, 그 외 null(인증 분기로 넘김)
  static String? redirectLocation(String matchedLocation) {
    final gateLocation = _locationByGate[gate.value];
    if (gateLocation != null) {
      return matchedLocation == gateLocation ? null : gateLocation;
    }
    return isGateLocation(matchedLocation) ? AppRoutes.home : null;
  }

  /// 차단 화면 경로면 true
  static bool isGateLocation(String matchedLocation) =>
      _locationByGate.containsValue(matchedLocation);

  // 앱 복귀 감시 (앱 수명 동안 1개 유지)
  static AppLifecycleListener? _resumeListener;

  /// 판정 구독 시작 > 재조회 계기 연결(앱 복귀, 점검 응답) > 첫 판정 대기 (실패해도 차단 없이 진행)
  static Future<void> bindAndLoad(ProviderContainer container) async {
    container.listen<AsyncValue<AppLaunchDecision>>(appLaunchDecisionProvider, (
      _,
      next,
    ) {
      final decision = next.valueOrNull;
      if (decision == null) return;
      // 설정 조회 실패면 직전 분기 유지 (오프라인 복귀로 점검·강제 업데이트 차단이 풀리지 않게)
      final isConfigMissing =
          container.read(appConfigProvider).valueOrNull == null;
      if (isConfigMissing && gate.value != AppLaunchGate.open) return;
      gate.value = decision.gate;
    }, fireImmediately: true);
    // 재조회 계기 2개: 앱 복귀(점검 시작·종료 반영), API 점검 응답 (#995)
    _resumeListener ??= AppLifecycleListener(
      onResume: () => container.invalidate(appConfigProvider),
    );
    container
        .read(serviceMaintenanceSignalProvider)
        .maintenanceResponses
        .listen((_) => container.invalidate(appConfigProvider));
    try {
      await container.read(appLaunchDecisionProvider.future);
    } catch (error) {
      AppLogger.warn(
        'app launch gate',
        'decision failed, launch without gate : $error',
      );
    }
  }
}
