import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:passql_app/core/billing/pro_purchase_port.dart';
import 'package:passql_app/data/billing/play_purchase_service.dart';
import 'package:passql_app/data/models/billing/play_verify_request.dart';
import 'package:passql_app/data/models/member/member_plan_response.dart';
import 'package:passql_app/data/sources/billing_api.dart';

/// 결제 창을 열면 기록만 하고, 구매 갱신은 테스트가 스트림으로 넣는 가짜 스토어
class _FakeInAppPurchase implements InAppPurchase {
  final StreamController<List<PurchaseDetails>> purchaseUpdates =
      StreamController<List<PurchaseDetails>>.broadcast();
  bool? lastAutoConsume;
  final List<PurchaseDetails> completedPurchases = [];

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => purchaseUpdates.stream;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async => ProductDetailsResponse(
    productDetails: [
      ProductDetails(
        id: PlayPurchaseService.examPassProductId,
        title: '회차 패스',
        description: '',
        price: '₩9,900',
        rawPrice: 9900,
        currencyCode: 'KRW',
      ),
    ],
    notFoundIDs: const [],
  );

  @override
  Future<bool> buyConsumable({
    required PurchaseParam purchaseParam,
    bool autoConsume = true,
  }) async {
    lastAutoConsume = autoConsume;
    return true;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async =>
      completedPurchases.add(purchase);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 확인 요청을 기록하고 정해진 등급을 돌려주는 가짜 결제 API
class _FakeBillingApi implements BillingApiClient {
  final List<PlayVerifyRequest> verifyRequests = [];

  @override
  Future<MemberPlanResponse> verifyPlayPurchase(PlayVerifyRequest body) async {
    verifyRequests.add(body);
    return const MemberPlanResponse(
      isBillingEnabled: true,
      plan: MemberPlanType.pro,
    );
  }
}

PurchaseDetails _examPassPurchase(PurchaseStatus status) => PurchaseDetails(
  productID: PlayPurchaseService.examPassProductId,
  verificationData: PurchaseVerificationData(
    localVerificationData: '',
    serverVerificationData: 'purchase-token-1',
    source: 'google_play',
  ),
  transactionDate: null,
  status: status,
)..pendingCompletePurchase = true;

void main() {
  late _FakeInAppPurchase store;
  late _FakeBillingApi billingApi;
  late int planRefreshCount;
  late PlayPurchaseService service;

  setUp(() {
    store = _FakeInAppPurchase();
    billingApi = _FakeBillingApi();
    planRefreshCount = 0;
    service = PlayPurchaseService(
      store: store,
      billingApi: billingApi,
      refreshPlan: () async {
        planRefreshCount++;
        return true;
      },
    )..startListening();
  });

  tearDown(() => service.dispose());

  test(
    'purchased_verifiesWithServer_refreshesPlan_completesPurchase',
    () async {
      final outcome = service.purchaseExamPass();
      await pumpEventQueue();
      store.purchaseUpdates.add([_examPassPurchase(PurchaseStatus.purchased)]);

      expect(await outcome, ProPurchaseOutcome.success);
      // 소모는 서버 몫 > 앱은 autoConsume 끔
      expect(store.lastAutoConsume, isFalse);
      expect(
        billingApi.verifyRequests.single.purchaseToken,
        'purchase-token-1',
      );
      expect(planRefreshCount, 1);
      expect(store.completedPurchases, hasLength(1));
    },
  );

  test('pending_returnsPending_withoutServerVerification', () async {
    final outcome = service.purchaseExamPass();
    await pumpEventQueue();
    store.purchaseUpdates.add([_examPassPurchase(PurchaseStatus.pending)]);

    expect(await outcome, ProPurchaseOutcome.pending);
    expect(billingApi.verifyRequests, isEmpty);
    expect(planRefreshCount, 0);
  });
}
