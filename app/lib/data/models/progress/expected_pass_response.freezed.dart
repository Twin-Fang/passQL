// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expected_pass_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExpectedPassSubjectAverage _$ExpectedPassSubjectAverageFromJson(
  Map<String, dynamic> json,
) {
  return _ExpectedPassSubjectAverage.fromJson(json);
}

/// @nodoc
mixin _$ExpectedPassSubjectAverage {
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  MockExamSubject get subject => throw _privateConstructorUsedError;
  String get subjectName =>
      throw _privateConstructorUsedError; // 최근 응시 과목 평균 점수 (소수 1자리)
  double get averageScore => throw _privateConstructorUsedError;
  int get maxScore => throw _privateConstructorUsedError; // 과락 기준 점수 (미만이면 과락)
  int get failBelowScore =>
      throw _privateConstructorUsedError; // 평균이 과락 기준 + 4점 이하
  bool get isFailRisk => throw _privateConstructorUsedError;

  /// Serializes this ExpectedPassSubjectAverage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExpectedPassSubjectAverage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExpectedPassSubjectAverageCopyWith<ExpectedPassSubjectAverage>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpectedPassSubjectAverageCopyWith<$Res> {
  factory $ExpectedPassSubjectAverageCopyWith(
    ExpectedPassSubjectAverage value,
    $Res Function(ExpectedPassSubjectAverage) then,
  ) =
      _$ExpectedPassSubjectAverageCopyWithImpl<
        $Res,
        ExpectedPassSubjectAverage
      >;
  @useResult
  $Res call({
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) MockExamSubject subject,
    String subjectName,
    double averageScore,
    int maxScore,
    int failBelowScore,
    bool isFailRisk,
  });
}

/// @nodoc
class _$ExpectedPassSubjectAverageCopyWithImpl<
  $Res,
  $Val extends ExpectedPassSubjectAverage
>
    implements $ExpectedPassSubjectAverageCopyWith<$Res> {
  _$ExpectedPassSubjectAverageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExpectedPassSubjectAverage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subject = null,
    Object? subjectName = null,
    Object? averageScore = null,
    Object? maxScore = null,
    Object? failBelowScore = null,
    Object? isFailRisk = null,
  }) {
    return _then(
      _value.copyWith(
            subject: null == subject
                ? _value.subject
                : subject // ignore: cast_nullable_to_non_nullable
                      as MockExamSubject,
            subjectName: null == subjectName
                ? _value.subjectName
                : subjectName // ignore: cast_nullable_to_non_nullable
                      as String,
            averageScore: null == averageScore
                ? _value.averageScore
                : averageScore // ignore: cast_nullable_to_non_nullable
                      as double,
            maxScore: null == maxScore
                ? _value.maxScore
                : maxScore // ignore: cast_nullable_to_non_nullable
                      as int,
            failBelowScore: null == failBelowScore
                ? _value.failBelowScore
                : failBelowScore // ignore: cast_nullable_to_non_nullable
                      as int,
            isFailRisk: null == isFailRisk
                ? _value.isFailRisk
                : isFailRisk // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExpectedPassSubjectAverageImplCopyWith<$Res>
    implements $ExpectedPassSubjectAverageCopyWith<$Res> {
  factory _$$ExpectedPassSubjectAverageImplCopyWith(
    _$ExpectedPassSubjectAverageImpl value,
    $Res Function(_$ExpectedPassSubjectAverageImpl) then,
  ) = __$$ExpectedPassSubjectAverageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) MockExamSubject subject,
    String subjectName,
    double averageScore,
    int maxScore,
    int failBelowScore,
    bool isFailRisk,
  });
}

/// @nodoc
class __$$ExpectedPassSubjectAverageImplCopyWithImpl<$Res>
    extends
        _$ExpectedPassSubjectAverageCopyWithImpl<
          $Res,
          _$ExpectedPassSubjectAverageImpl
        >
    implements _$$ExpectedPassSubjectAverageImplCopyWith<$Res> {
  __$$ExpectedPassSubjectAverageImplCopyWithImpl(
    _$ExpectedPassSubjectAverageImpl _value,
    $Res Function(_$ExpectedPassSubjectAverageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExpectedPassSubjectAverage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subject = null,
    Object? subjectName = null,
    Object? averageScore = null,
    Object? maxScore = null,
    Object? failBelowScore = null,
    Object? isFailRisk = null,
  }) {
    return _then(
      _$ExpectedPassSubjectAverageImpl(
        subject: null == subject
            ? _value.subject
            : subject // ignore: cast_nullable_to_non_nullable
                  as MockExamSubject,
        subjectName: null == subjectName
            ? _value.subjectName
            : subjectName // ignore: cast_nullable_to_non_nullable
                  as String,
        averageScore: null == averageScore
            ? _value.averageScore
            : averageScore // ignore: cast_nullable_to_non_nullable
                  as double,
        maxScore: null == maxScore
            ? _value.maxScore
            : maxScore // ignore: cast_nullable_to_non_nullable
                  as int,
        failBelowScore: null == failBelowScore
            ? _value.failBelowScore
            : failBelowScore // ignore: cast_nullable_to_non_nullable
                  as int,
        isFailRisk: null == isFailRisk
            ? _value.isFailRisk
            : isFailRisk // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExpectedPassSubjectAverageImpl implements _ExpectedPassSubjectAverage {
  const _$ExpectedPassSubjectAverageImpl({
    @JsonKey(unknownEnumValue: MockExamSubject.unknown)
    this.subject = MockExamSubject.unknown,
    this.subjectName = '',
    this.averageScore = 0,
    this.maxScore = 0,
    this.failBelowScore = 0,
    this.isFailRisk = false,
  });

  factory _$ExpectedPassSubjectAverageImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$ExpectedPassSubjectAverageImplFromJson(json);

  @override
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  final MockExamSubject subject;
  @override
  @JsonKey()
  final String subjectName;
  // 최근 응시 과목 평균 점수 (소수 1자리)
  @override
  @JsonKey()
  final double averageScore;
  @override
  @JsonKey()
  final int maxScore;
  // 과락 기준 점수 (미만이면 과락)
  @override
  @JsonKey()
  final int failBelowScore;
  // 평균이 과락 기준 + 4점 이하
  @override
  @JsonKey()
  final bool isFailRisk;

  @override
  String toString() {
    return 'ExpectedPassSubjectAverage(subject: $subject, subjectName: $subjectName, averageScore: $averageScore, maxScore: $maxScore, failBelowScore: $failBelowScore, isFailRisk: $isFailRisk)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpectedPassSubjectAverageImpl &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.subjectName, subjectName) ||
                other.subjectName == subjectName) &&
            (identical(other.averageScore, averageScore) ||
                other.averageScore == averageScore) &&
            (identical(other.maxScore, maxScore) ||
                other.maxScore == maxScore) &&
            (identical(other.failBelowScore, failBelowScore) ||
                other.failBelowScore == failBelowScore) &&
            (identical(other.isFailRisk, isFailRisk) ||
                other.isFailRisk == isFailRisk));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    subject,
    subjectName,
    averageScore,
    maxScore,
    failBelowScore,
    isFailRisk,
  );

  /// Create a copy of ExpectedPassSubjectAverage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpectedPassSubjectAverageImplCopyWith<_$ExpectedPassSubjectAverageImpl>
  get copyWith =>
      __$$ExpectedPassSubjectAverageImplCopyWithImpl<
        _$ExpectedPassSubjectAverageImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExpectedPassSubjectAverageImplToJson(this);
  }
}

abstract class _ExpectedPassSubjectAverage
    implements ExpectedPassSubjectAverage {
  const factory _ExpectedPassSubjectAverage({
    @JsonKey(unknownEnumValue: MockExamSubject.unknown)
    final MockExamSubject subject,
    final String subjectName,
    final double averageScore,
    final int maxScore,
    final int failBelowScore,
    final bool isFailRisk,
  }) = _$ExpectedPassSubjectAverageImpl;

  factory _ExpectedPassSubjectAverage.fromJson(Map<String, dynamic> json) =
      _$ExpectedPassSubjectAverageImpl.fromJson;

  @override
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  MockExamSubject get subject;
  @override
  String get subjectName; // 최근 응시 과목 평균 점수 (소수 1자리)
  @override
  double get averageScore;
  @override
  int get maxScore; // 과락 기준 점수 (미만이면 과락)
  @override
  int get failBelowScore; // 평균이 과락 기준 + 4점 이하
  @override
  bool get isFailRisk;

  /// Create a copy of ExpectedPassSubjectAverage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpectedPassSubjectAverageImplCopyWith<_$ExpectedPassSubjectAverageImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ExpectedPassResponse _$ExpectedPassResponseFromJson(Map<String, dynamic> json) {
  return _ExpectedPassResponse.fromJson(json);
}

/// @nodoc
mixin _$ExpectedPassResponse {
  int? get expectedPassPercent => throw _privateConstructorUsedError;
  double? get averageScore => throw _privateConstructorUsedError;
  int get basisAttemptCount => throw _privateConstructorUsedError;
  int get passedAttemptCount => throw _privateConstructorUsedError;
  int get passScore => throw _privateConstructorUsedError;
  List<ExpectedPassSubjectAverage> get subjectAverages =>
      throw _privateConstructorUsedError; // 공식 최근 연도 합격률 (%)
  double? get officialPassRatePercent => throw _privateConstructorUsedError;
  int? get officialStatisticYear => throw _privateConstructorUsedError;

  /// Serializes this ExpectedPassResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExpectedPassResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExpectedPassResponseCopyWith<ExpectedPassResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpectedPassResponseCopyWith<$Res> {
  factory $ExpectedPassResponseCopyWith(
    ExpectedPassResponse value,
    $Res Function(ExpectedPassResponse) then,
  ) = _$ExpectedPassResponseCopyWithImpl<$Res, ExpectedPassResponse>;
  @useResult
  $Res call({
    int? expectedPassPercent,
    double? averageScore,
    int basisAttemptCount,
    int passedAttemptCount,
    int passScore,
    List<ExpectedPassSubjectAverage> subjectAverages,
    double? officialPassRatePercent,
    int? officialStatisticYear,
  });
}

/// @nodoc
class _$ExpectedPassResponseCopyWithImpl<
  $Res,
  $Val extends ExpectedPassResponse
>
    implements $ExpectedPassResponseCopyWith<$Res> {
  _$ExpectedPassResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExpectedPassResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? expectedPassPercent = freezed,
    Object? averageScore = freezed,
    Object? basisAttemptCount = null,
    Object? passedAttemptCount = null,
    Object? passScore = null,
    Object? subjectAverages = null,
    Object? officialPassRatePercent = freezed,
    Object? officialStatisticYear = freezed,
  }) {
    return _then(
      _value.copyWith(
            expectedPassPercent: freezed == expectedPassPercent
                ? _value.expectedPassPercent
                : expectedPassPercent // ignore: cast_nullable_to_non_nullable
                      as int?,
            averageScore: freezed == averageScore
                ? _value.averageScore
                : averageScore // ignore: cast_nullable_to_non_nullable
                      as double?,
            basisAttemptCount: null == basisAttemptCount
                ? _value.basisAttemptCount
                : basisAttemptCount // ignore: cast_nullable_to_non_nullable
                      as int,
            passedAttemptCount: null == passedAttemptCount
                ? _value.passedAttemptCount
                : passedAttemptCount // ignore: cast_nullable_to_non_nullable
                      as int,
            passScore: null == passScore
                ? _value.passScore
                : passScore // ignore: cast_nullable_to_non_nullable
                      as int,
            subjectAverages: null == subjectAverages
                ? _value.subjectAverages
                : subjectAverages // ignore: cast_nullable_to_non_nullable
                      as List<ExpectedPassSubjectAverage>,
            officialPassRatePercent: freezed == officialPassRatePercent
                ? _value.officialPassRatePercent
                : officialPassRatePercent // ignore: cast_nullable_to_non_nullable
                      as double?,
            officialStatisticYear: freezed == officialStatisticYear
                ? _value.officialStatisticYear
                : officialStatisticYear // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExpectedPassResponseImplCopyWith<$Res>
    implements $ExpectedPassResponseCopyWith<$Res> {
  factory _$$ExpectedPassResponseImplCopyWith(
    _$ExpectedPassResponseImpl value,
    $Res Function(_$ExpectedPassResponseImpl) then,
  ) = __$$ExpectedPassResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? expectedPassPercent,
    double? averageScore,
    int basisAttemptCount,
    int passedAttemptCount,
    int passScore,
    List<ExpectedPassSubjectAverage> subjectAverages,
    double? officialPassRatePercent,
    int? officialStatisticYear,
  });
}

/// @nodoc
class __$$ExpectedPassResponseImplCopyWithImpl<$Res>
    extends _$ExpectedPassResponseCopyWithImpl<$Res, _$ExpectedPassResponseImpl>
    implements _$$ExpectedPassResponseImplCopyWith<$Res> {
  __$$ExpectedPassResponseImplCopyWithImpl(
    _$ExpectedPassResponseImpl _value,
    $Res Function(_$ExpectedPassResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExpectedPassResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? expectedPassPercent = freezed,
    Object? averageScore = freezed,
    Object? basisAttemptCount = null,
    Object? passedAttemptCount = null,
    Object? passScore = null,
    Object? subjectAverages = null,
    Object? officialPassRatePercent = freezed,
    Object? officialStatisticYear = freezed,
  }) {
    return _then(
      _$ExpectedPassResponseImpl(
        expectedPassPercent: freezed == expectedPassPercent
            ? _value.expectedPassPercent
            : expectedPassPercent // ignore: cast_nullable_to_non_nullable
                  as int?,
        averageScore: freezed == averageScore
            ? _value.averageScore
            : averageScore // ignore: cast_nullable_to_non_nullable
                  as double?,
        basisAttemptCount: null == basisAttemptCount
            ? _value.basisAttemptCount
            : basisAttemptCount // ignore: cast_nullable_to_non_nullable
                  as int,
        passedAttemptCount: null == passedAttemptCount
            ? _value.passedAttemptCount
            : passedAttemptCount // ignore: cast_nullable_to_non_nullable
                  as int,
        passScore: null == passScore
            ? _value.passScore
            : passScore // ignore: cast_nullable_to_non_nullable
                  as int,
        subjectAverages: null == subjectAverages
            ? _value._subjectAverages
            : subjectAverages // ignore: cast_nullable_to_non_nullable
                  as List<ExpectedPassSubjectAverage>,
        officialPassRatePercent: freezed == officialPassRatePercent
            ? _value.officialPassRatePercent
            : officialPassRatePercent // ignore: cast_nullable_to_non_nullable
                  as double?,
        officialStatisticYear: freezed == officialStatisticYear
            ? _value.officialStatisticYear
            : officialStatisticYear // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExpectedPassResponseImpl extends _ExpectedPassResponse {
  const _$ExpectedPassResponseImpl({
    this.expectedPassPercent,
    this.averageScore,
    this.basisAttemptCount = 0,
    this.passedAttemptCount = 0,
    this.passScore = 0,
    final List<ExpectedPassSubjectAverage> subjectAverages = const [],
    this.officialPassRatePercent,
    this.officialStatisticYear,
  }) : _subjectAverages = subjectAverages,
       super._();

  factory _$ExpectedPassResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExpectedPassResponseImplFromJson(json);

  @override
  final int? expectedPassPercent;
  @override
  final double? averageScore;
  @override
  @JsonKey()
  final int basisAttemptCount;
  @override
  @JsonKey()
  final int passedAttemptCount;
  @override
  @JsonKey()
  final int passScore;
  final List<ExpectedPassSubjectAverage> _subjectAverages;
  @override
  @JsonKey()
  List<ExpectedPassSubjectAverage> get subjectAverages {
    if (_subjectAverages is EqualUnmodifiableListView) return _subjectAverages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subjectAverages);
  }

  // 공식 최근 연도 합격률 (%)
  @override
  final double? officialPassRatePercent;
  @override
  final int? officialStatisticYear;

  @override
  String toString() {
    return 'ExpectedPassResponse(expectedPassPercent: $expectedPassPercent, averageScore: $averageScore, basisAttemptCount: $basisAttemptCount, passedAttemptCount: $passedAttemptCount, passScore: $passScore, subjectAverages: $subjectAverages, officialPassRatePercent: $officialPassRatePercent, officialStatisticYear: $officialStatisticYear)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpectedPassResponseImpl &&
            (identical(other.expectedPassPercent, expectedPassPercent) ||
                other.expectedPassPercent == expectedPassPercent) &&
            (identical(other.averageScore, averageScore) ||
                other.averageScore == averageScore) &&
            (identical(other.basisAttemptCount, basisAttemptCount) ||
                other.basisAttemptCount == basisAttemptCount) &&
            (identical(other.passedAttemptCount, passedAttemptCount) ||
                other.passedAttemptCount == passedAttemptCount) &&
            (identical(other.passScore, passScore) ||
                other.passScore == passScore) &&
            const DeepCollectionEquality().equals(
              other._subjectAverages,
              _subjectAverages,
            ) &&
            (identical(
                  other.officialPassRatePercent,
                  officialPassRatePercent,
                ) ||
                other.officialPassRatePercent == officialPassRatePercent) &&
            (identical(other.officialStatisticYear, officialStatisticYear) ||
                other.officialStatisticYear == officialStatisticYear));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    expectedPassPercent,
    averageScore,
    basisAttemptCount,
    passedAttemptCount,
    passScore,
    const DeepCollectionEquality().hash(_subjectAverages),
    officialPassRatePercent,
    officialStatisticYear,
  );

  /// Create a copy of ExpectedPassResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpectedPassResponseImplCopyWith<_$ExpectedPassResponseImpl>
  get copyWith =>
      __$$ExpectedPassResponseImplCopyWithImpl<_$ExpectedPassResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExpectedPassResponseImplToJson(this);
  }
}

abstract class _ExpectedPassResponse extends ExpectedPassResponse {
  const factory _ExpectedPassResponse({
    final int? expectedPassPercent,
    final double? averageScore,
    final int basisAttemptCount,
    final int passedAttemptCount,
    final int passScore,
    final List<ExpectedPassSubjectAverage> subjectAverages,
    final double? officialPassRatePercent,
    final int? officialStatisticYear,
  }) = _$ExpectedPassResponseImpl;
  const _ExpectedPassResponse._() : super._();

  factory _ExpectedPassResponse.fromJson(Map<String, dynamic> json) =
      _$ExpectedPassResponseImpl.fromJson;

  @override
  int? get expectedPassPercent;
  @override
  double? get averageScore;
  @override
  int get basisAttemptCount;
  @override
  int get passedAttemptCount;
  @override
  int get passScore;
  @override
  List<ExpectedPassSubjectAverage> get subjectAverages; // 공식 최근 연도 합격률 (%)
  @override
  double? get officialPassRatePercent;
  @override
  int? get officialStatisticYear;

  /// Create a copy of ExpectedPassResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpectedPassResponseImplCopyWith<_$ExpectedPassResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
