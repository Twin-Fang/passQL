// freezed 생성자 파라미터의 JsonKey 는 정상 사용법이라 경고를 끈다.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase_history_entry_response.freezed.dart';
part 'purchase_history_entry_response.g.dart';

/// 구매 내역 종류 2종: 스토어 구매, 운영 지급
enum PurchaseHistoryKind {
  @JsonValue('STORE_PURCHASE')
  storePurchase,
  @JsonValue('ADMIN_GRANT')
  adminGrant,
}

/// GET /members/me/purchases 응답 1건 (#816): 스토어 구매 또는 운영 지급, 서버 최신순
@freezed
class PurchaseHistoryEntryResponse with _$PurchaseHistoryEntryResponse {
  const PurchaseHistoryEntryResponse._();

  const factory PurchaseHistoryEntryResponse({
    // 서버에 새 종류가 생겨도 깨지지 않게 모르는 값은 스토어 구매로 봄
    @JsonKey(unknownEnumValue: PurchaseHistoryKind.storePurchase)
    @Default(PurchaseHistoryKind.storePurchase)
    PurchaseHistoryKind kind,
    // 구매·지급 시각 (KST)
    required DateTime purchasedAt,
    // 스토어 상품 ID (운영 지급이면 null)
    String? productId,
    // 스토어 서버 값 PLAY·APP_STORE (운영 지급이면 null)
    String? store,
    // 구매 상태 서버 값 VERIFIED·REVOKED (운영 지급이면 null)
    String? status,
    // 이 구매·지급으로 정해진 프로 만료 시각 (KST)
    DateTime? grantedExpiresAt,
    // 더한 이용 일수 (모르면 null)
    int? grantedDays,
    // 결제 금액 x 1,000,000 (스토어가 알려 준 값만)
    int? priceAmountMicros,
    // 결제 통화 ISO 4217 (예: KRW)
    String? currencyCode,
  }) = _PurchaseHistoryEntryResponse;

  factory PurchaseHistoryEntryResponse.fromJson(Map<String, dynamic> json) =>
      _$PurchaseHistoryEntryResponseFromJson(json);

  // 환불·회수된 구매의 서버 상태 값
  static const String _revokedStatus = 'REVOKED';

  /// 환불·회수된 구매인가
  bool get isRevoked => status == _revokedStatus;
}
