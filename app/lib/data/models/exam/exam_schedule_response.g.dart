// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_schedule_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExamScheduleResponseImpl _$$ExamScheduleResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ExamScheduleResponseImpl(
  examScheduleUuid: json['examScheduleUuid'] as String,
  certType: json['certType'] as String,
  round: (json['round'] as num).toInt(),
  examDate: json['examDate'] as String,
  isSelected: json['isSelected'] as bool,
  applicationStartDate: json['applicationStartDate'] as String?,
  applicationEndDate: json['applicationEndDate'] as String?,
  admissionTicketDate: json['admissionTicketDate'] as String?,
  preliminaryScoreStartDate: json['preliminaryScoreStartDate'] as String?,
  preliminaryScoreEndDate: json['preliminaryScoreEndDate'] as String?,
  resultAnnouncementDate: json['resultAnnouncementDate'] as String?,
  phase:
      $enumDecodeNullable(
        _$ExamSchedulePhaseEnumMap,
        json['phase'],
        unknownValue: ExamSchedulePhase.unknown,
      ) ??
      ExamSchedulePhase.unknown,
);

Map<String, dynamic> _$$ExamScheduleResponseImplToJson(
  _$ExamScheduleResponseImpl instance,
) => <String, dynamic>{
  'examScheduleUuid': instance.examScheduleUuid,
  'certType': instance.certType,
  'round': instance.round,
  'examDate': instance.examDate,
  'isSelected': instance.isSelected,
  'applicationStartDate': instance.applicationStartDate,
  'applicationEndDate': instance.applicationEndDate,
  'admissionTicketDate': instance.admissionTicketDate,
  'preliminaryScoreStartDate': instance.preliminaryScoreStartDate,
  'preliminaryScoreEndDate': instance.preliminaryScoreEndDate,
  'resultAnnouncementDate': instance.resultAnnouncementDate,
  'phase': _$ExamSchedulePhaseEnumMap[instance.phase]!,
};

const _$ExamSchedulePhaseEnumMap = {
  ExamSchedulePhase.beforeApplication: 'BEFORE_APPLICATION',
  ExamSchedulePhase.applicationOpen: 'APPLICATION_OPEN',
  ExamSchedulePhase.waitingAdmissionTicket: 'WAITING_ADMISSION_TICKET',
  ExamSchedulePhase.waitingExam: 'WAITING_EXAM',
  ExamSchedulePhase.waitingResult: 'WAITING_RESULT',
  ExamSchedulePhase.finished: 'FINISHED',
  ExamSchedulePhase.unknown: 'unknown',
};
