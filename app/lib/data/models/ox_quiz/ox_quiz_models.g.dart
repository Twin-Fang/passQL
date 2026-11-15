// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ox_quiz_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OxCardItemImpl _$$OxCardItemImplFromJson(Map<String, dynamic> json) =>
    _$OxCardItemImpl(
      cardKey: json['cardKey'] as String,
      conceptUuid: json['conceptUuid'] as String? ?? '',
      conceptTitle: json['conceptTitle'] as String? ?? '',
      topicName: json['topicName'] as String? ?? '',
      statement: json['statement'] as String,
      isTrue: json['isTrue'] as bool? ?? false,
      reason: json['reason'] as String? ?? '',
      box: (json['box'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$OxCardItemImplToJson(_$OxCardItemImpl instance) =>
    <String, dynamic>{
      'cardKey': instance.cardKey,
      'conceptUuid': instance.conceptUuid,
      'conceptTitle': instance.conceptTitle,
      'topicName': instance.topicName,
      'statement': instance.statement,
      'isTrue': instance.isTrue,
      'reason': instance.reason,
      'box': instance.box,
    };

_$OxCardSetResponseImpl _$$OxCardSetResponseImplFromJson(
  Map<String, dynamic> json,
) => _$OxCardSetResponseImpl(
  cards:
      (json['cards'] as List<dynamic>?)
          ?.map((e) => OxCardItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  dueCardCount: (json['dueCardCount'] as num?)?.toInt() ?? 0,
  newCardCount: (json['newCardCount'] as num?)?.toInt() ?? 0,
  todayAnsweredCount: (json['todayAnsweredCount'] as num?)?.toInt() ?? 0,
  dailyGoalCount: (json['dailyGoalCount'] as num?)?.toInt() ?? 0,
  hasLockedTopics: json['hasLockedTopics'] as bool? ?? false,
);

Map<String, dynamic> _$$OxCardSetResponseImplToJson(
  _$OxCardSetResponseImpl instance,
) => <String, dynamic>{
  'cards': instance.cards,
  'dueCardCount': instance.dueCardCount,
  'newCardCount': instance.newCardCount,
  'todayAnsweredCount': instance.todayAnsweredCount,
  'dailyGoalCount': instance.dailyGoalCount,
  'hasLockedTopics': instance.hasLockedTopics,
};

_$OxAnswerRequestImpl _$$OxAnswerRequestImplFromJson(
  Map<String, dynamic> json,
) => _$OxAnswerRequestImpl(
  cardKey: json['cardKey'] as String,
  isCorrect: json['isCorrect'] as bool,
);

Map<String, dynamic> _$$OxAnswerRequestImplToJson(
  _$OxAnswerRequestImpl instance,
) => <String, dynamic>{
  'cardKey': instance.cardKey,
  'isCorrect': instance.isCorrect,
};

_$OxAnswerResponseImpl _$$OxAnswerResponseImplFromJson(
  Map<String, dynamic> json,
) => _$OxAnswerResponseImpl(
  cardKey: json['cardKey'] as String,
  box: (json['box'] as num?)?.toInt() ?? 1,
  nextReviewDate: json['nextReviewDate'] == null
      ? null
      : DateTime.parse(json['nextReviewDate'] as String),
  correctStreak: (json['correctStreak'] as num?)?.toInt() ?? 0,
  todayAnsweredCount: (json['todayAnsweredCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$OxAnswerResponseImplToJson(
  _$OxAnswerResponseImpl instance,
) => <String, dynamic>{
  'cardKey': instance.cardKey,
  'box': instance.box,
  'nextReviewDate': instance.nextReviewDate?.toIso8601String(),
  'correctStreak': instance.correctStreak,
  'todayAnsweredCount': instance.todayAnsweredCount,
};
