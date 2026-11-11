import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/ads/rewarded_ad_player.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/error_code.dart';
import '../../providers/plan_providers.dart';
import '../../providers/session_reset.dart';

// 서버 검증 콜백 기다림: 확인 간격·최대 확인 횟수 (콜백은 보통 몇 초 안에 옴, #860)
const Duration _adBonusVerificationPollInterval = Duration(seconds: 2);
const int _adBonusVerificationMaxAttempts = 5;

/// 광고 띄우기 (서버 검증 값을 실어 보상형·보상형 전면 중 하나를 보임)
typedef AdBonusAdShower =
    Future<RewardedAdOutcome> Function(
      RewardedAdServerVerification? serverVerification,
    );

/// 광고 보너스 받기 공통 (#808·#860·#963): 한도 화면 광고 버튼, 결과 화면 보상형 전면 광고
/// 보상 표식 만들기 > 광고(서버 검증 값: 회원·표식) > 끝까지 보면 서버 보너스 확인(같은 grantAdBonus)
abstract final class AdBonusClaim {
  /// 광고 결과 반환 (rewarded 면 보너스가 등급에 반영된 뒤), 보너스 확인 실패는 그대로 던짐
  /// 광고를 보는 사이 화면이 닫혀도 보상은 기록 > 컨테이너는 호출부가 기다리기 전에 잡아 둠
  static Future<RewardedAdOutcome> watchAdThenConfirmBonus(
    ProviderContainer container, {
    required AdBonusAdShower showAd,
  }) async {
    // 광고마다 새 표식: AdMob 콜백(custom_data)과 앱 신고를 같은 광고로 묶음
    final rewardNonce = const Uuid().v4();
    final memberUuid = container.read(currentMemberUuidProvider);
    final outcome = await showAd(
      memberUuid == null
          ? null
          : RewardedAdServerVerification(
              userId: memberUuid,
              customData: rewardNonce,
            ),
    );
    if (outcome == RewardedAdOutcome.rewarded) {
      await _confirmAdBonus(container, rewardNonce);
    }
    return outcome;
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
}
