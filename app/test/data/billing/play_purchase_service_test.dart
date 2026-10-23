import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:passql_app/core/billing/pro_purchase_port.dart';
import 'package:passql_app/data/billing/play_account_identifier.dart';
import 'package:passql_app/data/billing/play_purchase_service.dart';
import 'package:passql_app/data/models/member/member_plan_response.dart';

import '../../helpers/fakes/fake_billing_api.dart';

// 서버 passOptions 가 내려주는 이용권 상품 ID 2종 (테스트 고정값)
const String _threeMonthPassId = 'pro_pass_3m';
const String _oneMonthPassId = 'pro_pass_1m';

/// 스토어에 등록된 상품 {상품 ID: (표시 가격, 숫자 가격)}
const Map<String, (String, double)> _storePriceByProductId = {
  _threeMonthPassId: ('₩9,900', 9900),
  _oneMonthPassId: ('₩4,400', 4400),
};

/// 결제 창을 열면 기록만 하고, 구매 갱신은 테스트가 스트림으로 넣는 가짜 스토어
class _FakeInAppPurchase implements InAppPurchase {
  final StreamController<List<PurchaseDetails>> purchaseUpdates =
      StreamController<List<PurchaseDetails>>.broadcast();
  bool? lastAutoConsume;
  PurchaseParam? lastPurchaseParam;
  final List<PurchaseDetails> completedPurchases = [];
  final List<Set<String>> queriedProductIds = [];

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => purchaseUpdates.stream;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async {
    queriedProductIds.add(identifiers);
    return ProductDetailsResponse(
      productDetails: [
        for (final productId in identifiers)
          if (_storePriceByProductId[productId] case (final price, final raw))
            ProductDetails(
              id: productId,
              title: '이용권',
              description: '',
              price: price,
              rawPrice: raw,
              currencyCode: 'KRW',
            ),
      ],
      notFoundIDs: [
        for (final productId in identifiers)
          if (!_storePriceByProductId.containsKey(productId)) productId,
      ],
    );
  }

  @override
  Future<bool> buyConsumable({
    required PurchaseParam purchaseParam,
    bool autoConsume = true,
  }) async {
    lastAutoConsume = autoConsume;
    lastPurchaseParam = purchaseParam;
    return true;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async =>
      completedPurchases.add(purchase);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

PurchaseDetails _passPurchase(
  PurchaseStatus status, {
  String productId = _threeMonthPassId,
}) => PurchaseDetails(
  productID: productId,
  verificationData: PurchaseVerificationData(
    localVerificationData: '',
    serverVerificationData: 'purchase-token-1',
    source: 'google_play',
  ),
  transactionDate: null,
  status: status,
)..pendingCompletePurchase = true;

// 계정 대조 고정 벡터 (서버 PlayBillingServiceTest 와 같은 값): uuid 소문자 문자열 UTF-8 > SHA-256 소문자 hex 64자
const String _hashVectorMemberUuid = '123e4567-e89b-12d3-a456-426614174000';
const String _hashVectorAccountId =
    '986c0dc956dc822b5d8f698661b9eb1ef880786ff9043c16744d2a420e99e9bb';

void main() {
  late _FakeInAppPurchase store;
  late FakeBillingApi billingApi;
  late int planRefreshCount;
  // 로그인 회원 uuid (로그아웃 테스트는 null)
  String? currentMemberUuid;
  late PlayPurchaseService service;

  setUp(() {
    store = _FakeInAppPurchase();
    billingApi = FakeBillingApi();
    planRefreshCount = 0;
    currentMemberUuid = _hashVectorMemberUuid;
    service = PlayPurchaseService(
      store: store,
      billingApi: billingApi,
      readMemberUuid: () => currentMemberUuid,
      refreshPlan: () async {
        planRefreshCount++;
        return true;
      },
    )..startListening();
  });

  tearDown(() => service.dispose());

  test(
    'purchased_verifiesWithServer_completesPurchase_returnsSuccess',
    () async {
      final outcome = service.purchasePass(_threeMonthPassId);
      await pumpEventQueue();
      store.purchaseUpdates.add([_passPurchase(PurchaseStatus.purchased)]);

      expect(await outcome, ProPurchaseOutcome.success);
      // 소모는 서버 몫 > 앱은 autoConsume 끔
      expect(store.lastAutoConsume, isFalse);
      expect(
        billingApi.playVerifyRequests.single.purchaseToken,
        'purchase-token-1',
      );
      // 결제 창 성공의 등급 갱신은 시트 몫 (중복 갱신 방지)
      expect(planRefreshCount, 0);
      expect(store.completedPurchases, hasLength(1));
    },
  );

  test(
    'loadPassPrices_returnsDisplayAndRawPrice_skipsUnknown_cachesProducts',
    () async {
      final prices = await service.loadPassPrices([
        _threeMonthPassId,
        _oneMonthPassId,
        'pro_unknown',
      ]);

      expect(
        prices.keys,
        unorderedEquals([_threeMonthPassId, _oneMonthPassId]),
      );
      expect(prices[_threeMonthPassId]?.displayPrice, '₩9,900');
      expect(prices[_oneMonthPassId]?.rawPrice, 4400);
      // 이미 읽은 상품은 결제 때 다시 조회하지 않음
      unawaited(service.purchasePass(_oneMonthPassId));
      await pumpEventQueue();
      expect(store.queriedProductIds, hasLength(1));
      expect(store.lastPurchaseParam?.productDetails.id, _oneMonthPassId);
    },
  );

  test('purchased_verifiesWithPurchasedProductId', () async {
    final outcome = service.purchasePass(_oneMonthPassId);
    await pumpEventQueue();
    store.purchaseUpdates.add([
      _passPurchase(PurchaseStatus.purchased, productId: _oneMonthPassId),
    ]);

    expect(await outcome, ProPurchaseOutcome.success);
    // 서버 확인 상품 ID = 실제 구매한 상품 (앱 하드코딩 없음)
    expect(billingApi.playVerifyRequests.single.productId, _oneMonthPassId);
  });

  test('purchase_unknownProduct_returnsUnavailable', () async {
    expect(
      await service.purchasePass('pro_unknown'),
      ProPurchaseOutcome.unavailable,
    );
    expect(store.lastPurchaseParam, isNull);
  });

  test('backgroundPurchased_refreshesPlan_announcesUnlock', () async {
    final unlocks = <void>[];
    service.backgroundProUnlocks.listen(unlocks.add);

    // 결제 창 밖 (지연 결제 완료·재시작 후 전달)
    store.purchaseUpdates.add([_passPurchase(PurchaseStatus.purchased)]);
    await pumpEventQueue();

    expect(billingApi.playVerifyRequests, hasLength(1));
    expect(planRefreshCount, 1);
    expect(unlocks, hasLength(1));
  });

  test('verifyFailure_returnsPending_keepsPurchaseUncompleted', () async {
    billingApi.shouldFailVerify = true;
    final outcome = service.purchasePass(_threeMonthPassId);
    await pumpEventQueue();
    store.purchaseUpdates.add([_passPurchase(PurchaseStatus.purchased)]);

    // Play 결제는 끝남 > 대기 안내, 처리 완료 안 함 (다음 재전송에서 다시 확인)
    expect(await outcome, ProPurchaseOutcome.pending);
    expect(store.completedPurchases, isEmpty);
  });

  test('pending_returnsPending_withoutServerVerification', () async {
    final outcome = service.purchasePass(_threeMonthPassId);
    await pumpEventQueue();
    store.purchaseUpdates.add([_passPurchase(PurchaseStatus.pending)]);

    expect(await outcome, ProPurchaseOutcome.pending);
    expect(billingApi.playVerifyRequests, isEmpty);
    expect(planRefreshCount, 0);
  });

  test('toPlayObfuscatedAccountId_matchesServerFixedVector', () {
    expect(
      toPlayObfuscatedAccountId(_hashVectorMemberUuid),
      _hashVectorAccountId,
    );
  });

  test('purchase_setsHashedMemberUuidAsApplicationUserName', () async {
    unawaited(service.purchasePass(_threeMonthPassId));
    await pumpEventQueue();

    // 서버가 Play obfuscatedExternalAccountId 와 대조 (다른 계정 재전송 차단)
    expect(store.lastPurchaseParam?.applicationUserName, _hashVectorAccountId);
  });

  test('purchase_withoutMember_failsWithoutOpeningStore', () async {
    currentMemberUuid = null;

    // 회원 미확정이면 계정 값 없이 결제하지 않음 (서버 대조 우회 차단)
    expect(
      await service.purchasePass(_threeMonthPassId),
      ProPurchaseOutcome.failed,
    );
    expect(store.lastPurchaseParam, isNull);
  });

  test('memberPlanResponse_parsesPassOptions_defaultsToEmpty', () {
    final withOptions = MemberPlanResponse.fromJson({
      'isBillingEnabled': true,
      'plan': 'FREE',
      'passOptions': [
        {
          'productId': _threeMonthPassId,
          'durationDays': 90,
          'expiresAtIfPurchased': '2026-01-21T12:00:00',
        },
      ],
    });
    final withoutOptions = MemberPlanResponse.fromJson({'plan': 'FREE'});

    expect(withOptions.passOptions.single.productId, _threeMonthPassId);
    expect(withOptions.passOptions.single.durationDays, 90);
    expect(
      withOptions.passOptions.single.expiresAtIfPurchased,
      DateTime(2026, 1, 21, 12),
    );
    expect(withoutOptions.passOptions, isEmpty);
  });

  test('memberPlanResponse_parsesLastPurchase_defaultsToNull', () {
    final purchased = MemberPlanResponse.fromJson({
      'isBillingEnabled': true,
      'plan': 'PRO',
      'lastPurchasedAt': '2026-10-20T14:30:00',
      'lastOrderId': 'GPA.0001',
    });
    final adminGrantOnly = MemberPlanResponse.fromJson({
      'isBillingEnabled': true,
      'plan': 'PRO',
      'lastPurchasedAt': null,
      'lastOrderId': null,
    });

    expect(purchased.lastPurchasedAt, DateTime(2026, 10, 20, 14, 30));
    expect(purchased.lastOrderId, 'GPA.0001');
    expect(adminGrantOnly.lastPurchasedAt, isNull);
    expect(adminGrantOnly.lastOrderId, isNull);
  });
}
