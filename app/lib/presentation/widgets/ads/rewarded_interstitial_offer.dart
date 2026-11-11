import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ads/ad_placement.dart';
import '../../../core/ads/full_screen_ad_guard.dart';
import '../../../core/ads/interstitial_frequency_cap.dart';
import '../../../core/ads/rewarded_ad_player.dart';
import '../../../core/ads/rewarded_interstitial_ad_player.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/error_code.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/utils/app_clock.dart';
import '../../design/design.dart';
import '../../providers/ad_providers.dart';
import '../../providers/plan_providers.dart';
import '../common/app_toast.dart';
import '../pro/pro_access_feedback.dart';
import 'ad_bonus_claim.dart';
import 'rewarded_interstitial_intro_dialog.dart';

/// 결과 화면 보상형 전면 광고 1회 제안 (#963)
/// 대상 확인 > 빈도 제한(첫 결과 유예·간격·하루 횟수) > 안내(5초, 건너뛰기) > 잠금 창 위 광고 > 끝까지 보면 보너스 확인 > 보상 연출
/// 대상 아님·제한·건너뜀·중간 닫음·광고 없음은 조용히 끝남, 끝까지 본 뒤 보너스 확인 실패는 토스트 한 줄
Future<void> offerRewardedInterstitialAd(BuildContext context) async {
  // 광고를 보는 사이 화면이 닫혀도 보너스 확인은 끝까지 > 컨테이너를 먼저 잡아 둠
  final container = ProviderScope.containerOf(context);
  final bonusQuestionCount = _offerableBonusQuestionCountOf(container);
  if (bonusQuestionCount == null) return;
  if (!await _passesFrequencyCap(container)) return;
  if (!context.mounted) return;

  final shouldStartAd = await showRewardedInterstitialIntroDialog(
    context,
    bonusQuestionCount: bonusQuestionCount,
  );
  if (!shouldStartAd || !context.mounted) return;

  try {
    final outcome = await _watchAdBehindBlockingProgress(context, container);
    if (outcome != RewardedAdOutcome.rewarded || !context.mounted) return;
    await _celebrateAdBonus(context, container, bonusQuestionCount);
  } catch (error) {
    final exception = error.asAppException;
    if (!context.mounted) return;
    // 공정 사용 상한은 다시 열리는 때, 그 외는 서버 오류 문구 (한도 화면 광고 버튼과 같은 문구)
    showAppToast(
      context,
      exception.code == ErrorCode.fairUseDailyLimitReached
          ? fairUseLimitResetNotice
          : exception.message,
    );
  }
}

/// 제안 대상이면 광고 1회 보너스 문제 수, 아니면 null
/// 대상 3개: 광고 허용(모바일·로그인·결제로 산 프로 아님), 결제 UI 대상(무료·결제 켜짐), 서버가 알려 준 보너스 수 있음
int? _offerableBonusQuestionCountOf(ProviderContainer container) {
  if (!container.read(adsEnabledProvider)) return null;
  if (!container.read(shouldShowProUiProvider)) return null;
  final bonusQuestionCount =
      container.read(knownPlanProvider)?.dailyBonus.bonusQuestionCount ?? 0;
  return bonusQuestionCount > 0 ? bonusQuestionCount : null;
}

/// 결과 진입 기록 > 다른 전체 화면 광고 없음 + 빈도 제한 통과면 안내 노출 1회 기록 후 true
/// 기기 저장소 읽기·쓰기 실패면 false (광고 없이 화면 흐름 유지)
Future<bool> _passesFrequencyCap(ProviderContainer container) async {
  final frequencyCap = container.read(interstitialFrequencyCapProvider);
  try {
    // 첫 결과 유예는 진입 횟수 기준 (안내 노출 여부와 무관하게 셈)
    await frequencyCap.recordResultEntry();
    if (FullScreenAdGuard.isFullScreenAdShowing) return false;
    if (!await frequencyCap.canShowAt(AppClock.now())) return false;
    await frequencyCap.recordShownAt(AppClock.now());
    return true;
  } catch (error) {
    AppLogger.warn(
      'ads rewarded interstitial',
      'frequency cap failed : $error',
    );
    return false;
  }
}

/// 광고 불러오기·보너스 확인 동안 화면 잠금 (광고는 잠금 창 위에 뜸, 기다리는 사이 닫기·이탈 방지)
Future<RewardedAdOutcome> _watchAdBehindBlockingProgress(
  BuildContext context,
  ProviderContainer container,
) async {
  // 기다리는 사이 다른 창이 위에 쌓여도 잠금 창만 닫음
  final closeBlockingProgress = showPassqlBlockingProgressWithCloser(context);
  try {
    return await AdBonusClaim.watchAdThenConfirmBonus(
      container,
      showAd: (serverVerification) => container
          .read(rewardedInterstitialAdPlayerProvider)
          .loadAndShow(
            AdPlacement.rewardedInterstitialResult,
            serverVerification: serverVerification,
          ),
    );
  } finally {
    // 잠금 창 닫기 (성공·실패 공통)
    closeBlockingProgress();
  }
}

/// 보너스 반영 뒤 보상 연출 (+N문제, 남은 수 차오름)
Future<void> _celebrateAdBonus(
  BuildContext context,
  ProviderContainer container,
  int bonusQuestionCount,
) {
  final knownPlan = container.read(knownPlanProvider);
  return showPassqlRewardCelebration(
    context,
    bonusQuestionCount: bonusQuestionCount,
    reasonText: PassqlRewardReason.adWatched,
    remainingAfter:
        container.read(freeRemainingSolvesProvider) ?? bonusQuestionCount,
    totalQuestionCount: knownPlan?.effectiveTodayFreeLimit,
    actionLabel: '확인',
  );
}

/// 결과 화면 진입 시 보상형 전면 광고 제안 1회 (첫 프레임 뒤, 화면을 기다리게 하지 않음): 챕터 결과
class RewardedInterstitialOnEnter extends StatefulWidget {
  const RewardedInterstitialOnEnter({super.key, required this.child});

  final Widget child;

  @override
  State<RewardedInterstitialOnEnter> createState() =>
      _RewardedInterstitialOnEnterState();
}

class _RewardedInterstitialOnEnterState
    extends State<RewardedInterstitialOnEnter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(offerRewardedInterstitialAd(context));
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// 결과 화면을 떠날 때 보상형 전면 광고 제안 1회 뒤 [onLeave] (닫기 버튼·뒤로가기 공통): 오늘의 세트 결과
/// 진입 때는 세트 보상 연출이 떠서 겹치지 않게 떠날 때로 미룸
class RewardedInterstitialOnLeave extends StatefulWidget {
  const RewardedInterstitialOnLeave({
    super.key,
    required this.onLeave,
    required this.builder,
  });

  /// 실제로 화면을 떠나는 동작 (풀이 흐름 나가기 등)
  final void Function(BuildContext context) onLeave;

  /// [leaveWithAdOffer]: 닫기 버튼에 연결할 "제안 뒤 떠나기"
  final Widget Function(BuildContext context, VoidCallback leaveWithAdOffer)
  builder;

  @override
  State<RewardedInterstitialOnLeave> createState() =>
      _RewardedInterstitialOnLeaveState();
}

class _RewardedInterstitialOnLeaveState
    extends State<RewardedInterstitialOnLeave> {
  /// 떠나는 중 (안내·광고 진행 중 닫기 연타·뒤로가기 중복 방지, 떠난 뒤에도 유지 > 화면 전환 중 두 번 나가기 방지)
  bool _isLeaving = false;

  /// 제안 > 떠나기 (제안이 실패해도 떠나기는 반드시, 성공·실패 공통)
  Future<void> _leaveWithAdOffer() async {
    if (_isLeaving) return;
    _isLeaving = true;
    try {
      await offerRewardedInterstitialAd(context);
    } catch (error) {
      AppLogger.warn('ads rewarded interstitial', 'offer failed : $error');
    } finally {
      if (mounted) widget.onLeave(context);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    // 뒤로가기도 제안을 거침 (떠나기는 onLeave 가 직접 pop)
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) unawaited(_leaveWithAdOffer());
    },
    child: widget.builder(context, () => unawaited(_leaveWithAdOffer())),
  );
}
