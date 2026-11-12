// freezed 생성자 파라미터의 JsonKey 는 정상 사용법이라 경고를 끈다.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'exam_schedule_response.freezed.dart';
part 'exam_schedule_response.g.dart';

/// 시험 단계 6종 (서버가 KST 오늘 기준 계산, #991) + 앱이 모르는 값
enum ExamSchedulePhase {
  @JsonValue('BEFORE_APPLICATION')
  beforeApplication,
  @JsonValue('APPLICATION_OPEN')
  applicationOpen,
  @JsonValue('WAITING_ADMISSION_TICKET')
  waitingAdmissionTicket,
  // 수험표 발급 ~ 시험 당일
  @JsonValue('WAITING_EXAM')
  waitingExam,
  @JsonValue('WAITING_RESULT')
  waitingResult,
  // 합격 발표일부터
  @JsonValue('FINISHED')
  finished,
  // 서버에 새 단계가 생겼을 때 (단계 표시 없이 D-day 만)
  unknown,
}

/// 시험 일정 1건: GET /exam-schedules/selected·/exam-schedules/sqld 공용
/// 선택된 시험 없으면 서버가 200 + null body 반환. 날짜는 yyyy-MM-dd, 일정 칸은 모르면 null (#991)
@freezed
class ExamScheduleResponse with _$ExamScheduleResponse {
  const factory ExamScheduleResponse({
    required String examScheduleUuid,
    required String certType,
    required int round,
    required String examDate,
    required bool isSelected,
    // 원서 접수 시작·마감
    String? applicationStartDate,
    String? applicationEndDate,
    // 수험표 발급
    String? admissionTicketDate,
    // 사전 점수 공개·재검토 접수 시작·마감
    String? preliminaryScoreStartDate,
    String? preliminaryScoreEndDate,
    // 합격 발표
    String? resultAnnouncementDate,
    @JsonKey(unknownEnumValue: ExamSchedulePhase.unknown)
    @Default(ExamSchedulePhase.unknown)
    ExamSchedulePhase phase,
  }) = _ExamScheduleResponse;

  factory ExamScheduleResponse.fromJson(Map<String, dynamic> json) =>
      _$ExamScheduleResponseFromJson(json);
}
