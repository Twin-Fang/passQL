import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:passql_app/core/billing/pro_purchase_port.dart';
import 'package:passql_app/data/billing/app_store_purchase_service.dart';

import '../../helpers/fakes/fake_billing_api.dart';

// 서버 passOptions 가 내려주는 이용권 상품 ID 2종 (테스트 고정값)
const String _threeMonthPassId = 'pro_pass_3m';
const String _oneMonthPassId = 'pro_pass_1m';
const String _memberUuid = '123E4567-E89B-12D3-A456-426614174000';

/// 결제 창을 열면 기록만 하고, 구매 갱신은 테스트가 스트림으로 넣는 가짜 App Store
class _FakeAppStore implements InAppPurchase {
  final StreamController<List<PurchaseDetails>> purchaseUpdates =
      StreamController<List<PurchaseDetails>>.broadcast();
  PurchaseParam? lastPurchaseParam;
  final List<PurchaseDetails> completedPurchases = [];

  /// 결제 창 열기 실패 (네이티브 PlatformException)
  Object? purchaseLaunchError;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => purchaseUpdates.stream;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async => ProductDetailsResponse(
    productDetails: [
      for (final productId in identifiers)
        ProductDetails(
          id: productId,
          title: '이용권',
          description: '',
          price: '₩9,900',
          rawPrice: 9900,
          currencyCode: 'KRW',
        ),
    ],
    notFoundIDs: const [],
  );

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    lastPurchaseParam = purchaseParam;
    final launchError = purchaseLaunchError;
    if (launchError != null) throw launchError;
    return true;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async =>
      completedPurchases.add(purchase);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// StoreKit 2 거래 1건 (스트림·미완료 조회 공통 형태). 대기·취소는 거래 ID 없음
SK2PurchaseDetails _transaction(
  PurchaseStatus status, {
  String productId = _threeMonthPassId,
  String? transactionId = '2000000001',
}) => SK2PurchaseDetails(
  productID: productId,
  purchaseID: transactionId,
  verificationData: PurchaseVerificationData(
    localVerificationData: '',
    serverVerificationData: 'signed-transaction-jws',
    source: kIAPSource,
  ),
  transactionDate: null,
  status: status,
);

void main() {
  late _FakeAppStore store;
  late FakeBillingApi billingApi;
  late int planRefreshCount;
  late List<PurchaseDetails> unfinishedTransactions;
  late AppStorePurchaseService service;

  setUp(() {
    store = _FakeAppStore();
    billingApi = FakeBillingApi();
    planRefreshCount = 0;
    unfinishedTransactions = [];
    service = AppStorePurchaseService(
      store: store,
      billingApi: billingApi,
      readMemberUuid: () => _memberUuid,
      refreshPlan: () async {
        planRefreshCount++;
        return true;
      },
      loadUnfinishedTransactions: () async => unfinishedTransactions,
    )..startListening();
  });

  tearDown(() => service.dispose());

  test('purchased_sendsSignedTransactionToServer_thenCompletes', () async {
    final outcome = service.purchasePass(_oneMonthPassId);
    await pumpEventQueue();
    store.purchaseUpdates.add([
      _transaction(PurchaseStatus.purchased, productId: _oneMonthPassId),
    ]);

    expect(await outcome, ProPurchaseOutcome.success);
    final request = billingApi.appStoreVerifyRequests.single;
    expect(request.productId, _oneMonthPassId);
    expect(request.signedTransaction, 'signed-transaction-jws');
    expect(billingApi.playVerifyRequests, isEmpty);
    expect(store.completedPurchases, hasLength(1));
  });

  test('purchase_setsMemberUuidAsAppAccountToken', () async {
    unawaited(service.purchasePass(_threeMonthPassId));
    await pumpEventQueue();

    // 플러그인이 UUID(uuidString:) 로 appAccountToken 에 넣음 > 해시 없이 uuid 그대로
    expect(
      store.lastPurchaseParam?.applicationUserName,
      _memberUuid.toLowerCase(),
    );
  });

  test('verifyFailure_returnsPending_keepsTransactionUnfinished', () async {
    billingApi.shouldFailVerify = true;
    final outcome = service.purchasePass(_threeMonthPassId);
    await pumpEventQueue();
    store.purchaseUpdates.add([_transaction(PurchaseStatus.purchased)]);

    // App Store 결제는 끝남 > 대기 안내, finish 안 함 (다음 재전송에서 다시 확인)
    expect(await outcome, ProPurchaseOutcome.pending);
    expect(store.completedPurchases, isEmpty);
  });

  test('cancelledAndPending_mapWithoutServerVerification', () async {
    final cancelled = service.purchasePass(_threeMonthPassId);
    await pumpEventQueue();
    store.purchaseUpdates.add([
      _transaction(PurchaseStatus.canceled, transactionId: null),
    ]);
    expect(await cancelled, ProPurchaseOutcome.cancelled);

    final pending = service.purchasePass(_threeMonthPassId);
    await pumpEventQueue();
    store.purchaseUpdates.add([
      _transaction(PurchaseStatus.pending, transactionId: null),
    ]);
    expect(await pending, ProPurchaseOutcome.pending);
    expect(billingApi.appStoreVerifyRequests, isEmpty);
  });

  test('launchError_mapsByStoreKitErrorCode', () async {
    store.purchaseLaunchError = PlatformException(
      code: 'storekit2_failed_to_fetch_product',
    );
    expect(
      await service.purchasePass(_threeMonthPassId),
      ProPurchaseOutcome.unavailable,
    );

    store.purchaseLaunchError = PlatformException(code: 'unknown');
    expect(
      await service.purchasePass(_threeMonthPassId),
      ProPurchaseOutcome.failed,
    );
  });

  test('duplicateUnfinishedTransaction_resendsAndSucceedsFromServer', () async {
    store.purchaseLaunchError = PlatformException(
      code: 'storekit_duplicate_product_object',
    );
    unfinishedTransactions = [_transaction(PurchaseStatus.purchased)];

    // 같은 상품의 미완료 거래 > 재전송으로 프로 확인 > success
    expect(
      await service.purchasePass(_threeMonthPassId),
      ProPurchaseOutcome.success,
    );
    expect(billingApi.appStoreVerifyRequests, hasLength(1));
    expect(store.completedPurchases, hasLength(1));
  });

  test('restore_resendsUnfinishedTransactions_completesAfterServer', () async {
    unfinishedTransactions = [_transaction(PurchaseStatus.purchased)];

    expect(await service.restorePurchases(), ProPurchaseOutcome.success);
    expect(billingApi.appStoreVerifyRequests, hasLength(1));
    expect(store.completedPurchases, hasLength(1));
  });

  test('restore_withoutUnfinished_fallsBackToServerPlan', () async {
    expect(await service.restorePurchases(), ProPurchaseOutcome.success);
    expect(billingApi.appStoreVerifyRequests, isEmpty);
    expect(planRefreshCount, 1);
  });

  test('resendAndStream_sameTransaction_verifiesOnce', () async {
    unfinishedTransactions = [_transaction(PurchaseStatus.purchased)];

    // 앱 시작 Transaction.updates 와 로그인 재전송이 겹쳐도 거래 ID 기준 1회
    store.purchaseUpdates.add([_transaction(PurchaseStatus.purchased)]);
    await service.resendUnverifiedPurchases();
    await pumpEventQueue();

    expect(billingApi.appStoreVerifyRequests, hasLength(1));
  });

  test('backgroundPurchased_refreshesPlan_announcesUnlock', () async {
    final unlocks = <void>[];
    service.backgroundProUnlocks.listen(unlocks.add);

    // 결제 창 밖 (Ask to Buy 승인·앱 시작 때 미완료 거래)
    store.purchaseUpdates.add([_transaction(PurchaseStatus.purchased)]);
    await pumpEventQueue();

    expect(billingApi.appStoreVerifyRequests, hasLength(1));
    expect(planRefreshCount, 1);
    expect(unlocks, hasLength(1));
  });
}
