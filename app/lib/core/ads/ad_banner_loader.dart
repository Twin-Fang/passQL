import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_placement.dart';
import 'ad_request_preparer.dart';
import 'loaded_ad_view.dart';

/// 배너 로더 포트. 테스트는 가짜로 바꿔 SDK 를 띄우지 않음
abstract interface class AdBannerLoader {
  /// 콘텐츠 폭에 맞춘 인라인 적응형 배너 (스크롤 목록 안 카드용). 실패·미설정이면 null (예외 없음)
  Future<LoadedAdView?> load(AdPlacement placement, int widthDp);
}

final adBannerLoaderProvider = Provider<AdBannerLoader>(
  (ref) => GoogleAdBannerLoader(ref.watch(adRequestPreparerProvider)),
);

/// google_mobile_ads 배너: 공통 준비 > 크기 계산 > 로드 > 실제 높이 확인 (시간 초과·실패는 해제 후 null)
class GoogleAdBannerLoader implements AdBannerLoader {
  GoogleAdBannerLoader(this._requestPreparer);

  /// 인라인 배너 최대 높이 (dp). 홈 히트맵 카드 높이 수준 > 다른 카드보다 튀지 않게, 300x250 은 제외
  static const int inlineBannerMaxHeightDp = 160;

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
      final size = AdSize.getInlineAdaptiveBannerAdSize(
        widthDp,
        inlineBannerMaxHeightDp,
      );

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
      // 인라인 적응형은 요청 높이 0 > 로드 뒤 실제 크기로 틀 높이 결정
      final platformSize = await loadedAd.getPlatformAdSize();
      if (platformSize == null || platformSize.height <= 0) {
        debugPrint('[ads banner] size unknown ${placement.name}');
        await loadedAd.dispose();
        return null;
      }
      return LoadedAdView(
        height: platformSize.height.toDouble(),
        view: SizedBox(
          width: platformSize.width.toDouble(),
          height: platformSize.height.toDouble(),
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
