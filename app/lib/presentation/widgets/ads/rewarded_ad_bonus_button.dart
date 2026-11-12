import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ads/ad_placement.dart';
import '../../../core/ads/rewarded_ad_player.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/error_code.dart';
import '../../design/design.dart';
import '../../providers/ad_providers.dart';
import '../../providers/plan_providers.dart';
import '../pro/pro_access_feedback.dart';
import 'ad_bonus_claim.dart';

// 버튼 아래 한 줄 3종 (공정 사용 상한은 fairUseLimitResetNotice, #963)
const String rewardedAdCheckingMessage = '광고 확인 중…';
const String rewardedAdDismissedMessage = '끝까지 봐야 받아요';
const String rewardedAdUnavailableMessage = '지금은 광고를 불러올 수 없어요';

/// 무료 하루 한도 광고 보너스 버튼 (#808): 결제 UI 대상(무료·결제 켜짐)이면 늘 보임, 광고를 못 쓰면 비활성 + 이유 한 줄 (#963)
/// 탭 > [onBonusAttemptStarted] > 보상 표식 만들기 > 보상형 광고(서버 검증 값: 회원·표식, #860) > 끝까지 보면 서버 보너스 확인 > [onBonusGranted]
/// 진행 중·실패·중간 닫음은 버튼 아래 한 줄
class RewardedAdBonusButton extends ConsumerStatefulWidget {
  const RewardedAdBonusButton({
    super.key,
    required this.onBonusGranted,
    this.onBonusAttemptStarted,
  });

  /// 시청·확인 시작: 보너스 반영 여부 Future (버튼이 사라져도 끝까지 진행 > 시트를 닫아도 결과 전달)
  final void Function(Future<bool> isBonusGranted)? onBonusAttemptStarted;

  /// 보너스가 등급에 반영된 뒤, 버튼이 아직 화면에 있을 때만 (시트 닫기 등)
  final VoidCallback onBonusGranted;

  @override
  ConsumerState<RewardedAdBonusButton> createState() =>
      _RewardedAdBonusButtonState();
}

class _RewardedAdBonusButtonState extends ConsumerState<RewardedAdBonusButton> {
  /// 광고 불러오기·시청·보너스 받기 진행 중 (중복 탭 방지)
  bool _isBusy = false;

  /// 마지막 실패 안내 (버튼 아래 한 줄)
  String? _statusMessage;

  /// 공정 사용 상한에 닿음 (오늘은 광고를 더 봐도 같은 거부 > 버튼 비활성 유지)
  bool _hasReachedFairUseLimit = false;

  /// 시청·확인 시작 알림 > 진행 (결과 Future 는 시트 밖 호출부도 기다림)
  void _startBonusAttempt() {
    if (_isBusy || _hasReachedFairUseLimit) return;
    setState(() {
      _isBusy = true;
      _statusMessage = null;
    });
    final isBonusGranted = _watchAdForBonus(ProviderScope.containerOf(context));
    widget.onBonusAttemptStarted?.call(isBonusGranted);
  }

  /// 광고 > 보상 받았으면 서버 보너스 > 반영 여부 (화면에 남아 있으면 완료 알림·실패 안내)
  /// 광고를 보는 사이 시트가 닫혀도 보상은 기록 > 컨테이너는 기다리기 전에 잡아 둠
  Future<bool> _watchAdForBonus(ProviderContainer container) async {
    String? failureMessage;
    try {
      final outcome = await AdBonusClaim.watchAdThenConfirmBonus(
        container,
        showAd: (serverVerification) => container
            .read(rewardedAdPlayerProvider)
            .loadAndShow(
              AdPlacement.rewardedDailyBonus,
              serverVerification: serverVerification,
            ),
      );
      switch (outcome) {
        case RewardedAdOutcome.rewarded:
          // 같은 화면에 다시 막혀도 버튼을 다시 쓸 수 있게 진행 상태부터 내림
          if (mounted) {
            setState(() => _isBusy = false);
            widget.onBonusGranted();
          }
          return true;
        case RewardedAdOutcome.unavailable:
          failureMessage = rewardedAdUnavailableMessage;
        case RewardedAdOutcome.dismissedWithoutReward:
          failureMessage = rewardedAdDismissedMessage;
      }
    } catch (error) {
      failureMessage = _failureMessageOf(error);
      _hasReachedFairUseLimit =
          error.asAppException.code == ErrorCode.fairUseDailyLimitReached;
    }
    if (mounted) {
      setState(() {
        _isBusy = false;
        _statusMessage = failureMessage;
      });
    }
    return false;
  }

  /// 보너스 확인 실패 > 버튼 아래 한 줄 (공정 사용 상한은 다시 열리는 때, 그 외는 서버 오류 문구)
  static String _failureMessageOf(Object error) {
    final exception = error.asAppException;
    return exception.code == ErrorCode.fairUseDailyLimitReached
        ? fairUseLimitResetNotice
        : exception.message;
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(shouldShowProUiProvider)) return const SizedBox.shrink();
    final canUseAds = ref.watch(adsEnabledProvider);
    final colors = context.passqlColors;
    // 한 줄 우선순위: 진행 중 > 공정 사용 상한 > 광고 못 씀 > 마지막 결과
    final statusMessage = _isBusy
        ? rewardedAdCheckingMessage
        : _hasReachedFairUseLimit
        ? fairUseLimitResetNotice
        : canUseAds
        ? _statusMessage
        : rewardedAdUnavailableMessage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PassqlButton(
          label: '광고 보기',
          icon: CupertinoIcons.play_fill,
          // 크레딧 시트의 주 버튼은 이용권 (#971)
          variant: PassqlButtonVariant.tinted,
          isLoading: _isBusy,
          onPressed: canUseAds && !_hasReachedFairUseLimit
              ? _startBonusAttempt
              : null,
        ),
        if (statusMessage != null) ...[
          const SizedBox(height: PassqlSpacing.xs),
          Text(
            statusMessage,
            textAlign: TextAlign.center,
            style: PassqlTypography.footnote.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
        ],
      ],
    );
  }
}
