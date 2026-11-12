import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/lock_screen/lock_screen_bridge.dart';
import '../../core/lock_screen/lock_screen_intro_rule.dart';
import '../../core/monitoring/app_analytics.dart';
import '../../core/storage/device_preferences.dart';
import '../../core/storage/storage_keys.dart';
import '../../core/utils/app_clock.dart';
import '../../data/models/member/member_plan_response.dart';
import 'app_config_providers.dart';
import 'plan_providers.dart';

export '../../core/lock_screen/lock_screen_bridge.dart';

/// 띄우는 간격 선택지 (분, 0 = 매번)
const List<int> lockScreenIntervalOptions = [0, 30, 60, 180];

/// 간격(분) > 표시 이름
String toLockScreenIntervalLabel(int intervalMinutes) =>
    switch (intervalMinutes) {
      0 => '매번',
      60 => '1시간마다',
      180 => '3시간마다',
      _ when intervalMinutes % 60 == 0 => '${intervalMinutes ~/ 60}시간마다',
      _ => '$intervalMinutes분마다',
    };

/// 잠금화면 기능을 보일지: Android + 서버 전체 스위치 켜짐 (설정 못 받으면 숨김)
final isLockScreenAvailableProvider = Provider<bool>((ref) {
  if (!ref.watch(lockScreenBridgeProvider).isLockScreenSupported) return false;
  return ref.watch(appConfigProvider).valueOrNull?.isLockScreenEnabled ?? false;
});

/// 서버 기본 간격 (분, 사용자가 고르기 전 값)
final lockScreenDefaultIntervalProvider = Provider<int>(
  (ref) =>
      ref
          .watch(appConfigProvider)
          .valueOrNull
          ?.lockScreenDefaultIntervalMinutes ??
      LockScreenSettings.disabled.intervalMinutes,
);

/// 서버가 실행형 SQL 문제를 내는가 (false 면 문제 종류 행 숨김·늘 객관식만)
final isLockScreenExecutableIncludedProvider = Provider<bool>(
  (ref) =>
      ref
          .watch(appConfigProvider)
          .valueOrNull
          ?.isLockScreenExecutableIncluded ??
      true,
);

/// 잠금화면 상태: 네이티브 설정 + 권한 + 한 번이라도 켰는지
@immutable
class LockScreenState {
  const LockScreenState({
    required this.settings,
    required this.permissionStatus,
    required this.hasEverEnabled,
  });

  final LockScreenSettings settings;
  final LockScreenPermissionStatus permissionStatus;
  final bool hasEverEnabled;

  /// 켜 두었는데 필수 권한이 빠짐 > 설정 행 "권한 필요"
  bool get isPermissionMissing =>
      settings.isEnabled && !permissionStatus.hasRequiredPermissions;
}

/// 잠금화면 설정·권한 (앱 복귀·권한 단계에서 refresh)
final lockScreenStateProvider =
    AsyncNotifierProvider<LockScreenStateNotifier, LockScreenState>(
      LockScreenStateNotifier.new,
    );

class LockScreenStateNotifier extends AsyncNotifier<LockScreenState> {
  LockScreenBridge get _bridge => ref.read(lockScreenBridgeProvider);

  @override
  Future<LockScreenState> build() => _load();

  Future<LockScreenState> _load() async {
    final (settings, permissionStatus, hasEverEnabled) = await (
      _bridge.getSettings(),
      _bridge.getPermissionStatus(),
      DevicePreferences.readBool(StorageKeys.lockScreenEverEnabled),
    ).wait;
    return LockScreenState(
      settings: settings,
      permissionStatus: permissionStatus,
      hasEverEnabled: hasEverEnabled ?? false,
    );
  }

  /// 네이티브 값 다시 읽기 (설정 앱에서 돌아온 뒤)
  Future<LockScreenState> refresh() async {
    final latest = await _load();
    state = AsyncData(latest);
    return latest;
  }

  /// 켜기: 간격(기존 값 > 서버 기본)·유형 저장 > 네이티브 켜기(필수 권한 없으면 false) > 기록·분석
  Future<bool> enable() async {
    final current = state.valueOrNull ?? await future;
    final intervalMinutes = current.hasEverEnabled
        ? current.settings.intervalMinutes
        : ref.read(lockScreenDefaultIntervalProvider);
    final isEnabled = await _bridge.enable(
      intervalMinutes: intervalMinutes,
      isExecutableExcluded: current.settings.isExecutableExcluded,
    );
    if (isEnabled) {
      await DevicePreferences.writeBool(
        StorageKeys.lockScreenEverEnabled,
        true,
      );
      unawaited(ref.read(appAnalyticsProvider).logLockScreenEnabled());
      syncLockScreenStatus(_bridge, ref.read(knownPlanProvider));
    }
    await refresh();
    return isEnabled;
  }

  Future<void> disable() async {
    await _bridge.disable();
    await refresh();
  }

  Future<void> updateInterval(int intervalMinutes) async {
    await _bridge.updateSettings(intervalMinutes: intervalMinutes);
    await refresh();
  }

  Future<void> updateFreshChoiceMode(bool isFreshChoiceMode) async {
    await _bridge.updateSettings(isFreshChoiceMode: isFreshChoiceMode);
    await refresh();
  }

  Future<void> updateExecutableExcluded(bool isExecutableExcluded) async {
    await _bridge.updateSettings(isExecutableExcluded: isExecutableExcluded);
    await refresh();
  }
}

/// 상태 알림 갱신: 오늘 푼 수·남은 크레딧(무료만)·프로 여부 (등급 모르면 보내지 않음)
void syncLockScreenStatus(LockScreenBridge bridge, MemberPlanResponse? plan) {
  if (plan == null || !bridge.isLockScreenSupported) return;
  final isPro = plan.plan == MemberPlanType.pro || !plan.isBillingEnabled;
  final limit = plan.effectiveTodayFreeLimit;
  unawaited(
    bridge.updateStatus(
      solvedTodayCount: plan.todayRandomSolvedCount,
      remainingCredits: isPro || limit <= 0
          ? null
          : (limit - plan.todayRandomSolvedCount).clamp(0, limit),
      isPro: isPro,
    ),
  );
}

/// 등급이 바뀔 때마다(제출 뒤 다시 받기·광고 보상·구매) 상태 알림 갱신 (앱·잠금화면 엔진 공통, main 에서 1회)
void startLockScreenStatusSync(ProviderContainer container) {
  final bridge = container.read(lockScreenBridgeProvider);
  if (!bridge.isLockScreenSupported) return;
  container.listen<MemberPlanResponse?>(
    knownPlanProvider,
    (_, plan) => syncLockScreenStatus(bridge, plan),
    fireImmediately: true,
  );
}

/// 소개 시트를 지금 띄울지 (기기 기록 + 판정 규칙)
Future<bool> shouldShowLockScreenIntro(
  WidgetRef ref, {
  required bool hasStudiedEnoughToday,
}) async {
  if (!ref.read(isLockScreenAvailableProvider)) return false;
  final lockScreenState = await ref.read(lockScreenStateProvider.future);
  final shownCount =
      await DevicePreferences.readInt(StorageKeys.lockScreenIntroShownCount) ??
      0;
  final lastShownAtMillis = await DevicePreferences.readInt(
    StorageKeys.lockScreenIntroLastShownAt,
  );
  return LockScreenIntroRule.shouldShow(
    isAvailable: true,
    isEnabled: lockScreenState.settings.isEnabled,
    hasStudiedEnoughToday: hasStudiedEnoughToday,
    shownCount: shownCount,
    lastShownAt: lastShownAtMillis == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(lastShownAtMillis),
    now: AppClock.now(),
  );
}

/// 소개 시트 노출 기록 (띄우기 전에 기록: 닫는 방법과 무관하게 횟수 셈)
Future<void> recordLockScreenIntroShown() async {
  final shownCount =
      await DevicePreferences.readInt(StorageKeys.lockScreenIntroShownCount) ??
      0;
  await DevicePreferences.writeInt(
    StorageKeys.lockScreenIntroShownCount,
    shownCount + 1,
  );
  await DevicePreferences.writeInt(
    StorageKeys.lockScreenIntroLastShownAt,
    AppClock.now().millisecondsSinceEpoch,
  );
  unawaited(AppAnalytics.current.logLockScreenIntroShown());
}

/// 홈 다음 할 일에 잠금화면 카드를 낼 수 있는가: 사용 가능 + 안 켬 + 소개를 끝까지 거절하지 않음 (노출 2회 미만)
final canSuggestLockScreenProvider = FutureProvider.autoDispose<bool>((
  ref,
) async {
  if (!ref.watch(isLockScreenAvailableProvider)) return false;
  final lockScreenState = await ref.watch(lockScreenStateProvider.future);
  if (lockScreenState.settings.isEnabled) return false;
  final shownCount =
      await DevicePreferences.readInt(StorageKeys.lockScreenIntroShownCount) ??
      0;
  return shownCount < LockScreenIntroRule.maximumShownCount;
});
