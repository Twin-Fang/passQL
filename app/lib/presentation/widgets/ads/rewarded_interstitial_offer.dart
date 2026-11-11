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

/// 보상형 전면 광고 제안 대상이면 광고 1회 보너스 문제 수, 아니면 null
/// 조건 3개: 광고 허용(모바일·로그인·결제로 산 프로 아님), 결제 UI 대상(무료·결제 켜짐), 서버가 알려 준 보너스 수 있음
int? offerableRewardedInterstitialBonusCountOf({
  required bool isAdsEnabled,
  required bool shouldShowProUi,
  required int bonusQuestionCount,
}) {
  if (!isAdsEnabled || !shouldShowProUi) return null;
  return bonusQuestionCount > 0 ? bonusQuestionCount : null;
}

/// 결과 화면 보상형 전면 광고 제안 1회 (#963): 결과 화면 하나가 하나를 가짐
/// 준비(대상 > 빈도 제한 > 광고 미리 불러오기 5초) > 불러온 경우에만 제시(안내 5초 > 광고 > 보너스 확인 > 보상 연출)
/// 대상 아님·제한·불러오기 실패·건너뜀·중간 닫음은 조용히 끝남, 쓰지 않은 광고는 [dispose] 에서 해제
class RewardedInterstitialOffer {
  /// 광고를 보는 사이 화면이 닫혀도 보너스 확인은 끝까지 > 컨테이너를 먼저 잡아 둠
  RewardedInterstitialOffer(this._container);

  final ProviderContainer _container;

  /// 불러 둔 광고 (제시하면 비움)
  PreloadedRewardedInterstitialAd? _preloadedAd;

  /// 준비 1회 (진행 중이면 같은 준비)
  Future<void>? _preparation;

  /// 화면이 떠났는가 (늦게 불러온 광고는 바로 해제)
  bool _isDisposed = false;

  /// 준비: 대상 확인 > 결과 진입 기록·빈도 제한 확인 > 광고 미리 불러오기 (여러 번 불러도 1회)
  Future<void> prepare() => _preparation ??= _prepareOnce();

  Future<void> _prepareOnce() async {
    if (_offerableBonusQuestionCount() == null) return;
    if (!await _canOfferByFrequencyCap()) return;
    final preloadedAd = await _container
        .read(rewardedInterstitialAdPlayerProvider)
        .preload(AdPlacement.rewardedInterstitialResult);
    if (preloadedAd == null) return;
    if (_isDisposed) {
      preloadedAd.dispose();
      return;
    }
    _preloadedAd = preloadedAd;
  }

  /// 불러 둔 광고가 있을 때만 제시: 대상 재확인 > 안내 노출 기록 > 안내 > 광고 > 보너스 확인 > 보상 연출
  /// 끝까지 본 뒤 보너스 확인 실패는 토스트 한 줄
  Future<void> presentIfReady(BuildContext context) async {
    final preloadedAd = _preloadedAd;
    _preloadedAd = null;
    if (preloadedAd == null) return;
    final bonusQuestionCount = _offerableBonusQuestionCount();
    final canPresent =
        bonusQuestionCount != null &&
        context.mounted &&
        await _recordIntroShown();
    if (!canPresent || !context.mounted) {
      preloadedAd.dispose();
      return;
    }

    final shouldStartAd = await showRewardedInterstitialIntroDialog(
      context,
      bonusQuestionCount: bonusQuestionCount,
    );
    if (!shouldStartAd || !context.mounted) {
      preloadedAd.dispose();
      return;
    }

    try {
      final outcome = await _watchAdThenConfirmBonus(context, preloadedAd);
      if (outcome != RewardedAdOutcome.rewarded || !context.mounted) return;
      await _celebrateAdBonus(context, bonusQuestionCount);
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

  /// 화면이 떠날 때: 쓰지 않은 광고 해제 + 이후 불러온 광고도 해제
  void dispose() {
    _isDisposed = true;
    _preloadedAd?.dispose();
    _preloadedAd = null;
  }

  int? _offerableBonusQuestionCount() =>
      offerableRewardedInterstitialBonusCountOf(
        isAdsEnabled: _container.read(adsEnabledProvider),
        shouldShowProUi: _container.read(shouldShowProUiProvider),
        bonusQuestionCount:
            _container.read(knownPlanProvider)?.dailyBonus.bonusQuestionCount ??
            0,
      );

  /// 결과 진입 기록 > 다른 전체 화면 광고 없음 + 빈도 제한 통과면 true (노출 기록은 안내를 띄울 때)
  /// 기기 저장소 읽기·쓰기 실패면 false (광고 없이 화면 흐름 유지)
  Future<bool> _canOfferByFrequencyCap() async {
    final frequencyCap = _container.read(interstitialFrequencyCapProvider);
    try {
      // 첫 결과 유예는 진입 횟수 기준 (안내 노출 여부와 무관하게 셈)
      await frequencyCap.recordResultEntry();
      if (FullScreenAdGuard.isFullScreenAdShowing) return false;
      return await frequencyCap.canShowAt(AppClock.now());
    } catch (error) {
      _logFrequencyCapFailure(error);
      return false;
    }
  }

  /// 안내 직전: 다른 전체 화면 광고 없음 + 빈도 제한 재확인 > 노출 1회 기록 (준비와 제시 사이 다른 제안 대비)
  Future<bool> _recordIntroShown() async {
    final frequencyCap = _container.read(interstitialFrequencyCapProvider);
    try {
      if (FullScreenAdGuard.isFullScreenAdShowing) return false;
      if (!await frequencyCap.canShowAt(AppClock.now())) return false;
      await frequencyCap.recordShownAt(AppClock.now());
      return true;
    } catch (error) {
      _logFrequencyCapFailure(error);
      return false;
    }
  }

  static void _logFrequencyCapFailure(Object error) => AppLogger.warn(
    'ads rewarded interstitial',
    'frequency cap failed : $error',
  );

  /// 광고 > 끝까지 보면 보너스 확인 (확인 대기 동안만 화면 잠금, 기다리는 사이 닫기·이탈 방지)
  Future<RewardedAdOutcome> _watchAdThenConfirmBonus(
    BuildContext context,
    PreloadedRewardedInterstitialAd preloadedAd,
  ) async {
    VoidCallback? closeBlockingProgress;
    try {
      return await AdBonusClaim.watchAdThenConfirmBonus(
        _container,
        showAd: (serverVerification) async {
          final outcome = await preloadedAd.show(
            serverVerification: serverVerification,
          );
          // 보상 받음 > 이어지는 서버 확인(검증 대기 최대 약 10초) 동안 잠금 창 (다른 창이 쌓여도 자기 창만 닫음)
          if (outcome == RewardedAdOutcome.rewarded && context.mounted) {
            closeBlockingProgress = showPassqlBlockingProgressWithCloser(
              context,
            );
          }
          return outcome;
        },
      );
    } finally {
      // 잠금 창 닫기 (성공·실패 공통)
      closeBlockingProgress?.call();
    }
  }

  /// 보너스 반영 뒤 보상 연출 (+N문제, 남은 수 차오름)
  Future<void> _celebrateAdBonus(BuildContext context, int bonusQuestionCount) {
    final knownPlan = _container.read(knownPlanProvider);
    return showPassqlRewardCelebration(
      context,
      bonusQuestionCount: bonusQuestionCount,
      reasonText: PassqlRewardReason.adWatched,
      remainingAfter:
          _container.read(freeRemainingSolvesProvider) ?? bonusQuestionCount,
      totalQuestionCount: knownPlan?.effectiveTodayFreeLimit,
      actionLabel: '확인',
    );
  }
}
