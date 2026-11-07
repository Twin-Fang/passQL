import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../logging/app_logger.dart';
import 'full_screen_ad_guard.dart';

/// 전체 화면 광고 표시 공통 (전면·앱 오프닝·보상형, #814): 콜백 연결 > show
/// 끝나는 경로 3개(닫힘, 표시 실패 콜백, show 예외) 모두 1회만 해제 후 [onClosed] (성공·실패 공통)
/// show 예외는 콜백이 오지 않아 처리하지 않으면 표시 중 표시가 남아 세션 내내 광고가 막힘
void showFullScreenAd<T extends Ad>({
  required T ad,
  required String logLabel,
  required void Function(FullScreenContentCallback<T> callback) attachCallback,
  required Future<void> Function() show,
  required VoidCallback onShown,
  required VoidCallback onClosed,
}) {
  var isClosed = false;
  void closeOnce() {
    if (isClosed) return;
    isClosed = true;
    ad.dispose();
    onClosed();
  }

  attachCallback(
    FullScreenContentCallback<T>(
      onAdShowedFullScreenContent: (_) => onShown(),
      onAdClicked: (_) => FullScreenAdGuard.recordAdClicked(),
      onAdDismissedFullScreenContent: (_) => closeOnce(),
      onAdFailedToShowFullScreenContent: (_, error) {
        AppLogger.warn('ads $logLabel', 'show failed : ${error.code}');
        closeOnce();
      },
    ),
  );
  unawaited(
    show().catchError((Object error) {
      AppLogger.warn('ads $logLabel', 'show threw : $error');
      closeOnce();
    }),
  );
}
