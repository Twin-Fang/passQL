// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expected_pass_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpectedPassSubjectAverageImpl _$$ExpectedPassSubjectAverageImplFromJson(
  Map<String, dynamic> json,
) => _$ExpectedPassSubjectAverageImpl(
  subject:
      $enumDecodeNullable(
        _$MockExamSubjectEnumMap,
        json['subject'],
        unknownValue: MockExamSubject.unknown,
      ) ??
      MockExamSubject.unknown,
  subjectName: json['subjectName'] as String? ?? '',
  averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0,
  maxScore: (json['maxScore'] as num?)?.toInt() ?? 0,
  failBelowScore: (json['failBelowScore'] as num?)?.toInt() ?? 0,
  isFailRisk: json['isFailRisk'] as bool? ?? false,
);

Map<String, dynamic> _$$ExpectedPassSubjectAverageImplToJson(
  _$ExpectedPassSubjectAverageImpl instance,
) => <String, dynamic>{
  'subject': _$MockExamSubjectEnumMap[instance.subject]!,
  'subjectName': instance.subjectName,
  'averageScore': instance.averageScore,
  'maxScore': instance.maxScore,
  'failBelowScore': instance.failBelowScore,
  'isFailRisk': instance.isFailRisk,
};

const _$MockExamSubjectEnumMap = {
  MockExamSubject.subjectOne: 'SUBJECT_ONE',
  MockExamSubject.subjectTwo: 'SUBJECT_TWO',
  MockExamSubject.unknown: 'unknown',
};

_$ExpectedPassResponseImpl _$$ExpectedPassResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ExpectedPassResponseImpl(
  expectedPassPercent: (json['expectedPassPercent'] as num?)?.toInt(),
  averageScore: (json['averageScore'] as num?)?.toDouble(),
  basisAttemptCount: (json['basisAttemptCount'] as num?)?.toInt() ?? 0,
  passedAttemptCount: (json['passedAttemptCount'] as num?)?.toInt() ?? 0,
  passScore: (json['passScore'] as num?)?.toInt() ?? 0,
  subjectAverages:
      (json['subjectAverages'] as List<dynamic>?)
          ?.map(
            (e) =>
                ExpectedPassSubjectAverage.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  officialPassRatePercent: (json['officialPassRatePercent'] as num?)
      ?.toDouble(),
  officialStatisticYear: (json['officialStatisticYear'] as num?)?.toInt(),
);

Map<String, dynamic> _$$ExpectedPassResponseImplToJson(
  _$ExpectedPassResponseImpl instance,
) => <String, dynamic>{
  'expectedPassPercent': instance.expectedPassPercent,
  'averageScore': instance.averageScore,
  'basisAttemptCount': instance.basisAttemptCount,
  'passedAttemptCount': instance.passedAttemptCount,
  'passScore': instance.passScore,
  'subjectAverages': instance.subjectAverages,
  'officialPassRatePercent': instance.officialPassRatePercent,
  'officialStatisticYear': instance.officialStatisticYear,
};
