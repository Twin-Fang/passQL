import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/ads/ad_placement.dart';
import '../../../core/ads/rewarded_ad_player.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/error_code.dart';
import '../../design/design.dart';
import '../../providers/ad_providers.dart';
import '../../providers/plan_providers.dart';
import '../../providers/session_reset.dart';

/// 보상형 광고를 불러오지 못했을 때 버튼 아래 한 줄
const String rewardedAdUnavailableMessage = '지금은 광고를 불러올 수 없어요';

/// 광고 보너스를 받은 뒤 토스트
String adBonusGrantedMessageOf(int bonusQuestionCount) =>
    '$bonusQuestionCount문제가 더 열렸어요';

// 서버 검증 콜백 기다림: 확인 간격·최대 확인 횟수 (콜백은 보통 몇 초 안에 옴, #860)
const Duration _adBonusVerificationPollInterval = Duration(seconds: 2);
const int _adBonusVerificationMaxAttempts = 5;

/// 무료 하루 한도 광고 보너스 버튼 (#808): 광고 사용 가능 + 오늘 남은 횟수 있을 때만 보임
/// 탭 > 보상 표식 만들기 > 보상형 광고(서버 검증 값: 회원·표식, #860) > 끝까지 보면 서버 보너스 확인 > [onBonusGranted]
/// 그 외 결과는 버튼 아래 한 줄
class RewardedAdBonusButton extends ConsumerStatefulWidget {
  const RewardedAdBonusButton({super.key, required this.onBonusGranted});

  /// 보너스가 등급에 반영된 뒤 (시트 닫기 등)
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

  /// 광고 > 보상 받았으면 서버 보너스 > 반영 완료 알림
  Future<void> _watchAdForBonus() async {
    if (_isBusy) return;
    setState(() {
      _isBusy = true;
      _statusMessage = null;
    });
    // 광고를 보는 사이 시트가 닫혀도 보상은 기록 > 컨테이너는 기다리기 전에 잡아 둠
    final container = ProviderScope.containerOf(context);
    // 광고마다 새 표식: AdMob 콜백(custom_data)과 앱 신고를 같은 광고로 묶음
    final rewardNonce = const Uuid().v4();
    final memberUuid = container.read(currentMemberUuidProvider);
    final outcome = await container
        .read(rewardedAdPlayerProvider)
        .loadAndShow(
          AdPlacement.rewardedDailyBonus,
          serverVerification: memberUuid == null
              ? null
              : RewardedAdServerVerification(
                  userId: memberUuid,
                  customData: rewardNonce,
                ),
        );
    String? failureMessage;
    switch (outcome) {
      case RewardedAdOutcome.rewarded:
        try {
          await _confirmAdBonus(container, rewardNonce);
          if (!mounted) return;
          widget.onBonusGranted();
          return;
        } catch (error) {
          failureMessage = error.asAppException.message;
        }
      case RewardedAdOutcome.unavailable:
        failureMessage = rewardedAdUnavailableMessage;
      case RewardedAdOutcome.dismissedWithoutReward:
        // 끝까지 안 봄 > 안내 없이 다시 누를 수 있게
        failureMessage = null;
    }
    if (!mounted) return;
    setState(() {
      _isBusy = false;
      _statusMessage = failureMessage;
    });
  }

  /// 보너스 확인 (같은 표식이라 몇 번 불러도 1회만 기록)
  /// 서버 검증 대기(409)면 2초 간격 최대 5번, 끝내 대기면 등급 새로고침 후 안내 (#860)
  /// 일시 실패(네트워크 등)는 1회 재시도, 하루 횟수 소진·앱 업데이트 안내는 바로 실패 (#814)
  static Future<void> _confirmAdBonus(
    ProviderContainer container,
    String rewardNonce,
  ) async {
    var hasRetriedTransientFailure = false;
    for (var attempt = 1; ; attempt++) {
      try {
        await container
            .read(planProvider.notifier)
            .grantAdBonus(rewardNonce: rewardNonce);
        return;
      } catch (error) {
        final errorCode = error.asAppException.code;
        if (errorCode == ErrorCode.adBonusVerificationPending) {
          if (attempt >= _adBonusVerificationMaxAttempts) {
            // 콜백이 늦게 오면 다음 등급 조회 때 반영
            await container.read(planProvider.notifier).refresh();
            rethrow;
          }
          await Future<void>.delayed(_adBonusVerificationPollInterval);
          continue;
        }
        final isFinalFailure =
            errorCode == ErrorCode.adBonusDailyLimitReached ||
            errorCode == ErrorCode.adBonusAppUpdateRequired ||
            hasRetriedTransientFailure;
        if (isFinalFailure) rethrow;
        hasRetriedTransientFailure = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dailyBonus = ref.watch(knownPlanProvider)?.dailyBonus;
    final isVisible =
        ref.watch(adsEnabledProvider) &&
        dailyBonus != null &&
        dailyBonus.hasRemainingAdBonus;
    if (!isVisible) return const SizedBox.shrink();
    final colors = context.passqlColors;
    final statusMessage = _statusMessage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PassqlButton(
          label:
              '광고 보고 ${dailyBonus.bonusQuestionCount}문제 더 풀기 · '
              '오늘 ${dailyBonus.remainingAdBonusCount}번 남음',
          icon: CupertinoIcons.play_rectangle,
          variant: PassqlButtonVariant.tinted,
          size: PassqlButtonSize.regular,
          isLoading: _isBusy,
          onPressed: _watchAdForBonus,
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
