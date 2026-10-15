import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  /// 판정 구독 시작 > 첫 판정 대기 (실패해도 차단 없이 진행)
  static Future<void> bindAndLoad(ProviderContainer container) async {
    container.listen<AsyncValue<AppLaunchDecision>>(appLaunchDecisionProvider, (
      _,
      next,
    ) {
      final decision = next.valueOrNull;
      if (decision != null) gate.value = decision.gate;
    }, fireImmediately: true);
    try {
      await container.read(appLaunchDecisionProvider.future);
    } catch (error) {
      debugPrint(
        '[app launch gate] decision failed, launch without gate : $error',
      );
    }
  }
}
