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
};

const _$MemberPlanTypeEnumMap = {
  MemberPlanType.free: 'FREE',
  MemberPlanType.pro: 'PRO',
};
