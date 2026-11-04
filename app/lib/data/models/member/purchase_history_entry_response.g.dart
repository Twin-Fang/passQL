// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_history_entry_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PurchaseHistoryEntryResponseImpl _$$PurchaseHistoryEntryResponseImplFromJson(
  Map<String, dynamic> json,
) => _$PurchaseHistoryEntryResponseImpl(
  kind:
      $enumDecodeNullable(
        _$PurchaseHistoryKindEnumMap,
        json['kind'],
        unknownValue: PurchaseHistoryKind.storePurchase,
      ) ??
      PurchaseHistoryKind.storePurchase,
  purchasedAt: DateTime.parse(json['purchasedAt'] as String),
  productId: json['productId'] as String?,
  store: json['store'] as String?,
  status: json['status'] as String?,
  grantedExpiresAt: json['grantedExpiresAt'] == null
      ? null
      : DateTime.parse(json['grantedExpiresAt'] as String),
  grantedDays: (json['grantedDays'] as num?)?.toInt(),
  priceAmountMicros: (json['priceAmountMicros'] as num?)?.toInt(),
  currencyCode: json['currencyCode'] as String?,
);

Map<String, dynamic> _$$PurchaseHistoryEntryResponseImplToJson(
  _$PurchaseHistoryEntryResponseImpl instance,
) => <String, dynamic>{
  'kind': _$PurchaseHistoryKindEnumMap[instance.kind]!,
  'purchasedAt': instance.purchasedAt.toIso8601String(),
  'productId': instance.productId,
  'store': instance.store,
  'status': instance.status,
  'grantedExpiresAt': instance.grantedExpiresAt?.toIso8601String(),
  'grantedDays': instance.grantedDays,
  'priceAmountMicros': instance.priceAmountMicros,
  'currencyCode': instance.currencyCode,
};

const _$PurchaseHistoryKindEnumMap = {
  PurchaseHistoryKind.storePurchase: 'STORE_PURCHASE',
  PurchaseHistoryKind.adminGrant: 'ADMIN_GRANT',
};
