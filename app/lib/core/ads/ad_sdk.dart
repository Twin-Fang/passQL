import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 광고를 띄울 수 있는 플랫폼인지 (Android·iOS 만. 웹·호스트 테스트는 false)
bool get isAdSupportedPlatform =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS);

/// 플랫폼 지원 여부. 테스트는 이것을 바꿔 광고 경로를 켠다
final adSupportedPlatformProvider = Provider<bool>(
  (_) => isAdSupportedPlatform,
);

/// 광고 SDK 초기화 공통 지점: 배너·네이티브·전면이 함께 사용
/// 첫 광고 요청 때 1회만 > 실패 시 캐시 비움 (다음 요청에서 재시도)
abstract final class AdSdk {
  static Future<void>? _initialization;

  static Future<void> ensureInitialized() => _initialization ??= () async {
    try {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          // 학습 앱이라 성인·선정 광고 차단 (전 연령 학생 사용)
          maxAdContentRating: MaxAdContentRating.pg,
        ),
      );
      await MobileAds.instance.initialize();
    } catch (_) {
      _initialization = null;
      rethrow;
    }
  }();
}
