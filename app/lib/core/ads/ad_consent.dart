import 'dart:async';
import 'dart:io' show Platform;

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// 광고 개인화 여부: iOS 추적 허용(ATT) 질문 1회, 허용 아니면 비개인화 요청
/// 질문은 앱 시작 첫 프레임 뒤(requestOnLaunch). 광고 요청에만 묶으면 광고가 안 뜨는 경로의 심사관이 못 봄 (심사 2.1)
/// Android 는 ATT 없음 > 개인화 기본. 국내 대상이라 EU 동의(UMP) 흐름 없음
abstract final class AdConsent {
  // 앱 활성화 뒤 팝업까지 두는 여유
  static const _settleDelay = Duration(milliseconds: 500);
  // 앱 활성화 대기 최대 시간 (넘기면 그대로 요청)
  static const _activeWaitTimeout = Duration(seconds: 10);

  // 시작 요청 <-> 광고 로더 동시 호출 시 팝업 1회만 (진행 중 요청 공유)
  static Future<TrackingStatus?>? _inFlightRequest;

  @visibleForTesting
  static bool Function() isIos = _isIosPlatform;

  @visibleForTesting
  static Future<TrackingStatus> Function() readStatus = _readTrackingStatus;

  @visibleForTesting
  static Future<TrackingStatus> Function() requestAuthorization =
      _requestTrackingAuthorization;

  @visibleForTesting
  static Future<void> Function() waitUntilActive = _waitUntilResumed;

  @visibleForTesting
  static Duration settleDelay = _settleDelay;

  @visibleForTesting
  static void resetForTest() {
    _inFlightRequest = null;
    isIos = _isIosPlatform;
    readStatus = _readTrackingStatus;
    requestAuthorization = _requestTrackingAuthorization;
    waitUntilActive = _waitUntilResumed;
    settleDelay = _settleDelay;
  }

  /// 앱 시작 직후 추적 허용 1회 질문 (이미 답한 기기는 묻지 않음, 실패해도 앱 진행)
  static Future<void> requestOnLaunch() async {
    await _resolveStatus();
  }

  /// true > 비개인화 광고로 요청 (iOS 미허용·상태 모름)
  static Future<bool> shouldUseNonPersonalizedAds() async {
    if (!isIos()) return false;
    final status = await _resolveStatus();
    return status != TrackingStatus.authorized;
  }

  static Future<TrackingStatus?> _resolveStatus() {
    if (!isIos()) return Future.value();
    return _inFlightRequest ??= _askTrackingStatus().whenComplete(() {
      // 답을 받으면 OS 가 기억 > 다음 호출은 상태 조회만. 실패 시 다음 요청에서 재시도
      _inFlightRequest = null;
    });
  }

  static Future<TrackingStatus?> _askTrackingStatus() async {
    try {
      var status = await readStatus();
      if (status == TrackingStatus.notDetermined) {
        // 앱이 완전히 활성화되기 전 요청 > iOS 가 팝업을 조용히 무시
        await waitUntilActive();
        await Future<void>.delayed(settleDelay);
        status = await requestAuthorization();
      }
      return status;
    } catch (error) {
      debugPrint('[ads consent] tracking request failed : $error');
      return null;
    }
  }

  static bool _isIosPlatform() => !kIsWeb && Platform.isIOS;

  static Future<TrackingStatus> _readTrackingStatus() =>
      AppTrackingTransparency.trackingAuthorizationStatus;

  static Future<TrackingStatus> _requestTrackingAuthorization() =>
      AppTrackingTransparency.requestTrackingAuthorization();

  static Future<void> _waitUntilResumed() async {
    final lifecycleState = WidgetsBinding.instance.lifecycleState;
    // 첫 프레임 직후(null)는 활성으로 봄
    if (lifecycleState == null || lifecycleState == AppLifecycleState.resumed) {
      return;
    }
    final resumed = Completer<void>();
    final listener = AppLifecycleListener(
      onResume: () {
        if (!resumed.isCompleted) resumed.complete();
      },
    );
    try {
      await resumed.future.timeout(_activeWaitTimeout, onTimeout: () {});
    } finally {
      listener.dispose();
    }
  }
}
