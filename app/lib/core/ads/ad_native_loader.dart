import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_placement.dart';
import 'ad_request_preparer.dart';
import 'loaded_ad_view.dart';
import 'native_ad_loading.dart';

/// 네이티브 광고 카드 모양 (화면 디자인 토큰 > 네이티브 팩토리). 라이트·다크마다 슬롯이 채움
/// 네이티브 쪽(Android PassqlNativeAdFactory.kt · iOS PassqlNativeAdFactory.swift)은 값을 갖지 않고 이것만 읽음
class NativeAdCardStyle {
  const NativeAdCardStyle({
    required this.backgroundColor,
    required this.headlineColor,
    required this.bodyColor,
    required this.mediaBackgroundColor,
    required this.callToActionBackgroundColor,
    required this.callToActionTextColor,
    required this.mediaCornerRadius,
    required this.callToActionCornerRadius,
    required this.callToActionHeight,
    required this.callToActionHorizontalPadding,
    required this.contentGap,
    required this.headlineFontSize,
    required this.bodyFontSize,
    required this.callToActionFontSize,
  });

  final Color backgroundColor;
  final Color headlineColor;
  final Color bodyColor;

  /// 미디어 여백(비율 맞춤으로 남는 칸) 배경
  final Color mediaBackgroundColor;
  final Color callToActionBackgroundColor;
  final Color callToActionTextColor;
  final double mediaCornerRadius;
  final double callToActionCornerRadius;
  final double callToActionHeight;
  final double callToActionHorizontalPadding;

  /// 미디어 <-> 글자 묶음 가로 간격
  final double contentGap;
  final double headlineFontSize;
  final double bodyFontSize;
  final double callToActionFontSize;

  /// 팩토리 customOptions (색은 ARGB 정수, 크기는 dp/pt)
  /// 키 이름은 두 팩토리와 같이 바꿀 것
  Map<String, Object> toCustomOptions({required double mediaSize}) => {
    'backgroundColor': backgroundColor.toARGB32(),
    'headlineColor': headlineColor.toARGB32(),
    'bodyColor': bodyColor.toARGB32(),
    'mediaBackgroundColor': mediaBackgroundColor.toARGB32(),
    'callToActionBackgroundColor': callToActionBackgroundColor.toARGB32(),
    'callToActionTextColor': callToActionTextColor.toARGB32(),
    'mediaSize': mediaSize,
    'mediaCornerRadius': mediaCornerRadius,
    'callToActionCornerRadius': callToActionCornerRadius,
    'callToActionHeight': callToActionHeight,
    'callToActionHorizontalPadding': callToActionHorizontalPadding,
    'contentGap': contentGap,
    'headlineFontSize': headlineFontSize,
    'bodyFontSize': bodyFontSize,
    'callToActionFontSize': callToActionFontSize,
  };
}

/// 네이티브 로더 포트. 테스트는 가짜로 바꿔 SDK 를 띄우지 않음
abstract interface class AdNativeLoader {
  /// 실패·미설정·시간 초과면 null (예외 없음)
  Future<LoadedAdView?> load(
    AdPlacement placement,
    int widthDp,
    NativeAdCardStyle style,
  );
}

final adNativeLoaderProvider = Provider<AdNativeLoader>(
  (ref) => GoogleAdNativeLoader(ref.watch(adRequestPreparerProvider)),
);

/// google_mobile_ads 네이티브: 앱 팩토리(미디어 왼쪽·글자 오른쪽 카드)가 광고 에셋을 그림
/// 팩토리 등록: Android MainActivity.configureFlutterEngine, iOS AppDelegate
class GoogleAdNativeLoader implements AdNativeLoader {
  GoogleAdNativeLoader(this._requestPreparer);

  /// 두 팩토리가 등록한 이름 (MainActivity.kt · AppDelegate.swift 와 같게)
  static const factoryId = 'passqlNativeCard';

  /// 미디어 뷰 한 변 (AdMob 최소 120x120, 영상 광고 재생 조건). 카드 본문 높이도 이 값
  static const double mediaSize = 120;

  /// 카드 본문 높이 (미디어 높이와 같음, 글자 묶음은 그 안에 맞춤)
  static const double contentHeight = mediaSize;

  // 이 시간 안에 안 오면 포기 > 슬롯은 항목 없음
  static const _loadTimeout = Duration(seconds: 20);

  final AdRequestPreparer _requestPreparer;

  @override
  Future<LoadedAdView?> load(
    AdPlacement placement,
    int widthDp,
    NativeAdCardStyle style,
  ) async {
    if (widthDp <= 0) return null;
    final loadedAd = await loadNativeAdOrNull(
      requestPreparer: _requestPreparer,
      placement: placement,
      loadTimeout: _loadTimeout,
      buildNativeAd: (preparedRequest, listener) => NativeAd(
        adUnitId: preparedRequest.unitId,
        factoryId: factoryId,
        customOptions: style.toCustomOptions(mediaSize: mediaSize),
        request: preparedRequest.request,
        // 정사각 미디어 칸 > 가로·세로 어느 쪽이든 받되 잘라내지 않고 맞춤 (팩토리 aspect fit)
        // AdChoices 아이콘은 미디어 쪽(왼쪽 위) > 오른쪽 제목 글자를 가리지 않음
        nativeAdOptions: NativeAdOptions(
          mediaAspectRatio: MediaAspectRatio.any,
          adChoicesPlacement: AdChoicesPlacement.topLeftCorner,
        ),
        listener: listener,
      ),
    );
    if (loadedAd == null) return null;
    return LoadedAdView(
      height: contentHeight,
      view: SizedBox(
        height: contentHeight,
        child: AdWidget(ad: loadedAd),
      ),
      dispose: loadedAd.dispose,
    );
  }
}
