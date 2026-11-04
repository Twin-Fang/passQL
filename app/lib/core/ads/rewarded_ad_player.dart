import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_placement.dart';
import 'ad_request_preparer.dart';
import 'full_screen_ad_guard.dart';
import 'full_screen_ad_loading.dart';

/// 보상형 광고 결과 3종
enum RewardedAdOutcome {
  rewarded, // 끝까지 봐서 보상 받음
  dismissedWithoutReward, // 보상 전에 닫음
  unavailable, // 미설정·로드 실패·시간 초과·다른 전체 화면 광고 표시 중
}

/// 보상형 광고 재생 포트 (누를 때 불러와 바로 보임). 테스트는 가짜로 바꿔 SDK 를 띄우지 않음
abstract interface class RewardedAdPlayer {
  /// 불러오기 > 표시 > 닫힘까지 기다림 (예외 없음)
  Future<RewardedAdOutcome> loadAndShow(AdPlacement placement);
}

final rewardedAdPlayerProvider = Provider<RewardedAdPlayer>(
  (ref) => GoogleRewardedAdPlayer(ref.watch(adRequestPreparerProvider)),
);

/// google_mobile_ads 보상형 (#808): 공통 준비 > 로드(30초 제한) > 겹침 확인 > 표시 > 닫힘
/// 표시 중에는 전체 화면 광고 표시 중으로 기록 (앱 오프닝·전면 광고 겹침 방지, #787)
class GoogleRewardedAdPlayer implements RewardedAdPlayer {
  GoogleRewardedAdPlayer(this._requestPreparer);

  final AdRequestPreparer _requestPreparer;

  @override
  Future<RewardedAdOutcome> loadAndShow(AdPlacement placement) async {
    final rewardedAd = await _load(placement);
    if (rewardedAd == null) return RewardedAdOutcome.unavailable;
    if (FullScreenAdGuard.isFullScreenAdShowing) {
      rewardedAd.dispose();
      return RewardedAdOutcome.unavailable;
    }
    return _show(rewardedAd);
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

  /// 표시 > 닫힘까지 대기. 닫힘·표시 실패 모두 해제 + 표시 중 해제 (성공·실패 공통)
  Future<RewardedAdOutcome> _show(RewardedAd rewardedAd) {
    final closedCompleter = Completer<RewardedAdOutcome>();
    var isRewarded = false;
    void finish(Ad ad, RewardedAdOutcome outcome) {
      ad.dispose();
      FullScreenAdGuard.markFullScreenAdClosed();
      if (!closedCompleter.isCompleted) closedCompleter.complete(outcome);
    }

    rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdClicked: (_) => FullScreenAdGuard.recordAdClicked(),
      onAdDismissedFullScreenContent: (ad) => finish(
        ad,
        isRewarded
            ? RewardedAdOutcome.rewarded
            : RewardedAdOutcome.dismissedWithoutReward,
      ),
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[ads rewarded] show failed : ${error.code}');
        finish(ad, RewardedAdOutcome.unavailable);
      },
    );
    FullScreenAdGuard.markFullScreenAdShowing();
    unawaited(rewardedAd.show(onUserEarnedReward: (_, _) => isRewarded = true));
    return closedCompleter.future;
  }
}
