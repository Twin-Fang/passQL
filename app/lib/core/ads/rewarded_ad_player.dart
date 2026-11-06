import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_placement.dart';
import 'ad_request_preparer.dart';
import 'full_screen_ad_guard.dart';
import 'full_screen_ad_loading.dart';
import 'full_screen_ad_showing.dart';

/// 보상형 광고 결과 3종
enum RewardedAdOutcome {
  rewarded, // 끝까지 봐서 보상 받음
  dismissedWithoutReward, // 보상 전에 닫음
  unavailable, // 미설정·로드 실패·시간 초과·다른 전체 화면 광고 표시 중
}

/// 보상형 광고 서버 검증 값 (#860): AdMob 이 보상 시 서버 콜백(user_id·custom_data)에 그대로 실어 보냄
class RewardedAdServerVerification {
  const RewardedAdServerVerification({
    required this.userId,
    required this.customData,
  });

  /// 회원 UUID (서버가 보너스를 줄 회원)
  final String userId;

  /// 광고마다 만든 보상 표식 (앱 신고와 콜백을 같은 광고로 묶음)
  final String customData;
}

/// 보상형 광고 재생 포트 (누를 때 불러와 바로 보임). 테스트는 가짜로 바꿔 SDK 를 띄우지 않음
abstract interface class RewardedAdPlayer {
  /// 불러오기 > (서버 검증 값 설정) > 표시 > 닫힘까지 기다림 (예외 없음)
  Future<RewardedAdOutcome> loadAndShow(
    AdPlacement placement, {
    RewardedAdServerVerification? serverVerification,
  });
}

final rewardedAdPlayerProvider = Provider<RewardedAdPlayer>(
  (ref) => GoogleRewardedAdPlayer(ref.watch(adRequestPreparerProvider)),
);

/// google_mobile_ads 보상형 (#808): 공통 준비 > 로드(30초 제한) > 겹침 확인 > 서버 검증 값 설정(#860) > 표시 > 닫힘
/// 표시 중에는 전체 화면 광고 표시 중으로 기록 (앱 오프닝·전면 광고 겹침 방지, #787)
class GoogleRewardedAdPlayer implements RewardedAdPlayer {
  GoogleRewardedAdPlayer(this._requestPreparer);

  final AdRequestPreparer _requestPreparer;

  @override
  Future<RewardedAdOutcome> loadAndShow(
    AdPlacement placement, {
    RewardedAdServerVerification? serverVerification,
  }) async {
    final rewardedAd = await _load(placement);
    if (rewardedAd == null) return RewardedAdOutcome.unavailable;
    if (FullScreenAdGuard.isFullScreenAdShowing) {
      rewardedAd.dispose();
      return RewardedAdOutcome.unavailable;
    }
    if (serverVerification != null) {
      await _applyServerVerification(rewardedAd, serverVerification);
    }
    return _show(rewardedAd);
  }

  /// 서버 검증 값 설정, 실패해도 광고는 보임 (서버 검증 꺼짐 동안은 앱 신고로 기록되므로)
  Future<void> _applyServerVerification(
    RewardedAd rewardedAd,
    RewardedAdServerVerification serverVerification,
  ) async {
    try {
      await rewardedAd.setServerSideOptions(
        ServerSideVerificationOptions(
          userId: serverVerification.userId,
          customData: serverVerification.customData,
        ),
      );
    } catch (error) {
      debugPrint('[ads rewarded] server verification options failed : $error');
    }
  }

  /// 로드: 실패·미설정·시간 초과면 null (공통 로드)
  Future<RewardedAd?> _load(AdPlacement placement) =>
      loadFullScreenAd<RewardedAd>(
        requestPreparer: _requestPreparer,
        placement: placement,
        logLabel: 'rewarded',
        startLoad: (preparedRequest, onLoaded, onFailed) => RewardedAd.load(
          adUnitId: preparedRequest.unitId,
          request: preparedRequest.request,
          rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: onLoaded,
            onAdFailedToLoad: onFailed,
          ),
        ),
      );

  /// 표시 > 닫힘까지 대기: 공통 표시(끝나는 경로 3개 모두) > 표시 중 해제 > 보상 여부로 결과
  Future<RewardedAdOutcome> _show(RewardedAd rewardedAd) {
    final closedCompleter = Completer<RewardedAdOutcome>();
    var isRewarded = false;
    FullScreenAdGuard.markFullScreenAdShowing();
    showFullScreenAd<RewardedAd>(
      ad: rewardedAd,
      logLabel: 'rewarded',
      attachCallback: (callback) =>
          rewardedAd.fullScreenContentCallback = callback,
      show: () =>
          rewardedAd.show(onUserEarnedReward: (_, _) => isRewarded = true),
      onShown: () {},
      onClosed: () {
        FullScreenAdGuard.markFullScreenAdClosed();
        closedCompleter.complete(
          isRewarded
              ? RewardedAdOutcome.rewarded
              : RewardedAdOutcome.dismissedWithoutReward,
        );
      },
    );
    return closedCompleter.future;
  }
}
