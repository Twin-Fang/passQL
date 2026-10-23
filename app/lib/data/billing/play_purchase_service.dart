import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../../core/billing/pro_purchase_port.dart';
import '../models/billing/play_verify_request.dart';
import '../models/member/member_plan_response.dart';
import 'play_account_identifier.dart';
import 'store_purchase_service.dart';

/// 이용권 Play 결제 (Android): 상품 조회 > 결제 창(소모형) > 구매 스트림 > 서버 확인 > 등급 갱신 > 구매 처리 완료
/// 상품 ID 는 등급 응답 passOptions 에서 받음 (앱 하드코딩 없음). 앱이 파는 상품은 이용권뿐 > 스트림 구매는 모두 서버 확인 대상
/// 소모(consume)는 서버가 함 (앱은 autoConsume: false). 등급 갱신은 refreshPlan 으로 바깥에 맡김 (data 는 등급 상태를 모름)
/// 결제 창·복원이 success 를 돌려주면 등급 갱신은 시트(refreshPlanIfPurchased, 닫혀도 실행) 몫 > 여기서는 판정에 필요할 때·백그라운드만 갱신
class PlayPurchaseService extends StorePurchaseService {
  PlayPurchaseService({
    required super.billingApi,
    required super.refreshPlan,
    required super.readMemberUuid,
    super.store,
  });

  // 이미 보유(서버 확인 전 구매가 남음) 결제 오류 표시 (BillingResponse.itemAlreadyOwned)
  static const String _itemAlreadyOwnedMarker = 'itemAlreadyOwned';

  /// 소모형 결제 창 (계정 표시 = 회원 uuid SHA-256, 서버가 obfuscatedExternalAccountId 와 대조)
  @override
  Future<bool> launchPurchase(ProductDetails product, String memberUuid) =>
      store.buyConsumable(
        purchaseParam: PurchaseParam(
          productDetails: product,
          applicationUserName: toPlayObfuscatedAccountId(memberUuid),
        ),
        autoConsume: false,
      );

  /// Play 보유 구매(결제 완료) = 서버 확인 전 구매
  /// 서버가 소모한 구매는 Play 목록에서 빠짐 (3일 안에 소모 안 되면 자동 환불)
  @override
  Future<List<PurchaseDetails>> loadUnverifiedPurchases() async {
    if (!await store.isAvailable()) return const [];
    final response = await store
        .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>()
        .queryPastPurchases();
    return [
      for (final purchase in response.pastPurchases)
        if (purchase.productID.isNotEmpty &&
            purchase.status == PurchaseStatus.purchased)
          purchase,
    ];
  }

  @override
  Future<MemberPlanResponse> requestServerVerification(
    PurchaseDetails purchase,
  ) => billingApi.verifyPlayPurchase(
    PlayVerifyRequest(
      productId: purchase.productID,
      purchaseToken: purchase.verificationData.serverVerificationData,
    ),
  );

  /// 구매 갱신 처리: 결제 창 진행 중이면 그 결과로, 아니면 백그라운드 확인
  /// 상품 ID 빈 갱신 = 결제 창이 끝난 결과(취소·오류·구매 정보 없는 성공)
  @override
  Future<void> onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      final isPassPurchase = purchase.productID.isNotEmpty;
      debugPrint('[billing] purchase update : status=${purchase.status.name}');
      switch (purchase.status) {
        case PurchaseStatus.pending:
          completeActivePurchase(ProPurchaseOutcome.pending);
        case PurchaseStatus.canceled:
          completeActivePurchase(ProPurchaseOutcome.cancelled);
        case PurchaseStatus.error:
          await _onPurchaseError(purchase);
        case PurchaseStatus.purchased || PurchaseStatus.restored:
          if (isPassPurchase) {
            await onPurchaseCompleted(purchase);
          } else {
            await completeActivePurchaseFromServerPlan();
          }
      }
    }
  }

  /// 결제 오류: 이미 보유(미확인 구매 남음)면 재전송 후 등급으로 판정, 그 외 failed
  Future<void> _onPurchaseError(PurchaseDetails purchase) async {
    final errorMessage = purchase.error?.message ?? '';
    debugPrint('[billing] purchase failed : $errorMessage');
    if (!hasActivePurchase) return;
    if (errorMessage.contains(_itemAlreadyOwnedMarker)) {
      await completeActivePurchaseFromServerPlan();
      return;
    }
    completeActivePurchase(ProPurchaseOutcome.failed);
  }
}
