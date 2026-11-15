// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sqld_exam_guide.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SqldExamGuideImpl _$$SqldExamGuideImplFromJson(
  Map<String, dynamic> json,
) => _$SqldExamGuideImpl(
  oneLineDefinition: json['oneLineDefinition'] as String,
  organizerName: json['organizerName'] as String,
  certificationNumber: json['certificationNumber'] as String,
  recommendedFor:
      (json['recommendedFor'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  subjects:
      (json['subjects'] as List<dynamic>?)
          ?.map((e) => SqldExamSubject.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SqldExamSubject>[],
  examDurationMinutes: (json['examDurationMinutes'] as num).toInt(),
  passingTotalScore: (json['passingTotalScore'] as num).toInt(),
  failingSubjectPercent: (json['failingSubjectPercent'] as num).toInt(),
  examFeeWon: (json['examFeeWon'] as num).toInt(),
  validityDescription: json['validityDescription'] as String,
  faqs:
      (json['faqs'] as List<dynamic>?)
          ?.map((e) => SqldExamFaq.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SqldExamFaq>[],
  yearlyStatistics:
      (json['yearlyStatistics'] as List<dynamic>?)
          ?.map((e) => SqldYearlyStatistic.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SqldYearlyStatistic>[],
  roundNotes:
      (json['roundNotes'] as List<dynamic>?)
          ?.map((e) => SqldRoundNote.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SqldRoundNote>[],
  comparisons:
      (json['comparisons'] as List<dynamic>?)
          ?.map(
            (e) =>
                SqldCertificationComparison.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <SqldCertificationComparison>[],
  insights: json['insights'] == null
      ? null
      : SqldExamInsights.fromJson(json['insights'] as Map<String, dynamic>),
  sources:
      (json['sources'] as List<dynamic>?)
          ?.map((e) => SqldExamSource.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SqldExamSource>[],
);

Map<String, dynamic> _$$SqldExamGuideImplToJson(_$SqldExamGuideImpl instance) =>
    <String, dynamic>{
      'oneLineDefinition': instance.oneLineDefinition,
      'organizerName': instance.organizerName,
      'certificationNumber': instance.certificationNumber,
      'recommendedFor': instance.recommendedFor,
      'subjects': instance.subjects,
      'examDurationMinutes': instance.examDurationMinutes,
      'passingTotalScore': instance.passingTotalScore,
      'failingSubjectPercent': instance.failingSubjectPercent,
      'examFeeWon': instance.examFeeWon,
      'validityDescription': instance.validityDescription,
      'faqs': instance.faqs,
      'yearlyStatistics': instance.yearlyStatistics,
      'roundNotes': instance.roundNotes,
      'comparisons': instance.comparisons,
      'insights': instance.insights,
      'sources': instance.sources,
    };

_$SqldExamSubjectImpl _$$SqldExamSubjectImplFromJson(
  Map<String, dynamic> json,
) => _$SqldExamSubjectImpl(
  name: json['name'] as String,
  questionCount: (json['questionCount'] as num).toInt(),
  points: (json['points'] as num).toInt(),
);

Map<String, dynamic> _$$SqldExamSubjectImplToJson(
  _$SqldExamSubjectImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'questionCount': instance.questionCount,
  'points': instance.points,
};

_$SqldExamFaqImpl _$$SqldExamFaqImplFromJson(Map<String, dynamic> json) =>
    _$SqldExamFaqImpl(
      question: json['question'] as String,
      answer: json['answer'] as String,
    );

Map<String, dynamic> _$$SqldExamFaqImplToJson(_$SqldExamFaqImpl instance) =>
    <String, dynamic>{'question': instance.question, 'answer': instance.answer};

_$SqldYearlyStatisticImpl _$$SqldYearlyStatisticImplFromJson(
  Map<String, dynamic> json,
) => _$SqldYearlyStatisticImpl(
  year: (json['year'] as num).toInt(),
  applicantCount: (json['applicantCount'] as num).toInt(),
  examineeCount: (json['examineeCount'] as num).toInt(),
  passerCount: (json['passerCount'] as num).toInt(),
  passRatePercent: (json['passRatePercent'] as num).toDouble(),
);

Map<String, dynamic> _$$SqldYearlyStatisticImplToJson(
  _$SqldYearlyStatisticImpl instance,
) => <String, dynamic>{
  'year': instance.year,
  'applicantCount': instance.applicantCount,
  'examineeCount': instance.examineeCount,
  'passerCount': instance.passerCount,
  'passRatePercent': instance.passRatePercent,
};

_$SqldRoundNoteImpl _$$SqldRoundNoteImplFromJson(Map<String, dynamic> json) =>
    _$SqldRoundNoteImpl(
      round: (json['round'] as num).toInt(),
      examDate: json['examDate'] as String,
      difficultyNote: json['difficultyNote'] as String,
      passRatePercent: (json['passRatePercent'] as num?)?.toDouble(),
      isOfficial: json['isOfficial'] as bool? ?? false,
    );

Map<String, dynamic> _$$SqldRoundNoteImplToJson(_$SqldRoundNoteImpl instance) =>
    <String, dynamic>{
      'round': instance.round,
      'examDate': instance.examDate,
      'difficultyNote': instance.difficultyNote,
      'passRatePercent': instance.passRatePercent,
      'isOfficial': instance.isOfficial,
    };

_$SqldCertificationComparisonImpl _$$SqldCertificationComparisonImplFromJson(
  Map<String, dynamic> json,
) => _$SqldCertificationComparisonImpl(
  certificationName: json['certificationName'] as String,
  year: (json['year'] as num).toInt(),
  passRatePercent: (json['passRatePercent'] as num).toDouble(),
);

Map<String, dynamic> _$$SqldCertificationComparisonImplToJson(
  _$SqldCertificationComparisonImpl instance,
) => <String, dynamic>{
  'certificationName': instance.certificationName,
  'year': instance.year,
  'passRatePercent': instance.passRatePercent,
};

_$SqldExamInsightsImpl _$$SqldExamInsightsImplFromJson(
  Map<String, dynamic> json,
) => _$SqldExamInsightsImpl(
  latestYear: (json['latestYear'] as num).toInt(),
  previousYear: (json['previousYear'] as num).toInt(),
  growthBaseYear: (json['growthBaseYear'] as num).toInt(),
  examineeGrowthMultiple: (json['examineeGrowthMultiple'] as num).toDouble(),
  passRateChangePoints: (json['passRateChangePoints'] as num).toDouble(),
);

Map<String, dynamic> _$$SqldExamInsightsImplToJson(
  _$SqldExamInsightsImpl instance,
) => <String, dynamic>{
  'latestYear': instance.latestYear,
  'previousYear': instance.previousYear,
  'growthBaseYear': instance.growthBaseYear,
  'examineeGrowthMultiple': instance.examineeGrowthMultiple,
  'passRateChangePoints': instance.passRateChangePoints,
};

_$SqldExamSourceImpl _$$SqldExamSourceImplFromJson(Map<String, dynamic> json) =>
    _$SqldExamSourceImpl(
      name: json['name'] as String,
      url: json['url'] as String?,
      checkedDate: json['checkedDate'] as String,
    );

Map<String, dynamic> _$$SqldExamSourceImplToJson(
  _$SqldExamSourceImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'url': instance.url,
  'checkedDate': instance.checkedDate,
};
