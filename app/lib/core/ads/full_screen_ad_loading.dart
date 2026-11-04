import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_placement.dart';
import 'ad_request_preparer.dart';

/// 전체 화면 광고 로드 대기 한도 (넘으면 포기, 다음 시도에서 다시 불러옴)
const Duration fullScreenAdLoadTimeout = Duration(seconds: 30);

/// SDK 로드 시작 (형식별 load 호출: 준비된 요청 + 성공·실패 콜백)
typedef FullScreenAdLoadStarter<T extends Ad> =
    Future<void> Function(
      PreparedAdRequest preparedRequest,
      void Function(T ad) onLoaded,
      void Function(LoadAdError error) onFailed,
    );

/// 전체 화면 광고 1개 로드 공통 (전면·앱 오프닝·보상형): 요청 준비 > SDK 로드 > 시간 초과 대기
/// 실패·미설정·시간 초과면 null (예외 없음), 시간 초과 뒤 늦게 온 광고는 해제
/// [logLabel]: 로그 접두사 안 형식 이름 (예: interstitial > [ads interstitial])
Future<T?> loadFullScreenAd<T extends Ad>({
  required AdRequestPreparer requestPreparer,
  required AdPlacement placement,
  required String logLabel,
  required FullScreenAdLoadStarter<T> startLoad,
}) async {
  try {
    final preparedRequest = await requestPreparer.prepare(placement);
    if (preparedRequest == null) return null;

    final loadCompleter = Completer<T?>();
    await startLoad(
      preparedRequest,
      (ad) {
        // 시간 초과 뒤 늦게 온 광고는 쓰지 않고 해제
        if (loadCompleter.isCompleted) {
          ad.dispose();
        } else {
          loadCompleter.complete(ad);
        }
      },
      (error) {
        debugPrint(
          '[ads $logLabel] load failed ${placement.name} : ${error.code}',
        );
        if (!loadCompleter.isCompleted) loadCompleter.complete(null);
      },
    );
    return await loadCompleter.future.timeout(
      fullScreenAdLoadTimeout,
      onTimeout: () {
        debugPrint('[ads $logLabel] load timeout ${placement.name}');
        return null;
      },
    );
  } catch (error) {
    debugPrint('[ads $logLabel] prepare failed ${placement.name} : $error');
    return null;
  }
}
