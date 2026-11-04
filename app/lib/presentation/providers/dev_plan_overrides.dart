import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_build_flavor.dart';
import '../../data/models/member/member_plan_response.dart';

/// 개발 등급 강제값: 시작값 --dart-define=PRO_DEBUG_PLAN=free|pro, 개발자 도구에서 바꿈 (운영 빌드는 무시)
enum ProDebugPlan { free, pro }

const String _debugPlanDefine = String.fromEnvironment('PRO_DEBUG_PLAN');

/// 개발 등급 강제값. 디버그·개발용 빌드에서만 값이 있음 (#809)
final debugPlanOverrideProvider =
    NotifierProvider<DebugPlanOverrideNotifier, ProDebugPlan?>(
      DebugPlanOverrideNotifier.new,
    );

class DebugPlanOverrideNotifier extends Notifier<ProDebugPlan?> {
  @override
  ProDebugPlan? build() {
    if (!AppBuildFlavor.canUseDevTools) return null;
    for (final debugPlan in ProDebugPlan.values) {
      if (debugPlan.name == _debugPlanDefine) return debugPlan;
    }
    return null;
  }

  /// 강제값 바꾸기 (null = 서버값 그대로, 운영 빌드는 무시)
  void select(ProDebugPlan? debugPlan) {
    if (!AppBuildFlavor.canUseDevTools) return;
    state = debugPlan;
  }
}

/// 무료 한도 흉내 6종 (#809, 결제 켜짐 흉내 #816): 화면 표시만 바꿈, 서버 데이터는 그대로
enum DevLimitSimulation {
  none('끔 (서버값)'),
  // 결제 꺼진 서버에서 무료 화면(A안 카드·배너·계정 화면) 확인용: 보너스·사용량 없음
  billingOnFree('결제 켜짐 흉내 (무료, 한도 없음)'),
  limitReached('한도 소진 (광고 2번 남음)'),
  oneAdBonusUsed('한도 소진 (광고 1번 받음)'),
  adBonusesUsedUp('한도 소진 (광고 다 씀)'),
  dailySetBonusesEarned('세트 보너스 받음 (+10)');

  const DevLimitSimulation(this.label);

  /// 개발자 도구 표시 이름
  final String label;
}

final devLimitSimulationProvider =
    NotifierProvider<DevLimitSimulationNotifier, DevLimitSimulation>(
      DevLimitSimulationNotifier.new,
    );

class DevLimitSimulationNotifier extends Notifier<DevLimitSimulation> {
  @override
  DevLimitSimulation build() => DevLimitSimulation.none;

  /// 흉내 바꾸기 (운영 빌드는 무시)
  void select(DevLimitSimulation simulation) {
    if (!AppBuildFlavor.canUseDevTools) return;
    state = simulation;
  }

  /// 흉내 중 광고 보너스 1회: 2번 남음 > 1번 받음 > 다 씀 (서버 호출 대신)
  void recordSimulatedAdBonus() {
    state = switch (state) {
      DevLimitSimulation.limitReached => DevLimitSimulation.oneAdBonusUsed,
      DevLimitSimulation.oneAdBonusUsed => DevLimitSimulation.adBonusesUsedUp,
      _ => state,
    };
  }
}

// 흉내에 쓰는 서버 규칙 값 (서버 DailyFreeBonusRule 과 같은 값)
const int _simulatedBonusQuestionCount = 5;
const int _simulatedAdBonusMaxCount = 2;
const int _simulatedBaseLimitFallback = 10;

/// 서버 등급 > 개발 강제값 반영: 등급 강제 > 한도 흉내 (흉내는 결제 켜진 무료 회원으로 바꿈)
MemberPlanResponse applyDevPlanOverrides(
  MemberPlanResponse serverPlan, {
  required ProDebugPlan? debugPlan,
  required DevLimitSimulation simulation,
}) {
  final plan = switch (debugPlan) {
    ProDebugPlan.free => serverPlan.copyWith(plan: MemberPlanType.free),
    ProDebugPlan.pro => serverPlan.copyWith(plan: MemberPlanType.pro),
    null => serverPlan,
  };
  if (simulation == DevLimitSimulation.none) return plan;

  // 흉내별 (광고 받은 횟수, 세트 보너스 받음, 한도 소진)
  final (adBonusUsedCount, isDailySetBonusEarned, isLimitReached) =
      switch (simulation) {
        DevLimitSimulation.limitReached => (0, false, true),
        DevLimitSimulation.oneAdBonusUsed => (1, false, true),
        DevLimitSimulation.adBonusesUsedUp => (2, false, true),
        DevLimitSimulation.dailySetBonusesEarned => (0, true, false),
        DevLimitSimulation.billingOnFree ||
        DevLimitSimulation.none => (0, false, false),
      };
  final baseLimit = plan.dailyFreeLimit > 0
      ? plan.dailyFreeLimit
      : _simulatedBaseLimitFallback;
  final earnedBonusCount = adBonusUsedCount + (isDailySetBonusEarned ? 2 : 0);
  final todayFreeLimit =
      baseLimit + earnedBonusCount * _simulatedBonusQuestionCount;
  return plan.copyWith(
    isBillingEnabled: true,
    plan: MemberPlanType.free,
    dailyFreeLimit: baseLimit,
    todayFreeLimit: todayFreeLimit,
    todayRandomSolvedCount: isLimitReached ? todayFreeLimit : 0,
    dailyBonus: DailyFreeBonus(
      isDailySetCompletionEarned: isDailySetBonusEarned,
      isDailySetAccuracyEarned: isDailySetBonusEarned,
      adBonusUsedCount: adBonusUsedCount,
      adBonusMaxCount: _simulatedAdBonusMaxCount,
      bonusQuestionCount: _simulatedBonusQuestionCount,
    ),
  );
}
