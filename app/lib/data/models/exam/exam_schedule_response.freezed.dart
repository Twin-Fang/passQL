// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exam_schedule_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExamScheduleResponse _$ExamScheduleResponseFromJson(Map<String, dynamic> json) {
  return _ExamScheduleResponse.fromJson(json);
}

/// @nodoc
mixin _$ExamScheduleResponse {
  String get examScheduleUuid => throw _privateConstructorUsedError;
  String get certType => throw _privateConstructorUsedError;
  int get round => throw _privateConstructorUsedError;
  String get examDate => throw _privateConstructorUsedError;
  bool get isSelected => throw _privateConstructorUsedError; // 원서 접수 시작·마감
  String? get applicationStartDate => throw _privateConstructorUsedError;
  String? get applicationEndDate =>
      throw _privateConstructorUsedError; // 수험표 발급
  String? get admissionTicketDate =>
      throw _privateConstructorUsedError; // 사전 점수 공개·재검토 접수 시작·마감
  String? get preliminaryScoreStartDate => throw _privateConstructorUsedError;
  String? get preliminaryScoreEndDate =>
      throw _privateConstructorUsedError; // 합격 발표
  String? get resultAnnouncementDate => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: ExamSchedulePhase.unknown)
  ExamSchedulePhase get phase => throw _privateConstructorUsedError;

  /// Serializes this ExamScheduleResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamScheduleResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamScheduleResponseCopyWith<ExamScheduleResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamScheduleResponseCopyWith<$Res> {
  factory $ExamScheduleResponseCopyWith(
    ExamScheduleResponse value,
    $Res Function(ExamScheduleResponse) then,
  ) = _$ExamScheduleResponseCopyWithImpl<$Res, ExamScheduleResponse>;
  @useResult
  $Res call({
    String examScheduleUuid,
    String certType,
    int round,
    String examDate,
    bool isSelected,
    String? applicationStartDate,
    String? applicationEndDate,
    String? admissionTicketDate,
    String? preliminaryScoreStartDate,
    String? preliminaryScoreEndDate,
    String? resultAnnouncementDate,
    @JsonKey(unknownEnumValue: ExamSchedulePhase.unknown)
    ExamSchedulePhase phase,
  });
}

/// @nodoc
class _$ExamScheduleResponseCopyWithImpl<
  $Res,
  $Val extends ExamScheduleResponse
>
    implements $ExamScheduleResponseCopyWith<$Res> {
  _$ExamScheduleResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamScheduleResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? examScheduleUuid = null,
    Object? certType = null,
    Object? round = null,
    Object? examDate = null,
    Object? isSelected = null,
    Object? applicationStartDate = freezed,
    Object? applicationEndDate = freezed,
    Object? admissionTicketDate = freezed,
    Object? preliminaryScoreStartDate = freezed,
    Object? preliminaryScoreEndDate = freezed,
    Object? resultAnnouncementDate = freezed,
    Object? phase = null,
  }) {
    return _then(
      _value.copyWith(
            examScheduleUuid: null == examScheduleUuid
                ? _value.examScheduleUuid
                : examScheduleUuid // ignore: cast_nullable_to_non_nullable
                      as String,
            certType: null == certType
                ? _value.certType
                : certType // ignore: cast_nullable_to_non_nullable
                      as String,
            round: null == round
                ? _value.round
                : round // ignore: cast_nullable_to_non_nullable
                      as int,
            examDate: null == examDate
                ? _value.examDate
                : examDate // ignore: cast_nullable_to_non_nullable
                      as String,
            isSelected: null == isSelected
                ? _value.isSelected
                : isSelected // ignore: cast_nullable_to_non_nullable
                      as bool,
            applicationStartDate: freezed == applicationStartDate
                ? _value.applicationStartDate
                : applicationStartDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            applicationEndDate: freezed == applicationEndDate
                ? _value.applicationEndDate
                : applicationEndDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            admissionTicketDate: freezed == admissionTicketDate
                ? _value.admissionTicketDate
                : admissionTicketDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            preliminaryScoreStartDate: freezed == preliminaryScoreStartDate
                ? _value.preliminaryScoreStartDate
                : preliminaryScoreStartDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            preliminaryScoreEndDate: freezed == preliminaryScoreEndDate
                ? _value.preliminaryScoreEndDate
                : preliminaryScoreEndDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            resultAnnouncementDate: freezed == resultAnnouncementDate
                ? _value.resultAnnouncementDate
                : resultAnnouncementDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            phase: null == phase
                ? _value.phase
                : phase // ignore: cast_nullable_to_non_nullable
                      as ExamSchedulePhase,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExamScheduleResponseImplCopyWith<$Res>
    implements $ExamScheduleResponseCopyWith<$Res> {
  factory _$$ExamScheduleResponseImplCopyWith(
    _$ExamScheduleResponseImpl value,
    $Res Function(_$ExamScheduleResponseImpl) then,
  ) = __$$ExamScheduleResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String examScheduleUuid,
    String certType,
    int round,
    String examDate,
    bool isSelected,
    String? applicationStartDate,
    String? applicationEndDate,
    String? admissionTicketDate,
    String? preliminaryScoreStartDate,
    String? preliminaryScoreEndDate,
    String? resultAnnouncementDate,
    @JsonKey(unknownEnumValue: ExamSchedulePhase.unknown)
    ExamSchedulePhase phase,
  });
}

/// @nodoc
class __$$ExamScheduleResponseImplCopyWithImpl<$Res>
    extends _$ExamScheduleResponseCopyWithImpl<$Res, _$ExamScheduleResponseImpl>
    implements _$$ExamScheduleResponseImplCopyWith<$Res> {
  __$$ExamScheduleResponseImplCopyWithImpl(
    _$ExamScheduleResponseImpl _value,
    $Res Function(_$ExamScheduleResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamScheduleResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? examScheduleUuid = null,
    Object? certType = null,
    Object? round = null,
    Object? examDate = null,
    Object? isSelected = null,
    Object? applicationStartDate = freezed,
    Object? applicationEndDate = freezed,
    Object? admissionTicketDate = freezed,
    Object? preliminaryScoreStartDate = freezed,
    Object? preliminaryScoreEndDate = freezed,
    Object? resultAnnouncementDate = freezed,
    Object? phase = null,
  }) {
    return _then(
      _$ExamScheduleResponseImpl(
        examScheduleUuid: null == examScheduleUuid
            ? _value.examScheduleUuid
            : examScheduleUuid // ignore: cast_nullable_to_non_nullable
                  as String,
        certType: null == certType
            ? _value.certType
            : certType // ignore: cast_nullable_to_non_nullable
                  as String,
        round: null == round
            ? _value.round
            : round // ignore: cast_nullable_to_non_nullable
                  as int,
        examDate: null == examDate
            ? _value.examDate
            : examDate // ignore: cast_nullable_to_non_nullable
                  as String,
        isSelected: null == isSelected
            ? _value.isSelected
            : isSelected // ignore: cast_nullable_to_non_nullable
                  as bool,
        applicationStartDate: freezed == applicationStartDate
            ? _value.applicationStartDate
            : applicationStartDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        applicationEndDate: freezed == applicationEndDate
            ? _value.applicationEndDate
            : applicationEndDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        admissionTicketDate: freezed == admissionTicketDate
            ? _value.admissionTicketDate
            : admissionTicketDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        preliminaryScoreStartDate: freezed == preliminaryScoreStartDate
            ? _value.preliminaryScoreStartDate
            : preliminaryScoreStartDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        preliminaryScoreEndDate: freezed == preliminaryScoreEndDate
            ? _value.preliminaryScoreEndDate
            : preliminaryScoreEndDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        resultAnnouncementDate: freezed == resultAnnouncementDate
            ? _value.resultAnnouncementDate
            : resultAnnouncementDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        phase: null == phase
            ? _value.phase
            : phase // ignore: cast_nullable_to_non_nullable
                  as ExamSchedulePhase,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamScheduleResponseImpl implements _ExamScheduleResponse {
  const _$ExamScheduleResponseImpl({
    required this.examScheduleUuid,
    required this.certType,
    required this.round,
    required this.examDate,
    required this.isSelected,
    this.applicationStartDate,
    this.applicationEndDate,
    this.admissionTicketDate,
    this.preliminaryScoreStartDate,
    this.preliminaryScoreEndDate,
    this.resultAnnouncementDate,
    @JsonKey(unknownEnumValue: ExamSchedulePhase.unknown)
    this.phase = ExamSchedulePhase.unknown,
  });

  factory _$ExamScheduleResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamScheduleResponseImplFromJson(json);

  @override
  final String examScheduleUuid;
  @override
  final String certType;
  @override
  final int round;
  @override
  final String examDate;
  @override
  final bool isSelected;
  // 원서 접수 시작·마감
  @override
  final String? applicationStartDate;
  @override
  final String? applicationEndDate;
  // 수험표 발급
  @override
  final String? admissionTicketDate;
  // 사전 점수 공개·재검토 접수 시작·마감
  @override
  final String? preliminaryScoreStartDate;
  @override
  final String? preliminaryScoreEndDate;
  // 합격 발표
  @override
  final String? resultAnnouncementDate;
  @override
  @JsonKey(unknownEnumValue: ExamSchedulePhase.unknown)
  final ExamSchedulePhase phase;

  @override
  String toString() {
    return 'ExamScheduleResponse(examScheduleUuid: $examScheduleUuid, certType: $certType, round: $round, examDate: $examDate, isSelected: $isSelected, applicationStartDate: $applicationStartDate, applicationEndDate: $applicationEndDate, admissionTicketDate: $admissionTicketDate, preliminaryScoreStartDate: $preliminaryScoreStartDate, preliminaryScoreEndDate: $preliminaryScoreEndDate, resultAnnouncementDate: $resultAnnouncementDate, phase: $phase)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamScheduleResponseImpl &&
            (identical(other.examScheduleUuid, examScheduleUuid) ||
                other.examScheduleUuid == examScheduleUuid) &&
            (identical(other.certType, certType) ||
                other.certType == certType) &&
            (identical(other.round, round) || other.round == round) &&
            (identical(other.examDate, examDate) ||
                other.examDate == examDate) &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected) &&
            (identical(other.applicationStartDate, applicationStartDate) ||
                other.applicationStartDate == applicationStartDate) &&
            (identical(other.applicationEndDate, applicationEndDate) ||
                other.applicationEndDate == applicationEndDate) &&
            (identical(other.admissionTicketDate, admissionTicketDate) ||
                other.admissionTicketDate == admissionTicketDate) &&
            (identical(
                  other.preliminaryScoreStartDate,
                  preliminaryScoreStartDate,
                ) ||
                other.preliminaryScoreStartDate == preliminaryScoreStartDate) &&
            (identical(
                  other.preliminaryScoreEndDate,
                  preliminaryScoreEndDate,
                ) ||
                other.preliminaryScoreEndDate == preliminaryScoreEndDate) &&
            (identical(other.resultAnnouncementDate, resultAnnouncementDate) ||
                other.resultAnnouncementDate == resultAnnouncementDate) &&
            (identical(other.phase, phase) || other.phase == phase));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    examScheduleUuid,
    certType,
    round,
    examDate,
    isSelected,
    applicationStartDate,
    applicationEndDate,
    admissionTicketDate,
    preliminaryScoreStartDate,
    preliminaryScoreEndDate,
    resultAnnouncementDate,
    phase,
  );

  /// Create a copy of ExamScheduleResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamScheduleResponseImplCopyWith<_$ExamScheduleResponseImpl>
  get copyWith =>
      __$$ExamScheduleResponseImplCopyWithImpl<_$ExamScheduleResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamScheduleResponseImplToJson(this);
  }
}

abstract class _ExamScheduleResponse implements ExamScheduleResponse {
  const factory _ExamScheduleResponse({
    required final String examScheduleUuid,
    required final String certType,
    required final int round,
    required final String examDate,
    required final bool isSelected,
    final String? applicationStartDate,
    final String? applicationEndDate,
    final String? admissionTicketDate,
    final String? preliminaryScoreStartDate,
    final String? preliminaryScoreEndDate,
    final String? resultAnnouncementDate,
    @JsonKey(unknownEnumValue: ExamSchedulePhase.unknown)
    final ExamSchedulePhase phase,
  }) = _$ExamScheduleResponseImpl;

  factory _ExamScheduleResponse.fromJson(Map<String, dynamic> json) =
      _$ExamScheduleResponseImpl.fromJson;

  @override
  String get examScheduleUuid;
  @override
  String get certType;
  @override
  int get round;
  @override
  String get examDate;
  @override
  bool get isSelected; // 원서 접수 시작·마감
  @override
  String? get applicationStartDate;
  @override
  String? get applicationEndDate; // 수험표 발급
  @override
  String? get admissionTicketDate; // 사전 점수 공개·재검토 접수 시작·마감
  @override
  String? get preliminaryScoreStartDate;
  @override
  String? get preliminaryScoreEndDate; // 합격 발표
  @override
  String? get resultAnnouncementDate;
  @override
  @JsonKey(unknownEnumValue: ExamSchedulePhase.unknown)
  ExamSchedulePhase get phase;

  /// Create a copy of ExamScheduleResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamScheduleResponseImplCopyWith<_$ExamScheduleResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
