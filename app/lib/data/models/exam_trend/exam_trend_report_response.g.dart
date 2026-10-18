// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_trend_report_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExamTrendReportResponseImpl _$$ExamTrendReportResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ExamTrendReportResponseImpl(
  title: json['title'] as String,
  basisDescription: json['basisDescription'] as String,
  updatedDate: json['updatedDate'] as String,
  summary: json['summary'] as String,
  latestTrendQuestionCount:
      (json['latestTrendQuestionCount'] as num?)?.toInt() ?? 0,
  subjectShares:
      (json['subjectShares'] as List<dynamic>?)
          ?.map(
            (e) => ExamTrendSubjectShare.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  risingPatterns:
      (json['risingPatterns'] as List<dynamic>?)
          ?.map((e) => ExamTrendPattern.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  frequentConcepts:
      (json['frequentConcepts'] as List<dynamic>?)
          ?.map((e) => ExamTrendConcept.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  studyTips:
      (json['studyTips'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  latestTrendTopics:
      (json['latestTrendTopics'] as List<dynamic>?)
          ?.map(
            (e) => LatestTrendTopicCount.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$$ExamTrendReportResponseImplToJson(
  _$ExamTrendReportResponseImpl instance,
) => <String, dynamic>{
  'title': instance.title,
  'basisDescription': instance.basisDescription,
  'updatedDate': instance.updatedDate,
  'summary': instance.summary,
  'latestTrendQuestionCount': instance.latestTrendQuestionCount,
  'subjectShares': instance.subjectShares,
  'risingPatterns': instance.risingPatterns,
  'frequentConcepts': instance.frequentConcepts,
  'studyTips': instance.studyTips,
  'latestTrendTopics': instance.latestTrendTopics,
};

_$ExamTrendSubjectShareImpl _$$ExamTrendSubjectShareImplFromJson(
  Map<String, dynamic> json,
) => _$ExamTrendSubjectShareImpl(
  subjectName: json['subjectName'] as String,
  questionCount: (json['questionCount'] as num).toInt(),
  percent: (json['percent'] as num).toInt(),
  description: json['description'] as String,
);

Map<String, dynamic> _$$ExamTrendSubjectShareImplToJson(
  _$ExamTrendSubjectShareImpl instance,
) => <String, dynamic>{
  'subjectName': instance.subjectName,
  'questionCount': instance.questionCount,
  'percent': instance.percent,
  'description': instance.description,
};

_$ExamTrendPatternImpl _$$ExamTrendPatternImplFromJson(
  Map<String, dynamic> json,
) => _$ExamTrendPatternImpl(
  title: json['title'] as String,
  description: json['description'] as String,
  examRoundsText: json['examRoundsText'] as String,
  topicCode: json['topicCode'] as String,
  topicName: json['topicName'] as String?,
  latestTrendQuestionCount:
      (json['latestTrendQuestionCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$ExamTrendPatternImplToJson(
  _$ExamTrendPatternImpl instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'examRoundsText': instance.examRoundsText,
  'topicCode': instance.topicCode,
  'topicName': instance.topicName,
  'latestTrendQuestionCount': instance.latestTrendQuestionCount,
};

_$ExamTrendConceptImpl _$$ExamTrendConceptImplFromJson(
  Map<String, dynamic> json,
) => _$ExamTrendConceptImpl(
  rank: (json['rank'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  frequencyText: json['frequencyText'] as String,
  topicCode: json['topicCode'] as String,
  topicName: json['topicName'] as String?,
  latestTrendQuestionCount:
      (json['latestTrendQuestionCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$ExamTrendConceptImplToJson(
  _$ExamTrendConceptImpl instance,
) => <String, dynamic>{
  'rank': instance.rank,
  'name': instance.name,
  'description': instance.description,
  'frequencyText': instance.frequencyText,
  'topicCode': instance.topicCode,
  'topicName': instance.topicName,
  'latestTrendQuestionCount': instance.latestTrendQuestionCount,
};

_$LatestTrendTopicCountImpl _$$LatestTrendTopicCountImplFromJson(
  Map<String, dynamic> json,
) => _$LatestTrendTopicCountImpl(
  topicCode: json['topicCode'] as String,
  topicName: json['topicName'] as String,
  latestTrendQuestionCount:
      (json['latestTrendQuestionCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$LatestTrendTopicCountImplToJson(
  _$LatestTrendTopicCountImpl instance,
) => <String, dynamic>{
  'topicCode': instance.topicCode,
  'topicName': instance.topicName,
  'latestTrendQuestionCount': instance.latestTrendQuestionCount,
};
