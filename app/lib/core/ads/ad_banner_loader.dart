import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_placement.dart';
import 'ad_request_preparer.dart';
import 'loaded_ad_view.dart';

/// 배너 로더 포트. 테스트는 가짜로 바꿔 SDK 를 띄우지 않음
abstract interface class AdBannerLoader {
  /// 화면 폭에 맞춘 고정(anchored) 적응형 배너. 실패·미설정이면 null (예외 없음)
  Future<LoadedAdView?> load(AdPlacement placement, int widthDp);
}

final adBannerLoaderProvider = Provider<AdBannerLoader>(
  (ref) => GoogleAdBannerLoader(ref.watch(adRequestPreparerProvider)),
);

/// google_mobile_ads 배너: 공통 준비 > 크기 계산 > 로드 (시간 초과·실패는 해제 후 null)
class GoogleAdBannerLoader implements AdBannerLoader {
  GoogleAdBannerLoader(this._requestPreparer);

  // 이 시간 안에 안 오면 포기 > 배너 자리 없음
  static const _loadTimeout = Duration(seconds: 20);

  final AdRequestPreparer _requestPreparer;

  @override
  Future<LoadedAdView?> load(AdPlacement placement, int widthDp) async {
    // 폭 0 으로 적응형 크기 요청 > SDK 예외 (첫 프레임)
    if (widthDp <= 0) return null;
    BannerAd? bannerAd;
    try {
      final preparedRequest = await _requestPreparer.prepare(placement);
      if (preparedRequest == null) return null;
      final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(widthDp);
      if (size == null) return null;

      final loadCompleter = Completer<BannerAd?>();
      bannerAd = BannerAd(
        adUnitId: preparedRequest.unitId,
        size: size,
        request: preparedRequest.request,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (!loadCompleter.isCompleted) {
              loadCompleter.complete(ad as BannerAd);
            }
          },
          onAdFailedToLoad: (_, error) {
            debugPrint(
              '[ads banner] load failed ${placement.name} : ${error.code}',
            );
            // 해제는 아래 null 경로 한 곳에서 (실패·시간 초과 공통)
            if (!loadCompleter.isCompleted) loadCompleter.complete(null);
          },
        ),
      );
      await bannerAd.load();
      final loadedAd = await loadCompleter.future.timeout(
        _loadTimeout,
        onTimeout: () {
          debugPrint('[ads banner] load timeout ${placement.name}');
          return null;
        },
      );
      if (loadedAd == null) {
        await bannerAd.dispose();
        return null;
      }
      return LoadedAdView(
        height: size.height.toDouble(),
        view: SizedBox(
          width: size.width.toDouble(),
          height: size.height.toDouble(),
          child: AdWidget(ad: loadedAd),
        ),
        dispose: loadedAd.dispose,
      );
    } catch (error) {
      // 광고는 보조 요소 > 사용자 알림 없이 기록만
      debugPrint('[ads banner] prepare failed ${placement.name} : $error');
      await bannerAd?.dispose();
      return null;
    }
  }
}
