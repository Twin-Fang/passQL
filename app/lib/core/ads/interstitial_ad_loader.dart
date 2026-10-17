import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_placement.dart';
import 'ad_request_preparer.dart';

/// 미리 불러 둔 전면 광고 1개: 로드 시각·표시·해제
class LoadedInterstitial {
  const LoadedInterstitial({
    required this.loadedAt,
    required this.show,
    required this.dispose,
  });

  final DateTime loadedAt;

  /// 표시 요청. 실제로 화면에 뜨면 onShown, 닫히거나 표시 실패하면 onClosed (어느 쪽이든 1회)
  final void Function({
    required VoidCallback onShown,
    required VoidCallback onClosed,
  })
  show;

  final VoidCallback dispose;
}

/// 전면 광고 로더 포트. 테스트는 가짜로 바꿔 SDK 를 띄우지 않음
abstract interface class InterstitialAdLoader {
  /// 실패·미설정·시간 초과면 null (예외 없음)
  Future<LoadedInterstitial?> load(AdPlacement placement);
}

final interstitialAdLoaderProvider = Provider<InterstitialAdLoader>(
  (ref) => GoogleInterstitialAdLoader(ref.watch(adRequestPreparerProvider)),
);

/// google_mobile_ads 전면: 공통 준비 > 로드 (시간 초과 뒤 늦게 온 광고는 해제)
class GoogleInterstitialAdLoader implements InterstitialAdLoader {
  GoogleInterstitialAdLoader(this._requestPreparer);

  // 이 시간 안에 안 오면 포기 (다음 미리 불러오기에서 재시도)
  static const _loadTimeout = Duration(seconds: 30);

  final AdRequestPreparer _requestPreparer;

  @override
  Future<LoadedInterstitial?> load(AdPlacement placement) async {
    try {
      final preparedRequest = await _requestPreparer.prepare(placement);
      if (preparedRequest == null) return null;

      final loadCompleter = Completer<InterstitialAd?>();
      await InterstitialAd.load(
        adUnitId: preparedRequest.unitId,
        request: preparedRequest.request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            // 시간 초과 뒤 늦게 온 광고는 쓰지 않고 해제
            if (loadCompleter.isCompleted) {
              ad.dispose();
            } else {
              loadCompleter.complete(ad);
            }
          },
          onAdFailedToLoad: (error) {
            debugPrint(
              '[ads interstitial] load failed ${placement.name} : ${error.code}',
            );
            if (!loadCompleter.isCompleted) loadCompleter.complete(null);
          },
        ),
      );
      final loadedAd = await loadCompleter.future.timeout(
        _loadTimeout,
        onTimeout: () {
          debugPrint('[ads interstitial] load timeout ${placement.name}');
          return null;
        },
      );
      if (loadedAd == null) return null;
      return LoadedInterstitial(
        loadedAt: DateTime.now(),
        show: ({required onShown, required onClosed}) =>
            _show(loadedAd, onShown: onShown, onClosed: onClosed),
        dispose: loadedAd.dispose,
      );
    } catch (error) {
      debugPrint(
        '[ads interstitial] prepare failed ${placement.name} : $error',
      );
      return null;
    }
  }

  /// 표시: 콜백 연결 > show. 닫힘·표시 실패 모두 해제 후 onClosed (성공·실패 공통)
  static void _show(
    InterstitialAd interstitialAd, {
    required VoidCallback onShown,
    required VoidCallback onClosed,
  }) {
    interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => onShown(),
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        onClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[ads interstitial] show failed : ${error.code}');
        ad.dispose();
        onClosed();
      },
    );
    unawaited(interstitialAd.show());
  }
}
