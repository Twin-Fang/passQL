import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_consent.dart';
import 'ad_placement.dart';
import 'ad_sdk.dart';
import 'loaded_ad_view.dart';

/// 배너 로더 포트. 테스트는 가짜로 바꿔 SDK 를 띄우지 않음
abstract interface class AdBannerLoader {
  /// 화면 폭에 맞춘 고정(anchored) 적응형 배너. 실패·미설정이면 null (예외 없음)
  Future<LoadedAdView?> load(AdPlacement placement, int widthDp);
}

final adBannerLoaderProvider = Provider<AdBannerLoader>(
  (_) => GoogleAdBannerLoader(),
);

/// google_mobile_ads 배너: 단위 ID 확인 > SDK 초기화 > 개인화 여부 > 크기 계산 > 로드
class GoogleAdBannerLoader implements AdBannerLoader {
  @override
  Future<LoadedAdView?> load(AdPlacement placement, int widthDp) async {
    // 폭 0 으로 적응형 크기 요청 > SDK 예외 (첫 프레임)
    if (widthDp <= 0) return null;
    try {
      final unitId = AdUnitIds.unitIdFor(placement, isIos: Platform.isIOS);
      // 릴리스인데 .env 비어 있음 > 광고 없음
      if (unitId == null) return null;

      await AdSdk.ensureInitialized();
      final isNonPersonalized = await AdConsent.shouldUseNonPersonalizedAds();
      final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(widthDp);
      if (size == null) return null;

      final loadCompleter = Completer<BannerAd?>();
      final bannerAd = BannerAd(
        adUnitId: unitId,
        size: size,
        // 요청에는 비개인화 여부만 (회원·학습 정보 미전달)
        request: AdRequest(nonPersonalizedAds: isNonPersonalized),
        listener: BannerAdListener(
          onAdLoaded: (ad) => loadCompleter.complete(ad as BannerAd),
          onAdFailedToLoad: (ad, error) {
            debugPrint(
              '[ads banner] load failed ${placement.name} : ${error.code}',
            );
            ad.dispose();
            loadCompleter.complete(null);
          },
        ),
      );
      await bannerAd.load();
      final loadedAd = await loadCompleter.future;
      if (loadedAd == null) return null;
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
      return null;
    }
  }
}
