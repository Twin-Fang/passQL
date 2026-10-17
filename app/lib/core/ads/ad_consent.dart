import 'dart:async';
import 'dart:io' show Platform;

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 추적 허용(ATT) 기기 접근 포트 4개: 플랫폼 확인, 상태 조회, 허용 요청, 앱 활성 대기
/// 테스트는 가짜로 바꿔 SDK·OS 팝업을 띄우지 않음
abstract interface class TrackingAuthorizationPlatform {
  bool get isIos;
  Future<TrackingStatus> readStatus();
  Future<TrackingStatus> requestAuthorization();
  Future<void> waitUntilActive();
}

/// 실제 기기 ATT (app_tracking_transparency + 앱 생명주기)
class DeviceTrackingAuthorizationPlatform
    implements TrackingAuthorizationPlatform {
  const DeviceTrackingAuthorizationPlatform();

  // 앱 활성화 대기 최대 시간 (넘기면 그대로 요청)
  static const _activeWaitTimeout = Duration(seconds: 10);

  @override
  bool get isIos => !kIsWeb && Platform.isIOS;

  @override
  Future<TrackingStatus> readStatus() =>
      AppTrackingTransparency.trackingAuthorizationStatus;

  @override
  Future<TrackingStatus> requestAuthorization() =>
      AppTrackingTransparency.requestTrackingAuthorization();

  @override
  Future<void> waitUntilActive() async {
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

/// 광고 개인화 여부: iOS 추적 허용(ATT) 질문 1회, 허용 아니면 비개인화 요청
/// 질문은 앱 시작 첫 프레임 뒤(requestOnLaunch). 광고 요청에만 묶으면 광고가 안 뜨는 경로의 심사관이 못 봄 (심사 2.1)
/// Android 는 ATT 없음 > 개인화 기본. 국내 대상이라 EU 동의(UMP) 흐름 없음
class AdConsent {
  AdConsent(this._platform, {this.settleDelay = defaultSettleDelay});

  /// 앱 활성화 뒤 팝업까지 두는 여유
  static const defaultSettleDelay = Duration(milliseconds: 500);

  final TrackingAuthorizationPlatform _platform;
  final Duration settleDelay;

  // 시작 요청 <-> 광고 로더 동시 호출 시 팝업 1회만 (진행 중 요청 공유)
  Future<TrackingStatus?>? _inFlightRequest;

  /// 앱 시작 직후 추적 허용 1회 질문 (이미 답한 기기는 묻지 않음, 실패해도 앱 진행)
  Future<void> requestOnLaunch() async {
    await _resolveStatus();
  }

  /// true > 비개인화 광고로 요청 (iOS 미허용·상태 모름)
  Future<bool> shouldUseNonPersonalizedAds() async {
    if (!_platform.isIos) return false;
    final status = await _resolveStatus();
    return status != TrackingStatus.authorized;
  }

  Future<TrackingStatus?> _resolveStatus() {
    if (!_platform.isIos) return Future.value();
    return _inFlightRequest ??= _askTrackingStatus().whenComplete(() {
      // 답을 받으면 OS 가 기억 > 다음 호출은 상태 조회만. 실패 시 다음 요청에서 재시도
      _inFlightRequest = null;
    });
  }

  Future<TrackingStatus?> _askTrackingStatus() async {
    try {
      var status = await _platform.readStatus();
      if (status == TrackingStatus.notDetermined) {
        // 앱이 완전히 활성화되기 전 요청 > iOS 가 팝업을 조용히 무시
        await _platform.waitUntilActive();
        await Future<void>.delayed(settleDelay);
        status = await _platform.requestAuthorization();
      }
      return status;
    } catch (error) {
      debugPrint('[ads consent] tracking request failed : $error');
      return null;
    }
  }
}

/// 앱 전체에서 하나 (시작 질문과 광고 로더가 진행 중 요청을 공유)
final adConsentProvider = Provider<AdConsent>(
  (_) => AdConsent(const DeviceTrackingAuthorizationPlatform()),
);
