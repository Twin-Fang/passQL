// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'concept_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConceptTopicListResponseImpl _$$ConceptTopicListResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ConceptTopicListResponseImpl(
  isAvailable: json['isAvailable'] as bool? ?? false,
  freeTopicCount: (json['freeTopicCount'] as num?)?.toInt() ?? 2,
  topics:
      (json['topics'] as List<dynamic>?)
          ?.map((e) => ConceptTopicSummary.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$ConceptTopicListResponseImplToJson(
  _$ConceptTopicListResponseImpl instance,
) => <String, dynamic>{
  'isAvailable': instance.isAvailable,
  'freeTopicCount': instance.freeTopicCount,
  'topics': instance.topics,
};

_$ConceptTopicSummaryImpl _$$ConceptTopicSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$ConceptTopicSummaryImpl(
  topicUuid: json['topicUuid'] as String,
  displayName: json['displayName'] as String,
  orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
  conceptCount: (json['conceptCount'] as num?)?.toInt() ?? 0,
  completedCount: (json['completedCount'] as num?)?.toInt() ?? 0,
  isLocked: json['isLocked'] as bool? ?? false,
);

Map<String, dynamic> _$$ConceptTopicSummaryImplToJson(
  _$ConceptTopicSummaryImpl instance,
) => <String, dynamic>{
  'topicUuid': instance.topicUuid,
  'displayName': instance.displayName,
  'orderIndex': instance.orderIndex,
  'conceptCount': instance.conceptCount,
  'completedCount': instance.completedCount,
  'isLocked': instance.isLocked,
};

_$ConceptListResponseImpl _$$ConceptListResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ConceptListResponseImpl(
  topicUuid: json['topicUuid'] as String,
  displayName: json['displayName'] as String,
  isLocked: json['isLocked'] as bool? ?? false,
  concepts:
      (json['concepts'] as List<dynamic>?)
          ?.map((e) => ConceptSummary.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$ConceptListResponseImplToJson(
  _$ConceptListResponseImpl instance,
) => <String, dynamic>{
  'topicUuid': instance.topicUuid,
  'displayName': instance.displayName,
  'isLocked': instance.isLocked,
  'concepts': instance.concepts,
};

_$ConceptSummaryImpl _$$ConceptSummaryImplFromJson(Map<String, dynamic> json) =>
    _$ConceptSummaryImpl(
      conceptUuid: json['conceptUuid'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String?,
      status:
          $enumDecodeNullable(
            _$ConceptStatusEnumMap,
            json['status'],
            unknownValue: ConceptStatus.notStarted,
          ) ??
          ConceptStatus.notStarted,
      checkCorrectCount: (json['checkCorrectCount'] as num?)?.toInt() ?? 0,
      checkQuestionCount: (json['checkQuestionCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ConceptSummaryImplToJson(
  _$ConceptSummaryImpl instance,
) => <String, dynamic>{
  'conceptUuid': instance.conceptUuid,
  'title': instance.title,
  'summary': instance.summary,
  'status': _$ConceptStatusEnumMap[instance.status]!,
  'checkCorrectCount': instance.checkCorrectCount,
  'checkQuestionCount': instance.checkQuestionCount,
};

const _$ConceptStatusEnumMap = {
  ConceptStatus.notStarted: 'NOT_STARTED',
  ConceptStatus.read: 'READ',
  ConceptStatus.solved: 'SOLVED',
};

_$ConceptDetailResponseImpl _$$ConceptDetailResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ConceptDetailResponseImpl(
  conceptUuid: json['conceptUuid'] as String,
  topicUuid: json['topicUuid'] as String,
  title: json['title'] as String,
  summary: json['summary'] as String?,
  coreMd: json['coreMd'] as String?,
  detailSections:
      (json['detailSections'] as List<dynamic>?)
          ?.map((e) => ConceptDetailSection.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  previousConceptUuid: json['previousConceptUuid'] as String?,
  nextConceptUuid: json['nextConceptUuid'] as String?,
  lastMode:
      $enumDecodeNullable(
        _$ConceptStudyModeEnumMap,
        json['lastMode'],
        unknownValue: ConceptStudyMode.read,
      ) ??
      ConceptStudyMode.read,
  lastDepth:
      $enumDecodeNullable(
        _$ConceptReadingDepthEnumMap,
        json['lastDepth'],
        unknownValue: ConceptReadingDepth.core,
      ) ??
      ConceptReadingDepth.core,
  isRead: json['isRead'] as bool? ?? false,
  checkCorrectCount: (json['checkCorrectCount'] as num?)?.toInt() ?? 0,
  relatedQuestionUuids:
      (json['relatedQuestionUuids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$$ConceptDetailResponseImplToJson(
  _$ConceptDetailResponseImpl instance,
) => <String, dynamic>{
  'conceptUuid': instance.conceptUuid,
  'topicUuid': instance.topicUuid,
  'title': instance.title,
  'summary': instance.summary,
  'coreMd': instance.coreMd,
  'detailSections': instance.detailSections,
  'previousConceptUuid': instance.previousConceptUuid,
  'nextConceptUuid': instance.nextConceptUuid,
  'lastMode': _$ConceptStudyModeEnumMap[instance.lastMode]!,
  'lastDepth': _$ConceptReadingDepthEnumMap[instance.lastDepth]!,
  'isRead': instance.isRead,
  'checkCorrectCount': instance.checkCorrectCount,
  'relatedQuestionUuids': instance.relatedQuestionUuids,
};

const _$ConceptStudyModeEnumMap = {
  ConceptStudyMode.read: 'READ',
  ConceptStudyMode.solve: 'SOLVE',
};

const _$ConceptReadingDepthEnumMap = {
  ConceptReadingDepth.core: 'CORE',
  ConceptReadingDepth.detail: 'DETAIL',
};

_$ConceptDetailSectionImpl _$$ConceptDetailSectionImplFromJson(
  Map<String, dynamic> json,
) => _$ConceptDetailSectionImpl(
  anchor: json['anchor'] as String,
  title: json['title'] as String,
  bodyMd: json['bodyMd'] as String? ?? '',
);

Map<String, dynamic> _$$ConceptDetailSectionImplToJson(
  _$ConceptDetailSectionImpl instance,
) => <String, dynamic>{
  'anchor': instance.anchor,
  'title': instance.title,
  'bodyMd': instance.bodyMd,
};

_$ConceptCheckQuestionResponseImpl _$$ConceptCheckQuestionResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ConceptCheckQuestionResponseImpl(
  questionUuid: json['questionUuid'] as String,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  stem: json['stem'] as String,
  stemSql: json['stemSql'] as String?,
  choices:
      (json['choices'] as List<dynamic>?)
          ?.map(
            (e) =>
                ConceptCheckChoiceResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$$ConceptCheckQuestionResponseImplToJson(
  _$ConceptCheckQuestionResponseImpl instance,
) => <String, dynamic>{
  'questionUuid': instance.questionUuid,
  'sortOrder': instance.sortOrder,
  'stem': instance.stem,
  'stemSql': instance.stemSql,
  'choices': instance.choices,
};

_$ConceptCheckChoiceResponseImpl _$$ConceptCheckChoiceResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ConceptCheckChoiceResponseImpl(
  choiceKey: json['choiceKey'] as String,
  body: json['body'] as String,
);

Map<String, dynamic> _$$ConceptCheckChoiceResponseImplToJson(
  _$ConceptCheckChoiceResponseImpl instance,
) => <String, dynamic>{'choiceKey': instance.choiceKey, 'body': instance.body};

_$ConceptCheckAnswerRequestImpl _$$ConceptCheckAnswerRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ConceptCheckAnswerRequestImpl(choiceKey: json['choiceKey'] as String);

Map<String, dynamic> _$$ConceptCheckAnswerRequestImplToJson(
  _$ConceptCheckAnswerRequestImpl instance,
) => <String, dynamic>{'choiceKey': instance.choiceKey};

_$ConceptCheckAnswerResponseImpl _$$ConceptCheckAnswerResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ConceptCheckAnswerResponseImpl(
  isCorrect: json['isCorrect'] as bool? ?? false,
  correctKey: json['correctKey'] as String,
  explanation: json['explanation'] as String? ?? '',
  rereadAnchor: json['rereadAnchor'] as String? ?? '',
  rationaleByChoiceKey:
      (json['rationaleByChoiceKey'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  checkCorrectCount: (json['checkCorrectCount'] as num?)?.toInt() ?? 0,
  checkSolvedCount: (json['checkSolvedCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$ConceptCheckAnswerResponseImplToJson(
  _$ConceptCheckAnswerResponseImpl instance,
) => <String, dynamic>{
  'isCorrect': instance.isCorrect,
  'correctKey': instance.correctKey,
  'explanation': instance.explanation,
  'rereadAnchor': instance.rereadAnchor,
  'rationaleByChoiceKey': instance.rationaleByChoiceKey,
  'checkCorrectCount': instance.checkCorrectCount,
  'checkSolvedCount': instance.checkSolvedCount,
};

_$ConceptProgressRequestImpl _$$ConceptProgressRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ConceptProgressRequestImpl(
  isRead: json['isRead'] as bool?,
  lastMode: $enumDecodeNullable(_$ConceptStudyModeEnumMap, json['lastMode']),
  lastDepth: $enumDecodeNullable(
    _$ConceptReadingDepthEnumMap,
    json['lastDepth'],
  ),
);

Map<String, dynamic> _$$ConceptProgressRequestImplToJson(
  _$ConceptProgressRequestImpl instance,
) => <String, dynamic>{
  'isRead': instance.isRead,
  'lastMode': _$ConceptStudyModeEnumMap[instance.lastMode],
  'lastDepth': _$ConceptReadingDepthEnumMap[instance.lastDepth],
};
