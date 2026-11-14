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

ExamAnswerSheetSubmitRequest _$ExamAnswerSheetSubmitRequestFromJson(
  Map<String, dynamic> json,
) {
  return _ExamAnswerSheetSubmitRequest.fromJson(json);
}

/// @nodoc
mixin _$ExamAnswerSheetSubmitRequest {
  String get clientToken => throw _privateConstructorUsedError;
  String get answers => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;

  /// Serializes this ExamAnswerSheetSubmitRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamAnswerSheetSubmitRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamAnswerSheetSubmitRequestCopyWith<ExamAnswerSheetSubmitRequest>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamAnswerSheetSubmitRequestCopyWith<$Res> {
  factory $ExamAnswerSheetSubmitRequestCopyWith(
    ExamAnswerSheetSubmitRequest value,
    $Res Function(ExamAnswerSheetSubmitRequest) then,
  ) =
      _$ExamAnswerSheetSubmitRequestCopyWithImpl<
        $Res,
        ExamAnswerSheetSubmitRequest
      >;
  @useResult
  $Res call({String clientToken, String answers, String source});
}

/// @nodoc
class _$ExamAnswerSheetSubmitRequestCopyWithImpl<
  $Res,
  $Val extends ExamAnswerSheetSubmitRequest
>
    implements $ExamAnswerSheetSubmitRequestCopyWith<$Res> {
  _$ExamAnswerSheetSubmitRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamAnswerSheetSubmitRequest
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
abstract class _$$ExamAnswerSheetSubmitRequestImplCopyWith<$Res>
    implements $ExamAnswerSheetSubmitRequestCopyWith<$Res> {
  factory _$$ExamAnswerSheetSubmitRequestImplCopyWith(
    _$ExamAnswerSheetSubmitRequestImpl value,
    $Res Function(_$ExamAnswerSheetSubmitRequestImpl) then,
  ) = __$$ExamAnswerSheetSubmitRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String clientToken, String answers, String source});
}

/// @nodoc
class __$$ExamAnswerSheetSubmitRequestImplCopyWithImpl<$Res>
    extends
        _$ExamAnswerSheetSubmitRequestCopyWithImpl<
          $Res,
          _$ExamAnswerSheetSubmitRequestImpl
        >
    implements _$$ExamAnswerSheetSubmitRequestImplCopyWith<$Res> {
  __$$ExamAnswerSheetSubmitRequestImplCopyWithImpl(
    _$ExamAnswerSheetSubmitRequestImpl _value,
    $Res Function(_$ExamAnswerSheetSubmitRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamAnswerSheetSubmitRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? clientToken = null,
    Object? answers = null,
    Object? source = null,
  }) {
    return _then(
      _$ExamAnswerSheetSubmitRequestImpl(
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
class _$ExamAnswerSheetSubmitRequestImpl
    implements _ExamAnswerSheetSubmitRequest {
  const _$ExamAnswerSheetSubmitRequestImpl({
    required this.clientToken,
    required this.answers,
    required this.source,
  });

  factory _$ExamAnswerSheetSubmitRequestImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$ExamAnswerSheetSubmitRequestImplFromJson(json);

  @override
  final String clientToken;
  @override
  final String answers;
  @override
  final String source;

  @override
  String toString() {
    return 'ExamAnswerSheetSubmitRequest(clientToken: $clientToken, answers: $answers, source: $source)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamAnswerSheetSubmitRequestImpl &&
            (identical(other.clientToken, clientToken) ||
                other.clientToken == clientToken) &&
            (identical(other.answers, answers) || other.answers == answers) &&
            (identical(other.source, source) || other.source == source));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, clientToken, answers, source);

  /// Create a copy of ExamAnswerSheetSubmitRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamAnswerSheetSubmitRequestImplCopyWith<
    _$ExamAnswerSheetSubmitRequestImpl
  >
  get copyWith =>
      __$$ExamAnswerSheetSubmitRequestImplCopyWithImpl<
        _$ExamAnswerSheetSubmitRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamAnswerSheetSubmitRequestImplToJson(this);
  }
}

abstract class _ExamAnswerSheetSubmitRequest
    implements ExamAnswerSheetSubmitRequest {
  const factory _ExamAnswerSheetSubmitRequest({
    required final String clientToken,
    required final String answers,
    required final String source,
  }) = _$ExamAnswerSheetSubmitRequestImpl;

  factory _ExamAnswerSheetSubmitRequest.fromJson(Map<String, dynamic> json) =
      _$ExamAnswerSheetSubmitRequestImpl.fromJson;

  @override
  String get clientToken;
  @override
  String get answers;
  @override
  String get source;

  /// Create a copy of ExamAnswerSheetSubmitRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamAnswerSheetSubmitRequestImplCopyWith<
    _$ExamAnswerSheetSubmitRequestImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

ExamAnswerSheetResponse _$ExamAnswerSheetResponseFromJson(
  Map<String, dynamic> json,
) {
  return _ExamAnswerSheetResponse.fromJson(json);
}

/// @nodoc
mixin _$ExamAnswerSheetResponse {
  String get certType => throw _privateConstructorUsedError;
  int get roundNumber => throw _privateConstructorUsedError;
  String get answers => throw _privateConstructorUsedError;
  String? get source => throw _privateConstructorUsedError;
  DateTime? get submittedAt => throw _privateConstructorUsedError;
  ExamAnswerGradingResponse? get result => throw _privateConstructorUsedError;

  /// Serializes this ExamAnswerSheetResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamAnswerSheetResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamAnswerSheetResponseCopyWith<ExamAnswerSheetResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamAnswerSheetResponseCopyWith<$Res> {
  factory $ExamAnswerSheetResponseCopyWith(
    ExamAnswerSheetResponse value,
    $Res Function(ExamAnswerSheetResponse) then,
  ) = _$ExamAnswerSheetResponseCopyWithImpl<$Res, ExamAnswerSheetResponse>;
  @useResult
  $Res call({
    String certType,
    int roundNumber,
    String answers,
    String? source,
    DateTime? submittedAt,
    ExamAnswerGradingResponse? result,
  });

  $ExamAnswerGradingResponseCopyWith<$Res>? get result;
}

/// @nodoc
class _$ExamAnswerSheetResponseCopyWithImpl<
  $Res,
  $Val extends ExamAnswerSheetResponse
>
    implements $ExamAnswerSheetResponseCopyWith<$Res> {
  _$ExamAnswerSheetResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamAnswerSheetResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? certType = null,
    Object? roundNumber = null,
    Object? answers = null,
    Object? source = freezed,
    Object? submittedAt = freezed,
    Object? result = freezed,
  }) {
    return _then(
      _value.copyWith(
            certType: null == certType
                ? _value.certType
                : certType // ignore: cast_nullable_to_non_nullable
                      as String,
            roundNumber: null == roundNumber
                ? _value.roundNumber
                : roundNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            answers: null == answers
                ? _value.answers
                : answers // ignore: cast_nullable_to_non_nullable
                      as String,
            source: freezed == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String?,
            submittedAt: freezed == submittedAt
                ? _value.submittedAt
                : submittedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            result: freezed == result
                ? _value.result
                : result // ignore: cast_nullable_to_non_nullable
                      as ExamAnswerGradingResponse?,
          )
          as $Val,
    );
  }

  /// Create a copy of ExamAnswerSheetResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExamAnswerGradingResponseCopyWith<$Res>? get result {
    if (_value.result == null) {
      return null;
    }

    return $ExamAnswerGradingResponseCopyWith<$Res>(_value.result!, (value) {
      return _then(_value.copyWith(result: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ExamAnswerSheetResponseImplCopyWith<$Res>
    implements $ExamAnswerSheetResponseCopyWith<$Res> {
  factory _$$ExamAnswerSheetResponseImplCopyWith(
    _$ExamAnswerSheetResponseImpl value,
    $Res Function(_$ExamAnswerSheetResponseImpl) then,
  ) = __$$ExamAnswerSheetResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String certType,
    int roundNumber,
    String answers,
    String? source,
    DateTime? submittedAt,
    ExamAnswerGradingResponse? result,
  });

  @override
  $ExamAnswerGradingResponseCopyWith<$Res>? get result;
}

/// @nodoc
class __$$ExamAnswerSheetResponseImplCopyWithImpl<$Res>
    extends
        _$ExamAnswerSheetResponseCopyWithImpl<
          $Res,
          _$ExamAnswerSheetResponseImpl
        >
    implements _$$ExamAnswerSheetResponseImplCopyWith<$Res> {
  __$$ExamAnswerSheetResponseImplCopyWithImpl(
    _$ExamAnswerSheetResponseImpl _value,
    $Res Function(_$ExamAnswerSheetResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamAnswerSheetResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? certType = null,
    Object? roundNumber = null,
    Object? answers = null,
    Object? source = freezed,
    Object? submittedAt = freezed,
    Object? result = freezed,
  }) {
    return _then(
      _$ExamAnswerSheetResponseImpl(
        certType: null == certType
            ? _value.certType
            : certType // ignore: cast_nullable_to_non_nullable
                  as String,
        roundNumber: null == roundNumber
            ? _value.roundNumber
            : roundNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        answers: null == answers
            ? _value.answers
            : answers // ignore: cast_nullable_to_non_nullable
                  as String,
        source: freezed == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String?,
        submittedAt: freezed == submittedAt
            ? _value.submittedAt
            : submittedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        result: freezed == result
            ? _value.result
            : result // ignore: cast_nullable_to_non_nullable
                  as ExamAnswerGradingResponse?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamAnswerSheetResponseImpl implements _ExamAnswerSheetResponse {
  const _$ExamAnswerSheetResponseImpl({
    required this.certType,
    required this.roundNumber,
    required this.answers,
    this.source,
    this.submittedAt,
    this.result,
  });

  factory _$ExamAnswerSheetResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamAnswerSheetResponseImplFromJson(json);

  @override
  final String certType;
  @override
  final int roundNumber;
  @override
  final String answers;
  @override
  final String? source;
  @override
  final DateTime? submittedAt;
  @override
  final ExamAnswerGradingResponse? result;

  @override
  String toString() {
    return 'ExamAnswerSheetResponse(certType: $certType, roundNumber: $roundNumber, answers: $answers, source: $source, submittedAt: $submittedAt, result: $result)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamAnswerSheetResponseImpl &&
            (identical(other.certType, certType) ||
                other.certType == certType) &&
            (identical(other.roundNumber, roundNumber) ||
                other.roundNumber == roundNumber) &&
            (identical(other.answers, answers) || other.answers == answers) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.result, result) || other.result == result));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    certType,
    roundNumber,
    answers,
    source,
    submittedAt,
    result,
  );

  /// Create a copy of ExamAnswerSheetResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamAnswerSheetResponseImplCopyWith<_$ExamAnswerSheetResponseImpl>
  get copyWith =>
      __$$ExamAnswerSheetResponseImplCopyWithImpl<
        _$ExamAnswerSheetResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamAnswerSheetResponseImplToJson(this);
  }
}

abstract class _ExamAnswerSheetResponse implements ExamAnswerSheetResponse {
  const factory _ExamAnswerSheetResponse({
    required final String certType,
    required final int roundNumber,
    required final String answers,
    final String? source,
    final DateTime? submittedAt,
    final ExamAnswerGradingResponse? result,
  }) = _$ExamAnswerSheetResponseImpl;

  factory _ExamAnswerSheetResponse.fromJson(Map<String, dynamic> json) =
      _$ExamAnswerSheetResponseImpl.fromJson;

  @override
  String get certType;
  @override
  int get roundNumber;
  @override
  String get answers;
  @override
  String? get source;
  @override
  DateTime? get submittedAt;
  @override
  ExamAnswerGradingResponse? get result;

  /// Create a copy of ExamAnswerSheetResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamAnswerSheetResponseImplCopyWith<_$ExamAnswerSheetResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ExamAnswerGradingResponse _$ExamAnswerGradingResponseFromJson(
  Map<String, dynamic> json,
) {
  return _ExamAnswerGradingResponse.fromJson(json);
}

/// @nodoc
mixin _$ExamAnswerGradingResponse {
  ExamAnswerSubjectScoreResponse get subject1 =>
      throw _privateConstructorUsedError;
  ExamAnswerSubjectScoreResponse get subject2 =>
      throw _privateConstructorUsedError;
  int get totalScore => throw _privateConstructorUsedError;
  ExamAnswerScoreRangeResponse? get scoreRange =>
      throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: ExamAnswerPassStatusValue.unknown)
  ExamAnswerPassStatusValue get passStatus =>
      throw _privateConstructorUsedError; // 참여자 중 상위 % (1~100 올림, 참여 10명 미만이면 null)
  int? get percentile => throw _privateConstructorUsedError;
  List<ExamAnswerQuestionResultResponse> get perQuestion =>
      throw _privateConstructorUsedError;

  /// Serializes this ExamAnswerGradingResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamAnswerGradingResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamAnswerGradingResponseCopyWith<ExamAnswerGradingResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamAnswerGradingResponseCopyWith<$Res> {
  factory $ExamAnswerGradingResponseCopyWith(
    ExamAnswerGradingResponse value,
    $Res Function(ExamAnswerGradingResponse) then,
  ) = _$ExamAnswerGradingResponseCopyWithImpl<$Res, ExamAnswerGradingResponse>;
  @useResult
  $Res call({
    ExamAnswerSubjectScoreResponse subject1,
    ExamAnswerSubjectScoreResponse subject2,
    int totalScore,
    ExamAnswerScoreRangeResponse? scoreRange,
    @JsonKey(unknownEnumValue: ExamAnswerPassStatusValue.unknown)
    ExamAnswerPassStatusValue passStatus,
    int? percentile,
    List<ExamAnswerQuestionResultResponse> perQuestion,
  });

  $ExamAnswerSubjectScoreResponseCopyWith<$Res> get subject1;
  $ExamAnswerSubjectScoreResponseCopyWith<$Res> get subject2;
  $ExamAnswerScoreRangeResponseCopyWith<$Res>? get scoreRange;
}

/// @nodoc
class _$ExamAnswerGradingResponseCopyWithImpl<
  $Res,
  $Val extends ExamAnswerGradingResponse
>
    implements $ExamAnswerGradingResponseCopyWith<$Res> {
  _$ExamAnswerGradingResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamAnswerGradingResponse
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
                      as ExamAnswerSubjectScoreResponse,
            subject2: null == subject2
                ? _value.subject2
                : subject2 // ignore: cast_nullable_to_non_nullable
                      as ExamAnswerSubjectScoreResponse,
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
                      as int?,
            perQuestion: null == perQuestion
                ? _value.perQuestion
                : perQuestion // ignore: cast_nullable_to_non_nullable
                      as List<ExamAnswerQuestionResultResponse>,
          )
          as $Val,
    );
  }

  /// Create a copy of ExamAnswerGradingResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExamAnswerSubjectScoreResponseCopyWith<$Res> get subject1 {
    return $ExamAnswerSubjectScoreResponseCopyWith<$Res>(_value.subject1, (
      value,
    ) {
      return _then(_value.copyWith(subject1: value) as $Val);
    });
  }

  /// Create a copy of ExamAnswerGradingResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExamAnswerSubjectScoreResponseCopyWith<$Res> get subject2 {
    return $ExamAnswerSubjectScoreResponseCopyWith<$Res>(_value.subject2, (
      value,
    ) {
      return _then(_value.copyWith(subject2: value) as $Val);
    });
  }

  /// Create a copy of ExamAnswerGradingResponse
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
abstract class _$$ExamAnswerGradingResponseImplCopyWith<$Res>
    implements $ExamAnswerGradingResponseCopyWith<$Res> {
  factory _$$ExamAnswerGradingResponseImplCopyWith(
    _$ExamAnswerGradingResponseImpl value,
    $Res Function(_$ExamAnswerGradingResponseImpl) then,
  ) = __$$ExamAnswerGradingResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ExamAnswerSubjectScoreResponse subject1,
    ExamAnswerSubjectScoreResponse subject2,
    int totalScore,
    ExamAnswerScoreRangeResponse? scoreRange,
    @JsonKey(unknownEnumValue: ExamAnswerPassStatusValue.unknown)
    ExamAnswerPassStatusValue passStatus,
    int? percentile,
    List<ExamAnswerQuestionResultResponse> perQuestion,
  });

  @override
  $ExamAnswerSubjectScoreResponseCopyWith<$Res> get subject1;
  @override
  $ExamAnswerSubjectScoreResponseCopyWith<$Res> get subject2;
  @override
  $ExamAnswerScoreRangeResponseCopyWith<$Res>? get scoreRange;
}

/// @nodoc
class __$$ExamAnswerGradingResponseImplCopyWithImpl<$Res>
    extends
        _$ExamAnswerGradingResponseCopyWithImpl<
          $Res,
          _$ExamAnswerGradingResponseImpl
        >
    implements _$$ExamAnswerGradingResponseImplCopyWith<$Res> {
  __$$ExamAnswerGradingResponseImplCopyWithImpl(
    _$ExamAnswerGradingResponseImpl _value,
    $Res Function(_$ExamAnswerGradingResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamAnswerGradingResponse
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
      _$ExamAnswerGradingResponseImpl(
        subject1: null == subject1
            ? _value.subject1
            : subject1 // ignore: cast_nullable_to_non_nullable
                  as ExamAnswerSubjectScoreResponse,
        subject2: null == subject2
            ? _value.subject2
            : subject2 // ignore: cast_nullable_to_non_nullable
                  as ExamAnswerSubjectScoreResponse,
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
                  as int?,
        perQuestion: null == perQuestion
            ? _value._perQuestion
            : perQuestion // ignore: cast_nullable_to_non_nullable
                  as List<ExamAnswerQuestionResultResponse>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamAnswerGradingResponseImpl implements _ExamAnswerGradingResponse {
  const _$ExamAnswerGradingResponseImpl({
    required this.subject1,
    required this.subject2,
    required this.totalScore,
    this.scoreRange,
    @JsonKey(unknownEnumValue: ExamAnswerPassStatusValue.unknown)
    this.passStatus = ExamAnswerPassStatusValue.unknown,
    this.percentile,
    final List<ExamAnswerQuestionResultResponse> perQuestion = const [],
  }) : _perQuestion = perQuestion;

  factory _$ExamAnswerGradingResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamAnswerGradingResponseImplFromJson(json);

  @override
  final ExamAnswerSubjectScoreResponse subject1;
  @override
  final ExamAnswerSubjectScoreResponse subject2;
  @override
  final int totalScore;
  @override
  final ExamAnswerScoreRangeResponse? scoreRange;
  @override
  @JsonKey(unknownEnumValue: ExamAnswerPassStatusValue.unknown)
  final ExamAnswerPassStatusValue passStatus;
  // 참여자 중 상위 % (1~100 올림, 참여 10명 미만이면 null)
  @override
  final int? percentile;
  final List<ExamAnswerQuestionResultResponse> _perQuestion;
  @override
  @JsonKey()
  List<ExamAnswerQuestionResultResponse> get perQuestion {
    if (_perQuestion is EqualUnmodifiableListView) return _perQuestion;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_perQuestion);
  }

  @override
  String toString() {
    return 'ExamAnswerGradingResponse(subject1: $subject1, subject2: $subject2, totalScore: $totalScore, scoreRange: $scoreRange, passStatus: $passStatus, percentile: $percentile, perQuestion: $perQuestion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamAnswerGradingResponseImpl &&
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

  /// Create a copy of ExamAnswerGradingResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamAnswerGradingResponseImplCopyWith<_$ExamAnswerGradingResponseImpl>
  get copyWith =>
      __$$ExamAnswerGradingResponseImplCopyWithImpl<
        _$ExamAnswerGradingResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamAnswerGradingResponseImplToJson(this);
  }
}

abstract class _ExamAnswerGradingResponse implements ExamAnswerGradingResponse {
  const factory _ExamAnswerGradingResponse({
    required final ExamAnswerSubjectScoreResponse subject1,
    required final ExamAnswerSubjectScoreResponse subject2,
    required final int totalScore,
    final ExamAnswerScoreRangeResponse? scoreRange,
    @JsonKey(unknownEnumValue: ExamAnswerPassStatusValue.unknown)
    final ExamAnswerPassStatusValue passStatus,
    final int? percentile,
    final List<ExamAnswerQuestionResultResponse> perQuestion,
  }) = _$ExamAnswerGradingResponseImpl;

  factory _ExamAnswerGradingResponse.fromJson(Map<String, dynamic> json) =
      _$ExamAnswerGradingResponseImpl.fromJson;

  @override
  ExamAnswerSubjectScoreResponse get subject1;
  @override
  ExamAnswerSubjectScoreResponse get subject2;
  @override
  int get totalScore;
  @override
  ExamAnswerScoreRangeResponse? get scoreRange;
  @override
  @JsonKey(unknownEnumValue: ExamAnswerPassStatusValue.unknown)
  ExamAnswerPassStatusValue get passStatus; // 참여자 중 상위 % (1~100 올림, 참여 10명 미만이면 null)
  @override
  int? get percentile;
  @override
  List<ExamAnswerQuestionResultResponse> get perQuestion;

  /// Create a copy of ExamAnswerGradingResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamAnswerGradingResponseImplCopyWith<_$ExamAnswerGradingResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ExamAnswerSubjectScoreResponse _$ExamAnswerSubjectScoreResponseFromJson(
  Map<String, dynamic> json,
) {
  return _ExamAnswerSubjectScoreResponse.fromJson(json);
}

/// @nodoc
mixin _$ExamAnswerSubjectScoreResponse {
  int get score => throw _privateConstructorUsedError;
  int get max => throw _privateConstructorUsedError;
  bool get isFailCut => throw _privateConstructorUsedError;

  /// Serializes this ExamAnswerSubjectScoreResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamAnswerSubjectScoreResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamAnswerSubjectScoreResponseCopyWith<ExamAnswerSubjectScoreResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamAnswerSubjectScoreResponseCopyWith<$Res> {
  factory $ExamAnswerSubjectScoreResponseCopyWith(
    ExamAnswerSubjectScoreResponse value,
    $Res Function(ExamAnswerSubjectScoreResponse) then,
  ) =
      _$ExamAnswerSubjectScoreResponseCopyWithImpl<
        $Res,
        ExamAnswerSubjectScoreResponse
      >;
  @useResult
  $Res call({int score, int max, bool isFailCut});
}

/// @nodoc
class _$ExamAnswerSubjectScoreResponseCopyWithImpl<
  $Res,
  $Val extends ExamAnswerSubjectScoreResponse
>
    implements $ExamAnswerSubjectScoreResponseCopyWith<$Res> {
  _$ExamAnswerSubjectScoreResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamAnswerSubjectScoreResponse
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
abstract class _$$ExamAnswerSubjectScoreResponseImplCopyWith<$Res>
    implements $ExamAnswerSubjectScoreResponseCopyWith<$Res> {
  factory _$$ExamAnswerSubjectScoreResponseImplCopyWith(
    _$ExamAnswerSubjectScoreResponseImpl value,
    $Res Function(_$ExamAnswerSubjectScoreResponseImpl) then,
  ) = __$$ExamAnswerSubjectScoreResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int score, int max, bool isFailCut});
}

/// @nodoc
class __$$ExamAnswerSubjectScoreResponseImplCopyWithImpl<$Res>
    extends
        _$ExamAnswerSubjectScoreResponseCopyWithImpl<
          $Res,
          _$ExamAnswerSubjectScoreResponseImpl
        >
    implements _$$ExamAnswerSubjectScoreResponseImplCopyWith<$Res> {
  __$$ExamAnswerSubjectScoreResponseImplCopyWithImpl(
    _$ExamAnswerSubjectScoreResponseImpl _value,
    $Res Function(_$ExamAnswerSubjectScoreResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamAnswerSubjectScoreResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? score = null,
    Object? max = null,
    Object? isFailCut = null,
  }) {
    return _then(
      _$ExamAnswerSubjectScoreResponseImpl(
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
class _$ExamAnswerSubjectScoreResponseImpl
    implements _ExamAnswerSubjectScoreResponse {
  const _$ExamAnswerSubjectScoreResponseImpl({
    required this.score,
    required this.max,
    this.isFailCut = false,
  });

  factory _$ExamAnswerSubjectScoreResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$ExamAnswerSubjectScoreResponseImplFromJson(json);

  @override
  final int score;
  @override
  final int max;
  @override
  @JsonKey()
  final bool isFailCut;

  @override
  String toString() {
    return 'ExamAnswerSubjectScoreResponse(score: $score, max: $max, isFailCut: $isFailCut)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamAnswerSubjectScoreResponseImpl &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.max, max) || other.max == max) &&
            (identical(other.isFailCut, isFailCut) ||
                other.isFailCut == isFailCut));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, score, max, isFailCut);

  /// Create a copy of ExamAnswerSubjectScoreResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamAnswerSubjectScoreResponseImplCopyWith<
    _$ExamAnswerSubjectScoreResponseImpl
  >
  get copyWith =>
      __$$ExamAnswerSubjectScoreResponseImplCopyWithImpl<
        _$ExamAnswerSubjectScoreResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamAnswerSubjectScoreResponseImplToJson(this);
  }
}

abstract class _ExamAnswerSubjectScoreResponse
    implements ExamAnswerSubjectScoreResponse {
  const factory _ExamAnswerSubjectScoreResponse({
    required final int score,
    required final int max,
    final bool isFailCut,
  }) = _$ExamAnswerSubjectScoreResponseImpl;

  factory _ExamAnswerSubjectScoreResponse.fromJson(Map<String, dynamic> json) =
      _$ExamAnswerSubjectScoreResponseImpl.fromJson;

  @override
  int get score;
  @override
  int get max;
  @override
  bool get isFailCut;

  /// Create a copy of ExamAnswerSubjectScoreResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamAnswerSubjectScoreResponseImplCopyWith<
    _$ExamAnswerSubjectScoreResponseImpl
  >
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

ExamAnswerQuestionResultResponse _$ExamAnswerQuestionResultResponseFromJson(
  Map<String, dynamic> json,
) {
  return _ExamAnswerQuestionResultResponse.fromJson(json);
}

/// @nodoc
mixin _$ExamAnswerQuestionResultResponse {
  int get questionNo => throw _privateConstructorUsedError;
  int get myAnswer => throw _privateConstructorUsedError;
  int? get answer => throw _privateConstructorUsedError;
  bool? get isCorrect => throw _privateConstructorUsedError;

  /// Serializes this ExamAnswerQuestionResultResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamAnswerQuestionResultResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamAnswerQuestionResultResponseCopyWith<ExamAnswerQuestionResultResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamAnswerQuestionResultResponseCopyWith<$Res> {
  factory $ExamAnswerQuestionResultResponseCopyWith(
    ExamAnswerQuestionResultResponse value,
    $Res Function(ExamAnswerQuestionResultResponse) then,
  ) =
      _$ExamAnswerQuestionResultResponseCopyWithImpl<
        $Res,
        ExamAnswerQuestionResultResponse
      >;
  @useResult
  $Res call({int questionNo, int myAnswer, int? answer, bool? isCorrect});
}

/// @nodoc
class _$ExamAnswerQuestionResultResponseCopyWithImpl<
  $Res,
  $Val extends ExamAnswerQuestionResultResponse
>
    implements $ExamAnswerQuestionResultResponseCopyWith<$Res> {
  _$ExamAnswerQuestionResultResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamAnswerQuestionResultResponse
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
abstract class _$$ExamAnswerQuestionResultResponseImplCopyWith<$Res>
    implements $ExamAnswerQuestionResultResponseCopyWith<$Res> {
  factory _$$ExamAnswerQuestionResultResponseImplCopyWith(
    _$ExamAnswerQuestionResultResponseImpl value,
    $Res Function(_$ExamAnswerQuestionResultResponseImpl) then,
  ) = __$$ExamAnswerQuestionResultResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int questionNo, int myAnswer, int? answer, bool? isCorrect});
}

/// @nodoc
class __$$ExamAnswerQuestionResultResponseImplCopyWithImpl<$Res>
    extends
        _$ExamAnswerQuestionResultResponseCopyWithImpl<
          $Res,
          _$ExamAnswerQuestionResultResponseImpl
        >
    implements _$$ExamAnswerQuestionResultResponseImplCopyWith<$Res> {
  __$$ExamAnswerQuestionResultResponseImplCopyWithImpl(
    _$ExamAnswerQuestionResultResponseImpl _value,
    $Res Function(_$ExamAnswerQuestionResultResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamAnswerQuestionResultResponse
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
      _$ExamAnswerQuestionResultResponseImpl(
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
class _$ExamAnswerQuestionResultResponseImpl
    implements _ExamAnswerQuestionResultResponse {
  const _$ExamAnswerQuestionResultResponseImpl({
    required this.questionNo,
    this.myAnswer = 0,
    this.answer,
    this.isCorrect,
  });

  factory _$ExamAnswerQuestionResultResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$ExamAnswerQuestionResultResponseImplFromJson(json);

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
    return 'ExamAnswerQuestionResultResponse(questionNo: $questionNo, myAnswer: $myAnswer, answer: $answer, isCorrect: $isCorrect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamAnswerQuestionResultResponseImpl &&
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

  /// Create a copy of ExamAnswerQuestionResultResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamAnswerQuestionResultResponseImplCopyWith<
    _$ExamAnswerQuestionResultResponseImpl
  >
  get copyWith =>
      __$$ExamAnswerQuestionResultResponseImplCopyWithImpl<
        _$ExamAnswerQuestionResultResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamAnswerQuestionResultResponseImplToJson(this);
  }
}

abstract class _ExamAnswerQuestionResultResponse
    implements ExamAnswerQuestionResultResponse {
  const factory _ExamAnswerQuestionResultResponse({
    required final int questionNo,
    final int myAnswer,
    final int? answer,
    final bool? isCorrect,
  }) = _$ExamAnswerQuestionResultResponseImpl;

  factory _ExamAnswerQuestionResultResponse.fromJson(
    Map<String, dynamic> json,
  ) = _$ExamAnswerQuestionResultResponseImpl.fromJson;

  @override
  int get questionNo;
  @override
  int get myAnswer;
  @override
  int? get answer;
  @override
  bool? get isCorrect;

  /// Create a copy of ExamAnswerQuestionResultResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamAnswerQuestionResultResponseImplCopyWith<
    _$ExamAnswerQuestionResultResponseImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
