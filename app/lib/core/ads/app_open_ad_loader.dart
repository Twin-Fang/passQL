import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_placement.dart';
import 'ad_request_preparer.dart';
import 'full_screen_ad_guard.dart';
import 'full_screen_ad_loading.dart';
import 'loaded_full_screen_ad.dart';

/// 앱 오프닝 광고 로더 포트. 테스트는 가짜로 바꿔 SDK 를 띄우지 않음
abstract interface class AppOpenAdLoader {
  /// 실패·미설정·시간 초과면 null (예외 없음)
  Future<LoadedFullScreenAd?> load(AdPlacement placement);
}

final appOpenAdLoaderProvider = Provider<AppOpenAdLoader>(
  (ref) => GoogleAppOpenAdLoader(ref.watch(adRequestPreparerProvider)),
);

/// google_mobile_ads 앱 오프닝: 공통 준비 > 로드 (시간 초과 뒤 늦게 온 광고는 해제)
class GoogleAppOpenAdLoader implements AppOpenAdLoader {
  GoogleAppOpenAdLoader(this._requestPreparer);

  final AdRequestPreparer _requestPreparer;

  @override
  Future<LoadedFullScreenAd?> load(AdPlacement placement) async {
    final appOpenAd = await loadFullScreenAd<AppOpenAd>(
      requestPreparer: _requestPreparer,
      placement: placement,
      logLabel: 'app open',
      startLoad: (preparedRequest, onLoaded, onFailed) => AppOpenAd.load(
        adUnitId: preparedRequest.unitId,
        request: preparedRequest.request,
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: onLoaded,
          onAdFailedToLoad: onFailed,
        ),
      ),
    );
    if (appOpenAd == null) return null;
    return LoadedFullScreenAd(
      loadedAt: DateTime.now(),
      show: ({required onShown, required onClosed}) =>
          _show(appOpenAd, onShown: onShown, onClosed: onClosed),
      dispose: appOpenAd.dispose,
    );
  }

  /// 표시: 콜백 연결 > show. 닫힘·표시 실패 모두 해제 후 onClosed (성공·실패 공통)
  static void _show(
    AppOpenAd appOpenAd, {
    required VoidCallback onShown,
    required VoidCallback onClosed,
  }) {
    appOpenAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => onShown(),
      onAdClicked: (_) => FullScreenAdGuard.recordAdClicked(),
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        onClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[ads app open] show failed : ${error.code}');
        ad.dispose();
        onClosed();
      },
    );
    unawaited(appOpenAd.show());
  }
}
