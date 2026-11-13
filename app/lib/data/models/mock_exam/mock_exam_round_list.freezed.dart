// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mock_exam_round_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MockExamRoundListResponse _$MockExamRoundListResponseFromJson(
  Map<String, dynamic> json,
) {
  return _MockExamRoundListResponse.fromJson(json);
}

/// @nodoc
mixin _$MockExamRoundListResponse {
  MockExamRule get examRule => throw _privateConstructorUsedError;
  MockExamInProgressAttempt? get inProgressAttempt =>
      throw _privateConstructorUsedError;
  List<MockExamRoundSummary> get rounds => throw _privateConstructorUsedError;

  /// Serializes this MockExamRoundListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MockExamRoundListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MockExamRoundListResponseCopyWith<MockExamRoundListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MockExamRoundListResponseCopyWith<$Res> {
  factory $MockExamRoundListResponseCopyWith(
    MockExamRoundListResponse value,
    $Res Function(MockExamRoundListResponse) then,
  ) = _$MockExamRoundListResponseCopyWithImpl<$Res, MockExamRoundListResponse>;
  @useResult
  $Res call({
    MockExamRule examRule,
    MockExamInProgressAttempt? inProgressAttempt,
    List<MockExamRoundSummary> rounds,
  });

  $MockExamRuleCopyWith<$Res> get examRule;
  $MockExamInProgressAttemptCopyWith<$Res>? get inProgressAttempt;
}

/// @nodoc
class _$MockExamRoundListResponseCopyWithImpl<
  $Res,
  $Val extends MockExamRoundListResponse
>
    implements $MockExamRoundListResponseCopyWith<$Res> {
  _$MockExamRoundListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MockExamRoundListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? examRule = null,
    Object? inProgressAttempt = freezed,
    Object? rounds = null,
  }) {
    return _then(
      _value.copyWith(
            examRule: null == examRule
                ? _value.examRule
                : examRule // ignore: cast_nullable_to_non_nullable
                      as MockExamRule,
            inProgressAttempt: freezed == inProgressAttempt
                ? _value.inProgressAttempt
                : inProgressAttempt // ignore: cast_nullable_to_non_nullable
                      as MockExamInProgressAttempt?,
            rounds: null == rounds
                ? _value.rounds
                : rounds // ignore: cast_nullable_to_non_nullable
                      as List<MockExamRoundSummary>,
          )
          as $Val,
    );
  }

  /// Create a copy of MockExamRoundListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MockExamRuleCopyWith<$Res> get examRule {
    return $MockExamRuleCopyWith<$Res>(_value.examRule, (value) {
      return _then(_value.copyWith(examRule: value) as $Val);
    });
  }

  /// Create a copy of MockExamRoundListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MockExamInProgressAttemptCopyWith<$Res>? get inProgressAttempt {
    if (_value.inProgressAttempt == null) {
      return null;
    }

    return $MockExamInProgressAttemptCopyWith<$Res>(_value.inProgressAttempt!, (
      value,
    ) {
      return _then(_value.copyWith(inProgressAttempt: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MockExamRoundListResponseImplCopyWith<$Res>
    implements $MockExamRoundListResponseCopyWith<$Res> {
  factory _$$MockExamRoundListResponseImplCopyWith(
    _$MockExamRoundListResponseImpl value,
    $Res Function(_$MockExamRoundListResponseImpl) then,
  ) = __$$MockExamRoundListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    MockExamRule examRule,
    MockExamInProgressAttempt? inProgressAttempt,
    List<MockExamRoundSummary> rounds,
  });

  @override
  $MockExamRuleCopyWith<$Res> get examRule;
  @override
  $MockExamInProgressAttemptCopyWith<$Res>? get inProgressAttempt;
}

/// @nodoc
class __$$MockExamRoundListResponseImplCopyWithImpl<$Res>
    extends
        _$MockExamRoundListResponseCopyWithImpl<
          $Res,
          _$MockExamRoundListResponseImpl
        >
    implements _$$MockExamRoundListResponseImplCopyWith<$Res> {
  __$$MockExamRoundListResponseImplCopyWithImpl(
    _$MockExamRoundListResponseImpl _value,
    $Res Function(_$MockExamRoundListResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MockExamRoundListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? examRule = null,
    Object? inProgressAttempt = freezed,
    Object? rounds = null,
  }) {
    return _then(
      _$MockExamRoundListResponseImpl(
        examRule: null == examRule
            ? _value.examRule
            : examRule // ignore: cast_nullable_to_non_nullable
                  as MockExamRule,
        inProgressAttempt: freezed == inProgressAttempt
            ? _value.inProgressAttempt
            : inProgressAttempt // ignore: cast_nullable_to_non_nullable
                  as MockExamInProgressAttempt?,
        rounds: null == rounds
            ? _value._rounds
            : rounds // ignore: cast_nullable_to_non_nullable
                  as List<MockExamRoundSummary>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MockExamRoundListResponseImpl implements _MockExamRoundListResponse {
  const _$MockExamRoundListResponseImpl({
    required this.examRule,
    this.inProgressAttempt,
    final List<MockExamRoundSummary> rounds = const [],
  }) : _rounds = rounds;

  factory _$MockExamRoundListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$MockExamRoundListResponseImplFromJson(json);

  @override
  final MockExamRule examRule;
  @override
  final MockExamInProgressAttempt? inProgressAttempt;
  final List<MockExamRoundSummary> _rounds;
  @override
  @JsonKey()
  List<MockExamRoundSummary> get rounds {
    if (_rounds is EqualUnmodifiableListView) return _rounds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rounds);
  }

  @override
  String toString() {
    return 'MockExamRoundListResponse(examRule: $examRule, inProgressAttempt: $inProgressAttempt, rounds: $rounds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamRoundListResponseImpl &&
            (identical(other.examRule, examRule) ||
                other.examRule == examRule) &&
            (identical(other.inProgressAttempt, inProgressAttempt) ||
                other.inProgressAttempt == inProgressAttempt) &&
            const DeepCollectionEquality().equals(other._rounds, _rounds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    examRule,
    inProgressAttempt,
    const DeepCollectionEquality().hash(_rounds),
  );

  /// Create a copy of MockExamRoundListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MockExamRoundListResponseImplCopyWith<_$MockExamRoundListResponseImpl>
  get copyWith =>
      __$$MockExamRoundListResponseImplCopyWithImpl<
        _$MockExamRoundListResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MockExamRoundListResponseImplToJson(this);
  }
}

abstract class _MockExamRoundListResponse implements MockExamRoundListResponse {
  const factory _MockExamRoundListResponse({
    required final MockExamRule examRule,
    final MockExamInProgressAttempt? inProgressAttempt,
    final List<MockExamRoundSummary> rounds,
  }) = _$MockExamRoundListResponseImpl;

  factory _MockExamRoundListResponse.fromJson(Map<String, dynamic> json) =
      _$MockExamRoundListResponseImpl.fromJson;

  @override
  MockExamRule get examRule;
  @override
  MockExamInProgressAttempt? get inProgressAttempt;
  @override
  List<MockExamRoundSummary> get rounds;

  /// Create a copy of MockExamRoundListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamRoundListResponseImplCopyWith<_$MockExamRoundListResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MockExamRule _$MockExamRuleFromJson(Map<String, dynamic> json) {
  return _MockExamRule.fromJson(json);
}

/// @nodoc
mixin _$MockExamRule {
  int get questionCount => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;
  int get maxScore => throw _privateConstructorUsedError;
  int get passScore => throw _privateConstructorUsedError;
  int get pointsPerQuestion => throw _privateConstructorUsedError;
  List<MockExamSubjectRule> get subjects => throw _privateConstructorUsedError;

  /// Serializes this MockExamRule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MockExamRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MockExamRuleCopyWith<MockExamRule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MockExamRuleCopyWith<$Res> {
  factory $MockExamRuleCopyWith(
    MockExamRule value,
    $Res Function(MockExamRule) then,
  ) = _$MockExamRuleCopyWithImpl<$Res, MockExamRule>;
  @useResult
  $Res call({
    int questionCount,
    int durationMinutes,
    int maxScore,
    int passScore,
    int pointsPerQuestion,
    List<MockExamSubjectRule> subjects,
  });
}

/// @nodoc
class _$MockExamRuleCopyWithImpl<$Res, $Val extends MockExamRule>
    implements $MockExamRuleCopyWith<$Res> {
  _$MockExamRuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MockExamRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionCount = null,
    Object? durationMinutes = null,
    Object? maxScore = null,
    Object? passScore = null,
    Object? pointsPerQuestion = null,
    Object? subjects = null,
  }) {
    return _then(
      _value.copyWith(
            questionCount: null == questionCount
                ? _value.questionCount
                : questionCount // ignore: cast_nullable_to_non_nullable
                      as int,
            durationMinutes: null == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            maxScore: null == maxScore
                ? _value.maxScore
                : maxScore // ignore: cast_nullable_to_non_nullable
                      as int,
            passScore: null == passScore
                ? _value.passScore
                : passScore // ignore: cast_nullable_to_non_nullable
                      as int,
            pointsPerQuestion: null == pointsPerQuestion
                ? _value.pointsPerQuestion
                : pointsPerQuestion // ignore: cast_nullable_to_non_nullable
                      as int,
            subjects: null == subjects
                ? _value.subjects
                : subjects // ignore: cast_nullable_to_non_nullable
                      as List<MockExamSubjectRule>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MockExamRuleImplCopyWith<$Res>
    implements $MockExamRuleCopyWith<$Res> {
  factory _$$MockExamRuleImplCopyWith(
    _$MockExamRuleImpl value,
    $Res Function(_$MockExamRuleImpl) then,
  ) = __$$MockExamRuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int questionCount,
    int durationMinutes,
    int maxScore,
    int passScore,
    int pointsPerQuestion,
    List<MockExamSubjectRule> subjects,
  });
}

/// @nodoc
class __$$MockExamRuleImplCopyWithImpl<$Res>
    extends _$MockExamRuleCopyWithImpl<$Res, _$MockExamRuleImpl>
    implements _$$MockExamRuleImplCopyWith<$Res> {
  __$$MockExamRuleImplCopyWithImpl(
    _$MockExamRuleImpl _value,
    $Res Function(_$MockExamRuleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MockExamRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionCount = null,
    Object? durationMinutes = null,
    Object? maxScore = null,
    Object? passScore = null,
    Object? pointsPerQuestion = null,
    Object? subjects = null,
  }) {
    return _then(
      _$MockExamRuleImpl(
        questionCount: null == questionCount
            ? _value.questionCount
            : questionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        durationMinutes: null == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        maxScore: null == maxScore
            ? _value.maxScore
            : maxScore // ignore: cast_nullable_to_non_nullable
                  as int,
        passScore: null == passScore
            ? _value.passScore
            : passScore // ignore: cast_nullable_to_non_nullable
                  as int,
        pointsPerQuestion: null == pointsPerQuestion
            ? _value.pointsPerQuestion
            : pointsPerQuestion // ignore: cast_nullable_to_non_nullable
                  as int,
        subjects: null == subjects
            ? _value._subjects
            : subjects // ignore: cast_nullable_to_non_nullable
                  as List<MockExamSubjectRule>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MockExamRuleImpl implements _MockExamRule {
  const _$MockExamRuleImpl({
    required this.questionCount,
    required this.durationMinutes,
    required this.maxScore,
    required this.passScore,
    required this.pointsPerQuestion,
    final List<MockExamSubjectRule> subjects = const [],
  }) : _subjects = subjects;

  factory _$MockExamRuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$MockExamRuleImplFromJson(json);

  @override
  final int questionCount;
  @override
  final int durationMinutes;
  @override
  final int maxScore;
  @override
  final int passScore;
  @override
  final int pointsPerQuestion;
  final List<MockExamSubjectRule> _subjects;
  @override
  @JsonKey()
  List<MockExamSubjectRule> get subjects {
    if (_subjects is EqualUnmodifiableListView) return _subjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subjects);
  }

  @override
  String toString() {
    return 'MockExamRule(questionCount: $questionCount, durationMinutes: $durationMinutes, maxScore: $maxScore, passScore: $passScore, pointsPerQuestion: $pointsPerQuestion, subjects: $subjects)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamRuleImpl &&
            (identical(other.questionCount, questionCount) ||
                other.questionCount == questionCount) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.maxScore, maxScore) ||
                other.maxScore == maxScore) &&
            (identical(other.passScore, passScore) ||
                other.passScore == passScore) &&
            (identical(other.pointsPerQuestion, pointsPerQuestion) ||
                other.pointsPerQuestion == pointsPerQuestion) &&
            const DeepCollectionEquality().equals(other._subjects, _subjects));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    questionCount,
    durationMinutes,
    maxScore,
    passScore,
    pointsPerQuestion,
    const DeepCollectionEquality().hash(_subjects),
  );

  /// Create a copy of MockExamRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MockExamRuleImplCopyWith<_$MockExamRuleImpl> get copyWith =>
      __$$MockExamRuleImplCopyWithImpl<_$MockExamRuleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MockExamRuleImplToJson(this);
  }
}

abstract class _MockExamRule implements MockExamRule {
  const factory _MockExamRule({
    required final int questionCount,
    required final int durationMinutes,
    required final int maxScore,
    required final int passScore,
    required final int pointsPerQuestion,
    final List<MockExamSubjectRule> subjects,
  }) = _$MockExamRuleImpl;

  factory _MockExamRule.fromJson(Map<String, dynamic> json) =
      _$MockExamRuleImpl.fromJson;

  @override
  int get questionCount;
  @override
  int get durationMinutes;
  @override
  int get maxScore;
  @override
  int get passScore;
  @override
  int get pointsPerQuestion;
  @override
  List<MockExamSubjectRule> get subjects;

  /// Create a copy of MockExamRule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamRuleImplCopyWith<_$MockExamRuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MockExamSubjectRule _$MockExamSubjectRuleFromJson(Map<String, dynamic> json) {
  return _MockExamSubjectRule.fromJson(json);
}

/// @nodoc
mixin _$MockExamSubjectRule {
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  MockExamSubject get subject => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get questionCount => throw _privateConstructorUsedError;
  int get maxScore => throw _privateConstructorUsedError;
  int get failBelowScore => throw _privateConstructorUsedError;

  /// Serializes this MockExamSubjectRule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MockExamSubjectRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MockExamSubjectRuleCopyWith<MockExamSubjectRule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MockExamSubjectRuleCopyWith<$Res> {
  factory $MockExamSubjectRuleCopyWith(
    MockExamSubjectRule value,
    $Res Function(MockExamSubjectRule) then,
  ) = _$MockExamSubjectRuleCopyWithImpl<$Res, MockExamSubjectRule>;
  @useResult
  $Res call({
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) MockExamSubject subject,
    String name,
    int questionCount,
    int maxScore,
    int failBelowScore,
  });
}

/// @nodoc
class _$MockExamSubjectRuleCopyWithImpl<$Res, $Val extends MockExamSubjectRule>
    implements $MockExamSubjectRuleCopyWith<$Res> {
  _$MockExamSubjectRuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MockExamSubjectRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subject = null,
    Object? name = null,
    Object? questionCount = null,
    Object? maxScore = null,
    Object? failBelowScore = null,
  }) {
    return _then(
      _value.copyWith(
            subject: null == subject
                ? _value.subject
                : subject // ignore: cast_nullable_to_non_nullable
                      as MockExamSubject,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            questionCount: null == questionCount
                ? _value.questionCount
                : questionCount // ignore: cast_nullable_to_non_nullable
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
abstract class _$$MockExamSubjectRuleImplCopyWith<$Res>
    implements $MockExamSubjectRuleCopyWith<$Res> {
  factory _$$MockExamSubjectRuleImplCopyWith(
    _$MockExamSubjectRuleImpl value,
    $Res Function(_$MockExamSubjectRuleImpl) then,
  ) = __$$MockExamSubjectRuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) MockExamSubject subject,
    String name,
    int questionCount,
    int maxScore,
    int failBelowScore,
  });
}

/// @nodoc
class __$$MockExamSubjectRuleImplCopyWithImpl<$Res>
    extends _$MockExamSubjectRuleCopyWithImpl<$Res, _$MockExamSubjectRuleImpl>
    implements _$$MockExamSubjectRuleImplCopyWith<$Res> {
  __$$MockExamSubjectRuleImplCopyWithImpl(
    _$MockExamSubjectRuleImpl _value,
    $Res Function(_$MockExamSubjectRuleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MockExamSubjectRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subject = null,
    Object? name = null,
    Object? questionCount = null,
    Object? maxScore = null,
    Object? failBelowScore = null,
  }) {
    return _then(
      _$MockExamSubjectRuleImpl(
        subject: null == subject
            ? _value.subject
            : subject // ignore: cast_nullable_to_non_nullable
                  as MockExamSubject,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        questionCount: null == questionCount
            ? _value.questionCount
            : questionCount // ignore: cast_nullable_to_non_nullable
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
class _$MockExamSubjectRuleImpl implements _MockExamSubjectRule {
  const _$MockExamSubjectRuleImpl({
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) required this.subject,
    required this.name,
    required this.questionCount,
    required this.maxScore,
    required this.failBelowScore,
  });

  factory _$MockExamSubjectRuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$MockExamSubjectRuleImplFromJson(json);

  @override
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  final MockExamSubject subject;
  @override
  final String name;
  @override
  final int questionCount;
  @override
  final int maxScore;
  @override
  final int failBelowScore;

  @override
  String toString() {
    return 'MockExamSubjectRule(subject: $subject, name: $name, questionCount: $questionCount, maxScore: $maxScore, failBelowScore: $failBelowScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamSubjectRuleImpl &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.questionCount, questionCount) ||
                other.questionCount == questionCount) &&
            (identical(other.maxScore, maxScore) ||
                other.maxScore == maxScore) &&
            (identical(other.failBelowScore, failBelowScore) ||
                other.failBelowScore == failBelowScore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    subject,
    name,
    questionCount,
    maxScore,
    failBelowScore,
  );

  /// Create a copy of MockExamSubjectRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MockExamSubjectRuleImplCopyWith<_$MockExamSubjectRuleImpl> get copyWith =>
      __$$MockExamSubjectRuleImplCopyWithImpl<_$MockExamSubjectRuleImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MockExamSubjectRuleImplToJson(this);
  }
}

abstract class _MockExamSubjectRule implements MockExamSubjectRule {
  const factory _MockExamSubjectRule({
    @JsonKey(unknownEnumValue: MockExamSubject.unknown)
    required final MockExamSubject subject,
    required final String name,
    required final int questionCount,
    required final int maxScore,
    required final int failBelowScore,
  }) = _$MockExamSubjectRuleImpl;

  factory _MockExamSubjectRule.fromJson(Map<String, dynamic> json) =
      _$MockExamSubjectRuleImpl.fromJson;

  @override
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  MockExamSubject get subject;
  @override
  String get name;
  @override
  int get questionCount;
  @override
  int get maxScore;
  @override
  int get failBelowScore;

  /// Create a copy of MockExamSubjectRule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamSubjectRuleImplCopyWith<_$MockExamSubjectRuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MockExamInProgressAttempt _$MockExamInProgressAttemptFromJson(
  Map<String, dynamic> json,
) {
  return _MockExamInProgressAttempt.fromJson(json);
}

/// @nodoc
mixin _$MockExamInProgressAttempt {
  String get attemptUuid => throw _privateConstructorUsedError;
  String get roundUuid => throw _privateConstructorUsedError;
  int get roundNumber => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  int get remainingSeconds => throw _privateConstructorUsedError;
  int get answeredCount => throw _privateConstructorUsedError;

  /// Serializes this MockExamInProgressAttempt to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MockExamInProgressAttempt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MockExamInProgressAttemptCopyWith<MockExamInProgressAttempt> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MockExamInProgressAttemptCopyWith<$Res> {
  factory $MockExamInProgressAttemptCopyWith(
    MockExamInProgressAttempt value,
    $Res Function(MockExamInProgressAttempt) then,
  ) = _$MockExamInProgressAttemptCopyWithImpl<$Res, MockExamInProgressAttempt>;
  @useResult
  $Res call({
    String attemptUuid,
    String roundUuid,
    int roundNumber,
    String title,
    int remainingSeconds,
    int answeredCount,
  });
}

/// @nodoc
class _$MockExamInProgressAttemptCopyWithImpl<
  $Res,
  $Val extends MockExamInProgressAttempt
>
    implements $MockExamInProgressAttemptCopyWith<$Res> {
  _$MockExamInProgressAttemptCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MockExamInProgressAttempt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attemptUuid = null,
    Object? roundUuid = null,
    Object? roundNumber = null,
    Object? title = null,
    Object? remainingSeconds = null,
    Object? answeredCount = null,
  }) {
    return _then(
      _value.copyWith(
            attemptUuid: null == attemptUuid
                ? _value.attemptUuid
                : attemptUuid // ignore: cast_nullable_to_non_nullable
                      as String,
            roundUuid: null == roundUuid
                ? _value.roundUuid
                : roundUuid // ignore: cast_nullable_to_non_nullable
                      as String,
            roundNumber: null == roundNumber
                ? _value.roundNumber
                : roundNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            remainingSeconds: null == remainingSeconds
                ? _value.remainingSeconds
                : remainingSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            answeredCount: null == answeredCount
                ? _value.answeredCount
                : answeredCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MockExamInProgressAttemptImplCopyWith<$Res>
    implements $MockExamInProgressAttemptCopyWith<$Res> {
  factory _$$MockExamInProgressAttemptImplCopyWith(
    _$MockExamInProgressAttemptImpl value,
    $Res Function(_$MockExamInProgressAttemptImpl) then,
  ) = __$$MockExamInProgressAttemptImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String attemptUuid,
    String roundUuid,
    int roundNumber,
    String title,
    int remainingSeconds,
    int answeredCount,
  });
}

/// @nodoc
class __$$MockExamInProgressAttemptImplCopyWithImpl<$Res>
    extends
        _$MockExamInProgressAttemptCopyWithImpl<
          $Res,
          _$MockExamInProgressAttemptImpl
        >
    implements _$$MockExamInProgressAttemptImplCopyWith<$Res> {
  __$$MockExamInProgressAttemptImplCopyWithImpl(
    _$MockExamInProgressAttemptImpl _value,
    $Res Function(_$MockExamInProgressAttemptImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MockExamInProgressAttempt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attemptUuid = null,
    Object? roundUuid = null,
    Object? roundNumber = null,
    Object? title = null,
    Object? remainingSeconds = null,
    Object? answeredCount = null,
  }) {
    return _then(
      _$MockExamInProgressAttemptImpl(
        attemptUuid: null == attemptUuid
            ? _value.attemptUuid
            : attemptUuid // ignore: cast_nullable_to_non_nullable
                  as String,
        roundUuid: null == roundUuid
            ? _value.roundUuid
            : roundUuid // ignore: cast_nullable_to_non_nullable
                  as String,
        roundNumber: null == roundNumber
            ? _value.roundNumber
            : roundNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        remainingSeconds: null == remainingSeconds
            ? _value.remainingSeconds
            : remainingSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        answeredCount: null == answeredCount
            ? _value.answeredCount
            : answeredCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MockExamInProgressAttemptImpl implements _MockExamInProgressAttempt {
  const _$MockExamInProgressAttemptImpl({
    required this.attemptUuid,
    required this.roundUuid,
    required this.roundNumber,
    required this.title,
    required this.remainingSeconds,
    required this.answeredCount,
  });

  factory _$MockExamInProgressAttemptImpl.fromJson(Map<String, dynamic> json) =>
      _$$MockExamInProgressAttemptImplFromJson(json);

  @override
  final String attemptUuid;
  @override
  final String roundUuid;
  @override
  final int roundNumber;
  @override
  final String title;
  @override
  final int remainingSeconds;
  @override
  final int answeredCount;

  @override
  String toString() {
    return 'MockExamInProgressAttempt(attemptUuid: $attemptUuid, roundUuid: $roundUuid, roundNumber: $roundNumber, title: $title, remainingSeconds: $remainingSeconds, answeredCount: $answeredCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamInProgressAttemptImpl &&
            (identical(other.attemptUuid, attemptUuid) ||
                other.attemptUuid == attemptUuid) &&
            (identical(other.roundUuid, roundUuid) ||
                other.roundUuid == roundUuid) &&
            (identical(other.roundNumber, roundNumber) ||
                other.roundNumber == roundNumber) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.remainingSeconds, remainingSeconds) ||
                other.remainingSeconds == remainingSeconds) &&
            (identical(other.answeredCount, answeredCount) ||
                other.answeredCount == answeredCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    attemptUuid,
    roundUuid,
    roundNumber,
    title,
    remainingSeconds,
    answeredCount,
  );

  /// Create a copy of MockExamInProgressAttempt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MockExamInProgressAttemptImplCopyWith<_$MockExamInProgressAttemptImpl>
  get copyWith =>
      __$$MockExamInProgressAttemptImplCopyWithImpl<
        _$MockExamInProgressAttemptImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MockExamInProgressAttemptImplToJson(this);
  }
}

abstract class _MockExamInProgressAttempt implements MockExamInProgressAttempt {
  const factory _MockExamInProgressAttempt({
    required final String attemptUuid,
    required final String roundUuid,
    required final int roundNumber,
    required final String title,
    required final int remainingSeconds,
    required final int answeredCount,
  }) = _$MockExamInProgressAttemptImpl;

  factory _MockExamInProgressAttempt.fromJson(Map<String, dynamic> json) =
      _$MockExamInProgressAttemptImpl.fromJson;

  @override
  String get attemptUuid;
  @override
  String get roundUuid;
  @override
  int get roundNumber;
  @override
  String get title;
  @override
  int get remainingSeconds;
  @override
  int get answeredCount;

  /// Create a copy of MockExamInProgressAttempt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamInProgressAttemptImplCopyWith<_$MockExamInProgressAttemptImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MockExamRoundSummary _$MockExamRoundSummaryFromJson(Map<String, dynamic> json) {
  return _MockExamRoundSummary.fromJson(json);
}

/// @nodoc
mixin _$MockExamRoundSummary {
  String get roundUuid => throw _privateConstructorUsedError;
  int get roundNumber => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  bool get isFreeTrialRound => throw _privateConstructorUsedError;
  bool get canStart => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: MockExamStartBlockReason.unknown)
  MockExamStartBlockReason? get startBlockReason =>
      throw _privateConstructorUsedError;
  int get submittedAttemptCount => throw _privateConstructorUsedError;
  int? get bestScore => throw _privateConstructorUsedError;

  /// 최고 점수 응시(동점이면 최근)의 합격 여부·불합격 이유 (과락 포함 서버 판정)
  bool? get bestAttemptIsPassed => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: MockExamFailReason.unknown)
  MockExamFailReason? get bestAttemptFailReason =>
      throw _privateConstructorUsedError;
  MockExamLastAttempt? get lastAttempt => throw _privateConstructorUsedError;

  /// Serializes this MockExamRoundSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MockExamRoundSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MockExamRoundSummaryCopyWith<MockExamRoundSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MockExamRoundSummaryCopyWith<$Res> {
  factory $MockExamRoundSummaryCopyWith(
    MockExamRoundSummary value,
    $Res Function(MockExamRoundSummary) then,
  ) = _$MockExamRoundSummaryCopyWithImpl<$Res, MockExamRoundSummary>;
  @useResult
  $Res call({
    String roundUuid,
    int roundNumber,
    String title,
    bool isFreeTrialRound,
    bool canStart,
    @JsonKey(unknownEnumValue: MockExamStartBlockReason.unknown)
    MockExamStartBlockReason? startBlockReason,
    int submittedAttemptCount,
    int? bestScore,
    bool? bestAttemptIsPassed,
    @JsonKey(unknownEnumValue: MockExamFailReason.unknown)
    MockExamFailReason? bestAttemptFailReason,
    MockExamLastAttempt? lastAttempt,
  });

  $MockExamLastAttemptCopyWith<$Res>? get lastAttempt;
}

/// @nodoc
class _$MockExamRoundSummaryCopyWithImpl<
  $Res,
  $Val extends MockExamRoundSummary
>
    implements $MockExamRoundSummaryCopyWith<$Res> {
  _$MockExamRoundSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MockExamRoundSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roundUuid = null,
    Object? roundNumber = null,
    Object? title = null,
    Object? isFreeTrialRound = null,
    Object? canStart = null,
    Object? startBlockReason = freezed,
    Object? submittedAttemptCount = null,
    Object? bestScore = freezed,
    Object? bestAttemptIsPassed = freezed,
    Object? bestAttemptFailReason = freezed,
    Object? lastAttempt = freezed,
  }) {
    return _then(
      _value.copyWith(
            roundUuid: null == roundUuid
                ? _value.roundUuid
                : roundUuid // ignore: cast_nullable_to_non_nullable
                      as String,
            roundNumber: null == roundNumber
                ? _value.roundNumber
                : roundNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            isFreeTrialRound: null == isFreeTrialRound
                ? _value.isFreeTrialRound
                : isFreeTrialRound // ignore: cast_nullable_to_non_nullable
                      as bool,
            canStart: null == canStart
                ? _value.canStart
                : canStart // ignore: cast_nullable_to_non_nullable
                      as bool,
            startBlockReason: freezed == startBlockReason
                ? _value.startBlockReason
                : startBlockReason // ignore: cast_nullable_to_non_nullable
                      as MockExamStartBlockReason?,
            submittedAttemptCount: null == submittedAttemptCount
                ? _value.submittedAttemptCount
                : submittedAttemptCount // ignore: cast_nullable_to_non_nullable
                      as int,
            bestScore: freezed == bestScore
                ? _value.bestScore
                : bestScore // ignore: cast_nullable_to_non_nullable
                      as int?,
            bestAttemptIsPassed: freezed == bestAttemptIsPassed
                ? _value.bestAttemptIsPassed
                : bestAttemptIsPassed // ignore: cast_nullable_to_non_nullable
                      as bool?,
            bestAttemptFailReason: freezed == bestAttemptFailReason
                ? _value.bestAttemptFailReason
                : bestAttemptFailReason // ignore: cast_nullable_to_non_nullable
                      as MockExamFailReason?,
            lastAttempt: freezed == lastAttempt
                ? _value.lastAttempt
                : lastAttempt // ignore: cast_nullable_to_non_nullable
                      as MockExamLastAttempt?,
          )
          as $Val,
    );
  }

  /// Create a copy of MockExamRoundSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MockExamLastAttemptCopyWith<$Res>? get lastAttempt {
    if (_value.lastAttempt == null) {
      return null;
    }

    return $MockExamLastAttemptCopyWith<$Res>(_value.lastAttempt!, (value) {
      return _then(_value.copyWith(lastAttempt: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MockExamRoundSummaryImplCopyWith<$Res>
    implements $MockExamRoundSummaryCopyWith<$Res> {
  factory _$$MockExamRoundSummaryImplCopyWith(
    _$MockExamRoundSummaryImpl value,
    $Res Function(_$MockExamRoundSummaryImpl) then,
  ) = __$$MockExamRoundSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String roundUuid,
    int roundNumber,
    String title,
    bool isFreeTrialRound,
    bool canStart,
    @JsonKey(unknownEnumValue: MockExamStartBlockReason.unknown)
    MockExamStartBlockReason? startBlockReason,
    int submittedAttemptCount,
    int? bestScore,
    bool? bestAttemptIsPassed,
    @JsonKey(unknownEnumValue: MockExamFailReason.unknown)
    MockExamFailReason? bestAttemptFailReason,
    MockExamLastAttempt? lastAttempt,
  });

  @override
  $MockExamLastAttemptCopyWith<$Res>? get lastAttempt;
}

/// @nodoc
class __$$MockExamRoundSummaryImplCopyWithImpl<$Res>
    extends _$MockExamRoundSummaryCopyWithImpl<$Res, _$MockExamRoundSummaryImpl>
    implements _$$MockExamRoundSummaryImplCopyWith<$Res> {
  __$$MockExamRoundSummaryImplCopyWithImpl(
    _$MockExamRoundSummaryImpl _value,
    $Res Function(_$MockExamRoundSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MockExamRoundSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roundUuid = null,
    Object? roundNumber = null,
    Object? title = null,
    Object? isFreeTrialRound = null,
    Object? canStart = null,
    Object? startBlockReason = freezed,
    Object? submittedAttemptCount = null,
    Object? bestScore = freezed,
    Object? bestAttemptIsPassed = freezed,
    Object? bestAttemptFailReason = freezed,
    Object? lastAttempt = freezed,
  }) {
    return _then(
      _$MockExamRoundSummaryImpl(
        roundUuid: null == roundUuid
            ? _value.roundUuid
            : roundUuid // ignore: cast_nullable_to_non_nullable
                  as String,
        roundNumber: null == roundNumber
            ? _value.roundNumber
            : roundNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        isFreeTrialRound: null == isFreeTrialRound
            ? _value.isFreeTrialRound
            : isFreeTrialRound // ignore: cast_nullable_to_non_nullable
                  as bool,
        canStart: null == canStart
            ? _value.canStart
            : canStart // ignore: cast_nullable_to_non_nullable
                  as bool,
        startBlockReason: freezed == startBlockReason
            ? _value.startBlockReason
            : startBlockReason // ignore: cast_nullable_to_non_nullable
                  as MockExamStartBlockReason?,
        submittedAttemptCount: null == submittedAttemptCount
            ? _value.submittedAttemptCount
            : submittedAttemptCount // ignore: cast_nullable_to_non_nullable
                  as int,
        bestScore: freezed == bestScore
            ? _value.bestScore
            : bestScore // ignore: cast_nullable_to_non_nullable
                  as int?,
        bestAttemptIsPassed: freezed == bestAttemptIsPassed
            ? _value.bestAttemptIsPassed
            : bestAttemptIsPassed // ignore: cast_nullable_to_non_nullable
                  as bool?,
        bestAttemptFailReason: freezed == bestAttemptFailReason
            ? _value.bestAttemptFailReason
            : bestAttemptFailReason // ignore: cast_nullable_to_non_nullable
                  as MockExamFailReason?,
        lastAttempt: freezed == lastAttempt
            ? _value.lastAttempt
            : lastAttempt // ignore: cast_nullable_to_non_nullable
                  as MockExamLastAttempt?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MockExamRoundSummaryImpl implements _MockExamRoundSummary {
  const _$MockExamRoundSummaryImpl({
    required this.roundUuid,
    required this.roundNumber,
    required this.title,
    required this.isFreeTrialRound,
    required this.canStart,
    @JsonKey(unknownEnumValue: MockExamStartBlockReason.unknown)
    this.startBlockReason,
    required this.submittedAttemptCount,
    this.bestScore,
    this.bestAttemptIsPassed,
    @JsonKey(unknownEnumValue: MockExamFailReason.unknown)
    this.bestAttemptFailReason,
    this.lastAttempt,
  });

  factory _$MockExamRoundSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MockExamRoundSummaryImplFromJson(json);

  @override
  final String roundUuid;
  @override
  final int roundNumber;
  @override
  final String title;
  @override
  final bool isFreeTrialRound;
  @override
  final bool canStart;
  @override
  @JsonKey(unknownEnumValue: MockExamStartBlockReason.unknown)
  final MockExamStartBlockReason? startBlockReason;
  @override
  final int submittedAttemptCount;
  @override
  final int? bestScore;

  /// 최고 점수 응시(동점이면 최근)의 합격 여부·불합격 이유 (과락 포함 서버 판정)
  @override
  final bool? bestAttemptIsPassed;
  @override
  @JsonKey(unknownEnumValue: MockExamFailReason.unknown)
  final MockExamFailReason? bestAttemptFailReason;
  @override
  final MockExamLastAttempt? lastAttempt;

  @override
  String toString() {
    return 'MockExamRoundSummary(roundUuid: $roundUuid, roundNumber: $roundNumber, title: $title, isFreeTrialRound: $isFreeTrialRound, canStart: $canStart, startBlockReason: $startBlockReason, submittedAttemptCount: $submittedAttemptCount, bestScore: $bestScore, bestAttemptIsPassed: $bestAttemptIsPassed, bestAttemptFailReason: $bestAttemptFailReason, lastAttempt: $lastAttempt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamRoundSummaryImpl &&
            (identical(other.roundUuid, roundUuid) ||
                other.roundUuid == roundUuid) &&
            (identical(other.roundNumber, roundNumber) ||
                other.roundNumber == roundNumber) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.isFreeTrialRound, isFreeTrialRound) ||
                other.isFreeTrialRound == isFreeTrialRound) &&
            (identical(other.canStart, canStart) ||
                other.canStart == canStart) &&
            (identical(other.startBlockReason, startBlockReason) ||
                other.startBlockReason == startBlockReason) &&
            (identical(other.submittedAttemptCount, submittedAttemptCount) ||
                other.submittedAttemptCount == submittedAttemptCount) &&
            (identical(other.bestScore, bestScore) ||
                other.bestScore == bestScore) &&
            (identical(other.bestAttemptIsPassed, bestAttemptIsPassed) ||
                other.bestAttemptIsPassed == bestAttemptIsPassed) &&
            (identical(other.bestAttemptFailReason, bestAttemptFailReason) ||
                other.bestAttemptFailReason == bestAttemptFailReason) &&
            (identical(other.lastAttempt, lastAttempt) ||
                other.lastAttempt == lastAttempt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    roundUuid,
    roundNumber,
    title,
    isFreeTrialRound,
    canStart,
    startBlockReason,
    submittedAttemptCount,
    bestScore,
    bestAttemptIsPassed,
    bestAttemptFailReason,
    lastAttempt,
  );

  /// Create a copy of MockExamRoundSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MockExamRoundSummaryImplCopyWith<_$MockExamRoundSummaryImpl>
  get copyWith =>
      __$$MockExamRoundSummaryImplCopyWithImpl<_$MockExamRoundSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MockExamRoundSummaryImplToJson(this);
  }
}

abstract class _MockExamRoundSummary implements MockExamRoundSummary {
  const factory _MockExamRoundSummary({
    required final String roundUuid,
    required final int roundNumber,
    required final String title,
    required final bool isFreeTrialRound,
    required final bool canStart,
    @JsonKey(unknownEnumValue: MockExamStartBlockReason.unknown)
    final MockExamStartBlockReason? startBlockReason,
    required final int submittedAttemptCount,
    final int? bestScore,
    final bool? bestAttemptIsPassed,
    @JsonKey(unknownEnumValue: MockExamFailReason.unknown)
    final MockExamFailReason? bestAttemptFailReason,
    final MockExamLastAttempt? lastAttempt,
  }) = _$MockExamRoundSummaryImpl;

  factory _MockExamRoundSummary.fromJson(Map<String, dynamic> json) =
      _$MockExamRoundSummaryImpl.fromJson;

  @override
  String get roundUuid;
  @override
  int get roundNumber;
  @override
  String get title;
  @override
  bool get isFreeTrialRound;
  @override
  bool get canStart;
  @override
  @JsonKey(unknownEnumValue: MockExamStartBlockReason.unknown)
  MockExamStartBlockReason? get startBlockReason;
  @override
  int get submittedAttemptCount;
  @override
  int? get bestScore;

  /// 최고 점수 응시(동점이면 최근)의 합격 여부·불합격 이유 (과락 포함 서버 판정)
  @override
  bool? get bestAttemptIsPassed;
  @override
  @JsonKey(unknownEnumValue: MockExamFailReason.unknown)
  MockExamFailReason? get bestAttemptFailReason;
  @override
  MockExamLastAttempt? get lastAttempt;

  /// Create a copy of MockExamRoundSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamRoundSummaryImplCopyWith<_$MockExamRoundSummaryImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MockExamLastAttempt _$MockExamLastAttemptFromJson(Map<String, dynamic> json) {
  return _MockExamLastAttempt.fromJson(json);
}

/// @nodoc
mixin _$MockExamLastAttempt {
  String get attemptUuid => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: MockExamAttemptStatus.unknown)
  MockExamAttemptStatus get status => throw _privateConstructorUsedError;
  int? get totalScore => throw _privateConstructorUsedError;
  bool? get isPassed => throw _privateConstructorUsedError;
  String? get submittedAt => throw _privateConstructorUsedError;

  /// Serializes this MockExamLastAttempt to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MockExamLastAttempt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MockExamLastAttemptCopyWith<MockExamLastAttempt> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MockExamLastAttemptCopyWith<$Res> {
  factory $MockExamLastAttemptCopyWith(
    MockExamLastAttempt value,
    $Res Function(MockExamLastAttempt) then,
  ) = _$MockExamLastAttemptCopyWithImpl<$Res, MockExamLastAttempt>;
  @useResult
  $Res call({
    String attemptUuid,
    @JsonKey(unknownEnumValue: MockExamAttemptStatus.unknown)
    MockExamAttemptStatus status,
    int? totalScore,
    bool? isPassed,
    String? submittedAt,
  });
}

/// @nodoc
class _$MockExamLastAttemptCopyWithImpl<$Res, $Val extends MockExamLastAttempt>
    implements $MockExamLastAttemptCopyWith<$Res> {
  _$MockExamLastAttemptCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MockExamLastAttempt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attemptUuid = null,
    Object? status = null,
    Object? totalScore = freezed,
    Object? isPassed = freezed,
    Object? submittedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            attemptUuid: null == attemptUuid
                ? _value.attemptUuid
                : attemptUuid // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as MockExamAttemptStatus,
            totalScore: freezed == totalScore
                ? _value.totalScore
                : totalScore // ignore: cast_nullable_to_non_nullable
                      as int?,
            isPassed: freezed == isPassed
                ? _value.isPassed
                : isPassed // ignore: cast_nullable_to_non_nullable
                      as bool?,
            submittedAt: freezed == submittedAt
                ? _value.submittedAt
                : submittedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MockExamLastAttemptImplCopyWith<$Res>
    implements $MockExamLastAttemptCopyWith<$Res> {
  factory _$$MockExamLastAttemptImplCopyWith(
    _$MockExamLastAttemptImpl value,
    $Res Function(_$MockExamLastAttemptImpl) then,
  ) = __$$MockExamLastAttemptImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String attemptUuid,
    @JsonKey(unknownEnumValue: MockExamAttemptStatus.unknown)
    MockExamAttemptStatus status,
    int? totalScore,
    bool? isPassed,
    String? submittedAt,
  });
}

/// @nodoc
class __$$MockExamLastAttemptImplCopyWithImpl<$Res>
    extends _$MockExamLastAttemptCopyWithImpl<$Res, _$MockExamLastAttemptImpl>
    implements _$$MockExamLastAttemptImplCopyWith<$Res> {
  __$$MockExamLastAttemptImplCopyWithImpl(
    _$MockExamLastAttemptImpl _value,
    $Res Function(_$MockExamLastAttemptImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MockExamLastAttempt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attemptUuid = null,
    Object? status = null,
    Object? totalScore = freezed,
    Object? isPassed = freezed,
    Object? submittedAt = freezed,
  }) {
    return _then(
      _$MockExamLastAttemptImpl(
        attemptUuid: null == attemptUuid
            ? _value.attemptUuid
            : attemptUuid // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as MockExamAttemptStatus,
        totalScore: freezed == totalScore
            ? _value.totalScore
            : totalScore // ignore: cast_nullable_to_non_nullable
                  as int?,
        isPassed: freezed == isPassed
            ? _value.isPassed
            : isPassed // ignore: cast_nullable_to_non_nullable
                  as bool?,
        submittedAt: freezed == submittedAt
            ? _value.submittedAt
            : submittedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MockExamLastAttemptImpl implements _MockExamLastAttempt {
  const _$MockExamLastAttemptImpl({
    required this.attemptUuid,
    @JsonKey(unknownEnumValue: MockExamAttemptStatus.unknown)
    required this.status,
    this.totalScore,
    this.isPassed,
    this.submittedAt,
  });

  factory _$MockExamLastAttemptImpl.fromJson(Map<String, dynamic> json) =>
      _$$MockExamLastAttemptImplFromJson(json);

  @override
  final String attemptUuid;
  @override
  @JsonKey(unknownEnumValue: MockExamAttemptStatus.unknown)
  final MockExamAttemptStatus status;
  @override
  final int? totalScore;
  @override
  final bool? isPassed;
  @override
  final String? submittedAt;

  @override
  String toString() {
    return 'MockExamLastAttempt(attemptUuid: $attemptUuid, status: $status, totalScore: $totalScore, isPassed: $isPassed, submittedAt: $submittedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamLastAttemptImpl &&
            (identical(other.attemptUuid, attemptUuid) ||
                other.attemptUuid == attemptUuid) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.totalScore, totalScore) ||
                other.totalScore == totalScore) &&
            (identical(other.isPassed, isPassed) ||
                other.isPassed == isPassed) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    attemptUuid,
    status,
    totalScore,
    isPassed,
    submittedAt,
  );

  /// Create a copy of MockExamLastAttempt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MockExamLastAttemptImplCopyWith<_$MockExamLastAttemptImpl> get copyWith =>
      __$$MockExamLastAttemptImplCopyWithImpl<_$MockExamLastAttemptImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MockExamLastAttemptImplToJson(this);
  }
}

abstract class _MockExamLastAttempt implements MockExamLastAttempt {
  const factory _MockExamLastAttempt({
    required final String attemptUuid,
    @JsonKey(unknownEnumValue: MockExamAttemptStatus.unknown)
    required final MockExamAttemptStatus status,
    final int? totalScore,
    final bool? isPassed,
    final String? submittedAt,
  }) = _$MockExamLastAttemptImpl;

  factory _MockExamLastAttempt.fromJson(Map<String, dynamic> json) =
      _$MockExamLastAttemptImpl.fromJson;

  @override
  String get attemptUuid;
  @override
  @JsonKey(unknownEnumValue: MockExamAttemptStatus.unknown)
  MockExamAttemptStatus get status;
  @override
  int? get totalScore;
  @override
  bool? get isPassed;
  @override
  String? get submittedAt;

  /// Create a copy of MockExamLastAttempt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamLastAttemptImplCopyWith<_$MockExamLastAttemptImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
