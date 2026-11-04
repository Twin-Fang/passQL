import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

import '../../core/billing/promo_code_redemption_port.dart';

/// App Store 오퍼 코드 입력 시트 (iOS, #816): StoreKit 2 AppStore.presentOfferCodeRedeemSheet
/// 코드 적용 거래는 구매 스트림(Transaction.updates)으로 들어와 기존 백그라운드 서버 확인 > 등급 갱신 > 토스트
class AppStorePromoCodeRedeemer implements PromoCodeRedemptionPort {
  AppStorePromoCodeRedeemer({required InAppPurchase store}) : _store = store;

  final InAppPurchase _store;

  @override
  bool get isCodeEntryInApp => false;

  @override
  Future<PromoCodeRedemptionOutcome> startRedemption({String? code}) async {
    try {
      if (!await _store.isAvailable()) {
        return PromoCodeRedemptionOutcome.unavailable;
      }
      await _store
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>()
          .presentCodeRedemptionSheet();
      return PromoCodeRedemptionOutcome.opened;
    } on Object catch (error) {
      debugPrint('[billing] offer code sheet failed : ${error.runtimeType}');
      return PromoCodeRedemptionOutcome.failed;
    }
  }
}
