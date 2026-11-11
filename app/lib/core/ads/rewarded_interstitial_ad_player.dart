import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_placement.dart';
import 'ad_request_preparer.dart';
import 'full_screen_ad_loading.dart';
import 'rewarded_ad_player.dart';

/// 보상형 전면 광고 재생 포트 (#963): 결과 화면 안내 카운트다운이 끝나면 불러와 바로 보임
/// 결과·서버 검증 값은 보상형 광고와 같은 형태 (같은 광고 보너스로 기록). 테스트는 가짜로 바꿔 SDK 를 띄우지 않음
abstract interface class RewardedInterstitialAdPlayer {
  /// 불러오기 > (서버 검증 값 설정) > 표시 > 닫힘까지 기다림 (예외 없음)
  Future<RewardedAdOutcome> loadAndShow(
    AdPlacement placement, {
    RewardedAdServerVerification? serverVerification,
  });
}

final rewardedInterstitialAdPlayerProvider =
    Provider<RewardedInterstitialAdPlayer>(
      (ref) => GoogleRewardedInterstitialAdPlayer(
        ref.watch(adRequestPreparerProvider),
      ),
    );

/// google_mobile_ads 보상형 전면: 공통 준비 > 로드(30초 제한) > 보상형 형식 공통 표시
class GoogleRewardedInterstitialAdPlayer
    implements RewardedInterstitialAdPlayer {
  GoogleRewardedInterstitialAdPlayer(this._requestPreparer);

  final AdRequestPreparer _requestPreparer;

  static const _logLabel = 'rewarded interstitial';

  @override
  Future<RewardedAdOutcome> loadAndShow(
    AdPlacement placement, {
    RewardedAdServerVerification? serverVerification,
  }) async {
    final rewardedInterstitialAd =
        await loadFullScreenAd<RewardedInterstitialAd>(
          requestPreparer: _requestPreparer,
          placement: placement,
          logLabel: _logLabel,
          startLoad: (preparedRequest, onLoaded, onFailed) =>
              RewardedInterstitialAd.load(
                adUnitId: preparedRequest.unitId,
                request: preparedRequest.request,
                rewardedInterstitialAdLoadCallback:
                    RewardedInterstitialAdLoadCallback(
                      onAdLoaded: onLoaded,
                      onAdFailedToLoad: onFailed,
                    ),
              ),
        );
    if (rewardedInterstitialAd == null) return RewardedAdOutcome.unavailable;
    return showRewardedFormatAd<RewardedInterstitialAd>(
      ad: rewardedInterstitialAd,
      logLabel: _logLabel,
      serverVerification: serverVerification,
      setServerSideOptions: rewardedInterstitialAd.setServerSideOptions,
      attachCallback: (callback) =>
          rewardedInterstitialAd.fullScreenContentCallback = callback,
      show: (onUserEarnedReward) =>
          rewardedInterstitialAd.show(onUserEarnedReward: onUserEarnedReward),
    );
  }
}
