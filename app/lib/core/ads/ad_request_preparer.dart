import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_consent.dart';
import 'ad_placement.dart';
import 'ad_sdk.dart';

/// 광고 요청 준비 결과: 단위 ID + 요청
class PreparedAdRequest {
  const PreparedAdRequest({required this.unitId, required this.request});

  final String unitId;
  final AdRequest request;
}

/// 광고 로더 3종(배너·네이티브·전면) 공통 준비: 단위 ID 확인 > SDK 초기화 > 개인화 동의 확인 > AdRequest
/// AdRequest 는 여기서만 만듦 (요청 내용 정책 한 곳)
class AdRequestPreparer {
  AdRequestPreparer({
    required AdConsent consent,
    String? Function(AdPlacement placement)? resolveUnitId,
    Future<void> Function()? initializeSdk,
  }) : _consent = consent,
       _resolveUnitId = resolveUnitId ?? _deviceUnitIdOf,
       _initializeSdk = initializeSdk ?? AdSdk.ensureInitialized;

  final AdConsent _consent;
  final String? Function(AdPlacement placement) _resolveUnitId;
  final Future<void> Function() _initializeSdk;

  /// 요청 준비. 단위 ID 없으면(릴리스인데 .env 비어 있음) null > 광고 없음. SDK·동의 실패는 예외 그대로
  Future<PreparedAdRequest?> prepare(AdPlacement placement) async {
    final unitId = _resolveUnitId(placement);
    if (unitId == null) return null;

    await _initializeSdk();
    final isNonPersonalized = await _consent.shouldUseNonPersonalizedAds();
    return PreparedAdRequest(
      unitId: unitId,
      // 요청에는 비개인화 여부만 (회원·학습 정보 미전달)
      request: AdRequest(nonPersonalizedAds: isNonPersonalized),
    );
  }

  static String? _deviceUnitIdOf(AdPlacement placement) =>
      AdUnitIds.unitIdFor(placement, isIos: Platform.isIOS);
}

final adRequestPreparerProvider = Provider<AdRequestPreparer>(
  (ref) => AdRequestPreparer(consent: ref.watch(adConsentProvider)),
);
