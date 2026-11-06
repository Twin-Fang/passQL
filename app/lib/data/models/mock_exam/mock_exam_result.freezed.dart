// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mock_exam_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MockExamResultResponse _$MockExamResultResponseFromJson(
  Map<String, dynamic> json,
) {
  return _MockExamResultResponse.fromJson(json);
}

/// @nodoc
mixin _$MockExamResultResponse {
  String get attemptUuid => throw _privateConstructorUsedError;
  String get roundUuid => throw _privateConstructorUsedError;
  int get roundNumber => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: MockExamSubmitReason.unknown)
  MockExamSubmitReason get submitReason => throw _privateConstructorUsedError;
  String get startedAt => throw _privateConstructorUsedError;
  String get submittedAt => throw _privateConstructorUsedError;
  int get elapsedSeconds => throw _privateConstructorUsedError;
  int get totalScore => throw _privateConstructorUsedError;
  int get maxScore => throw _privateConstructorUsedError;
  int get passScore => throw _privateConstructorUsedError;
  int get correctCount => throw _privateConstructorUsedError;
  int get questionCount => throw _privateConstructorUsedError;
  bool get isPassed => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: MockExamFailReason.unknown)
  MockExamFailReason get failReason => throw _privateConstructorUsedError;
  List<MockExamSubjectResult> get subjects =>
      throw _privateConstructorUsedError;
  List<MockExamTopicResult> get topics => throw _privateConstructorUsedError;
  List<MockExamQuestionMark> get questionMarks =>
      throw _privateConstructorUsedError;
  List<MockExamQuestionReview> get reviews =>
      throw _privateConstructorUsedError;
  MockExamNextStep? get nextStep => throw _privateConstructorUsedError;
  List<String> get lockedSections => throw _privateConstructorUsedError;

  /// Serializes this MockExamResultResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MockExamResultResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MockExamResultResponseCopyWith<MockExamResultResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MockExamResultResponseCopyWith<$Res> {
  factory $MockExamResultResponseCopyWith(
    MockExamResultResponse value,
    $Res Function(MockExamResultResponse) then,
  ) = _$MockExamResultResponseCopyWithImpl<$Res, MockExamResultResponse>;
  @useResult
  $Res call({
    String attemptUuid,
    String roundUuid,
    int roundNumber,
    String title,
    @JsonKey(unknownEnumValue: MockExamSubmitReason.unknown)
    MockExamSubmitReason submitReason,
    String startedAt,
    String submittedAt,
    int elapsedSeconds,
    int totalScore,
    int maxScore,
    int passScore,
    int correctCount,
    int questionCount,
    bool isPassed,
    @JsonKey(unknownEnumValue: MockExamFailReason.unknown)
    MockExamFailReason failReason,
    List<MockExamSubjectResult> subjects,
    List<MockExamTopicResult> topics,
    List<MockExamQuestionMark> questionMarks,
    List<MockExamQuestionReview> reviews,
    MockExamNextStep? nextStep,
    List<String> lockedSections,
  });

  $MockExamNextStepCopyWith<$Res>? get nextStep;
}

/// @nodoc
class _$MockExamResultResponseCopyWithImpl<
  $Res,
  $Val extends MockExamResultResponse
>
    implements $MockExamResultResponseCopyWith<$Res> {
  _$MockExamResultResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MockExamResultResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attemptUuid = null,
    Object? roundUuid = null,
    Object? roundNumber = null,
    Object? title = null,
    Object? submitReason = null,
    Object? startedAt = null,
    Object? submittedAt = null,
    Object? elapsedSeconds = null,
    Object? totalScore = null,
    Object? maxScore = null,
    Object? passScore = null,
    Object? correctCount = null,
    Object? questionCount = null,
    Object? isPassed = null,
    Object? failReason = null,
    Object? subjects = null,
    Object? topics = null,
    Object? questionMarks = null,
    Object? reviews = null,
    Object? nextStep = freezed,
    Object? lockedSections = null,
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
            submitReason: null == submitReason
                ? _value.submitReason
                : submitReason // ignore: cast_nullable_to_non_nullable
                      as MockExamSubmitReason,
            startedAt: null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as String,
            submittedAt: null == submittedAt
                ? _value.submittedAt
                : submittedAt // ignore: cast_nullable_to_non_nullable
                      as String,
            elapsedSeconds: null == elapsedSeconds
                ? _value.elapsedSeconds
                : elapsedSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            totalScore: null == totalScore
                ? _value.totalScore
                : totalScore // ignore: cast_nullable_to_non_nullable
                      as int,
            maxScore: null == maxScore
                ? _value.maxScore
                : maxScore // ignore: cast_nullable_to_non_nullable
                      as int,
            passScore: null == passScore
                ? _value.passScore
                : passScore // ignore: cast_nullable_to_non_nullable
                      as int,
            correctCount: null == correctCount
                ? _value.correctCount
                : correctCount // ignore: cast_nullable_to_non_nullable
                      as int,
            questionCount: null == questionCount
                ? _value.questionCount
                : questionCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isPassed: null == isPassed
                ? _value.isPassed
                : isPassed // ignore: cast_nullable_to_non_nullable
                      as bool,
            failReason: null == failReason
                ? _value.failReason
                : failReason // ignore: cast_nullable_to_non_nullable
                      as MockExamFailReason,
            subjects: null == subjects
                ? _value.subjects
                : subjects // ignore: cast_nullable_to_non_nullable
                      as List<MockExamSubjectResult>,
            topics: null == topics
                ? _value.topics
                : topics // ignore: cast_nullable_to_non_nullable
                      as List<MockExamTopicResult>,
            questionMarks: null == questionMarks
                ? _value.questionMarks
                : questionMarks // ignore: cast_nullable_to_non_nullable
                      as List<MockExamQuestionMark>,
            reviews: null == reviews
                ? _value.reviews
                : reviews // ignore: cast_nullable_to_non_nullable
                      as List<MockExamQuestionReview>,
            nextStep: freezed == nextStep
                ? _value.nextStep
                : nextStep // ignore: cast_nullable_to_non_nullable
                      as MockExamNextStep?,
            lockedSections: null == lockedSections
                ? _value.lockedSections
                : lockedSections // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }

  /// Create a copy of MockExamResultResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MockExamNextStepCopyWith<$Res>? get nextStep {
    if (_value.nextStep == null) {
      return null;
    }

    return $MockExamNextStepCopyWith<$Res>(_value.nextStep!, (value) {
      return _then(_value.copyWith(nextStep: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MockExamResultResponseImplCopyWith<$Res>
    implements $MockExamResultResponseCopyWith<$Res> {
  factory _$$MockExamResultResponseImplCopyWith(
    _$MockExamResultResponseImpl value,
    $Res Function(_$MockExamResultResponseImpl) then,
  ) = __$$MockExamResultResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String attemptUuid,
    String roundUuid,
    int roundNumber,
    String title,
    @JsonKey(unknownEnumValue: MockExamSubmitReason.unknown)
    MockExamSubmitReason submitReason,
    String startedAt,
    String submittedAt,
    int elapsedSeconds,
    int totalScore,
    int maxScore,
    int passScore,
    int correctCount,
    int questionCount,
    bool isPassed,
    @JsonKey(unknownEnumValue: MockExamFailReason.unknown)
    MockExamFailReason failReason,
    List<MockExamSubjectResult> subjects,
    List<MockExamTopicResult> topics,
    List<MockExamQuestionMark> questionMarks,
    List<MockExamQuestionReview> reviews,
    MockExamNextStep? nextStep,
    List<String> lockedSections,
  });

  @override
  $MockExamNextStepCopyWith<$Res>? get nextStep;
}

/// @nodoc
class __$$MockExamResultResponseImplCopyWithImpl<$Res>
    extends
        _$MockExamResultResponseCopyWithImpl<$Res, _$MockExamResultResponseImpl>
    implements _$$MockExamResultResponseImplCopyWith<$Res> {
  __$$MockExamResultResponseImplCopyWithImpl(
    _$MockExamResultResponseImpl _value,
    $Res Function(_$MockExamResultResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MockExamResultResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attemptUuid = null,
    Object? roundUuid = null,
    Object? roundNumber = null,
    Object? title = null,
    Object? submitReason = null,
    Object? startedAt = null,
    Object? submittedAt = null,
    Object? elapsedSeconds = null,
    Object? totalScore = null,
    Object? maxScore = null,
    Object? passScore = null,
    Object? correctCount = null,
    Object? questionCount = null,
    Object? isPassed = null,
    Object? failReason = null,
    Object? subjects = null,
    Object? topics = null,
    Object? questionMarks = null,
    Object? reviews = null,
    Object? nextStep = freezed,
    Object? lockedSections = null,
  }) {
    return _then(
      _$MockExamResultResponseImpl(
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
        submitReason: null == submitReason
            ? _value.submitReason
            : submitReason // ignore: cast_nullable_to_non_nullable
                  as MockExamSubmitReason,
        startedAt: null == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as String,
        submittedAt: null == submittedAt
            ? _value.submittedAt
            : submittedAt // ignore: cast_nullable_to_non_nullable
                  as String,
        elapsedSeconds: null == elapsedSeconds
            ? _value.elapsedSeconds
            : elapsedSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        totalScore: null == totalScore
            ? _value.totalScore
            : totalScore // ignore: cast_nullable_to_non_nullable
                  as int,
        maxScore: null == maxScore
            ? _value.maxScore
            : maxScore // ignore: cast_nullable_to_non_nullable
                  as int,
        passScore: null == passScore
            ? _value.passScore
            : passScore // ignore: cast_nullable_to_non_nullable
                  as int,
        correctCount: null == correctCount
            ? _value.correctCount
            : correctCount // ignore: cast_nullable_to_non_nullable
                  as int,
        questionCount: null == questionCount
            ? _value.questionCount
            : questionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isPassed: null == isPassed
            ? _value.isPassed
            : isPassed // ignore: cast_nullable_to_non_nullable
                  as bool,
        failReason: null == failReason
            ? _value.failReason
            : failReason // ignore: cast_nullable_to_non_nullable
                  as MockExamFailReason,
        subjects: null == subjects
            ? _value._subjects
            : subjects // ignore: cast_nullable_to_non_nullable
                  as List<MockExamSubjectResult>,
        topics: null == topics
            ? _value._topics
            : topics // ignore: cast_nullable_to_non_nullable
                  as List<MockExamTopicResult>,
        questionMarks: null == questionMarks
            ? _value._questionMarks
            : questionMarks // ignore: cast_nullable_to_non_nullable
                  as List<MockExamQuestionMark>,
        reviews: null == reviews
            ? _value._reviews
            : reviews // ignore: cast_nullable_to_non_nullable
                  as List<MockExamQuestionReview>,
        nextStep: freezed == nextStep
            ? _value.nextStep
            : nextStep // ignore: cast_nullable_to_non_nullable
                  as MockExamNextStep?,
        lockedSections: null == lockedSections
            ? _value._lockedSections
            : lockedSections // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MockExamResultResponseImpl implements _MockExamResultResponse {
  const _$MockExamResultResponseImpl({
    required this.attemptUuid,
    required this.roundUuid,
    required this.roundNumber,
    required this.title,
    @JsonKey(unknownEnumValue: MockExamSubmitReason.unknown)
    required this.submitReason,
    required this.startedAt,
    required this.submittedAt,
    required this.elapsedSeconds,
    required this.totalScore,
    required this.maxScore,
    required this.passScore,
    required this.correctCount,
    required this.questionCount,
    required this.isPassed,
    @JsonKey(unknownEnumValue: MockExamFailReason.unknown)
    required this.failReason,
    final List<MockExamSubjectResult> subjects = const [],
    final List<MockExamTopicResult> topics = const [],
    final List<MockExamQuestionMark> questionMarks = const [],
    final List<MockExamQuestionReview> reviews = const [],
    this.nextStep,
    final List<String> lockedSections = const [],
  }) : _subjects = subjects,
       _topics = topics,
       _questionMarks = questionMarks,
       _reviews = reviews,
       _lockedSections = lockedSections;

  factory _$MockExamResultResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$MockExamResultResponseImplFromJson(json);

  @override
  final String attemptUuid;
  @override
  final String roundUuid;
  @override
  final int roundNumber;
  @override
  final String title;
  @override
  @JsonKey(unknownEnumValue: MockExamSubmitReason.unknown)
  final MockExamSubmitReason submitReason;
  @override
  final String startedAt;
  @override
  final String submittedAt;
  @override
  final int elapsedSeconds;
  @override
  final int totalScore;
  @override
  final int maxScore;
  @override
  final int passScore;
  @override
  final int correctCount;
  @override
  final int questionCount;
  @override
  final bool isPassed;
  @override
  @JsonKey(unknownEnumValue: MockExamFailReason.unknown)
  final MockExamFailReason failReason;
  final List<MockExamSubjectResult> _subjects;
  @override
  @JsonKey()
  List<MockExamSubjectResult> get subjects {
    if (_subjects is EqualUnmodifiableListView) return _subjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subjects);
  }

  final List<MockExamTopicResult> _topics;
  @override
  @JsonKey()
  List<MockExamTopicResult> get topics {
    if (_topics is EqualUnmodifiableListView) return _topics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topics);
  }

  final List<MockExamQuestionMark> _questionMarks;
  @override
  @JsonKey()
  List<MockExamQuestionMark> get questionMarks {
    if (_questionMarks is EqualUnmodifiableListView) return _questionMarks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questionMarks);
  }

  final List<MockExamQuestionReview> _reviews;
  @override
  @JsonKey()
  List<MockExamQuestionReview> get reviews {
    if (_reviews is EqualUnmodifiableListView) return _reviews;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reviews);
  }

  @override
  final MockExamNextStep? nextStep;
  final List<String> _lockedSections;
  @override
  @JsonKey()
  List<String> get lockedSections {
    if (_lockedSections is EqualUnmodifiableListView) return _lockedSections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lockedSections);
  }

  @override
  String toString() {
    return 'MockExamResultResponse(attemptUuid: $attemptUuid, roundUuid: $roundUuid, roundNumber: $roundNumber, title: $title, submitReason: $submitReason, startedAt: $startedAt, submittedAt: $submittedAt, elapsedSeconds: $elapsedSeconds, totalScore: $totalScore, maxScore: $maxScore, passScore: $passScore, correctCount: $correctCount, questionCount: $questionCount, isPassed: $isPassed, failReason: $failReason, subjects: $subjects, topics: $topics, questionMarks: $questionMarks, reviews: $reviews, nextStep: $nextStep, lockedSections: $lockedSections)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamResultResponseImpl &&
            (identical(other.attemptUuid, attemptUuid) ||
                other.attemptUuid == attemptUuid) &&
            (identical(other.roundUuid, roundUuid) ||
                other.roundUuid == roundUuid) &&
            (identical(other.roundNumber, roundNumber) ||
                other.roundNumber == roundNumber) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.submitReason, submitReason) ||
                other.submitReason == submitReason) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.elapsedSeconds, elapsedSeconds) ||
                other.elapsedSeconds == elapsedSeconds) &&
            (identical(other.totalScore, totalScore) ||
                other.totalScore == totalScore) &&
            (identical(other.maxScore, maxScore) ||
                other.maxScore == maxScore) &&
            (identical(other.passScore, passScore) ||
                other.passScore == passScore) &&
            (identical(other.correctCount, correctCount) ||
                other.correctCount == correctCount) &&
            (identical(other.questionCount, questionCount) ||
                other.questionCount == questionCount) &&
            (identical(other.isPassed, isPassed) ||
                other.isPassed == isPassed) &&
            (identical(other.failReason, failReason) ||
                other.failReason == failReason) &&
            const DeepCollectionEquality().equals(other._subjects, _subjects) &&
            const DeepCollectionEquality().equals(other._topics, _topics) &&
            const DeepCollectionEquality().equals(
              other._questionMarks,
              _questionMarks,
            ) &&
            const DeepCollectionEquality().equals(other._reviews, _reviews) &&
            (identical(other.nextStep, nextStep) ||
                other.nextStep == nextStep) &&
            const DeepCollectionEquality().equals(
              other._lockedSections,
              _lockedSections,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    attemptUuid,
    roundUuid,
    roundNumber,
    title,
    submitReason,
    startedAt,
    submittedAt,
    elapsedSeconds,
    totalScore,
    maxScore,
    passScore,
    correctCount,
    questionCount,
    isPassed,
    failReason,
    const DeepCollectionEquality().hash(_subjects),
    const DeepCollectionEquality().hash(_topics),
    const DeepCollectionEquality().hash(_questionMarks),
    const DeepCollectionEquality().hash(_reviews),
    nextStep,
    const DeepCollectionEquality().hash(_lockedSections),
  ]);

  /// Create a copy of MockExamResultResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MockExamResultResponseImplCopyWith<_$MockExamResultResponseImpl>
  get copyWith =>
      __$$MockExamResultResponseImplCopyWithImpl<_$MockExamResultResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MockExamResultResponseImplToJson(this);
  }
}

abstract class _MockExamResultResponse implements MockExamResultResponse {
  const factory _MockExamResultResponse({
    required final String attemptUuid,
    required final String roundUuid,
    required final int roundNumber,
    required final String title,
    @JsonKey(unknownEnumValue: MockExamSubmitReason.unknown)
    required final MockExamSubmitReason submitReason,
    required final String startedAt,
    required final String submittedAt,
    required final int elapsedSeconds,
    required final int totalScore,
    required final int maxScore,
    required final int passScore,
    required final int correctCount,
    required final int questionCount,
    required final bool isPassed,
    @JsonKey(unknownEnumValue: MockExamFailReason.unknown)
    required final MockExamFailReason failReason,
    final List<MockExamSubjectResult> subjects,
    final List<MockExamTopicResult> topics,
    final List<MockExamQuestionMark> questionMarks,
    final List<MockExamQuestionReview> reviews,
    final MockExamNextStep? nextStep,
    final List<String> lockedSections,
  }) = _$MockExamResultResponseImpl;

  factory _MockExamResultResponse.fromJson(Map<String, dynamic> json) =
      _$MockExamResultResponseImpl.fromJson;

  @override
  String get attemptUuid;
  @override
  String get roundUuid;
  @override
  int get roundNumber;
  @override
  String get title;
  @override
  @JsonKey(unknownEnumValue: MockExamSubmitReason.unknown)
  MockExamSubmitReason get submitReason;
  @override
  String get startedAt;
  @override
  String get submittedAt;
  @override
  int get elapsedSeconds;
  @override
  int get totalScore;
  @override
  int get maxScore;
  @override
  int get passScore;
  @override
  int get correctCount;
  @override
  int get questionCount;
  @override
  bool get isPassed;
  @override
  @JsonKey(unknownEnumValue: MockExamFailReason.unknown)
  MockExamFailReason get failReason;
  @override
  List<MockExamSubjectResult> get subjects;
  @override
  List<MockExamTopicResult> get topics;
  @override
  List<MockExamQuestionMark> get questionMarks;
  @override
  List<MockExamQuestionReview> get reviews;
  @override
  MockExamNextStep? get nextStep;
  @override
  List<String> get lockedSections;

  /// Create a copy of MockExamResultResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamResultResponseImplCopyWith<_$MockExamResultResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MockExamSubjectResult _$MockExamSubjectResultFromJson(
  Map<String, dynamic> json,
) {
  return _MockExamSubjectResult.fromJson(json);
}

/// @nodoc
mixin _$MockExamSubjectResult {
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  MockExamSubject get subject => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get correctCount => throw _privateConstructorUsedError;
  int get questionCount => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  int get maxScore => throw _privateConstructorUsedError;
  int get failBelowScore => throw _privateConstructorUsedError;
  bool get isFailed => throw _privateConstructorUsedError;

  /// Serializes this MockExamSubjectResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MockExamSubjectResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MockExamSubjectResultCopyWith<MockExamSubjectResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MockExamSubjectResultCopyWith<$Res> {
  factory $MockExamSubjectResultCopyWith(
    MockExamSubjectResult value,
    $Res Function(MockExamSubjectResult) then,
  ) = _$MockExamSubjectResultCopyWithImpl<$Res, MockExamSubjectResult>;
  @useResult
  $Res call({
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) MockExamSubject subject,
    String name,
    int correctCount,
    int questionCount,
    int score,
    int maxScore,
    int failBelowScore,
    bool isFailed,
  });
}

/// @nodoc
class _$MockExamSubjectResultCopyWithImpl<
  $Res,
  $Val extends MockExamSubjectResult
>
    implements $MockExamSubjectResultCopyWith<$Res> {
  _$MockExamSubjectResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MockExamSubjectResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subject = null,
    Object? name = null,
    Object? correctCount = null,
    Object? questionCount = null,
    Object? score = null,
    Object? maxScore = null,
    Object? failBelowScore = null,
    Object? isFailed = null,
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
            correctCount: null == correctCount
                ? _value.correctCount
                : correctCount // ignore: cast_nullable_to_non_nullable
                      as int,
            questionCount: null == questionCount
                ? _value.questionCount
                : questionCount // ignore: cast_nullable_to_non_nullable
                      as int,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int,
            maxScore: null == maxScore
                ? _value.maxScore
                : maxScore // ignore: cast_nullable_to_non_nullable
                      as int,
            failBelowScore: null == failBelowScore
                ? _value.failBelowScore
                : failBelowScore // ignore: cast_nullable_to_non_nullable
                      as int,
            isFailed: null == isFailed
                ? _value.isFailed
                : isFailed // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MockExamSubjectResultImplCopyWith<$Res>
    implements $MockExamSubjectResultCopyWith<$Res> {
  factory _$$MockExamSubjectResultImplCopyWith(
    _$MockExamSubjectResultImpl value,
    $Res Function(_$MockExamSubjectResultImpl) then,
  ) = __$$MockExamSubjectResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) MockExamSubject subject,
    String name,
    int correctCount,
    int questionCount,
    int score,
    int maxScore,
    int failBelowScore,
    bool isFailed,
  });
}

/// @nodoc
class __$$MockExamSubjectResultImplCopyWithImpl<$Res>
    extends
        _$MockExamSubjectResultCopyWithImpl<$Res, _$MockExamSubjectResultImpl>
    implements _$$MockExamSubjectResultImplCopyWith<$Res> {
  __$$MockExamSubjectResultImplCopyWithImpl(
    _$MockExamSubjectResultImpl _value,
    $Res Function(_$MockExamSubjectResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MockExamSubjectResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subject = null,
    Object? name = null,
    Object? correctCount = null,
    Object? questionCount = null,
    Object? score = null,
    Object? maxScore = null,
    Object? failBelowScore = null,
    Object? isFailed = null,
  }) {
    return _then(
      _$MockExamSubjectResultImpl(
        subject: null == subject
            ? _value.subject
            : subject // ignore: cast_nullable_to_non_nullable
                  as MockExamSubject,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        correctCount: null == correctCount
            ? _value.correctCount
            : correctCount // ignore: cast_nullable_to_non_nullable
                  as int,
        questionCount: null == questionCount
            ? _value.questionCount
            : questionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
        maxScore: null == maxScore
            ? _value.maxScore
            : maxScore // ignore: cast_nullable_to_non_nullable
                  as int,
        failBelowScore: null == failBelowScore
            ? _value.failBelowScore
            : failBelowScore // ignore: cast_nullable_to_non_nullable
                  as int,
        isFailed: null == isFailed
            ? _value.isFailed
            : isFailed // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MockExamSubjectResultImpl implements _MockExamSubjectResult {
  const _$MockExamSubjectResultImpl({
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) required this.subject,
    required this.name,
    required this.correctCount,
    required this.questionCount,
    required this.score,
    required this.maxScore,
    required this.failBelowScore,
    required this.isFailed,
  });

  factory _$MockExamSubjectResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$MockExamSubjectResultImplFromJson(json);

  @override
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  final MockExamSubject subject;
  @override
  final String name;
  @override
  final int correctCount;
  @override
  final int questionCount;
  @override
  final int score;
  @override
  final int maxScore;
  @override
  final int failBelowScore;
  @override
  final bool isFailed;

  @override
  String toString() {
    return 'MockExamSubjectResult(subject: $subject, name: $name, correctCount: $correctCount, questionCount: $questionCount, score: $score, maxScore: $maxScore, failBelowScore: $failBelowScore, isFailed: $isFailed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamSubjectResultImpl &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.correctCount, correctCount) ||
                other.correctCount == correctCount) &&
            (identical(other.questionCount, questionCount) ||
                other.questionCount == questionCount) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.maxScore, maxScore) ||
                other.maxScore == maxScore) &&
            (identical(other.failBelowScore, failBelowScore) ||
                other.failBelowScore == failBelowScore) &&
            (identical(other.isFailed, isFailed) ||
                other.isFailed == isFailed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    subject,
    name,
    correctCount,
    questionCount,
    score,
    maxScore,
    failBelowScore,
    isFailed,
  );

  /// Create a copy of MockExamSubjectResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MockExamSubjectResultImplCopyWith<_$MockExamSubjectResultImpl>
  get copyWith =>
      __$$MockExamSubjectResultImplCopyWithImpl<_$MockExamSubjectResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MockExamSubjectResultImplToJson(this);
  }
}

abstract class _MockExamSubjectResult implements MockExamSubjectResult {
  const factory _MockExamSubjectResult({
    @JsonKey(unknownEnumValue: MockExamSubject.unknown)
    required final MockExamSubject subject,
    required final String name,
    required final int correctCount,
    required final int questionCount,
    required final int score,
    required final int maxScore,
    required final int failBelowScore,
    required final bool isFailed,
  }) = _$MockExamSubjectResultImpl;

  factory _MockExamSubjectResult.fromJson(Map<String, dynamic> json) =
      _$MockExamSubjectResultImpl.fromJson;

  @override
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  MockExamSubject get subject;
  @override
  String get name;
  @override
  int get correctCount;
  @override
  int get questionCount;
  @override
  int get score;
  @override
  int get maxScore;
  @override
  int get failBelowScore;
  @override
  bool get isFailed;

  /// Create a copy of MockExamSubjectResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamSubjectResultImplCopyWith<_$MockExamSubjectResultImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MockExamTopicResult _$MockExamTopicResultFromJson(Map<String, dynamic> json) {
  return _MockExamTopicResult.fromJson(json);
}

/// @nodoc
mixin _$MockExamTopicResult {
  String get topicUuid => throw _privateConstructorUsedError;
  String? get topicName => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  MockExamSubject get subject => throw _privateConstructorUsedError;
  int get correctCount => throw _privateConstructorUsedError;
  int get questionCount => throw _privateConstructorUsedError;

  /// Serializes this MockExamTopicResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MockExamTopicResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MockExamTopicResultCopyWith<MockExamTopicResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MockExamTopicResultCopyWith<$Res> {
  factory $MockExamTopicResultCopyWith(
    MockExamTopicResult value,
    $Res Function(MockExamTopicResult) then,
  ) = _$MockExamTopicResultCopyWithImpl<$Res, MockExamTopicResult>;
  @useResult
  $Res call({
    String topicUuid,
    String? topicName,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) MockExamSubject subject,
    int correctCount,
    int questionCount,
  });
}

/// @nodoc
class _$MockExamTopicResultCopyWithImpl<$Res, $Val extends MockExamTopicResult>
    implements $MockExamTopicResultCopyWith<$Res> {
  _$MockExamTopicResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MockExamTopicResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topicUuid = null,
    Object? topicName = freezed,
    Object? subject = null,
    Object? correctCount = null,
    Object? questionCount = null,
  }) {
    return _then(
      _value.copyWith(
            topicUuid: null == topicUuid
                ? _value.topicUuid
                : topicUuid // ignore: cast_nullable_to_non_nullable
                      as String,
            topicName: freezed == topicName
                ? _value.topicName
                : topicName // ignore: cast_nullable_to_non_nullable
                      as String?,
            subject: null == subject
                ? _value.subject
                : subject // ignore: cast_nullable_to_non_nullable
                      as MockExamSubject,
            correctCount: null == correctCount
                ? _value.correctCount
                : correctCount // ignore: cast_nullable_to_non_nullable
                      as int,
            questionCount: null == questionCount
                ? _value.questionCount
                : questionCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MockExamTopicResultImplCopyWith<$Res>
    implements $MockExamTopicResultCopyWith<$Res> {
  factory _$$MockExamTopicResultImplCopyWith(
    _$MockExamTopicResultImpl value,
    $Res Function(_$MockExamTopicResultImpl) then,
  ) = __$$MockExamTopicResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String topicUuid,
    String? topicName,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) MockExamSubject subject,
    int correctCount,
    int questionCount,
  });
}

/// @nodoc
class __$$MockExamTopicResultImplCopyWithImpl<$Res>
    extends _$MockExamTopicResultCopyWithImpl<$Res, _$MockExamTopicResultImpl>
    implements _$$MockExamTopicResultImplCopyWith<$Res> {
  __$$MockExamTopicResultImplCopyWithImpl(
    _$MockExamTopicResultImpl _value,
    $Res Function(_$MockExamTopicResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MockExamTopicResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topicUuid = null,
    Object? topicName = freezed,
    Object? subject = null,
    Object? correctCount = null,
    Object? questionCount = null,
  }) {
    return _then(
      _$MockExamTopicResultImpl(
        topicUuid: null == topicUuid
            ? _value.topicUuid
            : topicUuid // ignore: cast_nullable_to_non_nullable
                  as String,
        topicName: freezed == topicName
            ? _value.topicName
            : topicName // ignore: cast_nullable_to_non_nullable
                  as String?,
        subject: null == subject
            ? _value.subject
            : subject // ignore: cast_nullable_to_non_nullable
                  as MockExamSubject,
        correctCount: null == correctCount
            ? _value.correctCount
            : correctCount // ignore: cast_nullable_to_non_nullable
                  as int,
        questionCount: null == questionCount
            ? _value.questionCount
            : questionCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MockExamTopicResultImpl implements _MockExamTopicResult {
  const _$MockExamTopicResultImpl({
    required this.topicUuid,
    this.topicName,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) required this.subject,
    required this.correctCount,
    required this.questionCount,
  });

  factory _$MockExamTopicResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$MockExamTopicResultImplFromJson(json);

  @override
  final String topicUuid;
  @override
  final String? topicName;
  @override
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  final MockExamSubject subject;
  @override
  final int correctCount;
  @override
  final int questionCount;

  @override
  String toString() {
    return 'MockExamTopicResult(topicUuid: $topicUuid, topicName: $topicName, subject: $subject, correctCount: $correctCount, questionCount: $questionCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamTopicResultImpl &&
            (identical(other.topicUuid, topicUuid) ||
                other.topicUuid == topicUuid) &&
            (identical(other.topicName, topicName) ||
                other.topicName == topicName) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.correctCount, correctCount) ||
                other.correctCount == correctCount) &&
            (identical(other.questionCount, questionCount) ||
                other.questionCount == questionCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    topicUuid,
    topicName,
    subject,
    correctCount,
    questionCount,
  );

  /// Create a copy of MockExamTopicResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MockExamTopicResultImplCopyWith<_$MockExamTopicResultImpl> get copyWith =>
      __$$MockExamTopicResultImplCopyWithImpl<_$MockExamTopicResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MockExamTopicResultImplToJson(this);
  }
}

abstract class _MockExamTopicResult implements MockExamTopicResult {
  const factory _MockExamTopicResult({
    required final String topicUuid,
    final String? topicName,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown)
    required final MockExamSubject subject,
    required final int correctCount,
    required final int questionCount,
  }) = _$MockExamTopicResultImpl;

  factory _MockExamTopicResult.fromJson(Map<String, dynamic> json) =
      _$MockExamTopicResultImpl.fromJson;

  @override
  String get topicUuid;
  @override
  String? get topicName;
  @override
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  MockExamSubject get subject;
  @override
  int get correctCount;
  @override
  int get questionCount;

  /// Create a copy of MockExamTopicResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamTopicResultImplCopyWith<_$MockExamTopicResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MockExamQuestionMark _$MockExamQuestionMarkFromJson(Map<String, dynamic> json) {
  return _MockExamQuestionMark.fromJson(json);
}

/// @nodoc
mixin _$MockExamQuestionMark {
  int get questionNumber => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  MockExamSubject get subject => throw _privateConstructorUsedError;
  bool get isAnswered => throw _privateConstructorUsedError;
  bool get isCorrect => throw _privateConstructorUsedError;
  bool get isFlagged => throw _privateConstructorUsedError;

  /// Serializes this MockExamQuestionMark to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MockExamQuestionMark
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MockExamQuestionMarkCopyWith<MockExamQuestionMark> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MockExamQuestionMarkCopyWith<$Res> {
  factory $MockExamQuestionMarkCopyWith(
    MockExamQuestionMark value,
    $Res Function(MockExamQuestionMark) then,
  ) = _$MockExamQuestionMarkCopyWithImpl<$Res, MockExamQuestionMark>;
  @useResult
  $Res call({
    int questionNumber,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) MockExamSubject subject,
    bool isAnswered,
    bool isCorrect,
    bool isFlagged,
  });
}

/// @nodoc
class _$MockExamQuestionMarkCopyWithImpl<
  $Res,
  $Val extends MockExamQuestionMark
>
    implements $MockExamQuestionMarkCopyWith<$Res> {
  _$MockExamQuestionMarkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MockExamQuestionMark
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionNumber = null,
    Object? subject = null,
    Object? isAnswered = null,
    Object? isCorrect = null,
    Object? isFlagged = null,
  }) {
    return _then(
      _value.copyWith(
            questionNumber: null == questionNumber
                ? _value.questionNumber
                : questionNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            subject: null == subject
                ? _value.subject
                : subject // ignore: cast_nullable_to_non_nullable
                      as MockExamSubject,
            isAnswered: null == isAnswered
                ? _value.isAnswered
                : isAnswered // ignore: cast_nullable_to_non_nullable
                      as bool,
            isCorrect: null == isCorrect
                ? _value.isCorrect
                : isCorrect // ignore: cast_nullable_to_non_nullable
                      as bool,
            isFlagged: null == isFlagged
                ? _value.isFlagged
                : isFlagged // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MockExamQuestionMarkImplCopyWith<$Res>
    implements $MockExamQuestionMarkCopyWith<$Res> {
  factory _$$MockExamQuestionMarkImplCopyWith(
    _$MockExamQuestionMarkImpl value,
    $Res Function(_$MockExamQuestionMarkImpl) then,
  ) = __$$MockExamQuestionMarkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int questionNumber,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) MockExamSubject subject,
    bool isAnswered,
    bool isCorrect,
    bool isFlagged,
  });
}

/// @nodoc
class __$$MockExamQuestionMarkImplCopyWithImpl<$Res>
    extends _$MockExamQuestionMarkCopyWithImpl<$Res, _$MockExamQuestionMarkImpl>
    implements _$$MockExamQuestionMarkImplCopyWith<$Res> {
  __$$MockExamQuestionMarkImplCopyWithImpl(
    _$MockExamQuestionMarkImpl _value,
    $Res Function(_$MockExamQuestionMarkImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MockExamQuestionMark
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionNumber = null,
    Object? subject = null,
    Object? isAnswered = null,
    Object? isCorrect = null,
    Object? isFlagged = null,
  }) {
    return _then(
      _$MockExamQuestionMarkImpl(
        questionNumber: null == questionNumber
            ? _value.questionNumber
            : questionNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        subject: null == subject
            ? _value.subject
            : subject // ignore: cast_nullable_to_non_nullable
                  as MockExamSubject,
        isAnswered: null == isAnswered
            ? _value.isAnswered
            : isAnswered // ignore: cast_nullable_to_non_nullable
                  as bool,
        isCorrect: null == isCorrect
            ? _value.isCorrect
            : isCorrect // ignore: cast_nullable_to_non_nullable
                  as bool,
        isFlagged: null == isFlagged
            ? _value.isFlagged
            : isFlagged // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MockExamQuestionMarkImpl implements _MockExamQuestionMark {
  const _$MockExamQuestionMarkImpl({
    required this.questionNumber,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) required this.subject,
    required this.isAnswered,
    required this.isCorrect,
    required this.isFlagged,
  });

  factory _$MockExamQuestionMarkImpl.fromJson(Map<String, dynamic> json) =>
      _$$MockExamQuestionMarkImplFromJson(json);

  @override
  final int questionNumber;
  @override
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  final MockExamSubject subject;
  @override
  final bool isAnswered;
  @override
  final bool isCorrect;
  @override
  final bool isFlagged;

  @override
  String toString() {
    return 'MockExamQuestionMark(questionNumber: $questionNumber, subject: $subject, isAnswered: $isAnswered, isCorrect: $isCorrect, isFlagged: $isFlagged)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamQuestionMarkImpl &&
            (identical(other.questionNumber, questionNumber) ||
                other.questionNumber == questionNumber) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.isAnswered, isAnswered) ||
                other.isAnswered == isAnswered) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect) &&
            (identical(other.isFlagged, isFlagged) ||
                other.isFlagged == isFlagged));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    questionNumber,
    subject,
    isAnswered,
    isCorrect,
    isFlagged,
  );

  /// Create a copy of MockExamQuestionMark
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MockExamQuestionMarkImplCopyWith<_$MockExamQuestionMarkImpl>
  get copyWith =>
      __$$MockExamQuestionMarkImplCopyWithImpl<_$MockExamQuestionMarkImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MockExamQuestionMarkImplToJson(this);
  }
}

abstract class _MockExamQuestionMark implements MockExamQuestionMark {
  const factory _MockExamQuestionMark({
    required final int questionNumber,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown)
    required final MockExamSubject subject,
    required final bool isAnswered,
    required final bool isCorrect,
    required final bool isFlagged,
  }) = _$MockExamQuestionMarkImpl;

  factory _MockExamQuestionMark.fromJson(Map<String, dynamic> json) =
      _$MockExamQuestionMarkImpl.fromJson;

  @override
  int get questionNumber;
  @override
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  MockExamSubject get subject;
  @override
  bool get isAnswered;
  @override
  bool get isCorrect;
  @override
  bool get isFlagged;

  /// Create a copy of MockExamQuestionMark
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamQuestionMarkImplCopyWith<_$MockExamQuestionMarkImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MockExamQuestionReview _$MockExamQuestionReviewFromJson(
  Map<String, dynamic> json,
) {
  return _MockExamQuestionReview.fromJson(json);
}

/// @nodoc
mixin _$MockExamQuestionReview {
  int get questionNumber => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  MockExamSubject get subject => throw _privateConstructorUsedError;
  String get questionUuid => throw _privateConstructorUsedError;
  String? get topicName => throw _privateConstructorUsedError;
  String get stem => throw _privateConstructorUsedError;
  String? get schemaDisplay => throw _privateConstructorUsedError;
  List<QuestionSchemaTable> get schemaTables =>
      throw _privateConstructorUsedError;
  List<MockExamChoice> get choices => throw _privateConstructorUsedError;
  String? get selectedChoiceKey => throw _privateConstructorUsedError;
  String get correctChoiceKey => throw _privateConstructorUsedError;
  bool get isCorrect => throw _privateConstructorUsedError;
  String? get explanationSummary => throw _privateConstructorUsedError;

  /// Serializes this MockExamQuestionReview to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MockExamQuestionReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MockExamQuestionReviewCopyWith<MockExamQuestionReview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MockExamQuestionReviewCopyWith<$Res> {
  factory $MockExamQuestionReviewCopyWith(
    MockExamQuestionReview value,
    $Res Function(MockExamQuestionReview) then,
  ) = _$MockExamQuestionReviewCopyWithImpl<$Res, MockExamQuestionReview>;
  @useResult
  $Res call({
    int questionNumber,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) MockExamSubject subject,
    String questionUuid,
    String? topicName,
    String stem,
    String? schemaDisplay,
    List<QuestionSchemaTable> schemaTables,
    List<MockExamChoice> choices,
    String? selectedChoiceKey,
    String correctChoiceKey,
    bool isCorrect,
    String? explanationSummary,
  });
}

/// @nodoc
class _$MockExamQuestionReviewCopyWithImpl<
  $Res,
  $Val extends MockExamQuestionReview
>
    implements $MockExamQuestionReviewCopyWith<$Res> {
  _$MockExamQuestionReviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MockExamQuestionReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionNumber = null,
    Object? subject = null,
    Object? questionUuid = null,
    Object? topicName = freezed,
    Object? stem = null,
    Object? schemaDisplay = freezed,
    Object? schemaTables = null,
    Object? choices = null,
    Object? selectedChoiceKey = freezed,
    Object? correctChoiceKey = null,
    Object? isCorrect = null,
    Object? explanationSummary = freezed,
  }) {
    return _then(
      _value.copyWith(
            questionNumber: null == questionNumber
                ? _value.questionNumber
                : questionNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            subject: null == subject
                ? _value.subject
                : subject // ignore: cast_nullable_to_non_nullable
                      as MockExamSubject,
            questionUuid: null == questionUuid
                ? _value.questionUuid
                : questionUuid // ignore: cast_nullable_to_non_nullable
                      as String,
            topicName: freezed == topicName
                ? _value.topicName
                : topicName // ignore: cast_nullable_to_non_nullable
                      as String?,
            stem: null == stem
                ? _value.stem
                : stem // ignore: cast_nullable_to_non_nullable
                      as String,
            schemaDisplay: freezed == schemaDisplay
                ? _value.schemaDisplay
                : schemaDisplay // ignore: cast_nullable_to_non_nullable
                      as String?,
            schemaTables: null == schemaTables
                ? _value.schemaTables
                : schemaTables // ignore: cast_nullable_to_non_nullable
                      as List<QuestionSchemaTable>,
            choices: null == choices
                ? _value.choices
                : choices // ignore: cast_nullable_to_non_nullable
                      as List<MockExamChoice>,
            selectedChoiceKey: freezed == selectedChoiceKey
                ? _value.selectedChoiceKey
                : selectedChoiceKey // ignore: cast_nullable_to_non_nullable
                      as String?,
            correctChoiceKey: null == correctChoiceKey
                ? _value.correctChoiceKey
                : correctChoiceKey // ignore: cast_nullable_to_non_nullable
                      as String,
            isCorrect: null == isCorrect
                ? _value.isCorrect
                : isCorrect // ignore: cast_nullable_to_non_nullable
                      as bool,
            explanationSummary: freezed == explanationSummary
                ? _value.explanationSummary
                : explanationSummary // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MockExamQuestionReviewImplCopyWith<$Res>
    implements $MockExamQuestionReviewCopyWith<$Res> {
  factory _$$MockExamQuestionReviewImplCopyWith(
    _$MockExamQuestionReviewImpl value,
    $Res Function(_$MockExamQuestionReviewImpl) then,
  ) = __$$MockExamQuestionReviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int questionNumber,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) MockExamSubject subject,
    String questionUuid,
    String? topicName,
    String stem,
    String? schemaDisplay,
    List<QuestionSchemaTable> schemaTables,
    List<MockExamChoice> choices,
    String? selectedChoiceKey,
    String correctChoiceKey,
    bool isCorrect,
    String? explanationSummary,
  });
}

/// @nodoc
class __$$MockExamQuestionReviewImplCopyWithImpl<$Res>
    extends
        _$MockExamQuestionReviewCopyWithImpl<$Res, _$MockExamQuestionReviewImpl>
    implements _$$MockExamQuestionReviewImplCopyWith<$Res> {
  __$$MockExamQuestionReviewImplCopyWithImpl(
    _$MockExamQuestionReviewImpl _value,
    $Res Function(_$MockExamQuestionReviewImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MockExamQuestionReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionNumber = null,
    Object? subject = null,
    Object? questionUuid = null,
    Object? topicName = freezed,
    Object? stem = null,
    Object? schemaDisplay = freezed,
    Object? schemaTables = null,
    Object? choices = null,
    Object? selectedChoiceKey = freezed,
    Object? correctChoiceKey = null,
    Object? isCorrect = null,
    Object? explanationSummary = freezed,
  }) {
    return _then(
      _$MockExamQuestionReviewImpl(
        questionNumber: null == questionNumber
            ? _value.questionNumber
            : questionNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        subject: null == subject
            ? _value.subject
            : subject // ignore: cast_nullable_to_non_nullable
                  as MockExamSubject,
        questionUuid: null == questionUuid
            ? _value.questionUuid
            : questionUuid // ignore: cast_nullable_to_non_nullable
                  as String,
        topicName: freezed == topicName
            ? _value.topicName
            : topicName // ignore: cast_nullable_to_non_nullable
                  as String?,
        stem: null == stem
            ? _value.stem
            : stem // ignore: cast_nullable_to_non_nullable
                  as String,
        schemaDisplay: freezed == schemaDisplay
            ? _value.schemaDisplay
            : schemaDisplay // ignore: cast_nullable_to_non_nullable
                  as String?,
        schemaTables: null == schemaTables
            ? _value._schemaTables
            : schemaTables // ignore: cast_nullable_to_non_nullable
                  as List<QuestionSchemaTable>,
        choices: null == choices
            ? _value._choices
            : choices // ignore: cast_nullable_to_non_nullable
                  as List<MockExamChoice>,
        selectedChoiceKey: freezed == selectedChoiceKey
            ? _value.selectedChoiceKey
            : selectedChoiceKey // ignore: cast_nullable_to_non_nullable
                  as String?,
        correctChoiceKey: null == correctChoiceKey
            ? _value.correctChoiceKey
            : correctChoiceKey // ignore: cast_nullable_to_non_nullable
                  as String,
        isCorrect: null == isCorrect
            ? _value.isCorrect
            : isCorrect // ignore: cast_nullable_to_non_nullable
                  as bool,
        explanationSummary: freezed == explanationSummary
            ? _value.explanationSummary
            : explanationSummary // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MockExamQuestionReviewImpl implements _MockExamQuestionReview {
  const _$MockExamQuestionReviewImpl({
    required this.questionNumber,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) required this.subject,
    required this.questionUuid,
    this.topicName,
    required this.stem,
    this.schemaDisplay,
    final List<QuestionSchemaTable> schemaTables = const [],
    final List<MockExamChoice> choices = const [],
    this.selectedChoiceKey,
    required this.correctChoiceKey,
    required this.isCorrect,
    this.explanationSummary,
  }) : _schemaTables = schemaTables,
       _choices = choices;

  factory _$MockExamQuestionReviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$MockExamQuestionReviewImplFromJson(json);

  @override
  final int questionNumber;
  @override
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  final MockExamSubject subject;
  @override
  final String questionUuid;
  @override
  final String? topicName;
  @override
  final String stem;
  @override
  final String? schemaDisplay;
  final List<QuestionSchemaTable> _schemaTables;
  @override
  @JsonKey()
  List<QuestionSchemaTable> get schemaTables {
    if (_schemaTables is EqualUnmodifiableListView) return _schemaTables;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_schemaTables);
  }

  final List<MockExamChoice> _choices;
  @override
  @JsonKey()
  List<MockExamChoice> get choices {
    if (_choices is EqualUnmodifiableListView) return _choices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_choices);
  }

  @override
  final String? selectedChoiceKey;
  @override
  final String correctChoiceKey;
  @override
  final bool isCorrect;
  @override
  final String? explanationSummary;

  @override
  String toString() {
    return 'MockExamQuestionReview(questionNumber: $questionNumber, subject: $subject, questionUuid: $questionUuid, topicName: $topicName, stem: $stem, schemaDisplay: $schemaDisplay, schemaTables: $schemaTables, choices: $choices, selectedChoiceKey: $selectedChoiceKey, correctChoiceKey: $correctChoiceKey, isCorrect: $isCorrect, explanationSummary: $explanationSummary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamQuestionReviewImpl &&
            (identical(other.questionNumber, questionNumber) ||
                other.questionNumber == questionNumber) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.questionUuid, questionUuid) ||
                other.questionUuid == questionUuid) &&
            (identical(other.topicName, topicName) ||
                other.topicName == topicName) &&
            (identical(other.stem, stem) || other.stem == stem) &&
            (identical(other.schemaDisplay, schemaDisplay) ||
                other.schemaDisplay == schemaDisplay) &&
            const DeepCollectionEquality().equals(
              other._schemaTables,
              _schemaTables,
            ) &&
            const DeepCollectionEquality().equals(other._choices, _choices) &&
            (identical(other.selectedChoiceKey, selectedChoiceKey) ||
                other.selectedChoiceKey == selectedChoiceKey) &&
            (identical(other.correctChoiceKey, correctChoiceKey) ||
                other.correctChoiceKey == correctChoiceKey) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect) &&
            (identical(other.explanationSummary, explanationSummary) ||
                other.explanationSummary == explanationSummary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    questionNumber,
    subject,
    questionUuid,
    topicName,
    stem,
    schemaDisplay,
    const DeepCollectionEquality().hash(_schemaTables),
    const DeepCollectionEquality().hash(_choices),
    selectedChoiceKey,
    correctChoiceKey,
    isCorrect,
    explanationSummary,
  );

  /// Create a copy of MockExamQuestionReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MockExamQuestionReviewImplCopyWith<_$MockExamQuestionReviewImpl>
  get copyWith =>
      __$$MockExamQuestionReviewImplCopyWithImpl<_$MockExamQuestionReviewImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MockExamQuestionReviewImplToJson(this);
  }
}

abstract class _MockExamQuestionReview implements MockExamQuestionReview {
  const factory _MockExamQuestionReview({
    required final int questionNumber,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown)
    required final MockExamSubject subject,
    required final String questionUuid,
    final String? topicName,
    required final String stem,
    final String? schemaDisplay,
    final List<QuestionSchemaTable> schemaTables,
    final List<MockExamChoice> choices,
    final String? selectedChoiceKey,
    required final String correctChoiceKey,
    required final bool isCorrect,
    final String? explanationSummary,
  }) = _$MockExamQuestionReviewImpl;

  factory _MockExamQuestionReview.fromJson(Map<String, dynamic> json) =
      _$MockExamQuestionReviewImpl.fromJson;

  @override
  int get questionNumber;
  @override
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  MockExamSubject get subject;
  @override
  String get questionUuid;
  @override
  String? get topicName;
  @override
  String get stem;
  @override
  String? get schemaDisplay;
  @override
  List<QuestionSchemaTable> get schemaTables;
  @override
  List<MockExamChoice> get choices;
  @override
  String? get selectedChoiceKey;
  @override
  String get correctChoiceKey;
  @override
  bool get isCorrect;
  @override
  String? get explanationSummary;

  /// Create a copy of MockExamQuestionReview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamQuestionReviewImplCopyWith<_$MockExamQuestionReviewImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MockExamNextStep _$MockExamNextStepFromJson(Map<String, dynamic> json) {
  return _MockExamNextStep.fromJson(json);
}

/// @nodoc
mixin _$MockExamNextStep {
  String get headline => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  List<AiAnalysisAction> get actions => throw _privateConstructorUsedError;

  /// Serializes this MockExamNextStep to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MockExamNextStep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MockExamNextStepCopyWith<MockExamNextStep> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MockExamNextStepCopyWith<$Res> {
  factory $MockExamNextStepCopyWith(
    MockExamNextStep value,
    $Res Function(MockExamNextStep) then,
  ) = _$MockExamNextStepCopyWithImpl<$Res, MockExamNextStep>;
  @useResult
  $Res call({String headline, String message, List<AiAnalysisAction> actions});
}

/// @nodoc
class _$MockExamNextStepCopyWithImpl<$Res, $Val extends MockExamNextStep>
    implements $MockExamNextStepCopyWith<$Res> {
  _$MockExamNextStepCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MockExamNextStep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? headline = null,
    Object? message = null,
    Object? actions = null,
  }) {
    return _then(
      _value.copyWith(
            headline: null == headline
                ? _value.headline
                : headline // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            actions: null == actions
                ? _value.actions
                : actions // ignore: cast_nullable_to_non_nullable
                      as List<AiAnalysisAction>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MockExamNextStepImplCopyWith<$Res>
    implements $MockExamNextStepCopyWith<$Res> {
  factory _$$MockExamNextStepImplCopyWith(
    _$MockExamNextStepImpl value,
    $Res Function(_$MockExamNextStepImpl) then,
  ) = __$$MockExamNextStepImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String headline, String message, List<AiAnalysisAction> actions});
}

/// @nodoc
class __$$MockExamNextStepImplCopyWithImpl<$Res>
    extends _$MockExamNextStepCopyWithImpl<$Res, _$MockExamNextStepImpl>
    implements _$$MockExamNextStepImplCopyWith<$Res> {
  __$$MockExamNextStepImplCopyWithImpl(
    _$MockExamNextStepImpl _value,
    $Res Function(_$MockExamNextStepImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MockExamNextStep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? headline = null,
    Object? message = null,
    Object? actions = null,
  }) {
    return _then(
      _$MockExamNextStepImpl(
        headline: null == headline
            ? _value.headline
            : headline // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        actions: null == actions
            ? _value._actions
            : actions // ignore: cast_nullable_to_non_nullable
                  as List<AiAnalysisAction>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MockExamNextStepImpl implements _MockExamNextStep {
  const _$MockExamNextStepImpl({
    required this.headline,
    required this.message,
    final List<AiAnalysisAction> actions = const [],
  }) : _actions = actions;

  factory _$MockExamNextStepImpl.fromJson(Map<String, dynamic> json) =>
      _$$MockExamNextStepImplFromJson(json);

  @override
  final String headline;
  @override
  final String message;
  final List<AiAnalysisAction> _actions;
  @override
  @JsonKey()
  List<AiAnalysisAction> get actions {
    if (_actions is EqualUnmodifiableListView) return _actions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_actions);
  }

  @override
  String toString() {
    return 'MockExamNextStep(headline: $headline, message: $message, actions: $actions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamNextStepImpl &&
            (identical(other.headline, headline) ||
                other.headline == headline) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._actions, _actions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    headline,
    message,
    const DeepCollectionEquality().hash(_actions),
  );

  /// Create a copy of MockExamNextStep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MockExamNextStepImplCopyWith<_$MockExamNextStepImpl> get copyWith =>
      __$$MockExamNextStepImplCopyWithImpl<_$MockExamNextStepImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MockExamNextStepImplToJson(this);
  }
}

abstract class _MockExamNextStep implements MockExamNextStep {
  const factory _MockExamNextStep({
    required final String headline,
    required final String message,
    final List<AiAnalysisAction> actions,
  }) = _$MockExamNextStepImpl;

  factory _MockExamNextStep.fromJson(Map<String, dynamic> json) =
      _$MockExamNextStepImpl.fromJson;

  @override
  String get headline;
  @override
  String get message;
  @override
  List<AiAnalysisAction> get actions;

  /// Create a copy of MockExamNextStep
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamNextStepImplCopyWith<_$MockExamNextStepImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MockExamHistoryResponse _$MockExamHistoryResponseFromJson(
  Map<String, dynamic> json,
) {
  return _MockExamHistoryResponse.fromJson(json);
}

/// @nodoc
mixin _$MockExamHistoryResponse {
  int get passScore => throw _privateConstructorUsedError;
  List<MockExamHistoryEntry> get attempts => throw _privateConstructorUsedError;

  /// Serializes this MockExamHistoryResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MockExamHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MockExamHistoryResponseCopyWith<MockExamHistoryResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MockExamHistoryResponseCopyWith<$Res> {
  factory $MockExamHistoryResponseCopyWith(
    MockExamHistoryResponse value,
    $Res Function(MockExamHistoryResponse) then,
  ) = _$MockExamHistoryResponseCopyWithImpl<$Res, MockExamHistoryResponse>;
  @useResult
  $Res call({int passScore, List<MockExamHistoryEntry> attempts});
}

/// @nodoc
class _$MockExamHistoryResponseCopyWithImpl<
  $Res,
  $Val extends MockExamHistoryResponse
>
    implements $MockExamHistoryResponseCopyWith<$Res> {
  _$MockExamHistoryResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MockExamHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? passScore = null, Object? attempts = null}) {
    return _then(
      _value.copyWith(
            passScore: null == passScore
                ? _value.passScore
                : passScore // ignore: cast_nullable_to_non_nullable
                      as int,
            attempts: null == attempts
                ? _value.attempts
                : attempts // ignore: cast_nullable_to_non_nullable
                      as List<MockExamHistoryEntry>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MockExamHistoryResponseImplCopyWith<$Res>
    implements $MockExamHistoryResponseCopyWith<$Res> {
  factory _$$MockExamHistoryResponseImplCopyWith(
    _$MockExamHistoryResponseImpl value,
    $Res Function(_$MockExamHistoryResponseImpl) then,
  ) = __$$MockExamHistoryResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int passScore, List<MockExamHistoryEntry> attempts});
}

/// @nodoc
class __$$MockExamHistoryResponseImplCopyWithImpl<$Res>
    extends
        _$MockExamHistoryResponseCopyWithImpl<
          $Res,
          _$MockExamHistoryResponseImpl
        >
    implements _$$MockExamHistoryResponseImplCopyWith<$Res> {
  __$$MockExamHistoryResponseImplCopyWithImpl(
    _$MockExamHistoryResponseImpl _value,
    $Res Function(_$MockExamHistoryResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MockExamHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? passScore = null, Object? attempts = null}) {
    return _then(
      _$MockExamHistoryResponseImpl(
        passScore: null == passScore
            ? _value.passScore
            : passScore // ignore: cast_nullable_to_non_nullable
                  as int,
        attempts: null == attempts
            ? _value._attempts
            : attempts // ignore: cast_nullable_to_non_nullable
                  as List<MockExamHistoryEntry>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MockExamHistoryResponseImpl implements _MockExamHistoryResponse {
  const _$MockExamHistoryResponseImpl({
    required this.passScore,
    final List<MockExamHistoryEntry> attempts = const [],
  }) : _attempts = attempts;

  factory _$MockExamHistoryResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$MockExamHistoryResponseImplFromJson(json);

  @override
  final int passScore;
  final List<MockExamHistoryEntry> _attempts;
  @override
  @JsonKey()
  List<MockExamHistoryEntry> get attempts {
    if (_attempts is EqualUnmodifiableListView) return _attempts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attempts);
  }

  @override
  String toString() {
    return 'MockExamHistoryResponse(passScore: $passScore, attempts: $attempts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamHistoryResponseImpl &&
            (identical(other.passScore, passScore) ||
                other.passScore == passScore) &&
            const DeepCollectionEquality().equals(other._attempts, _attempts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    passScore,
    const DeepCollectionEquality().hash(_attempts),
  );

  /// Create a copy of MockExamHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MockExamHistoryResponseImplCopyWith<_$MockExamHistoryResponseImpl>
  get copyWith =>
      __$$MockExamHistoryResponseImplCopyWithImpl<
        _$MockExamHistoryResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MockExamHistoryResponseImplToJson(this);
  }
}

abstract class _MockExamHistoryResponse implements MockExamHistoryResponse {
  const factory _MockExamHistoryResponse({
    required final int passScore,
    final List<MockExamHistoryEntry> attempts,
  }) = _$MockExamHistoryResponseImpl;

  factory _MockExamHistoryResponse.fromJson(Map<String, dynamic> json) =
      _$MockExamHistoryResponseImpl.fromJson;

  @override
  int get passScore;
  @override
  List<MockExamHistoryEntry> get attempts;

  /// Create a copy of MockExamHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamHistoryResponseImplCopyWith<_$MockExamHistoryResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MockExamHistoryEntry _$MockExamHistoryEntryFromJson(Map<String, dynamic> json) {
  return _MockExamHistoryEntry.fromJson(json);
}

/// @nodoc
mixin _$MockExamHistoryEntry {
  String get attemptUuid => throw _privateConstructorUsedError;
  int get roundNumber => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get submittedAt => throw _privateConstructorUsedError;
  int get totalScore => throw _privateConstructorUsedError;
  int get subjectOneScore => throw _privateConstructorUsedError;
  int get subjectTwoScore => throw _privateConstructorUsedError;
  bool get isPassed => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: MockExamFailReason.unknown)
  MockExamFailReason get failReason => throw _privateConstructorUsedError;

  /// Serializes this MockExamHistoryEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MockExamHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MockExamHistoryEntryCopyWith<MockExamHistoryEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MockExamHistoryEntryCopyWith<$Res> {
  factory $MockExamHistoryEntryCopyWith(
    MockExamHistoryEntry value,
    $Res Function(MockExamHistoryEntry) then,
  ) = _$MockExamHistoryEntryCopyWithImpl<$Res, MockExamHistoryEntry>;
  @useResult
  $Res call({
    String attemptUuid,
    int roundNumber,
    String title,
    String submittedAt,
    int totalScore,
    int subjectOneScore,
    int subjectTwoScore,
    bool isPassed,
    @JsonKey(unknownEnumValue: MockExamFailReason.unknown)
    MockExamFailReason failReason,
  });
}

/// @nodoc
class _$MockExamHistoryEntryCopyWithImpl<
  $Res,
  $Val extends MockExamHistoryEntry
>
    implements $MockExamHistoryEntryCopyWith<$Res> {
  _$MockExamHistoryEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MockExamHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attemptUuid = null,
    Object? roundNumber = null,
    Object? title = null,
    Object? submittedAt = null,
    Object? totalScore = null,
    Object? subjectOneScore = null,
    Object? subjectTwoScore = null,
    Object? isPassed = null,
    Object? failReason = null,
  }) {
    return _then(
      _value.copyWith(
            attemptUuid: null == attemptUuid
                ? _value.attemptUuid
                : attemptUuid // ignore: cast_nullable_to_non_nullable
                      as String,
            roundNumber: null == roundNumber
                ? _value.roundNumber
                : roundNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            submittedAt: null == submittedAt
                ? _value.submittedAt
                : submittedAt // ignore: cast_nullable_to_non_nullable
                      as String,
            totalScore: null == totalScore
                ? _value.totalScore
                : totalScore // ignore: cast_nullable_to_non_nullable
                      as int,
            subjectOneScore: null == subjectOneScore
                ? _value.subjectOneScore
                : subjectOneScore // ignore: cast_nullable_to_non_nullable
                      as int,
            subjectTwoScore: null == subjectTwoScore
                ? _value.subjectTwoScore
                : subjectTwoScore // ignore: cast_nullable_to_non_nullable
                      as int,
            isPassed: null == isPassed
                ? _value.isPassed
                : isPassed // ignore: cast_nullable_to_non_nullable
                      as bool,
            failReason: null == failReason
                ? _value.failReason
                : failReason // ignore: cast_nullable_to_non_nullable
                      as MockExamFailReason,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MockExamHistoryEntryImplCopyWith<$Res>
    implements $MockExamHistoryEntryCopyWith<$Res> {
  factory _$$MockExamHistoryEntryImplCopyWith(
    _$MockExamHistoryEntryImpl value,
    $Res Function(_$MockExamHistoryEntryImpl) then,
  ) = __$$MockExamHistoryEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String attemptUuid,
    int roundNumber,
    String title,
    String submittedAt,
    int totalScore,
    int subjectOneScore,
    int subjectTwoScore,
    bool isPassed,
    @JsonKey(unknownEnumValue: MockExamFailReason.unknown)
    MockExamFailReason failReason,
  });
}

/// @nodoc
class __$$MockExamHistoryEntryImplCopyWithImpl<$Res>
    extends _$MockExamHistoryEntryCopyWithImpl<$Res, _$MockExamHistoryEntryImpl>
    implements _$$MockExamHistoryEntryImplCopyWith<$Res> {
  __$$MockExamHistoryEntryImplCopyWithImpl(
    _$MockExamHistoryEntryImpl _value,
    $Res Function(_$MockExamHistoryEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MockExamHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attemptUuid = null,
    Object? roundNumber = null,
    Object? title = null,
    Object? submittedAt = null,
    Object? totalScore = null,
    Object? subjectOneScore = null,
    Object? subjectTwoScore = null,
    Object? isPassed = null,
    Object? failReason = null,
  }) {
    return _then(
      _$MockExamHistoryEntryImpl(
        attemptUuid: null == attemptUuid
            ? _value.attemptUuid
            : attemptUuid // ignore: cast_nullable_to_non_nullable
                  as String,
        roundNumber: null == roundNumber
            ? _value.roundNumber
            : roundNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        submittedAt: null == submittedAt
            ? _value.submittedAt
            : submittedAt // ignore: cast_nullable_to_non_nullable
                  as String,
        totalScore: null == totalScore
            ? _value.totalScore
            : totalScore // ignore: cast_nullable_to_non_nullable
                  as int,
        subjectOneScore: null == subjectOneScore
            ? _value.subjectOneScore
            : subjectOneScore // ignore: cast_nullable_to_non_nullable
                  as int,
        subjectTwoScore: null == subjectTwoScore
            ? _value.subjectTwoScore
            : subjectTwoScore // ignore: cast_nullable_to_non_nullable
                  as int,
        isPassed: null == isPassed
            ? _value.isPassed
            : isPassed // ignore: cast_nullable_to_non_nullable
                  as bool,
        failReason: null == failReason
            ? _value.failReason
            : failReason // ignore: cast_nullable_to_non_nullable
                  as MockExamFailReason,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MockExamHistoryEntryImpl implements _MockExamHistoryEntry {
  const _$MockExamHistoryEntryImpl({
    required this.attemptUuid,
    required this.roundNumber,
    required this.title,
    required this.submittedAt,
    required this.totalScore,
    required this.subjectOneScore,
    required this.subjectTwoScore,
    required this.isPassed,
    @JsonKey(unknownEnumValue: MockExamFailReason.unknown)
    required this.failReason,
  });

  factory _$MockExamHistoryEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MockExamHistoryEntryImplFromJson(json);

  @override
  final String attemptUuid;
  @override
  final int roundNumber;
  @override
  final String title;
  @override
  final String submittedAt;
  @override
  final int totalScore;
  @override
  final int subjectOneScore;
  @override
  final int subjectTwoScore;
  @override
  final bool isPassed;
  @override
  @JsonKey(unknownEnumValue: MockExamFailReason.unknown)
  final MockExamFailReason failReason;

  @override
  String toString() {
    return 'MockExamHistoryEntry(attemptUuid: $attemptUuid, roundNumber: $roundNumber, title: $title, submittedAt: $submittedAt, totalScore: $totalScore, subjectOneScore: $subjectOneScore, subjectTwoScore: $subjectTwoScore, isPassed: $isPassed, failReason: $failReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamHistoryEntryImpl &&
            (identical(other.attemptUuid, attemptUuid) ||
                other.attemptUuid == attemptUuid) &&
            (identical(other.roundNumber, roundNumber) ||
                other.roundNumber == roundNumber) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.totalScore, totalScore) ||
                other.totalScore == totalScore) &&
            (identical(other.subjectOneScore, subjectOneScore) ||
                other.subjectOneScore == subjectOneScore) &&
            (identical(other.subjectTwoScore, subjectTwoScore) ||
                other.subjectTwoScore == subjectTwoScore) &&
            (identical(other.isPassed, isPassed) ||
                other.isPassed == isPassed) &&
            (identical(other.failReason, failReason) ||
                other.failReason == failReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    attemptUuid,
    roundNumber,
    title,
    submittedAt,
    totalScore,
    subjectOneScore,
    subjectTwoScore,
    isPassed,
    failReason,
  );

  /// Create a copy of MockExamHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MockExamHistoryEntryImplCopyWith<_$MockExamHistoryEntryImpl>
  get copyWith =>
      __$$MockExamHistoryEntryImplCopyWithImpl<_$MockExamHistoryEntryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MockExamHistoryEntryImplToJson(this);
  }
}

abstract class _MockExamHistoryEntry implements MockExamHistoryEntry {
  const factory _MockExamHistoryEntry({
    required final String attemptUuid,
    required final int roundNumber,
    required final String title,
    required final String submittedAt,
    required final int totalScore,
    required final int subjectOneScore,
    required final int subjectTwoScore,
    required final bool isPassed,
    @JsonKey(unknownEnumValue: MockExamFailReason.unknown)
    required final MockExamFailReason failReason,
  }) = _$MockExamHistoryEntryImpl;

  factory _MockExamHistoryEntry.fromJson(Map<String, dynamic> json) =
      _$MockExamHistoryEntryImpl.fromJson;

  @override
  String get attemptUuid;
  @override
  int get roundNumber;
  @override
  String get title;
  @override
  String get submittedAt;
  @override
  int get totalScore;
  @override
  int get subjectOneScore;
  @override
  int get subjectTwoScore;
  @override
  bool get isPassed;
  @override
  @JsonKey(unknownEnumValue: MockExamFailReason.unknown)
  MockExamFailReason get failReason;

  /// Create a copy of MockExamHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamHistoryEntryImplCopyWith<_$MockExamHistoryEntryImpl>
  get copyWith => throw _privateConstructorUsedError;
}
