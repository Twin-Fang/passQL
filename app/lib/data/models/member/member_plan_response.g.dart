// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_plan_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MemberPlanResponseImpl _$$MemberPlanResponseImplFromJson(
  Map<String, dynamic> json,
) => _$MemberPlanResponseImpl(
  isBillingEnabled: json['isBillingEnabled'] as bool? ?? false,
  plan:
      $enumDecodeNullable(
        _$MemberPlanTypeEnumMap,
        json['plan'],
        unknownValue: MemberPlanType.free,
      ) ??
      MemberPlanType.free,
  proExpiresAt: json['proExpiresAt'] == null
      ? null
      : DateTime.parse(json['proExpiresAt'] as String),
  todayRandomSolvedCount:
      (json['todayRandomSolvedCount'] as num?)?.toInt() ?? 0,
  dailyFreeLimit: (json['dailyFreeLimit'] as num?)?.toInt() ?? 0,
  purchasableUntil: json['purchasableUntil'] == null
      ? null
      : DateTime.parse(json['purchasableUntil'] as String),
  passOptions:
      (json['passOptions'] as List<dynamic>?)
          ?.map((e) => PassOption.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <PassOption>[],
  lastPurchasedAt: json['lastPurchasedAt'] == null
      ? null
      : DateTime.parse(json['lastPurchasedAt'] as String),
  lastOrderId: json['lastOrderId'] as String?,
);

Map<String, dynamic> _$$MemberPlanResponseImplToJson(
  _$MemberPlanResponseImpl instance,
) => <String, dynamic>{
  'isBillingEnabled': instance.isBillingEnabled,
  'plan': _$MemberPlanTypeEnumMap[instance.plan]!,
  'proExpiresAt': instance.proExpiresAt?.toIso8601String(),
  'todayRandomSolvedCount': instance.todayRandomSolvedCount,
  'dailyFreeLimit': instance.dailyFreeLimit,
  'purchasableUntil': instance.purchasableUntil?.toIso8601String(),
  'passOptions': instance.passOptions,
  'lastPurchasedAt': instance.lastPurchasedAt?.toIso8601String(),
  'lastOrderId': instance.lastOrderId,
};

const _$MemberPlanTypeEnumMap = {
  MemberPlanType.free: 'FREE',
  MemberPlanType.pro: 'PRO',
};

_$PassOptionImpl _$$PassOptionImplFromJson(Map<String, dynamic> json) =>
    _$PassOptionImpl(
      productId: json['productId'] as String,
      durationDays: (json['durationDays'] as num).toInt(),
      expiresAtIfPurchased: DateTime.parse(
        json['expiresAtIfPurchased'] as String,
      ),
    );

Map<String, dynamic> _$$PassOptionImplToJson(_$PassOptionImpl instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'durationDays': instance.durationDays,
      'expiresAtIfPurchased': instance.expiresAtIfPurchased.toIso8601String(),
    };
