import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:passql_app/core/billing/pro_purchase_port.dart';
import 'package:passql_app/data/billing/play_account_identifier.dart';
import 'package:passql_app/data/billing/play_purchase_service.dart';
import 'package:passql_app/data/models/billing/play_verify_request.dart';
import 'package:passql_app/data/models/member/member_plan_response.dart';
import 'package:passql_app/data/sources/billing_api.dart';

/// 결제 창을 열면 기록만 하고, 구매 갱신은 테스트가 스트림으로 넣는 가짜 스토어
class _FakeInAppPurchase implements InAppPurchase {
  final StreamController<List<PurchaseDetails>> purchaseUpdates =
      StreamController<List<PurchaseDetails>>.broadcast();
  bool? lastAutoConsume;
  PurchaseParam? lastPurchaseParam;
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
    lastPurchaseParam = purchaseParam;
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

  /// true 면 서버 확인 실패 (네트워크·5xx)
  bool shouldFailVerify = false;

  @override
  Future<MemberPlanResponse> verifyPlayPurchase(PlayVerifyRequest body) async {
    verifyRequests.add(body);
    if (shouldFailVerify) throw Exception('verify unavailable');
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

// 계정 대조 고정 벡터 (서버 PlayBillingServiceTest 와 같은 값): uuid 소문자 문자열 UTF-8 > SHA-256 소문자 hex 64자
const String _hashVectorMemberUuid = '123e4567-e89b-12d3-a456-426614174000';
const String _hashVectorAccountId =
    '986c0dc956dc822b5d8f698661b9eb1ef880786ff9043c16744d2a420e99e9bb';

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
      readMemberUuid: () => _hashVectorMemberUuid,
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
      // 결제 창 성공의 등급 갱신은 시트 몫 (중복 갱신 방지)
      expect(planRefreshCount, 0);
      expect(store.completedPurchases, hasLength(1));
    },
  );

  test('backgroundPurchased_refreshesPlan_announcesUnlock', () async {
    final unlocks = <void>[];
    service.backgroundProUnlocks.listen(unlocks.add);

    // 결제 창 밖 (지연 결제 완료·재시작 후 전달)
    store.purchaseUpdates.add([_examPassPurchase(PurchaseStatus.purchased)]);
    await pumpEventQueue();

    expect(billingApi.verifyRequests, hasLength(1));
    expect(planRefreshCount, 1);
    expect(unlocks, hasLength(1));
  });

  test('verifyFailure_returnsPending_keepsPurchaseUncompleted', () async {
    billingApi.shouldFailVerify = true;
    final outcome = service.purchaseExamPass();
    await pumpEventQueue();
    store.purchaseUpdates.add([_examPassPurchase(PurchaseStatus.purchased)]);

    // Play 결제는 끝남 > 대기 안내, 처리 완료 안 함 (다음 재전송에서 다시 확인)
    expect(await outcome, ProPurchaseOutcome.pending);
    expect(store.completedPurchases, isEmpty);
  });

  test('pending_returnsPending_withoutServerVerification', () async {
    final outcome = service.purchaseExamPass();
    await pumpEventQueue();
    store.purchaseUpdates.add([_examPassPurchase(PurchaseStatus.pending)]);

    expect(await outcome, ProPurchaseOutcome.pending);
    expect(billingApi.verifyRequests, isEmpty);
    expect(planRefreshCount, 0);
  });

  test('toPlayObfuscatedAccountId_matchesServerFixedVector', () {
    expect(
      toPlayObfuscatedAccountId(_hashVectorMemberUuid),
      _hashVectorAccountId,
    );
  });

  test('purchase_setsHashedMemberUuidAsApplicationUserName', () async {
    unawaited(service.purchaseExamPass());
    await pumpEventQueue();

    // 서버가 Play obfuscatedExternalAccountId 와 대조 (다른 계정 재전송 차단)
    expect(store.lastPurchaseParam?.applicationUserName, _hashVectorAccountId);
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
