import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_placement.dart';
import 'ad_request_preparer.dart';
import 'loaded_ad_view.dart';
import 'native_ad_loading.dart';

/// 한 줄 띠 색 5종 + 배지 문구 (화면 테마 > 네이티브 팩토리). 라이트·다크마다 슬롯이 채움
class NativeAdStripStyle {
  const NativeAdStripStyle({
    required this.background,
    required this.headlineText,
    required this.callToActionText,
    required this.badgeBackground,
    required this.badgeText,
    required this.badgeLabel,
  });

  final Color background;
  final Color headlineText;
  // 행동 문구와 > 화살표 공통
  final Color callToActionText;
  final Color badgeBackground;
  final Color badgeText;
  // 광고 표시 배지 문구 (정책상 필수)
  final String badgeLabel;
}

/// 한 줄 띠 네이티브 로더 포트. 테스트는 가짜로 바꿔 SDK 를 띄우지 않음
abstract interface class AdNativeStripLoader {
  /// 실패·미설정·시간 초과면 null (예외 없음)
  Future<LoadedAdView?> load(
    AdPlacement placement,
    double heightDp,
    NativeAdStripStyle style,
  );
}

final adNativeStripLoaderProvider = Provider<AdNativeStripLoader>(
  (ref) => GoogleAdNativeStripLoader(ref.watch(adRequestPreparerProvider)),
);

/// google_mobile_ads 네이티브 + 앱 팩토리 'passqlStrip' (Android·iOS 네이티브 레이아웃이 에셋을 그대로 그림)
class GoogleAdNativeStripLoader implements AdNativeStripLoader {
  GoogleAdNativeStripLoader(this._requestPreparer);

  // MainActivity.kt·AppDelegate.swift 의 등록 ID 와 같은 값
  static const factoryId = 'passqlStrip';

  // customOptions 키: PassqlStripNativeAdFactory.kt·.swift 와 같은 값
  static const backgroundColorKey = 'backgroundColor';
  static const headlineColorKey = 'headlineColor';
  static const callToActionColorKey = 'callToActionColor';
  static const badgeBackgroundColorKey = 'badgeBackgroundColor';
  static const badgeTextColorKey = 'badgeTextColor';
  static const badgeLabelKey = 'badgeLabel';

  // 이 시간 안에 안 오면 포기 > 띠 없음
  static const _loadTimeout = Duration(seconds: 20);

  final AdRequestPreparer _requestPreparer;

  @override
  Future<LoadedAdView?> load(
    AdPlacement placement,
    double heightDp,
    NativeAdStripStyle style,
  ) async {
    final loadedAd = await loadNativeAdOrNull(
      requestPreparer: _requestPreparer,
      placement: placement,
      loadTimeout: _loadTimeout,
      buildNativeAd: (preparedRequest, listener) => NativeAd(
        adUnitId: preparedRequest.unitId,
        request: preparedRequest.request,
        factoryId: factoryId,
        customOptions: customOptionsOf(style),
        listener: listener,
      ),
    );
    if (loadedAd == null) return null;
    return LoadedAdView(
      height: heightDp,
      view: SizedBox(
        height: heightDp,
        child: AdWidget(ad: loadedAd),
      ),
      dispose: loadedAd.dispose,
    );
  }

  /// 띠 스타일 > 팩토리 옵션 (색은 ARGB 정수)
  static Map<String, Object> customOptionsOf(NativeAdStripStyle style) => {
    backgroundColorKey: style.background.toARGB32(),
    headlineColorKey: style.headlineText.toARGB32(),
    callToActionColorKey: style.callToActionText.toARGB32(),
    badgeBackgroundColorKey: style.badgeBackground.toARGB32(),
    badgeTextColorKey: style.badgeText.toARGB32(),
    badgeLabelKey: style.badgeLabel,
  };
}
