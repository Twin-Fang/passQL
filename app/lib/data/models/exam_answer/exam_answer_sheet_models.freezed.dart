// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exam_answer_sheet_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExamAnswerSheetRequest _$ExamAnswerSheetRequestFromJson(
  Map<String, dynamic> json,
) {
  return _ExamAnswerSheetRequest.fromJson(json);
}

/// @nodoc
mixin _$ExamAnswerSheetRequest {
  String get clientToken => throw _privateConstructorUsedError;
  String get answers => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;

  /// Serializes this ExamAnswerSheetRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamAnswerSheetRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamAnswerSheetRequestCopyWith<ExamAnswerSheetRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamAnswerSheetRequestCopyWith<$Res> {
  factory $ExamAnswerSheetRequestCopyWith(
    ExamAnswerSheetRequest value,
    $Res Function(ExamAnswerSheetRequest) then,
  ) = _$ExamAnswerSheetRequestCopyWithImpl<$Res, ExamAnswerSheetRequest>;
  @useResult
  $Res call({String clientToken, String answers, String source});
}

/// @nodoc
class _$ExamAnswerSheetRequestCopyWithImpl<
  $Res,
  $Val extends ExamAnswerSheetRequest
>
    implements $ExamAnswerSheetRequestCopyWith<$Res> {
  _$ExamAnswerSheetRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamAnswerSheetRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? clientToken = null,
    Object? answers = null,
    Object? source = null,
  }) {
    return _then(
      _value.copyWith(
            clientToken: null == clientToken
                ? _value.clientToken
                : clientToken // ignore: cast_nullable_to_non_nullable
                      as String,
            answers: null == answers
                ? _value.answers
                : answers // ignore: cast_nullable_to_non_nullable
                      as String,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExamAnswerSheetRequestImplCopyWith<$Res>
    implements $ExamAnswerSheetRequestCopyWith<$Res> {
  factory _$$ExamAnswerSheetRequestImplCopyWith(
    _$ExamAnswerSheetRequestImpl value,
    $Res Function(_$ExamAnswerSheetRequestImpl) then,
  ) = __$$ExamAnswerSheetRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String clientToken, String answers, String source});
}

/// @nodoc
class __$$ExamAnswerSheetRequestImplCopyWithImpl<$Res>
    extends
        _$ExamAnswerSheetRequestCopyWithImpl<$Res, _$ExamAnswerSheetRequestImpl>
    implements _$$ExamAnswerSheetRequestImplCopyWith<$Res> {
  __$$ExamAnswerSheetRequestImplCopyWithImpl(
    _$ExamAnswerSheetRequestImpl _value,
    $Res Function(_$ExamAnswerSheetRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamAnswerSheetRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? clientToken = null,
    Object? answers = null,
    Object? source = null,
  }) {
    return _then(
      _$ExamAnswerSheetRequestImpl(
        clientToken: null == clientToken
            ? _value.clientToken
            : clientToken // ignore: cast_nullable_to_non_nullable
                  as String,
        answers: null == answers
            ? _value.answers
            : answers // ignore: cast_nullable_to_non_nullable
                  as String,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamAnswerSheetRequestImpl implements _ExamAnswerSheetRequest {
  const _$ExamAnswerSheetRequestImpl({
    required this.clientToken,
    required this.answers,
    required this.source,
  });

  factory _$ExamAnswerSheetRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamAnswerSheetRequestImplFromJson(json);

  @override
  final String clientToken;
  @override
  final String answers;
  @override
  final String source;

  @override
  String toString() {
    return 'ExamAnswerSheetRequest(clientToken: $clientToken, answers: $answers, source: $source)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamAnswerSheetRequestImpl &&
            (identical(other.clientToken, clientToken) ||
                other.clientToken == clientToken) &&
            (identical(other.answers, answers) || other.answers == answers) &&
            (identical(other.source, source) || other.source == source));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, clientToken, answers, source);

  /// Create a copy of ExamAnswerSheetRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamAnswerSheetRequestImplCopyWith<_$ExamAnswerSheetRequestImpl>
  get copyWith =>
      __$$ExamAnswerSheetRequestImplCopyWithImpl<_$ExamAnswerSheetRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamAnswerSheetRequestImplToJson(this);
  }
}

abstract class _ExamAnswerSheetRequest implements ExamAnswerSheetRequest {
  const factory _ExamAnswerSheetRequest({
    required final String clientToken,
    required final String answers,
    required final String source,
  }) = _$ExamAnswerSheetRequestImpl;

  factory _ExamAnswerSheetRequest.fromJson(Map<String, dynamic> json) =
      _$ExamAnswerSheetRequestImpl.fromJson;

  @override
  String get clientToken;
  @override
  String get answers;
  @override
  String get source;

  /// Create a copy of ExamAnswerSheetRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamAnswerSheetRequestImplCopyWith<_$ExamAnswerSheetRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ExamAnswerGradeResult _$ExamAnswerGradeResultFromJson(
  Map<String, dynamic> json,
) {
  return _ExamAnswerGradeResult.fromJson(json);
}

/// @nodoc
mixin _$ExamAnswerGradeResult {
  ExamAnswerSubjectGrade get subject1 => throw _privateConstructorUsedError;
  ExamAnswerSubjectGrade get subject2 => throw _privateConstructorUsedError;
  int get totalScore => throw _privateConstructorUsedError;
  ExamAnswerScoreRangeResponse? get scoreRange =>
      throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: ExamAnswerPassStatusValue.unknown)
  ExamAnswerPassStatusValue get passStatus =>
      throw _privateConstructorUsedError; // 참여자 중 상위 % (0~100)
  double? get percentile => throw _privateConstructorUsedError;
  List<ExamAnswerQuestionGrade> get perQuestion =>
      throw _privateConstructorUsedError;

  /// Serializes this ExamAnswerGradeResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamAnswerGradeResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamAnswerGradeResultCopyWith<ExamAnswerGradeResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamAnswerGradeResultCopyWith<$Res> {
  factory $ExamAnswerGradeResultCopyWith(
    ExamAnswerGradeResult value,
    $Res Function(ExamAnswerGradeResult) then,
  ) = _$ExamAnswerGradeResultCopyWithImpl<$Res, ExamAnswerGradeResult>;
  @useResult
  $Res call({
    ExamAnswerSubjectGrade subject1,
    ExamAnswerSubjectGrade subject2,
    int totalScore,
    ExamAnswerScoreRangeResponse? scoreRange,
    @JsonKey(unknownEnumValue: ExamAnswerPassStatusValue.unknown)
    ExamAnswerPassStatusValue passStatus,
    double? percentile,
    List<ExamAnswerQuestionGrade> perQuestion,
  });

  $ExamAnswerSubjectGradeCopyWith<$Res> get subject1;
  $ExamAnswerSubjectGradeCopyWith<$Res> get subject2;
  $ExamAnswerScoreRangeResponseCopyWith<$Res>? get scoreRange;
}

/// @nodoc
class _$ExamAnswerGradeResultCopyWithImpl<
  $Res,
  $Val extends ExamAnswerGradeResult
>
    implements $ExamAnswerGradeResultCopyWith<$Res> {
  _$ExamAnswerGradeResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamAnswerGradeResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subject1 = null,
    Object? subject2 = null,
    Object? totalScore = null,
    Object? scoreRange = freezed,
    Object? passStatus = null,
    Object? percentile = freezed,
    Object? perQuestion = null,
  }) {
    return _then(
      _value.copyWith(
            subject1: null == subject1
                ? _value.subject1
                : subject1 // ignore: cast_nullable_to_non_nullable
                      as ExamAnswerSubjectGrade,
            subject2: null == subject2
                ? _value.subject2
                : subject2 // ignore: cast_nullable_to_non_nullable
                      as ExamAnswerSubjectGrade,
            totalScore: null == totalScore
                ? _value.totalScore
                : totalScore // ignore: cast_nullable_to_non_nullable
                      as int,
            scoreRange: freezed == scoreRange
                ? _value.scoreRange
                : scoreRange // ignore: cast_nullable_to_non_nullable
                      as ExamAnswerScoreRangeResponse?,
            passStatus: null == passStatus
                ? _value.passStatus
                : passStatus // ignore: cast_nullable_to_non_nullable
                      as ExamAnswerPassStatusValue,
            percentile: freezed == percentile
                ? _value.percentile
                : percentile // ignore: cast_nullable_to_non_nullable
                      as double?,
            perQuestion: null == perQuestion
                ? _value.perQuestion
                : perQuestion // ignore: cast_nullable_to_non_nullable
                      as List<ExamAnswerQuestionGrade>,
          )
          as $Val,
    );
  }

  /// Create a copy of ExamAnswerGradeResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExamAnswerSubjectGradeCopyWith<$Res> get subject1 {
    return $ExamAnswerSubjectGradeCopyWith<$Res>(_value.subject1, (value) {
      return _then(_value.copyWith(subject1: value) as $Val);
    });
  }

  /// Create a copy of ExamAnswerGradeResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExamAnswerSubjectGradeCopyWith<$Res> get subject2 {
    return $ExamAnswerSubjectGradeCopyWith<$Res>(_value.subject2, (value) {
      return _then(_value.copyWith(subject2: value) as $Val);
    });
  }

  /// Create a copy of ExamAnswerGradeResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExamAnswerScoreRangeResponseCopyWith<$Res>? get scoreRange {
    if (_value.scoreRange == null) {
      return null;
    }

    return $ExamAnswerScoreRangeResponseCopyWith<$Res>(_value.scoreRange!, (
      value,
    ) {
      return _then(_value.copyWith(scoreRange: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ExamAnswerGradeResultImplCopyWith<$Res>
    implements $ExamAnswerGradeResultCopyWith<$Res> {
  factory _$$ExamAnswerGradeResultImplCopyWith(
    _$ExamAnswerGradeResultImpl value,
    $Res Function(_$ExamAnswerGradeResultImpl) then,
  ) = __$$ExamAnswerGradeResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ExamAnswerSubjectGrade subject1,
    ExamAnswerSubjectGrade subject2,
    int totalScore,
    ExamAnswerScoreRangeResponse? scoreRange,
    @JsonKey(unknownEnumValue: ExamAnswerPassStatusValue.unknown)
    ExamAnswerPassStatusValue passStatus,
    double? percentile,
    List<ExamAnswerQuestionGrade> perQuestion,
  });

  @override
  $ExamAnswerSubjectGradeCopyWith<$Res> get subject1;
  @override
  $ExamAnswerSubjectGradeCopyWith<$Res> get subject2;
  @override
  $ExamAnswerScoreRangeResponseCopyWith<$Res>? get scoreRange;
}

/// @nodoc
class __$$ExamAnswerGradeResultImplCopyWithImpl<$Res>
    extends
        _$ExamAnswerGradeResultCopyWithImpl<$Res, _$ExamAnswerGradeResultImpl>
    implements _$$ExamAnswerGradeResultImplCopyWith<$Res> {
  __$$ExamAnswerGradeResultImplCopyWithImpl(
    _$ExamAnswerGradeResultImpl _value,
    $Res Function(_$ExamAnswerGradeResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamAnswerGradeResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subject1 = null,
    Object? subject2 = null,
    Object? totalScore = null,
    Object? scoreRange = freezed,
    Object? passStatus = null,
    Object? percentile = freezed,
    Object? perQuestion = null,
  }) {
    return _then(
      _$ExamAnswerGradeResultImpl(
        subject1: null == subject1
            ? _value.subject1
            : subject1 // ignore: cast_nullable_to_non_nullable
                  as ExamAnswerSubjectGrade,
        subject2: null == subject2
            ? _value.subject2
            : subject2 // ignore: cast_nullable_to_non_nullable
                  as ExamAnswerSubjectGrade,
        totalScore: null == totalScore
            ? _value.totalScore
            : totalScore // ignore: cast_nullable_to_non_nullable
                  as int,
        scoreRange: freezed == scoreRange
            ? _value.scoreRange
            : scoreRange // ignore: cast_nullable_to_non_nullable
                  as ExamAnswerScoreRangeResponse?,
        passStatus: null == passStatus
            ? _value.passStatus
            : passStatus // ignore: cast_nullable_to_non_nullable
                  as ExamAnswerPassStatusValue,
        percentile: freezed == percentile
            ? _value.percentile
            : percentile // ignore: cast_nullable_to_non_nullable
                  as double?,
        perQuestion: null == perQuestion
            ? _value._perQuestion
            : perQuestion // ignore: cast_nullable_to_non_nullable
                  as List<ExamAnswerQuestionGrade>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamAnswerGradeResultImpl implements _ExamAnswerGradeResult {
  const _$ExamAnswerGradeResultImpl({
    required this.subject1,
    required this.subject2,
    required this.totalScore,
    this.scoreRange,
    @JsonKey(unknownEnumValue: ExamAnswerPassStatusValue.unknown)
    this.passStatus = ExamAnswerPassStatusValue.unknown,
    this.percentile,
    final List<ExamAnswerQuestionGrade> perQuestion = const [],
  }) : _perQuestion = perQuestion;

  factory _$ExamAnswerGradeResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamAnswerGradeResultImplFromJson(json);

  @override
  final ExamAnswerSubjectGrade subject1;
  @override
  final ExamAnswerSubjectGrade subject2;
  @override
  final int totalScore;
  @override
  final ExamAnswerScoreRangeResponse? scoreRange;
  @override
  @JsonKey(unknownEnumValue: ExamAnswerPassStatusValue.unknown)
  final ExamAnswerPassStatusValue passStatus;
  // 참여자 중 상위 % (0~100)
  @override
  final double? percentile;
  final List<ExamAnswerQuestionGrade> _perQuestion;
  @override
  @JsonKey()
  List<ExamAnswerQuestionGrade> get perQuestion {
    if (_perQuestion is EqualUnmodifiableListView) return _perQuestion;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_perQuestion);
  }

  @override
  String toString() {
    return 'ExamAnswerGradeResult(subject1: $subject1, subject2: $subject2, totalScore: $totalScore, scoreRange: $scoreRange, passStatus: $passStatus, percentile: $percentile, perQuestion: $perQuestion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamAnswerGradeResultImpl &&
            (identical(other.subject1, subject1) ||
                other.subject1 == subject1) &&
            (identical(other.subject2, subject2) ||
                other.subject2 == subject2) &&
            (identical(other.totalScore, totalScore) ||
                other.totalScore == totalScore) &&
            (identical(other.scoreRange, scoreRange) ||
                other.scoreRange == scoreRange) &&
            (identical(other.passStatus, passStatus) ||
                other.passStatus == passStatus) &&
            (identical(other.percentile, percentile) ||
                other.percentile == percentile) &&
            const DeepCollectionEquality().equals(
              other._perQuestion,
              _perQuestion,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    subject1,
    subject2,
    totalScore,
    scoreRange,
    passStatus,
    percentile,
    const DeepCollectionEquality().hash(_perQuestion),
  );

  /// Create a copy of ExamAnswerGradeResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamAnswerGradeResultImplCopyWith<_$ExamAnswerGradeResultImpl>
  get copyWith =>
      __$$ExamAnswerGradeResultImplCopyWithImpl<_$ExamAnswerGradeResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamAnswerGradeResultImplToJson(this);
  }
}

abstract class _ExamAnswerGradeResult implements ExamAnswerGradeResult {
  const factory _ExamAnswerGradeResult({
    required final ExamAnswerSubjectGrade subject1,
    required final ExamAnswerSubjectGrade subject2,
    required final int totalScore,
    final ExamAnswerScoreRangeResponse? scoreRange,
    @JsonKey(unknownEnumValue: ExamAnswerPassStatusValue.unknown)
    final ExamAnswerPassStatusValue passStatus,
    final double? percentile,
    final List<ExamAnswerQuestionGrade> perQuestion,
  }) = _$ExamAnswerGradeResultImpl;

  factory _ExamAnswerGradeResult.fromJson(Map<String, dynamic> json) =
      _$ExamAnswerGradeResultImpl.fromJson;

  @override
  ExamAnswerSubjectGrade get subject1;
  @override
  ExamAnswerSubjectGrade get subject2;
  @override
  int get totalScore;
  @override
  ExamAnswerScoreRangeResponse? get scoreRange;
  @override
  @JsonKey(unknownEnumValue: ExamAnswerPassStatusValue.unknown)
  ExamAnswerPassStatusValue get passStatus; // 참여자 중 상위 % (0~100)
  @override
  double? get percentile;
  @override
  List<ExamAnswerQuestionGrade> get perQuestion;

  /// Create a copy of ExamAnswerGradeResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamAnswerGradeResultImplCopyWith<_$ExamAnswerGradeResultImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ExamAnswerSubjectGrade _$ExamAnswerSubjectGradeFromJson(
  Map<String, dynamic> json,
) {
  return _ExamAnswerSubjectGrade.fromJson(json);
}

/// @nodoc
mixin _$ExamAnswerSubjectGrade {
  int get score => throw _privateConstructorUsedError;
  int get max => throw _privateConstructorUsedError;
  bool get isFailCut => throw _privateConstructorUsedError;

  /// Serializes this ExamAnswerSubjectGrade to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamAnswerSubjectGrade
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamAnswerSubjectGradeCopyWith<ExamAnswerSubjectGrade> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamAnswerSubjectGradeCopyWith<$Res> {
  factory $ExamAnswerSubjectGradeCopyWith(
    ExamAnswerSubjectGrade value,
    $Res Function(ExamAnswerSubjectGrade) then,
  ) = _$ExamAnswerSubjectGradeCopyWithImpl<$Res, ExamAnswerSubjectGrade>;
  @useResult
  $Res call({int score, int max, bool isFailCut});
}

/// @nodoc
class _$ExamAnswerSubjectGradeCopyWithImpl<
  $Res,
  $Val extends ExamAnswerSubjectGrade
>
    implements $ExamAnswerSubjectGradeCopyWith<$Res> {
  _$ExamAnswerSubjectGradeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamAnswerSubjectGrade
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? score = null,
    Object? max = null,
    Object? isFailCut = null,
  }) {
    return _then(
      _value.copyWith(
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int,
            max: null == max
                ? _value.max
                : max // ignore: cast_nullable_to_non_nullable
                      as int,
            isFailCut: null == isFailCut
                ? _value.isFailCut
                : isFailCut // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExamAnswerSubjectGradeImplCopyWith<$Res>
    implements $ExamAnswerSubjectGradeCopyWith<$Res> {
  factory _$$ExamAnswerSubjectGradeImplCopyWith(
    _$ExamAnswerSubjectGradeImpl value,
    $Res Function(_$ExamAnswerSubjectGradeImpl) then,
  ) = __$$ExamAnswerSubjectGradeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int score, int max, bool isFailCut});
}

/// @nodoc
class __$$ExamAnswerSubjectGradeImplCopyWithImpl<$Res>
    extends
        _$ExamAnswerSubjectGradeCopyWithImpl<$Res, _$ExamAnswerSubjectGradeImpl>
    implements _$$ExamAnswerSubjectGradeImplCopyWith<$Res> {
  __$$ExamAnswerSubjectGradeImplCopyWithImpl(
    _$ExamAnswerSubjectGradeImpl _value,
    $Res Function(_$ExamAnswerSubjectGradeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamAnswerSubjectGrade
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? score = null,
    Object? max = null,
    Object? isFailCut = null,
  }) {
    return _then(
      _$ExamAnswerSubjectGradeImpl(
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
        max: null == max
            ? _value.max
            : max // ignore: cast_nullable_to_non_nullable
                  as int,
        isFailCut: null == isFailCut
            ? _value.isFailCut
            : isFailCut // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamAnswerSubjectGradeImpl implements _ExamAnswerSubjectGrade {
  const _$ExamAnswerSubjectGradeImpl({
    required this.score,
    required this.max,
    this.isFailCut = false,
  });

  factory _$ExamAnswerSubjectGradeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamAnswerSubjectGradeImplFromJson(json);

  @override
  final int score;
  @override
  final int max;
  @override
  @JsonKey()
  final bool isFailCut;

  @override
  String toString() {
    return 'ExamAnswerSubjectGrade(score: $score, max: $max, isFailCut: $isFailCut)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamAnswerSubjectGradeImpl &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.max, max) || other.max == max) &&
            (identical(other.isFailCut, isFailCut) ||
                other.isFailCut == isFailCut));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, score, max, isFailCut);

  /// Create a copy of ExamAnswerSubjectGrade
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamAnswerSubjectGradeImplCopyWith<_$ExamAnswerSubjectGradeImpl>
  get copyWith =>
      __$$ExamAnswerSubjectGradeImplCopyWithImpl<_$ExamAnswerSubjectGradeImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamAnswerSubjectGradeImplToJson(this);
  }
}

abstract class _ExamAnswerSubjectGrade implements ExamAnswerSubjectGrade {
  const factory _ExamAnswerSubjectGrade({
    required final int score,
    required final int max,
    final bool isFailCut,
  }) = _$ExamAnswerSubjectGradeImpl;

  factory _ExamAnswerSubjectGrade.fromJson(Map<String, dynamic> json) =
      _$ExamAnswerSubjectGradeImpl.fromJson;

  @override
  int get score;
  @override
  int get max;
  @override
  bool get isFailCut;

  /// Create a copy of ExamAnswerSubjectGrade
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamAnswerSubjectGradeImplCopyWith<_$ExamAnswerSubjectGradeImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ExamAnswerScoreRangeResponse _$ExamAnswerScoreRangeResponseFromJson(
  Map<String, dynamic> json,
) {
  return _ExamAnswerScoreRangeResponse.fromJson(json);
}

/// @nodoc
mixin _$ExamAnswerScoreRangeResponse {
  int get min => throw _privateConstructorUsedError;
  int get max => throw _privateConstructorUsedError;

  /// Serializes this ExamAnswerScoreRangeResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamAnswerScoreRangeResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamAnswerScoreRangeResponseCopyWith<ExamAnswerScoreRangeResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamAnswerScoreRangeResponseCopyWith<$Res> {
  factory $ExamAnswerScoreRangeResponseCopyWith(
    ExamAnswerScoreRangeResponse value,
    $Res Function(ExamAnswerScoreRangeResponse) then,
  ) =
      _$ExamAnswerScoreRangeResponseCopyWithImpl<
        $Res,
        ExamAnswerScoreRangeResponse
      >;
  @useResult
  $Res call({int min, int max});
}

/// @nodoc
class _$ExamAnswerScoreRangeResponseCopyWithImpl<
  $Res,
  $Val extends ExamAnswerScoreRangeResponse
>
    implements $ExamAnswerScoreRangeResponseCopyWith<$Res> {
  _$ExamAnswerScoreRangeResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamAnswerScoreRangeResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? min = null, Object? max = null}) {
    return _then(
      _value.copyWith(
            min: null == min
                ? _value.min
                : min // ignore: cast_nullable_to_non_nullable
                      as int,
            max: null == max
                ? _value.max
                : max // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExamAnswerScoreRangeResponseImplCopyWith<$Res>
    implements $ExamAnswerScoreRangeResponseCopyWith<$Res> {
  factory _$$ExamAnswerScoreRangeResponseImplCopyWith(
    _$ExamAnswerScoreRangeResponseImpl value,
    $Res Function(_$ExamAnswerScoreRangeResponseImpl) then,
  ) = __$$ExamAnswerScoreRangeResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int min, int max});
}

/// @nodoc
class __$$ExamAnswerScoreRangeResponseImplCopyWithImpl<$Res>
    extends
        _$ExamAnswerScoreRangeResponseCopyWithImpl<
          $Res,
          _$ExamAnswerScoreRangeResponseImpl
        >
    implements _$$ExamAnswerScoreRangeResponseImplCopyWith<$Res> {
  __$$ExamAnswerScoreRangeResponseImplCopyWithImpl(
    _$ExamAnswerScoreRangeResponseImpl _value,
    $Res Function(_$ExamAnswerScoreRangeResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamAnswerScoreRangeResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? min = null, Object? max = null}) {
    return _then(
      _$ExamAnswerScoreRangeResponseImpl(
        min: null == min
            ? _value.min
            : min // ignore: cast_nullable_to_non_nullable
                  as int,
        max: null == max
            ? _value.max
            : max // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamAnswerScoreRangeResponseImpl
    implements _ExamAnswerScoreRangeResponse {
  const _$ExamAnswerScoreRangeResponseImpl({
    required this.min,
    required this.max,
  });

  factory _$ExamAnswerScoreRangeResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$ExamAnswerScoreRangeResponseImplFromJson(json);

  @override
  final int min;
  @override
  final int max;

  @override
  String toString() {
    return 'ExamAnswerScoreRangeResponse(min: $min, max: $max)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamAnswerScoreRangeResponseImpl &&
            (identical(other.min, min) || other.min == min) &&
            (identical(other.max, max) || other.max == max));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, min, max);

  /// Create a copy of ExamAnswerScoreRangeResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamAnswerScoreRangeResponseImplCopyWith<
    _$ExamAnswerScoreRangeResponseImpl
  >
  get copyWith =>
      __$$ExamAnswerScoreRangeResponseImplCopyWithImpl<
        _$ExamAnswerScoreRangeResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamAnswerScoreRangeResponseImplToJson(this);
  }
}

abstract class _ExamAnswerScoreRangeResponse
    implements ExamAnswerScoreRangeResponse {
  const factory _ExamAnswerScoreRangeResponse({
    required final int min,
    required final int max,
  }) = _$ExamAnswerScoreRangeResponseImpl;

  factory _ExamAnswerScoreRangeResponse.fromJson(Map<String, dynamic> json) =
      _$ExamAnswerScoreRangeResponseImpl.fromJson;

  @override
  int get min;
  @override
  int get max;

  /// Create a copy of ExamAnswerScoreRangeResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamAnswerScoreRangeResponseImplCopyWith<
    _$ExamAnswerScoreRangeResponseImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

ExamAnswerQuestionGrade _$ExamAnswerQuestionGradeFromJson(
  Map<String, dynamic> json,
) {
  return _ExamAnswerQuestionGrade.fromJson(json);
}

/// @nodoc
mixin _$ExamAnswerQuestionGrade {
  int get questionNo => throw _privateConstructorUsedError;
  int get myAnswer => throw _privateConstructorUsedError;
  int? get answer => throw _privateConstructorUsedError;
  bool? get isCorrect => throw _privateConstructorUsedError;

  /// Serializes this ExamAnswerQuestionGrade to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamAnswerQuestionGrade
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamAnswerQuestionGradeCopyWith<ExamAnswerQuestionGrade> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamAnswerQuestionGradeCopyWith<$Res> {
  factory $ExamAnswerQuestionGradeCopyWith(
    ExamAnswerQuestionGrade value,
    $Res Function(ExamAnswerQuestionGrade) then,
  ) = _$ExamAnswerQuestionGradeCopyWithImpl<$Res, ExamAnswerQuestionGrade>;
  @useResult
  $Res call({int questionNo, int myAnswer, int? answer, bool? isCorrect});
}

/// @nodoc
class _$ExamAnswerQuestionGradeCopyWithImpl<
  $Res,
  $Val extends ExamAnswerQuestionGrade
>
    implements $ExamAnswerQuestionGradeCopyWith<$Res> {
  _$ExamAnswerQuestionGradeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamAnswerQuestionGrade
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionNo = null,
    Object? myAnswer = null,
    Object? answer = freezed,
    Object? isCorrect = freezed,
  }) {
    return _then(
      _value.copyWith(
            questionNo: null == questionNo
                ? _value.questionNo
                : questionNo // ignore: cast_nullable_to_non_nullable
                      as int,
            myAnswer: null == myAnswer
                ? _value.myAnswer
                : myAnswer // ignore: cast_nullable_to_non_nullable
                      as int,
            answer: freezed == answer
                ? _value.answer
                : answer // ignore: cast_nullable_to_non_nullable
                      as int?,
            isCorrect: freezed == isCorrect
                ? _value.isCorrect
                : isCorrect // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExamAnswerQuestionGradeImplCopyWith<$Res>
    implements $ExamAnswerQuestionGradeCopyWith<$Res> {
  factory _$$ExamAnswerQuestionGradeImplCopyWith(
    _$ExamAnswerQuestionGradeImpl value,
    $Res Function(_$ExamAnswerQuestionGradeImpl) then,
  ) = __$$ExamAnswerQuestionGradeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int questionNo, int myAnswer, int? answer, bool? isCorrect});
}

/// @nodoc
class __$$ExamAnswerQuestionGradeImplCopyWithImpl<$Res>
    extends
        _$ExamAnswerQuestionGradeCopyWithImpl<
          $Res,
          _$ExamAnswerQuestionGradeImpl
        >
    implements _$$ExamAnswerQuestionGradeImplCopyWith<$Res> {
  __$$ExamAnswerQuestionGradeImplCopyWithImpl(
    _$ExamAnswerQuestionGradeImpl _value,
    $Res Function(_$ExamAnswerQuestionGradeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamAnswerQuestionGrade
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionNo = null,
    Object? myAnswer = null,
    Object? answer = freezed,
    Object? isCorrect = freezed,
  }) {
    return _then(
      _$ExamAnswerQuestionGradeImpl(
        questionNo: null == questionNo
            ? _value.questionNo
            : questionNo // ignore: cast_nullable_to_non_nullable
                  as int,
        myAnswer: null == myAnswer
            ? _value.myAnswer
            : myAnswer // ignore: cast_nullable_to_non_nullable
                  as int,
        answer: freezed == answer
            ? _value.answer
            : answer // ignore: cast_nullable_to_non_nullable
                  as int?,
        isCorrect: freezed == isCorrect
            ? _value.isCorrect
            : isCorrect // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamAnswerQuestionGradeImpl implements _ExamAnswerQuestionGrade {
  const _$ExamAnswerQuestionGradeImpl({
    required this.questionNo,
    this.myAnswer = 0,
    this.answer,
    this.isCorrect,
  });

  factory _$ExamAnswerQuestionGradeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamAnswerQuestionGradeImplFromJson(json);

  @override
  final int questionNo;
  @override
  @JsonKey()
  final int myAnswer;
  @override
  final int? answer;
  @override
  final bool? isCorrect;

  @override
  String toString() {
    return 'ExamAnswerQuestionGrade(questionNo: $questionNo, myAnswer: $myAnswer, answer: $answer, isCorrect: $isCorrect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamAnswerQuestionGradeImpl &&
            (identical(other.questionNo, questionNo) ||
                other.questionNo == questionNo) &&
            (identical(other.myAnswer, myAnswer) ||
                other.myAnswer == myAnswer) &&
            (identical(other.answer, answer) || other.answer == answer) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, questionNo, myAnswer, answer, isCorrect);

  /// Create a copy of ExamAnswerQuestionGrade
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamAnswerQuestionGradeImplCopyWith<_$ExamAnswerQuestionGradeImpl>
  get copyWith =>
      __$$ExamAnswerQuestionGradeImplCopyWithImpl<
        _$ExamAnswerQuestionGradeImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamAnswerQuestionGradeImplToJson(this);
  }
}

abstract class _ExamAnswerQuestionGrade implements ExamAnswerQuestionGrade {
  const factory _ExamAnswerQuestionGrade({
    required final int questionNo,
    final int myAnswer,
    final int? answer,
    final bool? isCorrect,
  }) = _$ExamAnswerQuestionGradeImpl;

  factory _ExamAnswerQuestionGrade.fromJson(Map<String, dynamic> json) =
      _$ExamAnswerQuestionGradeImpl.fromJson;

  @override
  int get questionNo;
  @override
  int get myAnswer;
  @override
  int? get answer;
  @override
  bool? get isCorrect;

  /// Create a copy of ExamAnswerQuestionGrade
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamAnswerQuestionGradeImplCopyWith<_$ExamAnswerQuestionGradeImpl>
  get copyWith => throw _privateConstructorUsedError;
}
