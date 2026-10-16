import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/ads/ad_consent.dart';

/// iOS 추적 허용(ATT): 앱 시작 시 1회, 동시 호출 공유, 실패해도 비개인화로 진행
void main() {
  late int requestCount;
  late TrackingStatus currentStatus;

  setUp(() {
    requestCount = 0;
    currentStatus = TrackingStatus.notDetermined;
    AdConsent.isIos = () => true;
    AdConsent.readStatus = () async => currentStatus;
    AdConsent.requestAuthorization = () async {
      requestCount++;
      currentStatus = TrackingStatus.authorized;
      return currentStatus;
    };
    AdConsent.waitUntilActive = () async {};
    AdConsent.settleDelay = Duration.zero;
  });

  tearDown(AdConsent.resetForTest);

  test('이미 답한 기기에서는 다시 묻지 않는다', () async {
    currentStatus = TrackingStatus.denied;
    await AdConsent.requestOnLaunch();
    expect(requestCount, 0);
    expect(await AdConsent.shouldUseNonPersonalizedAds(), isTrue);
  });

  test('시작 요청과 광고 로더가 동시에 불러도 팝업은 한 번만 요청한다', () async {
    final results = await Future.wait([
      AdConsent.requestOnLaunch().then((_) => false),
      AdConsent.shouldUseNonPersonalizedAds(),
      AdConsent.shouldUseNonPersonalizedAds(),
    ]);
    expect(requestCount, 1);
    // 허용 > 개인화 요청 (비개인화 false)
    expect(results[1], isFalse);
    expect(results[2], isFalse);
  });

  test('요청이 예외를 내도 앱은 진행하고 광고는 비개인화로 간다', () async {
    AdConsent.requestAuthorization = () async => throw StateError('ATT');
    await AdConsent.requestOnLaunch();
    expect(await AdConsent.shouldUseNonPersonalizedAds(), isTrue);
  });

  test('Android 는 묻지 않고 개인화로 요청한다', () async {
    AdConsent.isIos = () => false;
    await AdConsent.requestOnLaunch();
    expect(requestCount, 0);
    expect(await AdConsent.shouldUseNonPersonalizedAds(), isFalse);
  });
}
