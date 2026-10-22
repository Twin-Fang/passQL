import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../../core/billing/pro_purchase_port.dart';
import '../models/billing/play_verify_request.dart';
import '../models/member/member_plan_response.dart';
import '../sources/billing_api.dart';
import 'play_account_identifier.dart';

/// 회차 패스 Play 결제 (Android): 상품 조회 > 결제 창(소모형) > 구매 스트림 > 서버 확인 > 등급 갱신 > 구매 처리 완료
/// 소모(consume)는 서버가 함 (앱은 autoConsume: false). 등급 갱신은 [refreshPlan] 으로 바깥에 맡김 (data 는 등급 상태를 모름)
/// 결제 창·복원이 success 를 돌려주면 등급 갱신은 시트(refreshPlanIfPurchased, 닫혀도 실행) 몫 > 여기서는 판정에 필요할 때·백그라운드만 갱신
class PlayPurchaseService implements ProPurchasePort {
  PlayPurchaseService({
    required BillingApiClient billingApi,
    required Future<bool> Function() refreshPlan,
    required String? Function() readMemberUuid,
    InAppPurchase? store,
  }) : _billingApi = billingApi,
       _refreshPlan = refreshPlan,
       _readMemberUuid = readMemberUuid,
       _store = store ?? InAppPurchase.instance;

  /// Play Console 일회성 소모형 상품 ID
  static const String examPassProductId = 'pro_exam_pass';

  // 이미 보유(서버 확인 전 구매가 남음) 결제 오류 표시 (BillingResponse.itemAlreadyOwned)
  static const String _itemAlreadyOwnedMarker = 'itemAlreadyOwned';

  final BillingApiClient _billingApi;

  /// 등급 다시 받기 > 프로면 true
  final Future<bool> Function() _refreshPlan;

  /// 지금 로그인한 회원 uuid (로그아웃 null), 결제 창 열 때마다 읽음
  final String? Function() _readMemberUuid;
  final InAppPurchase _store;

  final StreamController<void> _backgroundUnlockController =
      StreamController<void>.broadcast();
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  /// 조회한 상품 (실패하면 다음 호출에서 다시 조회)
  ProductDetails? _examPassProduct;

  /// 진행 중인 결제 창의 결과. null 이면 스트림 구매는 백그라운드 처리
  Completer<ProPurchaseOutcome>? _activePurchase;

  /// 구매 토큰별 진행 중 서버 확인 (스트림·재전송이 겹쳐도 1회)
  final Map<String, Future<MemberPlanResponse?>> _verificationByToken = {};

  /// 결제 창 밖에서 확인된 구매로 프로가 됨 (지연 결제 완료 등)
  Stream<void> get backgroundProUnlocks => _backgroundUnlockController.stream;

  /// 구매 스트림 구독 (앱 수명 동안 1회, 앱이 꺼져 있던 동안의 결제 갱신도 여기로 들어옴)
  void startListening() {
    _purchaseSubscription ??= _store.purchaseStream.listen(
      _onPurchaseUpdates,
      onError: (Object error) =>
          debugPrint('[billing] purchase stream error : $error'),
    );
  }

  @override
  Future<String?> loadExamPassPrice() async =>
      (await _loadExamPassProduct())?.price;

  /// 결제 창 열기 > 스트림 결과 대기 (결제 중 다시 누르면 같은 결과 공유)
  @override
  Future<ProPurchaseOutcome> purchaseExamPass() async {
    final runningPurchase = _activePurchase;
    if (runningPurchase != null) return runningPurchase.future;
    // 구매 계정 표시 필수: 서버가 확인 요청 회원과 대조 (회원 미확정이면 결제 창 안 염)
    final memberUuid = _readMemberUuid();
    if (memberUuid == null) {
      debugPrint('[billing] purchase blocked : member not signed in');
      return ProPurchaseOutcome.failed;
    }
    final product = await _loadExamPassProduct();
    if (product == null) return ProPurchaseOutcome.unavailable;
    final activePurchase = _activePurchase = Completer<ProPurchaseOutcome>();
    try {
      final isLaunched = await _store.buyConsumable(
        purchaseParam: PurchaseParam(
          productDetails: product,
          applicationUserName: toPlayObfuscatedAccountId(memberUuid),
        ),
        autoConsume: false,
      );
      if (!isLaunched) _completeActivePurchase(ProPurchaseOutcome.failed);
    } on Object catch (error) {
      debugPrint('[billing] purchase start failed : $error');
      _completeActivePurchase(ProPurchaseOutcome.failed);
    }
    return activePurchase.future;
  }

  /// 복원: 미확인 구매 재전송 > 프로가 안 됐으면 서버 등급 재조회 (소모된 구매는 Play 에 없으므로 서버 등급이 기준)
  @override
  Future<ProPurchaseOutcome> restorePurchases() async =>
      await _isProAfterResendOrServerPlan()
      ? ProPurchaseOutcome.success
      : ProPurchaseOutcome.nothingToRestore;

  /// 백그라운드 미확인 구매 재전송 (앱 시작·복귀·로그인): 확인으로 프로가 되면 등급 갱신
  Future<void> resendUnverifiedPurchases() async {
    if (await _resendAndCheckPro()) await _refreshPlanSafely();
  }

  /// 미확인 구매 재전송 > 프로 확인됐으면 true, 아니면 서버 등급 재조회로 판정
  Future<bool> _isProAfterResendOrServerPlan() async =>
      await _resendAndCheckPro() || await _refreshPlanSafely();

  /// 미확인 구매 재전송: Play 보유 구매(결제 완료) > 서버 확인 > 하나라도 프로로 확인되면 true
  /// 서버가 소모한 구매는 Play 목록에서 빠짐 > 남은 것 = 서버 확인 전 구매 (3일 안에 소모 안 되면 자동 환불)
  Future<bool> _resendAndCheckPro() async {
    try {
      if (!await _store.isAvailable()) return false;
      final response = await _store
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>()
          .queryPastPurchases();
      final unverifiedPurchases = response.pastPurchases.where(
        (purchase) =>
            purchase.productID == examPassProductId &&
            purchase.status == PurchaseStatus.purchased,
      );
      final verifiedPlans = await Future.wait(
        unverifiedPurchases.map(_verifyPurchase),
      );
      return verifiedPlans.any((plan) => plan?.plan == MemberPlanType.pro);
    } on Object catch (error) {
      debugPrint('[billing] resend unverified failed : $error');
      return false;
    }
  }

  /// 상품 1회 조회 후 보관 (스토어 없음·상품 없음 > null)
  Future<ProductDetails?> _loadExamPassProduct() async {
    final cachedProduct = _examPassProduct;
    if (cachedProduct != null) return cachedProduct;
    try {
      if (!await _store.isAvailable()) return null;
      final response = await _store.queryProductDetails({examPassProductId});
      if (response.error != null || response.productDetails.isEmpty) {
        debugPrint(
          '[billing] product query failed : ${response.error?.message ?? 'not found'}',
        );
        return null;
      }
      return _examPassProduct = response.productDetails.first;
    } on Object catch (error) {
      debugPrint('[billing] product query failed : $error');
      return null;
    }
  }

  /// 구매 갱신 처리: 결제 창 진행 중이면 그 결과로, 아니면 백그라운드 확인
  /// 상품 ID 빈 갱신 = 결제 창이 끝난 결과(취소·오류·구매 정보 없는 성공)
  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      final isExamPass = purchase.productID == examPassProductId;
      if (!isExamPass && purchase.productID.isNotEmpty) continue;
      debugPrint('[billing] purchase update : status=${purchase.status.name}');
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _completeActivePurchase(ProPurchaseOutcome.pending);
        case PurchaseStatus.canceled:
          _completeActivePurchase(ProPurchaseOutcome.cancelled);
        case PurchaseStatus.error:
          await _onPurchaseError(purchase);
        case PurchaseStatus.purchased || PurchaseStatus.restored:
          if (isExamPass) {
            await _onPurchaseCompleted(purchase);
          } else {
            await _completeActivePurchaseFromServerPlan();
          }
      }
    }
  }

  /// 결제 완료 > 서버 확인 > 결과 (결제 창: 결과만, 백그라운드: 등급 갱신 + 프로 알림)
  /// 확인 실패 = Play 결제는 끝남 > pending, 미확인으로 남겨 다음 재전송에서 다시
  Future<void> _onPurchaseCompleted(PurchaseDetails purchase) async {
    final isActivePurchase = _activePurchase != null;
    final verifiedPlan = await _verifyPurchase(purchase);
    // 서버가 결제 대기로 보면 등급 그대로 > pending
    final isPro = verifiedPlan?.plan == MemberPlanType.pro;
    if (isActivePurchase) {
      _completeActivePurchase(
        isPro ? ProPurchaseOutcome.success : ProPurchaseOutcome.pending,
      );
      return;
    }
    if (!isPro) return;
    await _refreshPlanSafely();
    _backgroundUnlockController.add(null);
  }

  /// 결제 오류: 이미 보유(미확인 구매 남음)면 재전송 후 등급으로 판정, 그 외 failed
  Future<void> _onPurchaseError(PurchaseDetails purchase) async {
    final errorMessage = purchase.error?.message ?? '';
    debugPrint('[billing] purchase failed : $errorMessage');
    if (_activePurchase == null) return;
    if (errorMessage.contains(_itemAlreadyOwnedMarker)) {
      await _completeActivePurchaseFromServerPlan();
      return;
    }
    _completeActivePurchase(ProPurchaseOutcome.failed);
  }

  /// 구매 정보 없이 끝난 결제 창: 미확인 구매 재전송·서버 등급 > 프로면 success, 아니면 failed
  Future<void> _completeActivePurchaseFromServerPlan() async {
    if (_activePurchase == null) return;
    _completeActivePurchase(
      await _isProAfterResendOrServerPlan()
          ? ProPurchaseOutcome.success
          : ProPurchaseOutcome.failed,
    );
  }

  /// 서버 확인 (같은 토큰 진행 중이면 공유): 성공 > 구매 처리 완료 > 새 등급, 실패 > null
  Future<MemberPlanResponse?> _verifyPurchase(PurchaseDetails purchase) {
    final purchaseToken = purchase.verificationData.serverVerificationData;
    // 정리 콜백은 block body (지운 Future 를 돌려주면 whenComplete 가 자기 자신을 기다려 멈춤)
    return _verificationByToken[purchaseToken] ??=
        _sendVerification(purchase, purchaseToken).whenComplete(() {
          _verificationByToken.remove(purchaseToken);
        });
  }

  Future<MemberPlanResponse?> _sendVerification(
    PurchaseDetails purchase,
    String purchaseToken,
  ) async {
    try {
      final verifiedPlan = await _billingApi.verifyPlayPurchase(
        PlayVerifyRequest(
          productId: examPassProductId,
          purchaseToken: purchaseToken,
        ),
      );
      debugPrint('[billing] verified : plan=${verifiedPlan.plan.name}');
      await _completePurchaseSafely(purchase);
      return verifiedPlan;
    } on Object catch (error) {
      // 구매 토큰은 로그에 넣지 않음
      debugPrint('[billing] verify failed : ${error.runtimeType}');
      return null;
    }
  }

  /// 스트림 항목 처리 완료 (서버가 이미 소모했으면 Play 응답 오류만 남고 무시)
  Future<void> _completePurchaseSafely(PurchaseDetails purchase) async {
    if (!purchase.pendingCompletePurchase) return;
    try {
      await _store.completePurchase(purchase);
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

  void _completeActivePurchase(ProPurchaseOutcome outcome) {
    final activePurchase = _activePurchase;
    if (activePurchase == null) return;
    _activePurchase = null;
    activePurchase.complete(outcome);
  }

  void dispose() {
    unawaited(_purchaseSubscription?.cancel());
    unawaited(_backgroundUnlockController.close());
  }
}
