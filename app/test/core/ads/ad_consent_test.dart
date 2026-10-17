import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/ads/ad_consent.dart';

/// 상태·요청 횟수를 기억하는 가짜 ATT (요청하면 허용으로 바뀜)
class _FakeTrackingPlatform implements TrackingAuthorizationPlatform {
  _FakeTrackingPlatform({this.isIos = true});

  @override
  final bool isIos;

  TrackingStatus currentStatus = TrackingStatus.notDetermined;
  int requestCount = 0;
  Object? requestError;

  @override
  Future<TrackingStatus> readStatus() async => currentStatus;

  @override
  Future<TrackingStatus> requestAuthorization() async {
    requestCount++;
    final error = requestError;
    if (error != null) throw error;
    currentStatus = TrackingStatus.authorized;
    return currentStatus;
  }

  @override
  Future<void> waitUntilActive() async {}
}

/// iOS 추적 허용(ATT): 앱 시작 시 1회, 동시 호출 공유, 실패해도 비개인화로 진행
void main() {
  late _FakeTrackingPlatform platform;
  late AdConsent consent;

  setUp(() {
    platform = _FakeTrackingPlatform();
    consent = AdConsent(platform, settleDelay: Duration.zero);
  });

  test('이미 답한 기기에서는 다시 묻지 않는다', () async {
    platform.currentStatus = TrackingStatus.denied;
    await consent.requestOnLaunch();
    expect(platform.requestCount, 0);
    expect(await consent.shouldUseNonPersonalizedAds(), isTrue);
  });

  test('시작 요청과 광고 로더가 동시에 불러도 팝업은 한 번만 요청한다', () async {
    final results = await Future.wait([
      consent.requestOnLaunch().then((_) => false),
      consent.shouldUseNonPersonalizedAds(),
      consent.shouldUseNonPersonalizedAds(),
    ]);
    expect(platform.requestCount, 1);
    // 허용 > 개인화 요청 (비개인화 false)
    expect(results[1], isFalse);
    expect(results[2], isFalse);
  });

  test('요청이 예외를 내도 앱은 진행하고 광고는 비개인화로 간다', () async {
    platform.requestError = StateError('ATT');
    await consent.requestOnLaunch();
    expect(await consent.shouldUseNonPersonalizedAds(), isTrue);
  });

  test('Android 는 묻지 않고 개인화로 요청한다', () async {
    platform = _FakeTrackingPlatform(isIos: false);
    consent = AdConsent(platform, settleDelay: Duration.zero);
    await consent.requestOnLaunch();
    expect(platform.requestCount, 0);
    expect(await consent.shouldUseNonPersonalizedAds(), isFalse);
  });
}
