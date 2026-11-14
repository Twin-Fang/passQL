// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_answer_round_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExamAnswerRoundResponseImpl _$$ExamAnswerRoundResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ExamAnswerRoundResponseImpl(
  round: ExamAnswerRound.fromJson(
    _readRoundJson(json, 'round') as Map<String, dynamic>,
  ),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => ExamAnswerItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$ExamAnswerRoundResponseImplToJson(
  _$ExamAnswerRoundResponseImpl instance,
) => <String, dynamic>{
  'round': instance.round,
  'items': instance.items,
  'participantCount': instance.participantCount,
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

_$ExamAnswerRoundImpl _$$ExamAnswerRoundImplFromJson(
  Map<String, dynamic> json,
) => _$ExamAnswerRoundImpl(
  certType: json['certType'] as String,
  roundNumber: (json['roundNumber'] as num).toInt(),
  title: json['title'] as String? ?? '',
  examDate: json['examDate'] as String?,
  status:
      $enumDecodeNullable(
        _$ExamAnswerRoundStatusEnumMap,
        json['status'],
        unknownValue: ExamAnswerRoundStatus.unknown,
      ) ??
      ExamAnswerRoundStatus.unknown,
  notice: json['notice'] as String?,
);

Map<String, dynamic> _$$ExamAnswerRoundImplToJson(
  _$ExamAnswerRoundImpl instance,
) => <String, dynamic>{
  'certType': instance.certType,
  'roundNumber': instance.roundNumber,
  'title': instance.title,
  'examDate': instance.examDate,
  'status': _$ExamAnswerRoundStatusEnumMap[instance.status]!,
  'notice': instance.notice,
};

const _$ExamAnswerRoundStatusEnumMap = {
  ExamAnswerRoundStatus.collecting: 'COLLECTING',
  ExamAnswerRoundStatus.official: 'OFFICIAL',
  ExamAnswerRoundStatus.closed: 'CLOSED',
  ExamAnswerRoundStatus.unknown: 'unknown',
};

_$ExamAnswerItemImpl _$$ExamAnswerItemImplFromJson(Map<String, dynamic> json) =>
    _$ExamAnswerItemImpl(
      questionNo: (json['questionNo'] as num).toInt(),
      subjectNo: (json['subjectNo'] as num).toInt(),
      conceptTitle: json['conceptTitle'] as String? ?? '',
      conceptTags: json['conceptTags'] == null
          ? const []
          : const ExamAnswerStringListConverter().fromJson(
              json['conceptTags'] as Object,
            ),
      topicCode: json['topicCode'] as String?,
      answer: (json['answer'] as num?)?.toInt(),
      answerStatus:
          $enumDecodeNullable(
            _$ExamAnswerItemStatusEnumMap,
            json['answerStatus'],
            unknownValue: ExamAnswerItemStatus.unknown,
          ) ??
          ExamAnswerItemStatus.undecided,
      alternativeAnswers: json['alternativeAnswers'] == null
          ? const []
          : const ExamAnswerIntListConverter().fromJson(
              json['alternativeAnswers'] as Object,
            ),
      tally: json['tally'] == null
          ? const [0, 0, 0, 0]
          : const ExamAnswerTallyConverter().fromJson(json['tally'] as Object),
      voteCount: (json['voteCount'] as num?)?.toInt() ?? 0,
      agreementRate: (json['agreementRate'] as num?)?.toDouble() ?? 0,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$$ExamAnswerItemImplToJson(
  _$ExamAnswerItemImpl instance,
) => <String, dynamic>{
  'questionNo': instance.questionNo,
  'subjectNo': instance.subjectNo,
  'conceptTitle': instance.conceptTitle,
  'conceptTags': const ExamAnswerStringListConverter().toJson(
    instance.conceptTags,
  ),
  'topicCode': instance.topicCode,
  'answer': instance.answer,
  'answerStatus': _$ExamAnswerItemStatusEnumMap[instance.answerStatus]!,
  'alternativeAnswers': const ExamAnswerIntListConverter().toJson(
    instance.alternativeAnswers,
  ),
  'tally': const ExamAnswerTallyConverter().toJson(instance.tally),
  'voteCount': instance.voteCount,
  'agreementRate': instance.agreementRate,
  'note': instance.note,
};

const _$ExamAnswerItemStatusEnumMap = {
  ExamAnswerItemStatus.undecided: 'UNKNOWN',
  ExamAnswerItemStatus.leading: 'LEADING',
  ExamAnswerItemStatus.disputed: 'DISPUTED',
  ExamAnswerItemStatus.confirmed: 'CONFIRMED',
  ExamAnswerItemStatus.official: 'OFFICIAL',
  ExamAnswerItemStatus.unknown: 'unknown',
};
