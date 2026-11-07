import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../logging/app_logger.dart';
import 'ad_placement.dart';
import 'ad_request_preparer.dart';
import 'full_screen_ad_guard.dart';

/// 네이티브 광고 1개 로드 공통(템플릿 카드·한 줄 띠): 요청 준비 > 광고 조립 > 로드 > 시간 초과 대기
/// 실패·미설정·시간 초과·예외면 해제 후 null (예외 없음)
Future<NativeAd?> loadNativeAdOrNull({
  required AdRequestPreparer requestPreparer,
  required AdPlacement placement,
  required Duration loadTimeout,
  required NativeAd Function(
    PreparedAdRequest preparedRequest,
    NativeAdListener listener,
  )
  buildNativeAd,
}) async {
  NativeAd? nativeAd;
  try {
    final preparedRequest = await requestPreparer.prepare(placement);
    if (preparedRequest == null) return null;

    final loadCompleter = Completer<NativeAd?>();
    nativeAd = buildNativeAd(
      preparedRequest,
      NativeAdListener(
        // 광고가 연 외부 화면에서 돌아올 때 앱 오프닝 광고 제외용
        onAdClicked: (_) => FullScreenAdGuard.recordAdClicked(),
        onAdLoaded: (ad) {
          if (!loadCompleter.isCompleted) {
            loadCompleter.complete(ad as NativeAd);
          }
        },
        onAdFailedToLoad: (_, error) {
          AppLogger.warn(
            'ads native',
            'load failed ${placement.name} : ${error.code}',
          );
          // 해제는 아래 null 경로 한 곳에서 (실패·시간 초과 공통)
          if (!loadCompleter.isCompleted) loadCompleter.complete(null);
        },
      ),
    );
    await nativeAd.load();
    final loadedAd = await loadCompleter.future.timeout(
      loadTimeout,
      onTimeout: () {
        AppLogger.warn('ads native', 'load timeout ${placement.name}');
        return null;
      },
    );
    if (loadedAd == null) {
      await nativeAd.dispose();
      return null;
    }
    return loadedAd;
  } catch (error) {
    // 광고는 보조 요소 > 사용자 알림 없이 기록만
    AppLogger.warn('ads native', 'prepare failed ${placement.name} : $error');
    await nativeAd?.dispose();
    return null;
  }
}
