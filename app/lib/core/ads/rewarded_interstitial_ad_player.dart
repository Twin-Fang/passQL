import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_placement.dart';
import 'ad_request_preparer.dart';
import 'full_screen_ad_loading.dart';
import 'rewarded_ad_player.dart';

/// 보상형 전면 광고 미리 불러오기 대기 한도 (5초, 넘으면 안내 없이 끝남)
const Duration rewardedInterstitialPreloadTimeout = Duration(seconds: 5);

/// 미리 불러 둔 보상형 전면 광고 1개: 표시 1회 또는 해제 (먼저 한 쪽만 유효)
/// 결과·서버 검증 값은 보상형 광고와 같은 형태 (같은 광고 보너스로 기록)
abstract interface class PreloadedRewardedInterstitialAd {
  /// (서버 검증 값 설정) > 표시 > 닫힘까지 기다림 (예외 없음, 해제·표시 뒤면 unavailable)
  Future<RewardedAdOutcome> show({
    RewardedAdServerVerification? serverVerification,
  });

  /// 보이지 않고 버림 (건너뜀·화면 떠남, 표시한 뒤면 무시)
  void dispose();
}

/// 보상형 전면 광고 불러오기 포트 (#963): 결과 화면이 먼저 불러 두고, 불러온 경우에만 안내를 띄움
/// 테스트는 가짜로 바꿔 SDK 를 띄우지 않음
abstract interface class RewardedInterstitialAdPlayer {
  /// 불러오기 (5초 제한), 미설정·실패·시간 초과면 null (예외 없음)
  Future<PreloadedRewardedInterstitialAd?> preload(AdPlacement placement);
}

final rewardedInterstitialAdPlayerProvider =
    Provider<RewardedInterstitialAdPlayer>(
      (ref) => GoogleRewardedInterstitialAdPlayer(
        ref.watch(adRequestPreparerProvider),
      ),
    );

/// google_mobile_ads 보상형 전면: 공통 준비 > 로드(5초 제한) > 불러 둔 광고 반환
class GoogleRewardedInterstitialAdPlayer
    implements RewardedInterstitialAdPlayer {
  GoogleRewardedInterstitialAdPlayer(this._requestPreparer);

  final AdRequestPreparer _requestPreparer;

  static const _logLabel = 'rewarded interstitial';

  @override
  Future<PreloadedRewardedInterstitialAd?> preload(
    AdPlacement placement,
  ) async {
    final rewardedInterstitialAd =
        await loadFullScreenAd<RewardedInterstitialAd>(
          requestPreparer: _requestPreparer,
          placement: placement,
          logLabel: _logLabel,
          loadTimeout: rewardedInterstitialPreloadTimeout,
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
    if (rewardedInterstitialAd == null) return null;
    return _GooglePreloadedRewardedInterstitialAd(rewardedInterstitialAd);
  }
}

/// SDK 광고 객체 1개 감싸기: 표시·해제 중 먼저 온 쪽만 실행 (광고 객체는 1회용)
class _GooglePreloadedRewardedInterstitialAd
    implements PreloadedRewardedInterstitialAd {
  _GooglePreloadedRewardedInterstitialAd(this._ad);

  final RewardedInterstitialAd _ad;

  /// 표시 또는 해제를 이미 했는가 (표시 경로는 닫힐 때 공통 표시가 해제)
  bool _isUsed = false;

  @override
  Future<RewardedAdOutcome> show({
    RewardedAdServerVerification? serverVerification,
  }) async {
    if (_isUsed) return RewardedAdOutcome.unavailable;
    _isUsed = true;
    return showRewardedFormatAd<RewardedInterstitialAd>(
      ad: _ad,
      logLabel: GoogleRewardedInterstitialAdPlayer._logLabel,
      serverVerification: serverVerification,
      setServerSideOptions: _ad.setServerSideOptions,
      attachCallback: (callback) => _ad.fullScreenContentCallback = callback,
      show: (onUserEarnedReward) =>
          _ad.show(onUserEarnedReward: onUserEarnedReward),
    );
  }

  @override
  void dispose() {
    if (_isUsed) return;
    _isUsed = true;
    _ad.dispose();
  }
}
