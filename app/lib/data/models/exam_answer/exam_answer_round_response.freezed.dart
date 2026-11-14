// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exam_answer_round_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExamAnswerRoundResponse _$ExamAnswerRoundResponseFromJson(
  Map<String, dynamic> json,
) {
  return _ExamAnswerRoundResponse.fromJson(json);
}

/// @nodoc
mixin _$ExamAnswerRoundResponse {
  String get certType => throw _privateConstructorUsedError;
  int get roundNumber => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError; // 시험일 yyyy-MM-dd
  String? get examDate => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: ExamAnswerRoundStatus.unknown)
  ExamAnswerRoundStatus get status => throw _privateConstructorUsedError;
  String? get notice => throw _privateConstructorUsedError;
  ExamAnswerGradingRuleResponse? get gradingRule =>
      throw _privateConstructorUsedError;
  int get participantCount => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  List<ExamAnswerItemResponse> get items => throw _privateConstructorUsedError;

  /// Serializes this ExamAnswerRoundResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamAnswerRoundResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamAnswerRoundResponseCopyWith<ExamAnswerRoundResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamAnswerRoundResponseCopyWith<$Res> {
  factory $ExamAnswerRoundResponseCopyWith(
    ExamAnswerRoundResponse value,
    $Res Function(ExamAnswerRoundResponse) then,
  ) = _$ExamAnswerRoundResponseCopyWithImpl<$Res, ExamAnswerRoundResponse>;
  @useResult
  $Res call({
    String certType,
    int roundNumber,
    String title,
    String? examDate,
    @JsonKey(unknownEnumValue: ExamAnswerRoundStatus.unknown)
    ExamAnswerRoundStatus status,
    String? notice,
    ExamAnswerGradingRuleResponse? gradingRule,
    int participantCount,
    DateTime? updatedAt,
    List<ExamAnswerItemResponse> items,
  });

  $ExamAnswerGradingRuleResponseCopyWith<$Res>? get gradingRule;
}

/// @nodoc
class _$ExamAnswerRoundResponseCopyWithImpl<
  $Res,
  $Val extends ExamAnswerRoundResponse
>
    implements $ExamAnswerRoundResponseCopyWith<$Res> {
  _$ExamAnswerRoundResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamAnswerRoundResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? certType = null,
    Object? roundNumber = null,
    Object? title = null,
    Object? examDate = freezed,
    Object? status = null,
    Object? notice = freezed,
    Object? gradingRule = freezed,
    Object? participantCount = null,
    Object? updatedAt = freezed,
    Object? items = null,
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
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            examDate: freezed == examDate
                ? _value.examDate
                : examDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ExamAnswerRoundStatus,
            notice: freezed == notice
                ? _value.notice
                : notice // ignore: cast_nullable_to_non_nullable
                      as String?,
            gradingRule: freezed == gradingRule
                ? _value.gradingRule
                : gradingRule // ignore: cast_nullable_to_non_nullable
                      as ExamAnswerGradingRuleResponse?,
            participantCount: null == participantCount
                ? _value.participantCount
                : participantCount // ignore: cast_nullable_to_non_nullable
                      as int,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<ExamAnswerItemResponse>,
          )
          as $Val,
    );
  }

  /// Create a copy of ExamAnswerRoundResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExamAnswerGradingRuleResponseCopyWith<$Res>? get gradingRule {
    if (_value.gradingRule == null) {
      return null;
    }

    return $ExamAnswerGradingRuleResponseCopyWith<$Res>(_value.gradingRule!, (
      value,
    ) {
      return _then(_value.copyWith(gradingRule: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ExamAnswerRoundResponseImplCopyWith<$Res>
    implements $ExamAnswerRoundResponseCopyWith<$Res> {
  factory _$$ExamAnswerRoundResponseImplCopyWith(
    _$ExamAnswerRoundResponseImpl value,
    $Res Function(_$ExamAnswerRoundResponseImpl) then,
  ) = __$$ExamAnswerRoundResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String certType,
    int roundNumber,
    String title,
    String? examDate,
    @JsonKey(unknownEnumValue: ExamAnswerRoundStatus.unknown)
    ExamAnswerRoundStatus status,
    String? notice,
    ExamAnswerGradingRuleResponse? gradingRule,
    int participantCount,
    DateTime? updatedAt,
    List<ExamAnswerItemResponse> items,
  });

  @override
  $ExamAnswerGradingRuleResponseCopyWith<$Res>? get gradingRule;
}

/// @nodoc
class __$$ExamAnswerRoundResponseImplCopyWithImpl<$Res>
    extends
        _$ExamAnswerRoundResponseCopyWithImpl<
          $Res,
          _$ExamAnswerRoundResponseImpl
        >
    implements _$$ExamAnswerRoundResponseImplCopyWith<$Res> {
  __$$ExamAnswerRoundResponseImplCopyWithImpl(
    _$ExamAnswerRoundResponseImpl _value,
    $Res Function(_$ExamAnswerRoundResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamAnswerRoundResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? certType = null,
    Object? roundNumber = null,
    Object? title = null,
    Object? examDate = freezed,
    Object? status = null,
    Object? notice = freezed,
    Object? gradingRule = freezed,
    Object? participantCount = null,
    Object? updatedAt = freezed,
    Object? items = null,
  }) {
    return _then(
      _$ExamAnswerRoundResponseImpl(
        certType: null == certType
            ? _value.certType
            : certType // ignore: cast_nullable_to_non_nullable
                  as String,
        roundNumber: null == roundNumber
            ? _value.roundNumber
            : roundNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        examDate: freezed == examDate
            ? _value.examDate
            : examDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ExamAnswerRoundStatus,
        notice: freezed == notice
            ? _value.notice
            : notice // ignore: cast_nullable_to_non_nullable
                  as String?,
        gradingRule: freezed == gradingRule
            ? _value.gradingRule
            : gradingRule // ignore: cast_nullable_to_non_nullable
                  as ExamAnswerGradingRuleResponse?,
        participantCount: null == participantCount
            ? _value.participantCount
            : participantCount // ignore: cast_nullable_to_non_nullable
                  as int,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<ExamAnswerItemResponse>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamAnswerRoundResponseImpl extends _ExamAnswerRoundResponse {
  const _$ExamAnswerRoundResponseImpl({
    required this.certType,
    required this.roundNumber,
    this.title = '',
    this.examDate,
    @JsonKey(unknownEnumValue: ExamAnswerRoundStatus.unknown)
    this.status = ExamAnswerRoundStatus.unknown,
    this.notice,
    this.gradingRule,
    this.participantCount = 0,
    this.updatedAt,
    final List<ExamAnswerItemResponse> items = const [],
  }) : _items = items,
       super._();

  factory _$ExamAnswerRoundResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamAnswerRoundResponseImplFromJson(json);

  @override
  final String certType;
  @override
  final int roundNumber;
  @override
  @JsonKey()
  final String title;
  // 시험일 yyyy-MM-dd
  @override
  final String? examDate;
  @override
  @JsonKey(unknownEnumValue: ExamAnswerRoundStatus.unknown)
  final ExamAnswerRoundStatus status;
  @override
  final String? notice;
  @override
  final ExamAnswerGradingRuleResponse? gradingRule;
  @override
  @JsonKey()
  final int participantCount;
  @override
  final DateTime? updatedAt;
  final List<ExamAnswerItemResponse> _items;
  @override
  @JsonKey()
  List<ExamAnswerItemResponse> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'ExamAnswerRoundResponse(certType: $certType, roundNumber: $roundNumber, title: $title, examDate: $examDate, status: $status, notice: $notice, gradingRule: $gradingRule, participantCount: $participantCount, updatedAt: $updatedAt, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamAnswerRoundResponseImpl &&
            (identical(other.certType, certType) ||
                other.certType == certType) &&
            (identical(other.roundNumber, roundNumber) ||
                other.roundNumber == roundNumber) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.examDate, examDate) ||
                other.examDate == examDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notice, notice) || other.notice == notice) &&
            (identical(other.gradingRule, gradingRule) ||
                other.gradingRule == gradingRule) &&
            (identical(other.participantCount, participantCount) ||
                other.participantCount == participantCount) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    certType,
    roundNumber,
    title,
    examDate,
    status,
    notice,
    gradingRule,
    participantCount,
    updatedAt,
    const DeepCollectionEquality().hash(_items),
  );

  /// Create a copy of ExamAnswerRoundResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamAnswerRoundResponseImplCopyWith<_$ExamAnswerRoundResponseImpl>
  get copyWith =>
      __$$ExamAnswerRoundResponseImplCopyWithImpl<
        _$ExamAnswerRoundResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamAnswerRoundResponseImplToJson(this);
  }
}

abstract class _ExamAnswerRoundResponse extends ExamAnswerRoundResponse {
  const factory _ExamAnswerRoundResponse({
    required final String certType,
    required final int roundNumber,
    final String title,
    final String? examDate,
    @JsonKey(unknownEnumValue: ExamAnswerRoundStatus.unknown)
    final ExamAnswerRoundStatus status,
    final String? notice,
    final ExamAnswerGradingRuleResponse? gradingRule,
    final int participantCount,
    final DateTime? updatedAt,
    final List<ExamAnswerItemResponse> items,
  }) = _$ExamAnswerRoundResponseImpl;
  const _ExamAnswerRoundResponse._() : super._();

  factory _ExamAnswerRoundResponse.fromJson(Map<String, dynamic> json) =
      _$ExamAnswerRoundResponseImpl.fromJson;

  @override
  String get certType;
  @override
  int get roundNumber;
  @override
  String get title; // 시험일 yyyy-MM-dd
  @override
  String? get examDate;
  @override
  @JsonKey(unknownEnumValue: ExamAnswerRoundStatus.unknown)
  ExamAnswerRoundStatus get status;
  @override
  String? get notice;
  @override
  ExamAnswerGradingRuleResponse? get gradingRule;
  @override
  int get participantCount;
  @override
  DateTime? get updatedAt;
  @override
  List<ExamAnswerItemResponse> get items;

  /// Create a copy of ExamAnswerRoundResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamAnswerRoundResponseImplCopyWith<_$ExamAnswerRoundResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ExamAnswerGradingRuleResponse _$ExamAnswerGradingRuleResponseFromJson(
  Map<String, dynamic> json,
) {
  return _ExamAnswerGradingRuleResponse.fromJson(json);
}

/// @nodoc
mixin _$ExamAnswerGradingRuleResponse {
  int get totalQuestionCount => throw _privateConstructorUsedError;
  int get pointsPerQuestion => throw _privateConstructorUsedError;
  int get maxScore => throw _privateConstructorUsedError;
  int get passScore =>
      throw _privateConstructorUsedError; // 과락 기준 (과목 만점 대비 %, 미만이면 과락)
  int get subjectFailBelowPercent => throw _privateConstructorUsedError;
  List<ExamAnswerSubjectRuleResponse> get subjects =>
      throw _privateConstructorUsedError;

  /// Serializes this ExamAnswerGradingRuleResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamAnswerGradingRuleResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamAnswerGradingRuleResponseCopyWith<ExamAnswerGradingRuleResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamAnswerGradingRuleResponseCopyWith<$Res> {
  factory $ExamAnswerGradingRuleResponseCopyWith(
    ExamAnswerGradingRuleResponse value,
    $Res Function(ExamAnswerGradingRuleResponse) then,
  ) =
      _$ExamAnswerGradingRuleResponseCopyWithImpl<
        $Res,
        ExamAnswerGradingRuleResponse
      >;
  @useResult
  $Res call({
    int totalQuestionCount,
    int pointsPerQuestion,
    int maxScore,
    int passScore,
    int subjectFailBelowPercent,
    List<ExamAnswerSubjectRuleResponse> subjects,
  });
}

/// @nodoc
class _$ExamAnswerGradingRuleResponseCopyWithImpl<
  $Res,
  $Val extends ExamAnswerGradingRuleResponse
>
    implements $ExamAnswerGradingRuleResponseCopyWith<$Res> {
  _$ExamAnswerGradingRuleResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamAnswerGradingRuleResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalQuestionCount = null,
    Object? pointsPerQuestion = null,
    Object? maxScore = null,
    Object? passScore = null,
    Object? subjectFailBelowPercent = null,
    Object? subjects = null,
  }) {
    return _then(
      _value.copyWith(
            totalQuestionCount: null == totalQuestionCount
                ? _value.totalQuestionCount
                : totalQuestionCount // ignore: cast_nullable_to_non_nullable
                      as int,
            pointsPerQuestion: null == pointsPerQuestion
                ? _value.pointsPerQuestion
                : pointsPerQuestion // ignore: cast_nullable_to_non_nullable
                      as int,
            maxScore: null == maxScore
                ? _value.maxScore
                : maxScore // ignore: cast_nullable_to_non_nullable
                      as int,
            passScore: null == passScore
                ? _value.passScore
                : passScore // ignore: cast_nullable_to_non_nullable
                      as int,
            subjectFailBelowPercent: null == subjectFailBelowPercent
                ? _value.subjectFailBelowPercent
                : subjectFailBelowPercent // ignore: cast_nullable_to_non_nullable
                      as int,
            subjects: null == subjects
                ? _value.subjects
                : subjects // ignore: cast_nullable_to_non_nullable
                      as List<ExamAnswerSubjectRuleResponse>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExamAnswerGradingRuleResponseImplCopyWith<$Res>
    implements $ExamAnswerGradingRuleResponseCopyWith<$Res> {
  factory _$$ExamAnswerGradingRuleResponseImplCopyWith(
    _$ExamAnswerGradingRuleResponseImpl value,
    $Res Function(_$ExamAnswerGradingRuleResponseImpl) then,
  ) = __$$ExamAnswerGradingRuleResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalQuestionCount,
    int pointsPerQuestion,
    int maxScore,
    int passScore,
    int subjectFailBelowPercent,
    List<ExamAnswerSubjectRuleResponse> subjects,
  });
}

/// @nodoc
class __$$ExamAnswerGradingRuleResponseImplCopyWithImpl<$Res>
    extends
        _$ExamAnswerGradingRuleResponseCopyWithImpl<
          $Res,
          _$ExamAnswerGradingRuleResponseImpl
        >
    implements _$$ExamAnswerGradingRuleResponseImplCopyWith<$Res> {
  __$$ExamAnswerGradingRuleResponseImplCopyWithImpl(
    _$ExamAnswerGradingRuleResponseImpl _value,
    $Res Function(_$ExamAnswerGradingRuleResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamAnswerGradingRuleResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalQuestionCount = null,
    Object? pointsPerQuestion = null,
    Object? maxScore = null,
    Object? passScore = null,
    Object? subjectFailBelowPercent = null,
    Object? subjects = null,
  }) {
    return _then(
      _$ExamAnswerGradingRuleResponseImpl(
        totalQuestionCount: null == totalQuestionCount
            ? _value.totalQuestionCount
            : totalQuestionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        pointsPerQuestion: null == pointsPerQuestion
            ? _value.pointsPerQuestion
            : pointsPerQuestion // ignore: cast_nullable_to_non_nullable
                  as int,
        maxScore: null == maxScore
            ? _value.maxScore
            : maxScore // ignore: cast_nullable_to_non_nullable
                  as int,
        passScore: null == passScore
            ? _value.passScore
            : passScore // ignore: cast_nullable_to_non_nullable
                  as int,
        subjectFailBelowPercent: null == subjectFailBelowPercent
            ? _value.subjectFailBelowPercent
            : subjectFailBelowPercent // ignore: cast_nullable_to_non_nullable
                  as int,
        subjects: null == subjects
            ? _value._subjects
            : subjects // ignore: cast_nullable_to_non_nullable
                  as List<ExamAnswerSubjectRuleResponse>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamAnswerGradingRuleResponseImpl
    extends _ExamAnswerGradingRuleResponse {
  const _$ExamAnswerGradingRuleResponseImpl({
    required this.totalQuestionCount,
    required this.pointsPerQuestion,
    required this.maxScore,
    required this.passScore,
    this.subjectFailBelowPercent = 0,
    final List<ExamAnswerSubjectRuleResponse> subjects = const [],
  }) : _subjects = subjects,
       super._();

  factory _$ExamAnswerGradingRuleResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$ExamAnswerGradingRuleResponseImplFromJson(json);

  @override
  final int totalQuestionCount;
  @override
  final int pointsPerQuestion;
  @override
  final int maxScore;
  @override
  final int passScore;
  // 과락 기준 (과목 만점 대비 %, 미만이면 과락)
  @override
  @JsonKey()
  final int subjectFailBelowPercent;
  final List<ExamAnswerSubjectRuleResponse> _subjects;
  @override
  @JsonKey()
  List<ExamAnswerSubjectRuleResponse> get subjects {
    if (_subjects is EqualUnmodifiableListView) return _subjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subjects);
  }

  @override
  String toString() {
    return 'ExamAnswerGradingRuleResponse(totalQuestionCount: $totalQuestionCount, pointsPerQuestion: $pointsPerQuestion, maxScore: $maxScore, passScore: $passScore, subjectFailBelowPercent: $subjectFailBelowPercent, subjects: $subjects)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamAnswerGradingRuleResponseImpl &&
            (identical(other.totalQuestionCount, totalQuestionCount) ||
                other.totalQuestionCount == totalQuestionCount) &&
            (identical(other.pointsPerQuestion, pointsPerQuestion) ||
                other.pointsPerQuestion == pointsPerQuestion) &&
            (identical(other.maxScore, maxScore) ||
                other.maxScore == maxScore) &&
            (identical(other.passScore, passScore) ||
                other.passScore == passScore) &&
            (identical(
                  other.subjectFailBelowPercent,
                  subjectFailBelowPercent,
                ) ||
                other.subjectFailBelowPercent == subjectFailBelowPercent) &&
            const DeepCollectionEquality().equals(other._subjects, _subjects));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalQuestionCount,
    pointsPerQuestion,
    maxScore,
    passScore,
    subjectFailBelowPercent,
    const DeepCollectionEquality().hash(_subjects),
  );

  /// Create a copy of ExamAnswerGradingRuleResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamAnswerGradingRuleResponseImplCopyWith<
    _$ExamAnswerGradingRuleResponseImpl
  >
  get copyWith =>
      __$$ExamAnswerGradingRuleResponseImplCopyWithImpl<
        _$ExamAnswerGradingRuleResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamAnswerGradingRuleResponseImplToJson(this);
  }
}

abstract class _ExamAnswerGradingRuleResponse
    extends ExamAnswerGradingRuleResponse {
  const factory _ExamAnswerGradingRuleResponse({
    required final int totalQuestionCount,
    required final int pointsPerQuestion,
    required final int maxScore,
    required final int passScore,
    final int subjectFailBelowPercent,
    final List<ExamAnswerSubjectRuleResponse> subjects,
  }) = _$ExamAnswerGradingRuleResponseImpl;
  const _ExamAnswerGradingRuleResponse._() : super._();

  factory _ExamAnswerGradingRuleResponse.fromJson(Map<String, dynamic> json) =
      _$ExamAnswerGradingRuleResponseImpl.fromJson;

  @override
  int get totalQuestionCount;
  @override
  int get pointsPerQuestion;
  @override
  int get maxScore;
  @override
  int get passScore; // 과락 기준 (과목 만점 대비 %, 미만이면 과락)
  @override
  int get subjectFailBelowPercent;
  @override
  List<ExamAnswerSubjectRuleResponse> get subjects;

  /// Create a copy of ExamAnswerGradingRuleResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamAnswerGradingRuleResponseImplCopyWith<
    _$ExamAnswerGradingRuleResponseImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

ExamAnswerSubjectRuleResponse _$ExamAnswerSubjectRuleResponseFromJson(
  Map<String, dynamic> json,
) {
  return _ExamAnswerSubjectRuleResponse.fromJson(json);
}

/// @nodoc
mixin _$ExamAnswerSubjectRuleResponse {
  int get subjectNo => throw _privateConstructorUsedError;
  String get subjectName => throw _privateConstructorUsedError;
  int get firstQuestionNo => throw _privateConstructorUsedError;
  int get lastQuestionNo => throw _privateConstructorUsedError;
  int get maxScore => throw _privateConstructorUsedError;
  int get failBelowScore => throw _privateConstructorUsedError;

  /// Serializes this ExamAnswerSubjectRuleResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamAnswerSubjectRuleResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamAnswerSubjectRuleResponseCopyWith<ExamAnswerSubjectRuleResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamAnswerSubjectRuleResponseCopyWith<$Res> {
  factory $ExamAnswerSubjectRuleResponseCopyWith(
    ExamAnswerSubjectRuleResponse value,
    $Res Function(ExamAnswerSubjectRuleResponse) then,
  ) =
      _$ExamAnswerSubjectRuleResponseCopyWithImpl<
        $Res,
        ExamAnswerSubjectRuleResponse
      >;
  @useResult
  $Res call({
    int subjectNo,
    String subjectName,
    int firstQuestionNo,
    int lastQuestionNo,
    int maxScore,
    int failBelowScore,
  });
}

/// @nodoc
class _$ExamAnswerSubjectRuleResponseCopyWithImpl<
  $Res,
  $Val extends ExamAnswerSubjectRuleResponse
>
    implements $ExamAnswerSubjectRuleResponseCopyWith<$Res> {
  _$ExamAnswerSubjectRuleResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamAnswerSubjectRuleResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subjectNo = null,
    Object? subjectName = null,
    Object? firstQuestionNo = null,
    Object? lastQuestionNo = null,
    Object? maxScore = null,
    Object? failBelowScore = null,
  }) {
    return _then(
      _value.copyWith(
            subjectNo: null == subjectNo
                ? _value.subjectNo
                : subjectNo // ignore: cast_nullable_to_non_nullable
                      as int,
            subjectName: null == subjectName
                ? _value.subjectName
                : subjectName // ignore: cast_nullable_to_non_nullable
                      as String,
            firstQuestionNo: null == firstQuestionNo
                ? _value.firstQuestionNo
                : firstQuestionNo // ignore: cast_nullable_to_non_nullable
                      as int,
            lastQuestionNo: null == lastQuestionNo
                ? _value.lastQuestionNo
                : lastQuestionNo // ignore: cast_nullable_to_non_nullable
                      as int,
            maxScore: null == maxScore
                ? _value.maxScore
                : maxScore // ignore: cast_nullable_to_non_nullable
                      as int,
            failBelowScore: null == failBelowScore
                ? _value.failBelowScore
                : failBelowScore // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExamAnswerSubjectRuleResponseImplCopyWith<$Res>
    implements $ExamAnswerSubjectRuleResponseCopyWith<$Res> {
  factory _$$ExamAnswerSubjectRuleResponseImplCopyWith(
    _$ExamAnswerSubjectRuleResponseImpl value,
    $Res Function(_$ExamAnswerSubjectRuleResponseImpl) then,
  ) = __$$ExamAnswerSubjectRuleResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int subjectNo,
    String subjectName,
    int firstQuestionNo,
    int lastQuestionNo,
    int maxScore,
    int failBelowScore,
  });
}

/// @nodoc
class __$$ExamAnswerSubjectRuleResponseImplCopyWithImpl<$Res>
    extends
        _$ExamAnswerSubjectRuleResponseCopyWithImpl<
          $Res,
          _$ExamAnswerSubjectRuleResponseImpl
        >
    implements _$$ExamAnswerSubjectRuleResponseImplCopyWith<$Res> {
  __$$ExamAnswerSubjectRuleResponseImplCopyWithImpl(
    _$ExamAnswerSubjectRuleResponseImpl _value,
    $Res Function(_$ExamAnswerSubjectRuleResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamAnswerSubjectRuleResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subjectNo = null,
    Object? subjectName = null,
    Object? firstQuestionNo = null,
    Object? lastQuestionNo = null,
    Object? maxScore = null,
    Object? failBelowScore = null,
  }) {
    return _then(
      _$ExamAnswerSubjectRuleResponseImpl(
        subjectNo: null == subjectNo
            ? _value.subjectNo
            : subjectNo // ignore: cast_nullable_to_non_nullable
                  as int,
        subjectName: null == subjectName
            ? _value.subjectName
            : subjectName // ignore: cast_nullable_to_non_nullable
                  as String,
        firstQuestionNo: null == firstQuestionNo
            ? _value.firstQuestionNo
            : firstQuestionNo // ignore: cast_nullable_to_non_nullable
                  as int,
        lastQuestionNo: null == lastQuestionNo
            ? _value.lastQuestionNo
            : lastQuestionNo // ignore: cast_nullable_to_non_nullable
                  as int,
        maxScore: null == maxScore
            ? _value.maxScore
            : maxScore // ignore: cast_nullable_to_non_nullable
                  as int,
        failBelowScore: null == failBelowScore
            ? _value.failBelowScore
            : failBelowScore // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamAnswerSubjectRuleResponseImpl
    implements _ExamAnswerSubjectRuleResponse {
  const _$ExamAnswerSubjectRuleResponseImpl({
    required this.subjectNo,
    this.subjectName = '',
    required this.firstQuestionNo,
    required this.lastQuestionNo,
    required this.maxScore,
    required this.failBelowScore,
  });

  factory _$ExamAnswerSubjectRuleResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$ExamAnswerSubjectRuleResponseImplFromJson(json);

  @override
  final int subjectNo;
  @override
  @JsonKey()
  final String subjectName;
  @override
  final int firstQuestionNo;
  @override
  final int lastQuestionNo;
  @override
  final int maxScore;
  @override
  final int failBelowScore;

  @override
  String toString() {
    return 'ExamAnswerSubjectRuleResponse(subjectNo: $subjectNo, subjectName: $subjectName, firstQuestionNo: $firstQuestionNo, lastQuestionNo: $lastQuestionNo, maxScore: $maxScore, failBelowScore: $failBelowScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamAnswerSubjectRuleResponseImpl &&
            (identical(other.subjectNo, subjectNo) ||
                other.subjectNo == subjectNo) &&
            (identical(other.subjectName, subjectName) ||
                other.subjectName == subjectName) &&
            (identical(other.firstQuestionNo, firstQuestionNo) ||
                other.firstQuestionNo == firstQuestionNo) &&
            (identical(other.lastQuestionNo, lastQuestionNo) ||
                other.lastQuestionNo == lastQuestionNo) &&
            (identical(other.maxScore, maxScore) ||
                other.maxScore == maxScore) &&
            (identical(other.failBelowScore, failBelowScore) ||
                other.failBelowScore == failBelowScore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    subjectNo,
    subjectName,
    firstQuestionNo,
    lastQuestionNo,
    maxScore,
    failBelowScore,
  );

  /// Create a copy of ExamAnswerSubjectRuleResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamAnswerSubjectRuleResponseImplCopyWith<
    _$ExamAnswerSubjectRuleResponseImpl
  >
  get copyWith =>
      __$$ExamAnswerSubjectRuleResponseImplCopyWithImpl<
        _$ExamAnswerSubjectRuleResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamAnswerSubjectRuleResponseImplToJson(this);
  }
}

abstract class _ExamAnswerSubjectRuleResponse
    implements ExamAnswerSubjectRuleResponse {
  const factory _ExamAnswerSubjectRuleResponse({
    required final int subjectNo,
    final String subjectName,
    required final int firstQuestionNo,
    required final int lastQuestionNo,
    required final int maxScore,
    required final int failBelowScore,
  }) = _$ExamAnswerSubjectRuleResponseImpl;

  factory _ExamAnswerSubjectRuleResponse.fromJson(Map<String, dynamic> json) =
      _$ExamAnswerSubjectRuleResponseImpl.fromJson;

  @override
  int get subjectNo;
  @override
  String get subjectName;
  @override
  int get firstQuestionNo;
  @override
  int get lastQuestionNo;
  @override
  int get maxScore;
  @override
  int get failBelowScore;

  /// Create a copy of ExamAnswerSubjectRuleResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamAnswerSubjectRuleResponseImplCopyWith<
    _$ExamAnswerSubjectRuleResponseImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

ExamAnswerItemResponse _$ExamAnswerItemResponseFromJson(
  Map<String, dynamic> json,
) {
  return _ExamAnswerItemResponse.fromJson(json);
}

/// @nodoc
mixin _$ExamAnswerItemResponse {
  int get questionNo => throw _privateConstructorUsedError;
  int get subjectNo => throw _privateConstructorUsedError;
  String? get conceptTitle => throw _privateConstructorUsedError;
  List<String> get conceptTags =>
      throw _privateConstructorUsedError; // 우리 토픽 코드 (개념 학습·문제 풀기 연결, 없으면 연결 버튼 없음)
  String? get topicCode =>
      throw _privateConstructorUsedError; // 표시용 정답 1~4 (공식·확정·우세면 운영 정답, 아니면 득표 1위, 표 없으면 null)
  int? get answer => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: ExamAnswerItemStatus.unknown)
  ExamAnswerItemStatus get answerStatus => throw _privateConstructorUsedError; // 복수 정답 인정 보기
  List<int> get alternativeAnswers =>
      throw _privateConstructorUsedError; // 보기별 득표 {"1": n, ..., "4": n}
  Map<String, int> get tally => throw _privateConstructorUsedError;
  int get voteCount => throw _privateConstructorUsedError; // 표시 정답 득표 비율 0~1
  double get agreementRate => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;

  /// Serializes this ExamAnswerItemResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamAnswerItemResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamAnswerItemResponseCopyWith<ExamAnswerItemResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamAnswerItemResponseCopyWith<$Res> {
  factory $ExamAnswerItemResponseCopyWith(
    ExamAnswerItemResponse value,
    $Res Function(ExamAnswerItemResponse) then,
  ) = _$ExamAnswerItemResponseCopyWithImpl<$Res, ExamAnswerItemResponse>;
  @useResult
  $Res call({
    int questionNo,
    int subjectNo,
    String? conceptTitle,
    List<String> conceptTags,
    String? topicCode,
    int? answer,
    @JsonKey(unknownEnumValue: ExamAnswerItemStatus.unknown)
    ExamAnswerItemStatus answerStatus,
    List<int> alternativeAnswers,
    Map<String, int> tally,
    int voteCount,
    double agreementRate,
    String? note,
  });
}

/// @nodoc
class _$ExamAnswerItemResponseCopyWithImpl<
  $Res,
  $Val extends ExamAnswerItemResponse
>
    implements $ExamAnswerItemResponseCopyWith<$Res> {
  _$ExamAnswerItemResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamAnswerItemResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionNo = null,
    Object? subjectNo = null,
    Object? conceptTitle = freezed,
    Object? conceptTags = null,
    Object? topicCode = freezed,
    Object? answer = freezed,
    Object? answerStatus = null,
    Object? alternativeAnswers = null,
    Object? tally = null,
    Object? voteCount = null,
    Object? agreementRate = null,
    Object? note = freezed,
  }) {
    return _then(
      _value.copyWith(
            questionNo: null == questionNo
                ? _value.questionNo
                : questionNo // ignore: cast_nullable_to_non_nullable
                      as int,
            subjectNo: null == subjectNo
                ? _value.subjectNo
                : subjectNo // ignore: cast_nullable_to_non_nullable
                      as int,
            conceptTitle: freezed == conceptTitle
                ? _value.conceptTitle
                : conceptTitle // ignore: cast_nullable_to_non_nullable
                      as String?,
            conceptTags: null == conceptTags
                ? _value.conceptTags
                : conceptTags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            topicCode: freezed == topicCode
                ? _value.topicCode
                : topicCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            answer: freezed == answer
                ? _value.answer
                : answer // ignore: cast_nullable_to_non_nullable
                      as int?,
            answerStatus: null == answerStatus
                ? _value.answerStatus
                : answerStatus // ignore: cast_nullable_to_non_nullable
                      as ExamAnswerItemStatus,
            alternativeAnswers: null == alternativeAnswers
                ? _value.alternativeAnswers
                : alternativeAnswers // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            tally: null == tally
                ? _value.tally
                : tally // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            voteCount: null == voteCount
                ? _value.voteCount
                : voteCount // ignore: cast_nullable_to_non_nullable
                      as int,
            agreementRate: null == agreementRate
                ? _value.agreementRate
                : agreementRate // ignore: cast_nullable_to_non_nullable
                      as double,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExamAnswerItemResponseImplCopyWith<$Res>
    implements $ExamAnswerItemResponseCopyWith<$Res> {
  factory _$$ExamAnswerItemResponseImplCopyWith(
    _$ExamAnswerItemResponseImpl value,
    $Res Function(_$ExamAnswerItemResponseImpl) then,
  ) = __$$ExamAnswerItemResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int questionNo,
    int subjectNo,
    String? conceptTitle,
    List<String> conceptTags,
    String? topicCode,
    int? answer,
    @JsonKey(unknownEnumValue: ExamAnswerItemStatus.unknown)
    ExamAnswerItemStatus answerStatus,
    List<int> alternativeAnswers,
    Map<String, int> tally,
    int voteCount,
    double agreementRate,
    String? note,
  });
}

/// @nodoc
class __$$ExamAnswerItemResponseImplCopyWithImpl<$Res>
    extends
        _$ExamAnswerItemResponseCopyWithImpl<$Res, _$ExamAnswerItemResponseImpl>
    implements _$$ExamAnswerItemResponseImplCopyWith<$Res> {
  __$$ExamAnswerItemResponseImplCopyWithImpl(
    _$ExamAnswerItemResponseImpl _value,
    $Res Function(_$ExamAnswerItemResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamAnswerItemResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionNo = null,
    Object? subjectNo = null,
    Object? conceptTitle = freezed,
    Object? conceptTags = null,
    Object? topicCode = freezed,
    Object? answer = freezed,
    Object? answerStatus = null,
    Object? alternativeAnswers = null,
    Object? tally = null,
    Object? voteCount = null,
    Object? agreementRate = null,
    Object? note = freezed,
  }) {
    return _then(
      _$ExamAnswerItemResponseImpl(
        questionNo: null == questionNo
            ? _value.questionNo
            : questionNo // ignore: cast_nullable_to_non_nullable
                  as int,
        subjectNo: null == subjectNo
            ? _value.subjectNo
            : subjectNo // ignore: cast_nullable_to_non_nullable
                  as int,
        conceptTitle: freezed == conceptTitle
            ? _value.conceptTitle
            : conceptTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        conceptTags: null == conceptTags
            ? _value._conceptTags
            : conceptTags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        topicCode: freezed == topicCode
            ? _value.topicCode
            : topicCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        answer: freezed == answer
            ? _value.answer
            : answer // ignore: cast_nullable_to_non_nullable
                  as int?,
        answerStatus: null == answerStatus
            ? _value.answerStatus
            : answerStatus // ignore: cast_nullable_to_non_nullable
                  as ExamAnswerItemStatus,
        alternativeAnswers: null == alternativeAnswers
            ? _value._alternativeAnswers
            : alternativeAnswers // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        tally: null == tally
            ? _value._tally
            : tally // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        voteCount: null == voteCount
            ? _value.voteCount
            : voteCount // ignore: cast_nullable_to_non_nullable
                  as int,
        agreementRate: null == agreementRate
            ? _value.agreementRate
            : agreementRate // ignore: cast_nullable_to_non_nullable
                  as double,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamAnswerItemResponseImpl extends _ExamAnswerItemResponse {
  const _$ExamAnswerItemResponseImpl({
    required this.questionNo,
    required this.subjectNo,
    this.conceptTitle,
    final List<String> conceptTags = const [],
    this.topicCode,
    this.answer,
    @JsonKey(unknownEnumValue: ExamAnswerItemStatus.unknown)
    this.answerStatus = ExamAnswerItemStatus.undecided,
    final List<int> alternativeAnswers = const [],
    final Map<String, int> tally = const {},
    this.voteCount = 0,
    this.agreementRate = 0,
    this.note,
  }) : _conceptTags = conceptTags,
       _alternativeAnswers = alternativeAnswers,
       _tally = tally,
       super._();

  factory _$ExamAnswerItemResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamAnswerItemResponseImplFromJson(json);

  @override
  final int questionNo;
  @override
  final int subjectNo;
  @override
  final String? conceptTitle;
  final List<String> _conceptTags;
  @override
  @JsonKey()
  List<String> get conceptTags {
    if (_conceptTags is EqualUnmodifiableListView) return _conceptTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_conceptTags);
  }

  // 우리 토픽 코드 (개념 학습·문제 풀기 연결, 없으면 연결 버튼 없음)
  @override
  final String? topicCode;
  // 표시용 정답 1~4 (공식·확정·우세면 운영 정답, 아니면 득표 1위, 표 없으면 null)
  @override
  final int? answer;
  @override
  @JsonKey(unknownEnumValue: ExamAnswerItemStatus.unknown)
  final ExamAnswerItemStatus answerStatus;
  // 복수 정답 인정 보기
  final List<int> _alternativeAnswers;
  // 복수 정답 인정 보기
  @override
  @JsonKey()
  List<int> get alternativeAnswers {
    if (_alternativeAnswers is EqualUnmodifiableListView)
      return _alternativeAnswers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alternativeAnswers);
  }

  // 보기별 득표 {"1": n, ..., "4": n}
  final Map<String, int> _tally;
  // 보기별 득표 {"1": n, ..., "4": n}
  @override
  @JsonKey()
  Map<String, int> get tally {
    if (_tally is EqualUnmodifiableMapView) return _tally;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_tally);
  }

  @override
  @JsonKey()
  final int voteCount;
  // 표시 정답 득표 비율 0~1
  @override
  @JsonKey()
  final double agreementRate;
  @override
  final String? note;

  @override
  String toString() {
    return 'ExamAnswerItemResponse(questionNo: $questionNo, subjectNo: $subjectNo, conceptTitle: $conceptTitle, conceptTags: $conceptTags, topicCode: $topicCode, answer: $answer, answerStatus: $answerStatus, alternativeAnswers: $alternativeAnswers, tally: $tally, voteCount: $voteCount, agreementRate: $agreementRate, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamAnswerItemResponseImpl &&
            (identical(other.questionNo, questionNo) ||
                other.questionNo == questionNo) &&
            (identical(other.subjectNo, subjectNo) ||
                other.subjectNo == subjectNo) &&
            (identical(other.conceptTitle, conceptTitle) ||
                other.conceptTitle == conceptTitle) &&
            const DeepCollectionEquality().equals(
              other._conceptTags,
              _conceptTags,
            ) &&
            (identical(other.topicCode, topicCode) ||
                other.topicCode == topicCode) &&
            (identical(other.answer, answer) || other.answer == answer) &&
            (identical(other.answerStatus, answerStatus) ||
                other.answerStatus == answerStatus) &&
            const DeepCollectionEquality().equals(
              other._alternativeAnswers,
              _alternativeAnswers,
            ) &&
            const DeepCollectionEquality().equals(other._tally, _tally) &&
            (identical(other.voteCount, voteCount) ||
                other.voteCount == voteCount) &&
            (identical(other.agreementRate, agreementRate) ||
                other.agreementRate == agreementRate) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    questionNo,
    subjectNo,
    conceptTitle,
    const DeepCollectionEquality().hash(_conceptTags),
    topicCode,
    answer,
    answerStatus,
    const DeepCollectionEquality().hash(_alternativeAnswers),
    const DeepCollectionEquality().hash(_tally),
    voteCount,
    agreementRate,
    note,
  );

  /// Create a copy of ExamAnswerItemResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamAnswerItemResponseImplCopyWith<_$ExamAnswerItemResponseImpl>
  get copyWith =>
      __$$ExamAnswerItemResponseImplCopyWithImpl<_$ExamAnswerItemResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamAnswerItemResponseImplToJson(this);
  }
}

abstract class _ExamAnswerItemResponse extends ExamAnswerItemResponse {
  const factory _ExamAnswerItemResponse({
    required final int questionNo,
    required final int subjectNo,
    final String? conceptTitle,
    final List<String> conceptTags,
    final String? topicCode,
    final int? answer,
    @JsonKey(unknownEnumValue: ExamAnswerItemStatus.unknown)
    final ExamAnswerItemStatus answerStatus,
    final List<int> alternativeAnswers,
    final Map<String, int> tally,
    final int voteCount,
    final double agreementRate,
    final String? note,
  }) = _$ExamAnswerItemResponseImpl;
  const _ExamAnswerItemResponse._() : super._();

  factory _ExamAnswerItemResponse.fromJson(Map<String, dynamic> json) =
      _$ExamAnswerItemResponseImpl.fromJson;

  @override
  int get questionNo;
  @override
  int get subjectNo;
  @override
  String? get conceptTitle;
  @override
  List<String> get conceptTags; // 우리 토픽 코드 (개념 학습·문제 풀기 연결, 없으면 연결 버튼 없음)
  @override
  String? get topicCode; // 표시용 정답 1~4 (공식·확정·우세면 운영 정답, 아니면 득표 1위, 표 없으면 null)
  @override
  int? get answer;
  @override
  @JsonKey(unknownEnumValue: ExamAnswerItemStatus.unknown)
  ExamAnswerItemStatus get answerStatus; // 복수 정답 인정 보기
  @override
  List<int> get alternativeAnswers; // 보기별 득표 {"1": n, ..., "4": n}
  @override
  Map<String, int> get tally;
  @override
  int get voteCount; // 표시 정답 득표 비율 0~1
  @override
  double get agreementRate;
  @override
  String? get note;

  /// Create a copy of ExamAnswerItemResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamAnswerItemResponseImplCopyWith<_$ExamAnswerItemResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
