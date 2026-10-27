import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../core/billing/pro_purchase_port.dart';
import '../../core/logging/app_logger.dart';
import '../models/member/member_plan_response.dart';
import '../sources/billing_api.dart';

/// 스토어 결제 어댑터 공통 (Play·App Store): 상품 조회·보관, 결제 창 결과 대기, 서버 확인 중복 합치기, 구매 처리 완료, 등급 갱신
/// 스토어별 차이 4개만 하위 클래스: 결제 창 열기, 구매 갱신 해석, 미확인 구매 목록, 서버 확인 요청
/// 구매 처리 완료(completePurchase)는 서버 확인 성공 뒤에만 (실패 구매는 스토어에 남겨 다음 재전송에서 다시)
abstract class StorePurchaseService implements ProPurchasePort {
  StorePurchaseService({
    required this.billingApi,
    required Future<bool> Function() refreshPlan,
    required String? Function() readMemberUuid,
    InAppPurchase? store,
  }) : _refreshPlan = refreshPlan,
       _readMemberUuid = readMemberUuid,
       store = store ?? InAppPurchase.instance;

  @protected
  final BillingApiClient billingApi;
  @protected
  final InAppPurchase store;

  /// 등급 다시 받기 > 프로면 true
  final Future<bool> Function() _refreshPlan;

  /// 지금 로그인한 회원 uuid (로그아웃 null), 결제 창 열 때마다 읽음
  final String? Function() _readMemberUuid;

  final StreamController<void> _backgroundUnlockController =
      StreamController<void>.broadcast();
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  /// 조회한 상품 {상품 ID: 상품} (못 읽은 상품은 다음 호출에서 다시 조회)
  final Map<String, ProductDetails> _productById = {};

  /// 진행 중인 결제 창의 결과. null 이면 스트림 구매는 백그라운드 처리
  Completer<ProPurchaseOutcome>? _activePurchase;

  /// 구매별 진행 중 서버 확인 (스트림·재전송이 겹쳐도 1회)
  final Map<String, Future<MemberPlanResponse?>> _verificationByKey = {};

  /// 결제 창 밖에서 확인된 구매로 프로가 됨 (지연 결제 완료 등)
  Stream<void> get backgroundProUnlocks => _backgroundUnlockController.stream;

  /// 결제 창이 열려 결과를 기다리는 중인가
  @protected
  bool get hasActivePurchase => _activePurchase != null;

  /// 구매 스트림 구독 (앱 수명 동안 1회, 앱이 꺼져 있던 동안의 결제 갱신도 여기로 들어옴)
  void startListening() {
    _purchaseSubscription ??= store.purchaseStream.listen(
      onPurchaseUpdates,
      onError: (Object error) =>
          debugPrint('[billing] purchase stream error : $error'),
    );
  }

  /// 결제 창 열기 (회원 uuid 는 스토어별 계정 표시로 변환해 넣음). 못 열면 false
  @protected
  Future<bool> launchPurchase(ProductDetails product, String memberUuid);

  /// 구매 갱신 해석 > 결과 (스토어마다 상태 표현이 다름)
  @protected
  Future<void> onPurchaseUpdates(List<PurchaseDetails> purchases);

  /// 스토어에 남은 서버 확인 전 구매 (결제 완료 상태만)
  @protected
  Future<List<PurchaseDetails>> loadUnverifiedPurchases();

  /// 서버 확인 요청 1회 (실패는 throw)
  @protected
  Future<MemberPlanResponse> requestServerVerification(
    PurchaseDetails purchase,
  );

  /// 서버 확인 중복 합치기 키 (기본: 서버 확인 값)
  @protected
  String verificationKeyOf(PurchaseDetails purchase) =>
      purchase.verificationData.serverVerificationData;

  /// 결제 창 열기 실패 처리 (기본: failed)
  @protected
  Future<void> onPurchaseLaunchFailed(Object error) async {
    debugPrint('[billing] purchase start failed : $error');
    completeActivePurchase(ProPurchaseOutcome.failed);
  }

  @override
  Future<Map<String, PassPrice>> loadPassPrices(List<String> productIds) async {
    final products = await _loadProducts(productIds);
    return {
      for (final product in products.values)
        product.id: PassPrice(
          displayPrice: product.price,
          rawPrice: product.rawPrice,
        ),
    };
  }

  /// 결제 창 열기 > 스트림 결과 대기 (결제 중 다시 누르면 같은 결과 공유)
  @override
  Future<ProPurchaseOutcome> purchasePass(String productId) async {
    final runningPurchase = _activePurchase;
    if (runningPurchase != null) return runningPurchase.future;
    // 구매 계정 표시 필수: 서버가 확인 요청 회원과 대조 (회원 미확정이면 결제 창 안 염)
    final memberUuid = _readMemberUuid();
    if (memberUuid == null) {
      debugPrint('[billing] purchase blocked : member not signed in');
      return ProPurchaseOutcome.failed;
    }
    final product = (await _loadProducts([productId]))[productId];
    if (product == null) return ProPurchaseOutcome.unavailable;
    final activePurchase = _activePurchase = Completer<ProPurchaseOutcome>();
    AppLogger.info('action', 'purchase started $productId');
    try {
      final isLaunched = await launchPurchase(product, memberUuid);
      if (!isLaunched) completeActivePurchase(ProPurchaseOutcome.failed);
    } on Object catch (error) {
      await onPurchaseLaunchFailed(error);
    }
    return activePurchase.future;
  }

  /// 복원: 미확인 구매 재전송 > 프로가 안 됐으면 서버 등급 재조회 (서버 등급이 기준)
  @override
  Future<ProPurchaseOutcome> restorePurchases() async =>
      await _isProAfterResendOrServerPlan()
      ? ProPurchaseOutcome.success
      : ProPurchaseOutcome.nothingToRestore;

  /// 백그라운드 미확인 구매 재전송 (앱 시작·복귀·로그인): 확인으로 프로가 되면 등급 갱신
  Future<void> resendUnverifiedPurchases() async {
    if (await _resendAndCheckPro()) await _refreshPlanSafely();
  }

  /// 결제 완료 > 서버 확인 > 결과 (결제 창: 결과만, 백그라운드: 등급 갱신 + 프로 알림)
  /// 확인 실패 = 스토어 결제는 끝남 > pending, 미확인으로 남겨 다음 재전송에서 다시
  @protected
  Future<void> onPurchaseCompleted(PurchaseDetails purchase) async {
    final isActivePurchase = _activePurchase != null;
    final verifiedPlan = await _verifyPurchase(purchase);
    // 서버가 결제 대기로 보면 등급 그대로 > pending
    final isPro = verifiedPlan?.plan == MemberPlanType.pro;
    if (isActivePurchase) {
      completeActivePurchase(
        isPro ? ProPurchaseOutcome.success : ProPurchaseOutcome.pending,
      );
      return;
    }
    if (!isPro) return;
    await _refreshPlanSafely();
    _backgroundUnlockController.add(null);
  }

  /// 구매 정보 없이 끝난 결제 창: 미확인 구매 재전송·서버 등급 > 프로면 success, 아니면 failed
  @protected
  Future<void> completeActivePurchaseFromServerPlan() async {
    if (_activePurchase == null) return;
    completeActivePurchase(
      await _isProAfterResendOrServerPlan()
          ? ProPurchaseOutcome.success
          : ProPurchaseOutcome.failed,
    );
  }

  @protected
  void completeActivePurchase(ProPurchaseOutcome outcome) {
    final activePurchase = _activePurchase;
    if (activePurchase == null) return;
    _activePurchase = null;
    AppLogger.info('action', 'purchase result ${outcome.name}');
    activePurchase.complete(outcome);
  }

  /// 미확인 구매 재전송 > 프로 확인됐으면 true, 아니면 서버 등급 재조회로 판정
  Future<bool> _isProAfterResendOrServerPlan() async =>
      await _resendAndCheckPro() || await _refreshPlanSafely();

  /// 미확인 구매 재전송 > 하나라도 프로로 확인되면 true
  Future<bool> _resendAndCheckPro() async {
    try {
      final unverifiedPurchases = await loadUnverifiedPurchases();
      final verifiedPlans = await Future.wait(
        unverifiedPurchases.map(_verifyPurchase),
      );
      return verifiedPlans.any((plan) => plan?.plan == MemberPlanType.pro);
    } on Object catch (error) {
      debugPrint('[billing] resend unverified failed : $error');
      return false;
    }
  }

  /// 상품 조회: 보관 안 된 ID만 조회 > 보관 > 요청 ID 중 읽은 상품 (스토어 없음·상품 없음은 빠짐)
  Future<Map<String, ProductDetails>> _loadProducts(
    List<String> productIds,
  ) async {
    final missingProductIds = productIds
        .where((productId) => !_productById.containsKey(productId))
        .toSet();
    if (missingProductIds.isNotEmpty) await _queryProducts(missingProductIds);
    return {
      for (final productId in productIds) productId: ?_productById[productId],
    };
  }

  /// 스토어 상품 조회 > 보관 (실패는 로그만, 다음 호출에서 다시)
  Future<void> _queryProducts(Set<String> productIds) async {
    try {
      if (!await store.isAvailable()) return;
      final response = await store.queryProductDetails(productIds);
      if (response.error != null || response.notFoundIDs.isNotEmpty) {
        debugPrint(
          '[billing] product query failed : ${response.error?.message ?? 'not found ${response.notFoundIDs}'}',
        );
      }
      for (final product in response.productDetails) {
        _productById[product.id] = product;
      }
    } on Object catch (error) {
      debugPrint('[billing] product query failed : $error');
    }
  }

  /// 서버 확인 (같은 구매 진행 중이면 공유): 성공 > 구매 처리 완료 > 새 등급, 실패 > null
  Future<MemberPlanResponse?> _verifyPurchase(PurchaseDetails purchase) {
    final verificationKey = verificationKeyOf(purchase);
    // 정리 콜백은 block body (지운 Future 를 돌려주면 whenComplete 가 자기 자신을 기다려 멈춤)
    return _verificationByKey[verificationKey] ??= _sendVerification(purchase)
        .whenComplete(() {
          _verificationByKey.remove(verificationKey);
        });
  }

  Future<MemberPlanResponse?> _sendVerification(
    PurchaseDetails purchase,
  ) async {
    try {
      final verifiedPlan = await requestServerVerification(purchase);
      debugPrint('[billing] verified : plan=${verifiedPlan.plan.name}');
      await _completePurchaseSafely(purchase);
      return verifiedPlan;
    } on Object catch (error) {
      // 구매 토큰·서명 거래는 로그에 넣지 않음
      debugPrint('[billing] verify failed : ${error.runtimeType}');
      return null;
    }
  }

  /// 스트림 항목 처리 완료 (이미 처리된 구매면 스토어 오류만 남고 무시)
  Future<void> _completePurchaseSafely(PurchaseDetails purchase) async {
    if (!purchase.pendingCompletePurchase) return;
    try {
      await store.completePurchase(purchase);
    } on Object catch (error) {
      debugPrint('[billing] complete purchase failed : $error');
    }
  }

  /// 등급 다시 받기 (실패 > 프로 아님으로 봄)
  Future<bool> _refreshPlanSafely() async {
    try {
      return await _refreshPlan();
    } on Object catch (error) {
      debugPrint('[billing] plan refresh failed : $error');
      return false;
    }
  }

  void dispose() {
    unawaited(_purchaseSubscription?.cancel());
    unawaited(_backgroundUnlockController.close());
  }
}
