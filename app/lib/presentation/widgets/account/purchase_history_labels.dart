import '../../../core/billing/pass_discount.dart';
import '../../../core/billing/pro_purchase_port.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/number_format.dart';
import '../../../data/models/member/member_plan_response.dart';
import '../../../data/models/member/purchase_history_entry_response.dart';

// 스토어 서버 값 > 표시 이름 (PLAY·APP_STORE)
const Map<String, String> _storeLabelByServerValue = {
  'PLAY': 'Google Play',
  'APP_STORE': 'App Store',
};
// 결제 금액 micros > 통화 단위 (x 1,000,000)
const int _microsPerCurrencyUnit = 1000000;

/// 판매 이용권 {상품 ID: 이용 일수} (옛 구매 이름 찾기용, 등급 모름이면 빈 값)
Map<String, int> durationDaysByProductIdOf(MemberPlanResponse? plan) => {
  for (final option in plan?.passOptions ?? const <PassOption>[])
    option.productId: option.durationDays,
};

/// 이용권 이름 (#816): 더한 일수 또는 판매 이용권 일수 > 3개월권, 운영 지급 > 운영 지급 N일, 모르면 이용권
/// [durationDaysByProductId]: 등급 응답 passOptions (옛 구매는 grantedDays 가 없어 상품 ID 로 찾음)
String passNameOf(
  PurchaseHistoryEntryResponse entry, {
  Map<String, int> durationDaysByProductId = const {},
}) {
  final grantedDays = entry.grantedDays;
  if (entry.kind == PurchaseHistoryKind.adminGrant) {
    return grantedDays == null ? '운영 지급' : '운영 지급 $grantedDays일';
  }
  final durationDays = grantedDays ?? durationDaysByProductId[entry.productId];
  return durationDays == null ? '이용권' : '${toPassMonths(durationDays)}개월권';
}

/// 구매 내역 한 줄 왼쪽: 2026.10.28 · 3개월권 · App Store ([hasStoreLabel] false 면 스토어 생략)
String purchaseHistoryTitleOf(
  PurchaseHistoryEntryResponse entry, {
  Map<String, int> durationDaysByProductId = const {},
  bool hasStoreLabel = true,
}) {
  final storeLabel = hasStoreLabel
      ? _storeLabelByServerValue[entry.store]
      : null;
  return [
    formatDottedDate(entry.purchasedAt),
    passNameOf(entry, durationDaysByProductId: durationDaysByProductId),
    ?storeLabel,
  ].join(' | ');
}

/// 구매 내역 한 줄 오른쪽: 9,900원 / 무료(운영 지급) / 환불됨 / 금액 모름이면 null
String? purchaseHistoryAmountOf(PurchaseHistoryEntryResponse entry) {
  if (entry.kind == PurchaseHistoryKind.adminGrant) return '무료';
  if (entry.isRevoked) return '환불됨';
  final micros = entry.priceAmountMicros;
  final currencyCode = entry.currencyCode;
  if (micros == null || currencyCode == null) return null;
  final amount = (micros / _microsPerCurrencyUnit).round();
  return currencyCode == koreanWonCurrencyCode
      ? '${formatThousands(amount)}원'
      : '${formatThousands(amount)} $currencyCode';
}
