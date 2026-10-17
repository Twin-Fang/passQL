import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_placement.dart';
import 'ad_request_preparer.dart';
import 'loaded_ad_view.dart';
import 'native_ad_loading.dart';

/// 네이티브 템플릿 색 6종 (화면 테마 > SDK 템플릿). 라이트·다크마다 슬롯이 채움
class NativeAdPalette {
  const NativeAdPalette({
    required this.background,
    required this.primaryText,
    required this.secondaryText,
    required this.tertiaryText,
    required this.callToActionBackground,
    required this.callToActionText,
  });

  final Color background;
  final Color primaryText;
  final Color secondaryText;
  final Color tertiaryText;
  final Color callToActionBackground;
  final Color callToActionText;
}

/// 네이티브 로더 포트. 테스트는 가짜로 바꿔 SDK 를 띄우지 않음
abstract interface class AdNativeLoader {
  /// 실패·미설정·시간 초과면 null (예외 없음)
  Future<LoadedAdView?> load(
    AdPlacement placement,
    int widthDp,
    NativeAdPalette palette,
  );
}

final adNativeLoaderProvider = Provider<AdNativeLoader>(
  (ref) => GoogleAdNativeLoader(ref.watch(adRequestPreparerProvider)),
);

/// google_mobile_ads 네이티브: SDK small 템플릿이 광고 에셋을 그림 (앱이 에셋을 가공하지 않음, 정책)
class GoogleAdNativeLoader implements AdNativeLoader {
  GoogleAdNativeLoader(this._requestPreparer);

  /// small 템플릿 높이 (이보다 작으면 잘림)
  static const double templateHeight = 100;

  // 이 시간 안에 안 오면 포기 > 슬롯은 항목 없음
  static const _loadTimeout = Duration(seconds: 20);

  final AdRequestPreparer _requestPreparer;

  @override
  Future<LoadedAdView?> load(
    AdPlacement placement,
    int widthDp,
    NativeAdPalette palette,
  ) async {
    if (widthDp <= 0) return null;
    final loadedAd = await loadNativeAdOrNull(
      requestPreparer: _requestPreparer,
      placement: placement,
      loadTimeout: _loadTimeout,
      buildNativeAd: (preparedRequest, listener) => NativeAd(
        adUnitId: preparedRequest.unitId,
        request: preparedRequest.request,
        nativeTemplateStyle: _templateStyleOf(palette),
        listener: listener,
      ),
    );
    if (loadedAd == null) return null;
    return LoadedAdView(
      height: templateHeight,
      view: SizedBox(
        height: templateHeight,
        child: AdWidget(ad: loadedAd),
      ),
      dispose: loadedAd.dispose,
    );
  }

  /// 앱 색 > small 템플릿 스타일 (글자 크기·글꼴은 SDK 기본)
  static NativeTemplateStyle _templateStyleOf(NativeAdPalette palette) =>
      NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: palette.background,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: palette.callToActionText,
          backgroundColor: palette.callToActionBackground,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: palette.primaryText,
          backgroundColor: palette.background,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: palette.secondaryText,
          backgroundColor: palette.background,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: palette.tertiaryText,
          backgroundColor: palette.background,
        ),
      );
}
