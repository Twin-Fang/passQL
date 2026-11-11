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
import '../pro/pro_access_feedback.dart';

// 버튼 아래 한 줄 3종 (공정 사용 상한은 fairUseLimitResetNotice, #963)
const String rewardedAdCheckingMessage = '광고 확인 중…';
const String rewardedAdDismissedMessage = '끝까지 봐야 받아요';
const String rewardedAdUnavailableMessage = '지금은 광고를 불러올 수 없어요';

// 서버 검증 콜백 기다림: 확인 간격·최대 확인 횟수 (콜백은 보통 몇 초 안에 옴, #860)
const Duration _adBonusVerificationPollInterval = Duration(seconds: 2);
const int _adBonusVerificationMaxAttempts = 5;

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

  /// 시청·확인 시작 알림 > 진행 (결과 Future 는 시트 밖 호출부도 기다림)
  void _startBonusAttempt() {
    if (_isBusy) return;
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
          // 같은 화면에 다시 막혀도 버튼을 다시 쓸 수 있게 진행 상태부터 내림
          if (mounted) {
            setState(() => _isBusy = false);
            widget.onBonusGranted();
          }
          return true;
        } catch (error) {
          failureMessage = _failureMessageOf(error);
        }
      case RewardedAdOutcome.unavailable:
        failureMessage = rewardedAdUnavailableMessage;
      case RewardedAdOutcome.dismissedWithoutReward:
        failureMessage = rewardedAdDismissedMessage;
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

  /// 보너스 확인 (같은 표식이라 몇 번 불러도 1회만 기록)
  /// 서버 검증 대기(409)면 2초 간격 최대 5번, 끝내 대기면 등급 새로고침 후 안내 (#860)
  /// 일시 실패(네트워크 등)는 1회 재시도, 공정 사용 상한·옛 서버 횟수 소진·앱 업데이트 안내는 바로 실패 (#814·#963)
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
            errorCode == ErrorCode.fairUseDailyLimitReached ||
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
    if (!ref.watch(shouldShowProUiProvider)) return const SizedBox.shrink();
    final canUseAds = ref.watch(adsEnabledProvider);
    final colors = context.passqlColors;
    // 한 줄 우선순위: 진행 중 > 광고 못 씀 > 마지막 결과
    final statusMessage = _isBusy
        ? rewardedAdCheckingMessage
        : canUseAds
        ? _statusMessage
        : rewardedAdUnavailableMessage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PassqlButton(
          label: '광고 보기',
          icon: CupertinoIcons.play_fill,
          isLoading: _isBusy,
          onPressed: canUseAds ? _startBonusAttempt : null,
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
