import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/ads/ad_consent.dart';
import 'package:passql_app/core/ads/ad_placement.dart';
import 'package:passql_app/core/ads/ad_request_preparer.dart';

/// 고정 상태 가짜 ATT (호출 순서 기록용 콜백)
class _FixedTrackingPlatform implements TrackingAuthorizationPlatform {
  _FixedTrackingPlatform(this.status, {required this.onRead});

  final TrackingStatus status;
  final void Function() onRead;

  @override
  bool get isIos => true;

  @override
  Future<TrackingStatus> readStatus() async {
    onRead();
    return status;
  }

  @override
  Future<TrackingStatus> requestAuthorization() async => status;

  @override
  Future<void> waitUntilActive() async {}
}

/// 광고 로더 3종 공통 준비: 단위 ID > SDK 초기화 > 동의 확인 > AdRequest
void main() {
  late List<String> callOrder;

  AdRequestPreparer preparerWith({
    required String? unitId,
    TrackingStatus status = TrackingStatus.authorized,
    Object? sdkError,
  }) {
    final consent = AdConsent(
      _FixedTrackingPlatform(status, onRead: () => callOrder.add('consent')),
      settleDelay: Duration.zero,
    );
    return AdRequestPreparer(
      consent: consent,
      resolveUnitId: (_) {
        callOrder.add('unitId');
        return unitId;
      },
      initializeSdk: () async {
        callOrder.add('sdk');
        final error = sdkError;
        if (error != null) throw error;
      },
    );
  }

  setUp(() => callOrder = []);

  test('단위 ID 가 없으면 SDK 를 띄우지 않고 null (광고 없음)', () async {
    final prepared = await preparerWith(
      unitId: null,
    ).prepare(AdPlacement.nativeStrip);

    expect(prepared, isNull);
    expect(callOrder, ['unitId']);
  });

  test('단위 ID > SDK 초기화 > 동의 확인 순서로 준비한다', () async {
    final prepared = await preparerWith(
      unitId: 'unit-1',
    ).prepare(AdPlacement.nativeQuestions);

    expect(callOrder, ['unitId', 'sdk', 'consent']);
    expect(prepared!.unitId, 'unit-1');
  });

  test('추적 허용이면 개인화, 거부면 비개인화 요청', () async {
    final authorized = await preparerWith(
      unitId: 'unit-1',
    ).prepare(AdPlacement.interstitialResult);
    final denied = await preparerWith(
      unitId: 'unit-1',
      status: TrackingStatus.denied,
    ).prepare(AdPlacement.interstitialResult);

    expect(authorized!.request.nonPersonalizedAds, isFalse);
    expect(denied!.request.nonPersonalizedAds, isTrue);
  });

  test('요청에는 사용자 정보를 싣지 않는다', () async {
    final prepared = await preparerWith(
      unitId: 'unit-1',
    ).prepare(AdPlacement.nativeStrip);

    expect(prepared!.request.keywords, isNull);
    expect(prepared.request.contentUrl, isNull);
    expect(prepared.request.neighboringContentUrls, isNull);
  });

  test('SDK 초기화 실패는 예외 그대로 (로더가 잡아 null 처리)', () async {
    final preparer = preparerWith(
      unitId: 'unit-1',
      sdkError: StateError('sdk'),
    );

    await expectLater(
      preparer.prepare(AdPlacement.nativeStrip),
      throwsStateError,
    );
    expect(callOrder, ['unitId', 'sdk']);
  });
}
