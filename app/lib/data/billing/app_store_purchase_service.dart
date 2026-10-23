import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart';

import '../../core/billing/pro_purchase_port.dart';
import '../models/billing/app_store_verify_request.dart';
import '../models/member/member_plan_response.dart';
import 'store_purchase_service.dart';

/// 이용권 App Store 결제 (iOS, StoreKit 2): 상품 조회 > 결제 창(비갱신 구독) > 구매 스트림 > 서버 확인 > 거래 처리 완료(finish)
/// 계정 표시 = 회원 uuid 그대로 (StoreKit 2 appAccountToken, 서버가 서명 거래 안 값과 대조)
/// 미완료 거래(서버 확인 전)는 앱 시작 때 Transaction.updates 로 다시 들어오고, 로그인·복귀·복원 때 직접 조회해 재전송
class AppStorePurchaseService extends StorePurchaseService {
  AppStorePurchaseService({
    required super.billingApi,
    required super.refreshPlan,
    required super.readMemberUuid,
    super.store,
    Future<List<PurchaseDetails>> Function()? loadUnfinishedTransactions,
  }) : _loadUnfinishedTransactions =
           loadUnfinishedTransactions ?? _loadStoreKitUnfinishedTransactions;

  // 결제 창 오류 코드 2개 (in_app_purchase_storekit 네이티브 PigeonError code)
  // 같은 상품의 미완료 거래가 남음 > 재전송 후 등급으로 판정
  static const String _duplicateTransactionErrorCode =
      'storekit_duplicate_product_object';
  // 상품을 못 읽음 > 구매 불가
  static const String _productNotFoundErrorCode =
      'storekit2_failed_to_fetch_product';

  /// StoreKit 2 미완료 거래 조회 (테스트에서 교체)
  final Future<List<PurchaseDetails>> Function() _loadUnfinishedTransactions;

  /// 비갱신 구독 결제 창 (플러그인은 소모·비소모 구분 없이 Product.purchase 하나, appAccountToken = 회원 uuid)
  /// uuid 형식이 아니면 플러그인이 appAccountToken 을 빼고 결제 > 서버 대조 실패 (회원 uuid 는 항상 UUID)
  @override
  Future<bool> launchPurchase(ProductDetails product, String memberUuid) =>
      store.buyNonConsumable(
        purchaseParam: PurchaseParam(
          productDetails: product,
          applicationUserName: memberUuid.toLowerCase(),
        ),
      );

  /// 결제 창 오류: 미완료 거래 남음 > 재전송·등급 판정, 상품 없음 > unavailable, 그 외 failed
  @override
  Future<void> onPurchaseLaunchFailed(Object error) async {
    final errorCode = error is PlatformException ? error.code : null;
    debugPrint(
      '[billing] app store purchase start failed : ${errorCode ?? error.runtimeType}',
    );
    switch (errorCode) {
      case _duplicateTransactionErrorCode:
        await completeActivePurchaseFromServerPlan();
      case _productNotFoundErrorCode:
        completeActivePurchase(ProPurchaseOutcome.unavailable);
      default:
        completeActivePurchase(ProPurchaseOutcome.failed);
    }
  }

  @override
  Future<List<PurchaseDetails>> loadUnverifiedPurchases() =>
      _loadUnfinishedTransactions();

  /// 서버 확인 값 = StoreKit 2 서명 거래 JWS (verificationResult.jwsRepresentation)
  @override
  Future<MemberPlanResponse> requestServerVerification(
    PurchaseDetails purchase,
  ) => billingApi.verifyAppStorePurchase(
    AppStoreVerifyRequest(
      productId: purchase.productID,
      signedTransaction: purchase.verificationData.serverVerificationData,
    ),
  );

  /// 거래 ID 기준 합치기 (같은 거래의 JWS 가 조회마다 달라도 1회)
  @override
  String verificationKeyOf(PurchaseDetails purchase) =>
      purchase.purchaseID ?? purchase.verificationData.serverVerificationData;

  /// 구매 갱신 처리: 결제 창 진행 중이면 그 결과로, 아니면 백그라운드 확인
  /// StoreKit 2 대기·취소는 거래 없이(purchaseID null) 상품 ID 만 옴
  @override
  Future<void> onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      debugPrint('[billing] purchase update : status=${purchase.status.name}');
      switch (purchase.status) {
        case PurchaseStatus.pending:
          completeActivePurchase(ProPurchaseOutcome.pending);
        case PurchaseStatus.canceled:
          completeActivePurchase(ProPurchaseOutcome.cancelled);
        case PurchaseStatus.error:
          debugPrint('[billing] purchase failed : ${purchase.error?.code}');
          completeActivePurchase(ProPurchaseOutcome.failed);
        case PurchaseStatus.purchased || PurchaseStatus.restored:
          await onPurchaseCompleted(purchase);
      }
    }
  }
}

/// StoreKit 2 Transaction.unfinished > 구매 갱신 형태 (스트림 항목과 같은 SK2PurchaseDetails, finish 에 거래 ID 사용)
Future<List<PurchaseDetails>> _loadStoreKitUnfinishedTransactions() async {
  final transactions = await SK2Transaction.unfinishedTransactions();
  return [
    for (final transaction in transactions)
      if (transaction.receiptData case final signedTransaction?)
        SK2PurchaseDetails(
          productID: transaction.productId,
          purchaseID: transaction.id,
          verificationData: PurchaseVerificationData(
            localVerificationData: transaction.jsonRepresentation ?? '',
            serverVerificationData: signedTransaction,
            source: kIAPSource,
          ),
          transactionDate: transaction.purchaseDate,
          status: PurchaseStatus.purchased,
          appAccountToken: transaction.appAccountToken,
        ),
  ];
}
