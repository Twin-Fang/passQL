// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sqld_exam_schedule_overview_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SqldExamScheduleOverviewResponse _$SqldExamScheduleOverviewResponseFromJson(
  Map<String, dynamic> json,
) {
  return _SqldExamScheduleOverviewResponse.fromJson(json);
}

/// @nodoc
mixin _$SqldExamScheduleOverviewResponse {
  int get year => throw _privateConstructorUsedError; // 그해 회차 (회차 오름차순)
  List<ExamScheduleResponse> get schedules =>
      throw _privateConstructorUsedError; // 오늘 이후 가장 가까운 시험 (연도 무관, 없으면 null)
  ExamScheduleResponse? get nextSchedule =>
      throw _privateConstructorUsedError; // 마지막 자동 수집 성공 시각 (KST, 없으면 null)
  DateTime? get lastCollectedAt =>
      throw _privateConstructorUsedError; // 공식 일정·접수 페이지 (데이터자격검정)
  String? get officialScheduleUrl => throw _privateConstructorUsedError;

  /// Serializes this SqldExamScheduleOverviewResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SqldExamScheduleOverviewResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SqldExamScheduleOverviewResponseCopyWith<SqldExamScheduleOverviewResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SqldExamScheduleOverviewResponseCopyWith<$Res> {
  factory $SqldExamScheduleOverviewResponseCopyWith(
    SqldExamScheduleOverviewResponse value,
    $Res Function(SqldExamScheduleOverviewResponse) then,
  ) =
      _$SqldExamScheduleOverviewResponseCopyWithImpl<
        $Res,
        SqldExamScheduleOverviewResponse
      >;
  @useResult
  $Res call({
    int year,
    List<ExamScheduleResponse> schedules,
    ExamScheduleResponse? nextSchedule,
    DateTime? lastCollectedAt,
    String? officialScheduleUrl,
  });

  $ExamScheduleResponseCopyWith<$Res>? get nextSchedule;
}

/// @nodoc
class _$SqldExamScheduleOverviewResponseCopyWithImpl<
  $Res,
  $Val extends SqldExamScheduleOverviewResponse
>
    implements $SqldExamScheduleOverviewResponseCopyWith<$Res> {
  _$SqldExamScheduleOverviewResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SqldExamScheduleOverviewResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? schedules = null,
    Object? nextSchedule = freezed,
    Object? lastCollectedAt = freezed,
    Object? officialScheduleUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            year: null == year
                ? _value.year
                : year // ignore: cast_nullable_to_non_nullable
                      as int,
            schedules: null == schedules
                ? _value.schedules
                : schedules // ignore: cast_nullable_to_non_nullable
                      as List<ExamScheduleResponse>,
            nextSchedule: freezed == nextSchedule
                ? _value.nextSchedule
                : nextSchedule // ignore: cast_nullable_to_non_nullable
                      as ExamScheduleResponse?,
            lastCollectedAt: freezed == lastCollectedAt
                ? _value.lastCollectedAt
                : lastCollectedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            officialScheduleUrl: freezed == officialScheduleUrl
                ? _value.officialScheduleUrl
                : officialScheduleUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of SqldExamScheduleOverviewResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExamScheduleResponseCopyWith<$Res>? get nextSchedule {
    if (_value.nextSchedule == null) {
      return null;
    }

    return $ExamScheduleResponseCopyWith<$Res>(_value.nextSchedule!, (value) {
      return _then(_value.copyWith(nextSchedule: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SqldExamScheduleOverviewResponseImplCopyWith<$Res>
    implements $SqldExamScheduleOverviewResponseCopyWith<$Res> {
  factory _$$SqldExamScheduleOverviewResponseImplCopyWith(
    _$SqldExamScheduleOverviewResponseImpl value,
    $Res Function(_$SqldExamScheduleOverviewResponseImpl) then,
  ) = __$$SqldExamScheduleOverviewResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int year,
    List<ExamScheduleResponse> schedules,
    ExamScheduleResponse? nextSchedule,
    DateTime? lastCollectedAt,
    String? officialScheduleUrl,
  });

  @override
  $ExamScheduleResponseCopyWith<$Res>? get nextSchedule;
}

/// @nodoc
class __$$SqldExamScheduleOverviewResponseImplCopyWithImpl<$Res>
    extends
        _$SqldExamScheduleOverviewResponseCopyWithImpl<
          $Res,
          _$SqldExamScheduleOverviewResponseImpl
        >
    implements _$$SqldExamScheduleOverviewResponseImplCopyWith<$Res> {
  __$$SqldExamScheduleOverviewResponseImplCopyWithImpl(
    _$SqldExamScheduleOverviewResponseImpl _value,
    $Res Function(_$SqldExamScheduleOverviewResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SqldExamScheduleOverviewResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? schedules = null,
    Object? nextSchedule = freezed,
    Object? lastCollectedAt = freezed,
    Object? officialScheduleUrl = freezed,
  }) {
    return _then(
      _$SqldExamScheduleOverviewResponseImpl(
        year: null == year
            ? _value.year
            : year // ignore: cast_nullable_to_non_nullable
                  as int,
        schedules: null == schedules
            ? _value._schedules
            : schedules // ignore: cast_nullable_to_non_nullable
                  as List<ExamScheduleResponse>,
        nextSchedule: freezed == nextSchedule
            ? _value.nextSchedule
            : nextSchedule // ignore: cast_nullable_to_non_nullable
                  as ExamScheduleResponse?,
        lastCollectedAt: freezed == lastCollectedAt
            ? _value.lastCollectedAt
            : lastCollectedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        officialScheduleUrl: freezed == officialScheduleUrl
            ? _value.officialScheduleUrl
            : officialScheduleUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SqldExamScheduleOverviewResponseImpl
    implements _SqldExamScheduleOverviewResponse {
  const _$SqldExamScheduleOverviewResponseImpl({
    required this.year,
    final List<ExamScheduleResponse> schedules = const <ExamScheduleResponse>[],
    this.nextSchedule,
    this.lastCollectedAt,
    this.officialScheduleUrl,
  }) : _schedules = schedules;

  factory _$SqldExamScheduleOverviewResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$SqldExamScheduleOverviewResponseImplFromJson(json);

  @override
  final int year;
  // 그해 회차 (회차 오름차순)
  final List<ExamScheduleResponse> _schedules;
  // 그해 회차 (회차 오름차순)
  @override
  @JsonKey()
  List<ExamScheduleResponse> get schedules {
    if (_schedules is EqualUnmodifiableListView) return _schedules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_schedules);
  }

  // 오늘 이후 가장 가까운 시험 (연도 무관, 없으면 null)
  @override
  final ExamScheduleResponse? nextSchedule;
  // 마지막 자동 수집 성공 시각 (KST, 없으면 null)
  @override
  final DateTime? lastCollectedAt;
  // 공식 일정·접수 페이지 (데이터자격검정)
  @override
  final String? officialScheduleUrl;

  @override
  String toString() {
    return 'SqldExamScheduleOverviewResponse(year: $year, schedules: $schedules, nextSchedule: $nextSchedule, lastCollectedAt: $lastCollectedAt, officialScheduleUrl: $officialScheduleUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SqldExamScheduleOverviewResponseImpl &&
            (identical(other.year, year) || other.year == year) &&
            const DeepCollectionEquality().equals(
              other._schedules,
              _schedules,
            ) &&
            (identical(other.nextSchedule, nextSchedule) ||
                other.nextSchedule == nextSchedule) &&
            (identical(other.lastCollectedAt, lastCollectedAt) ||
                other.lastCollectedAt == lastCollectedAt) &&
            (identical(other.officialScheduleUrl, officialScheduleUrl) ||
                other.officialScheduleUrl == officialScheduleUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    year,
    const DeepCollectionEquality().hash(_schedules),
    nextSchedule,
    lastCollectedAt,
    officialScheduleUrl,
  );

  /// Create a copy of SqldExamScheduleOverviewResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SqldExamScheduleOverviewResponseImplCopyWith<
    _$SqldExamScheduleOverviewResponseImpl
  >
  get copyWith =>
      __$$SqldExamScheduleOverviewResponseImplCopyWithImpl<
        _$SqldExamScheduleOverviewResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SqldExamScheduleOverviewResponseImplToJson(this);
  }
}

abstract class _SqldExamScheduleOverviewResponse
    implements SqldExamScheduleOverviewResponse {
  const factory _SqldExamScheduleOverviewResponse({
    required final int year,
    final List<ExamScheduleResponse> schedules,
    final ExamScheduleResponse? nextSchedule,
    final DateTime? lastCollectedAt,
    final String? officialScheduleUrl,
  }) = _$SqldExamScheduleOverviewResponseImpl;

  factory _SqldExamScheduleOverviewResponse.fromJson(
    Map<String, dynamic> json,
  ) = _$SqldExamScheduleOverviewResponseImpl.fromJson;

  @override
  int get year; // 그해 회차 (회차 오름차순)
  @override
  List<ExamScheduleResponse> get schedules; // 오늘 이후 가장 가까운 시험 (연도 무관, 없으면 null)
  @override
  ExamScheduleResponse? get nextSchedule; // 마지막 자동 수집 성공 시각 (KST, 없으면 null)
  @override
  DateTime? get lastCollectedAt; // 공식 일정·접수 페이지 (데이터자격검정)
  @override
  String? get officialScheduleUrl;

  /// Create a copy of SqldExamScheduleOverviewResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SqldExamScheduleOverviewResponseImplCopyWith<
    _$SqldExamScheduleOverviewResponseImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
