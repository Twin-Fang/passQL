// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_history_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreditHistoryResponseImpl _$$CreditHistoryResponseImplFromJson(
  Map<String, dynamic> json,
) => _$CreditHistoryResponseImpl(
  days:
      (json['days'] as List<dynamic>?)
          ?.map(
            (e) => CreditHistoryDayResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <CreditHistoryDayResponse>[],
);

Map<String, dynamic> _$$CreditHistoryResponseImplToJson(
  _$CreditHistoryResponseImpl instance,
) => <String, dynamic>{'days': instance.days};

_$CreditHistoryDayResponseImpl _$$CreditHistoryDayResponseImplFromJson(
  Map<String, dynamic> json,
) => _$CreditHistoryDayResponseImpl(
  date: DateTime.parse(json['date'] as String),
  baseCredits: (json['baseCredits'] as num?)?.toInt() ?? 0,
  dailySetCompletionCredits:
      (json['dailySetCompletionCredits'] as num?)?.toInt() ?? 0,
  dailySetAccuracyCredits:
      (json['dailySetAccuracyCredits'] as num?)?.toInt() ?? 0,
  adBonusCount: (json['adBonusCount'] as num?)?.toInt() ?? 0,
  adBonusCredits: (json['adBonusCredits'] as num?)?.toInt() ?? 0,
  usedCredits: (json['usedCredits'] as num?)?.toInt() ?? 0,
  remainingCredits: (json['remainingCredits'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$CreditHistoryDayResponseImplToJson(
  _$CreditHistoryDayResponseImpl instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'baseCredits': instance.baseCredits,
  'dailySetCompletionCredits': instance.dailySetCompletionCredits,
  'dailySetAccuracyCredits': instance.dailySetAccuracyCredits,
  'adBonusCount': instance.adBonusCount,
  'adBonusCredits': instance.adBonusCredits,
  'usedCredits': instance.usedCredits,
  'remainingCredits': instance.remainingCredits,
};
