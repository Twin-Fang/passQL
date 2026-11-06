// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mock_exam_sheet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MockExamSheetResponse _$MockExamSheetResponseFromJson(
  Map<String, dynamic> json,
) {
  return _MockExamSheetResponse.fromJson(json);
}

/// @nodoc
mixin _$MockExamSheetResponse {
  String get attemptUuid => throw _privateConstructorUsedError;
  String get roundUuid => throw _privateConstructorUsedError;
  int get roundNumber => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: MockExamAttemptStatus.unknown)
  MockExamAttemptStatus get status => throw _privateConstructorUsedError;
  int get remainingSeconds => throw _privateConstructorUsedError;
  List<MockExamSheetQuestion> get questions =>
      throw _privateConstructorUsedError;

  /// Serializes this MockExamSheetResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MockExamSheetResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MockExamSheetResponseCopyWith<MockExamSheetResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MockExamSheetResponseCopyWith<$Res> {
  factory $MockExamSheetResponseCopyWith(
    MockExamSheetResponse value,
    $Res Function(MockExamSheetResponse) then,
  ) = _$MockExamSheetResponseCopyWithImpl<$Res, MockExamSheetResponse>;
  @useResult
  $Res call({
    String attemptUuid,
    String roundUuid,
    int roundNumber,
    String title,
    @JsonKey(unknownEnumValue: MockExamAttemptStatus.unknown)
    MockExamAttemptStatus status,
    int remainingSeconds,
    List<MockExamSheetQuestion> questions,
  });
}

/// @nodoc
class _$MockExamSheetResponseCopyWithImpl<
  $Res,
  $Val extends MockExamSheetResponse
>
    implements $MockExamSheetResponseCopyWith<$Res> {
  _$MockExamSheetResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MockExamSheetResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attemptUuid = null,
    Object? roundUuid = null,
    Object? roundNumber = null,
    Object? title = null,
    Object? status = null,
    Object? remainingSeconds = null,
    Object? questions = null,
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
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as MockExamAttemptStatus,
            remainingSeconds: null == remainingSeconds
                ? _value.remainingSeconds
                : remainingSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            questions: null == questions
                ? _value.questions
                : questions // ignore: cast_nullable_to_non_nullable
                      as List<MockExamSheetQuestion>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MockExamSheetResponseImplCopyWith<$Res>
    implements $MockExamSheetResponseCopyWith<$Res> {
  factory _$$MockExamSheetResponseImplCopyWith(
    _$MockExamSheetResponseImpl value,
    $Res Function(_$MockExamSheetResponseImpl) then,
  ) = __$$MockExamSheetResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String attemptUuid,
    String roundUuid,
    int roundNumber,
    String title,
    @JsonKey(unknownEnumValue: MockExamAttemptStatus.unknown)
    MockExamAttemptStatus status,
    int remainingSeconds,
    List<MockExamSheetQuestion> questions,
  });
}

/// @nodoc
class __$$MockExamSheetResponseImplCopyWithImpl<$Res>
    extends
        _$MockExamSheetResponseCopyWithImpl<$Res, _$MockExamSheetResponseImpl>
    implements _$$MockExamSheetResponseImplCopyWith<$Res> {
  __$$MockExamSheetResponseImplCopyWithImpl(
    _$MockExamSheetResponseImpl _value,
    $Res Function(_$MockExamSheetResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MockExamSheetResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attemptUuid = null,
    Object? roundUuid = null,
    Object? roundNumber = null,
    Object? title = null,
    Object? status = null,
    Object? remainingSeconds = null,
    Object? questions = null,
  }) {
    return _then(
      _$MockExamSheetResponseImpl(
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
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as MockExamAttemptStatus,
        remainingSeconds: null == remainingSeconds
            ? _value.remainingSeconds
            : remainingSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        questions: null == questions
            ? _value._questions
            : questions // ignore: cast_nullable_to_non_nullable
                  as List<MockExamSheetQuestion>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MockExamSheetResponseImpl implements _MockExamSheetResponse {
  const _$MockExamSheetResponseImpl({
    required this.attemptUuid,
    required this.roundUuid,
    required this.roundNumber,
    required this.title,
    @JsonKey(unknownEnumValue: MockExamAttemptStatus.unknown)
    required this.status,
    required this.remainingSeconds,
    final List<MockExamSheetQuestion> questions = const [],
  }) : _questions = questions;

  factory _$MockExamSheetResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$MockExamSheetResponseImplFromJson(json);

  @override
  final String attemptUuid;
  @override
  final String roundUuid;
  @override
  final int roundNumber;
  @override
  final String title;
  @override
  @JsonKey(unknownEnumValue: MockExamAttemptStatus.unknown)
  final MockExamAttemptStatus status;
  @override
  final int remainingSeconds;
  final List<MockExamSheetQuestion> _questions;
  @override
  @JsonKey()
  List<MockExamSheetQuestion> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  @override
  String toString() {
    return 'MockExamSheetResponse(attemptUuid: $attemptUuid, roundUuid: $roundUuid, roundNumber: $roundNumber, title: $title, status: $status, remainingSeconds: $remainingSeconds, questions: $questions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamSheetResponseImpl &&
            (identical(other.attemptUuid, attemptUuid) ||
                other.attemptUuid == attemptUuid) &&
            (identical(other.roundUuid, roundUuid) ||
                other.roundUuid == roundUuid) &&
            (identical(other.roundNumber, roundNumber) ||
                other.roundNumber == roundNumber) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.remainingSeconds, remainingSeconds) ||
                other.remainingSeconds == remainingSeconds) &&
            const DeepCollectionEquality().equals(
              other._questions,
              _questions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    attemptUuid,
    roundUuid,
    roundNumber,
    title,
    status,
    remainingSeconds,
    const DeepCollectionEquality().hash(_questions),
  );

  /// Create a copy of MockExamSheetResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MockExamSheetResponseImplCopyWith<_$MockExamSheetResponseImpl>
  get copyWith =>
      __$$MockExamSheetResponseImplCopyWithImpl<_$MockExamSheetResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MockExamSheetResponseImplToJson(this);
  }
}

abstract class _MockExamSheetResponse implements MockExamSheetResponse {
  const factory _MockExamSheetResponse({
    required final String attemptUuid,
    required final String roundUuid,
    required final int roundNumber,
    required final String title,
    @JsonKey(unknownEnumValue: MockExamAttemptStatus.unknown)
    required final MockExamAttemptStatus status,
    required final int remainingSeconds,
    final List<MockExamSheetQuestion> questions,
  }) = _$MockExamSheetResponseImpl;

  factory _MockExamSheetResponse.fromJson(Map<String, dynamic> json) =
      _$MockExamSheetResponseImpl.fromJson;

  @override
  String get attemptUuid;
  @override
  String get roundUuid;
  @override
  int get roundNumber;
  @override
  String get title;
  @override
  @JsonKey(unknownEnumValue: MockExamAttemptStatus.unknown)
  MockExamAttemptStatus get status;
  @override
  int get remainingSeconds;
  @override
  List<MockExamSheetQuestion> get questions;

  /// Create a copy of MockExamSheetResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamSheetResponseImplCopyWith<_$MockExamSheetResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MockExamSheetQuestion _$MockExamSheetQuestionFromJson(
  Map<String, dynamic> json,
) {
  return _MockExamSheetQuestion.fromJson(json);
}

/// @nodoc
mixin _$MockExamSheetQuestion {
  int get questionNumber => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  MockExamSubject get subject => throw _privateConstructorUsedError;
  String? get topicName => throw _privateConstructorUsedError;
  String get stem => throw _privateConstructorUsedError;
  String? get schemaDisplay => throw _privateConstructorUsedError;
  List<QuestionSchemaTable> get schemaTables =>
      throw _privateConstructorUsedError;
  List<MockExamChoice> get choices => throw _privateConstructorUsedError;
  String? get selectedChoiceKey => throw _privateConstructorUsedError;
  bool get isFlagged => throw _privateConstructorUsedError;

  /// Serializes this MockExamSheetQuestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MockExamSheetQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MockExamSheetQuestionCopyWith<MockExamSheetQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MockExamSheetQuestionCopyWith<$Res> {
  factory $MockExamSheetQuestionCopyWith(
    MockExamSheetQuestion value,
    $Res Function(MockExamSheetQuestion) then,
  ) = _$MockExamSheetQuestionCopyWithImpl<$Res, MockExamSheetQuestion>;
  @useResult
  $Res call({
    int questionNumber,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) MockExamSubject subject,
    String? topicName,
    String stem,
    String? schemaDisplay,
    List<QuestionSchemaTable> schemaTables,
    List<MockExamChoice> choices,
    String? selectedChoiceKey,
    bool isFlagged,
  });
}

/// @nodoc
class _$MockExamSheetQuestionCopyWithImpl<
  $Res,
  $Val extends MockExamSheetQuestion
>
    implements $MockExamSheetQuestionCopyWith<$Res> {
  _$MockExamSheetQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MockExamSheetQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionNumber = null,
    Object? subject = null,
    Object? topicName = freezed,
    Object? stem = null,
    Object? schemaDisplay = freezed,
    Object? schemaTables = null,
    Object? choices = null,
    Object? selectedChoiceKey = freezed,
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
abstract class _$$MockExamSheetQuestionImplCopyWith<$Res>
    implements $MockExamSheetQuestionCopyWith<$Res> {
  factory _$$MockExamSheetQuestionImplCopyWith(
    _$MockExamSheetQuestionImpl value,
    $Res Function(_$MockExamSheetQuestionImpl) then,
  ) = __$$MockExamSheetQuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int questionNumber,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) MockExamSubject subject,
    String? topicName,
    String stem,
    String? schemaDisplay,
    List<QuestionSchemaTable> schemaTables,
    List<MockExamChoice> choices,
    String? selectedChoiceKey,
    bool isFlagged,
  });
}

/// @nodoc
class __$$MockExamSheetQuestionImplCopyWithImpl<$Res>
    extends
        _$MockExamSheetQuestionCopyWithImpl<$Res, _$MockExamSheetQuestionImpl>
    implements _$$MockExamSheetQuestionImplCopyWith<$Res> {
  __$$MockExamSheetQuestionImplCopyWithImpl(
    _$MockExamSheetQuestionImpl _value,
    $Res Function(_$MockExamSheetQuestionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MockExamSheetQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionNumber = null,
    Object? subject = null,
    Object? topicName = freezed,
    Object? stem = null,
    Object? schemaDisplay = freezed,
    Object? schemaTables = null,
    Object? choices = null,
    Object? selectedChoiceKey = freezed,
    Object? isFlagged = null,
  }) {
    return _then(
      _$MockExamSheetQuestionImpl(
        questionNumber: null == questionNumber
            ? _value.questionNumber
            : questionNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        subject: null == subject
            ? _value.subject
            : subject // ignore: cast_nullable_to_non_nullable
                  as MockExamSubject,
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
class _$MockExamSheetQuestionImpl implements _MockExamSheetQuestion {
  const _$MockExamSheetQuestionImpl({
    required this.questionNumber,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) required this.subject,
    this.topicName,
    required this.stem,
    this.schemaDisplay,
    final List<QuestionSchemaTable> schemaTables = const [],
    final List<MockExamChoice> choices = const [],
    this.selectedChoiceKey,
    this.isFlagged = false,
  }) : _schemaTables = schemaTables,
       _choices = choices;

  factory _$MockExamSheetQuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$MockExamSheetQuestionImplFromJson(json);

  @override
  final int questionNumber;
  @override
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  final MockExamSubject subject;
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
  @JsonKey()
  final bool isFlagged;

  @override
  String toString() {
    return 'MockExamSheetQuestion(questionNumber: $questionNumber, subject: $subject, topicName: $topicName, stem: $stem, schemaDisplay: $schemaDisplay, schemaTables: $schemaTables, choices: $choices, selectedChoiceKey: $selectedChoiceKey, isFlagged: $isFlagged)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamSheetQuestionImpl &&
            (identical(other.questionNumber, questionNumber) ||
                other.questionNumber == questionNumber) &&
            (identical(other.subject, subject) || other.subject == subject) &&
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
            (identical(other.isFlagged, isFlagged) ||
                other.isFlagged == isFlagged));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    questionNumber,
    subject,
    topicName,
    stem,
    schemaDisplay,
    const DeepCollectionEquality().hash(_schemaTables),
    const DeepCollectionEquality().hash(_choices),
    selectedChoiceKey,
    isFlagged,
  );

  /// Create a copy of MockExamSheetQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MockExamSheetQuestionImplCopyWith<_$MockExamSheetQuestionImpl>
  get copyWith =>
      __$$MockExamSheetQuestionImplCopyWithImpl<_$MockExamSheetQuestionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MockExamSheetQuestionImplToJson(this);
  }
}

abstract class _MockExamSheetQuestion implements MockExamSheetQuestion {
  const factory _MockExamSheetQuestion({
    required final int questionNumber,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown)
    required final MockExamSubject subject,
    final String? topicName,
    required final String stem,
    final String? schemaDisplay,
    final List<QuestionSchemaTable> schemaTables,
    final List<MockExamChoice> choices,
    final String? selectedChoiceKey,
    final bool isFlagged,
  }) = _$MockExamSheetQuestionImpl;

  factory _MockExamSheetQuestion.fromJson(Map<String, dynamic> json) =
      _$MockExamSheetQuestionImpl.fromJson;

  @override
  int get questionNumber;
  @override
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  MockExamSubject get subject;
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
  bool get isFlagged;

  /// Create a copy of MockExamSheetQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamSheetQuestionImplCopyWith<_$MockExamSheetQuestionImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MockExamChoice _$MockExamChoiceFromJson(Map<String, dynamic> json) {
  return _MockExamChoice.fromJson(json);
}

/// @nodoc
mixin _$MockExamChoice {
  String get key => throw _privateConstructorUsedError;
  String get kind => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  bool? get isCorrect => throw _privateConstructorUsedError;
  String? get rationale => throw _privateConstructorUsedError;

  /// Serializes this MockExamChoice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MockExamChoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MockExamChoiceCopyWith<MockExamChoice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MockExamChoiceCopyWith<$Res> {
  factory $MockExamChoiceCopyWith(
    MockExamChoice value,
    $Res Function(MockExamChoice) then,
  ) = _$MockExamChoiceCopyWithImpl<$Res, MockExamChoice>;
  @useResult
  $Res call({
    String key,
    String kind,
    String body,
    bool? isCorrect,
    String? rationale,
  });
}

/// @nodoc
class _$MockExamChoiceCopyWithImpl<$Res, $Val extends MockExamChoice>
    implements $MockExamChoiceCopyWith<$Res> {
  _$MockExamChoiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MockExamChoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? kind = null,
    Object? body = null,
    Object? isCorrect = freezed,
    Object? rationale = freezed,
  }) {
    return _then(
      _value.copyWith(
            key: null == key
                ? _value.key
                : key // ignore: cast_nullable_to_non_nullable
                      as String,
            kind: null == kind
                ? _value.kind
                : kind // ignore: cast_nullable_to_non_nullable
                      as String,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
            isCorrect: freezed == isCorrect
                ? _value.isCorrect
                : isCorrect // ignore: cast_nullable_to_non_nullable
                      as bool?,
            rationale: freezed == rationale
                ? _value.rationale
                : rationale // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MockExamChoiceImplCopyWith<$Res>
    implements $MockExamChoiceCopyWith<$Res> {
  factory _$$MockExamChoiceImplCopyWith(
    _$MockExamChoiceImpl value,
    $Res Function(_$MockExamChoiceImpl) then,
  ) = __$$MockExamChoiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String key,
    String kind,
    String body,
    bool? isCorrect,
    String? rationale,
  });
}

/// @nodoc
class __$$MockExamChoiceImplCopyWithImpl<$Res>
    extends _$MockExamChoiceCopyWithImpl<$Res, _$MockExamChoiceImpl>
    implements _$$MockExamChoiceImplCopyWith<$Res> {
  __$$MockExamChoiceImplCopyWithImpl(
    _$MockExamChoiceImpl _value,
    $Res Function(_$MockExamChoiceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MockExamChoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? kind = null,
    Object? body = null,
    Object? isCorrect = freezed,
    Object? rationale = freezed,
  }) {
    return _then(
      _$MockExamChoiceImpl(
        key: null == key
            ? _value.key
            : key // ignore: cast_nullable_to_non_nullable
                  as String,
        kind: null == kind
            ? _value.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        isCorrect: freezed == isCorrect
            ? _value.isCorrect
            : isCorrect // ignore: cast_nullable_to_non_nullable
                  as bool?,
        rationale: freezed == rationale
            ? _value.rationale
            : rationale // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MockExamChoiceImpl implements _MockExamChoice {
  const _$MockExamChoiceImpl({
    required this.key,
    required this.kind,
    required this.body,
    this.isCorrect,
    this.rationale,
  });

  factory _$MockExamChoiceImpl.fromJson(Map<String, dynamic> json) =>
      _$$MockExamChoiceImplFromJson(json);

  @override
  final String key;
  @override
  final String kind;
  @override
  final String body;
  @override
  final bool? isCorrect;
  @override
  final String? rationale;

  @override
  String toString() {
    return 'MockExamChoice(key: $key, kind: $kind, body: $body, isCorrect: $isCorrect, rationale: $rationale)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamChoiceImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect) &&
            (identical(other.rationale, rationale) ||
                other.rationale == rationale));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, key, kind, body, isCorrect, rationale);

  /// Create a copy of MockExamChoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MockExamChoiceImplCopyWith<_$MockExamChoiceImpl> get copyWith =>
      __$$MockExamChoiceImplCopyWithImpl<_$MockExamChoiceImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MockExamChoiceImplToJson(this);
  }
}

abstract class _MockExamChoice implements MockExamChoice {
  const factory _MockExamChoice({
    required final String key,
    required final String kind,
    required final String body,
    final bool? isCorrect,
    final String? rationale,
  }) = _$MockExamChoiceImpl;

  factory _MockExamChoice.fromJson(Map<String, dynamic> json) =
      _$MockExamChoiceImpl.fromJson;

  @override
  String get key;
  @override
  String get kind;
  @override
  String get body;
  @override
  bool? get isCorrect;
  @override
  String? get rationale;

  /// Create a copy of MockExamChoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamChoiceImplCopyWith<_$MockExamChoiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MockExamAnswerSaveRequest _$MockExamAnswerSaveRequestFromJson(
  Map<String, dynamic> json,
) {
  return _MockExamAnswerSaveRequest.fromJson(json);
}

/// @nodoc
mixin _$MockExamAnswerSaveRequest {
  String? get selectedChoiceKey => throw _privateConstructorUsedError;
  bool get isFlagged => throw _privateConstructorUsedError;

  /// Serializes this MockExamAnswerSaveRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MockExamAnswerSaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MockExamAnswerSaveRequestCopyWith<MockExamAnswerSaveRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MockExamAnswerSaveRequestCopyWith<$Res> {
  factory $MockExamAnswerSaveRequestCopyWith(
    MockExamAnswerSaveRequest value,
    $Res Function(MockExamAnswerSaveRequest) then,
  ) = _$MockExamAnswerSaveRequestCopyWithImpl<$Res, MockExamAnswerSaveRequest>;
  @useResult
  $Res call({String? selectedChoiceKey, bool isFlagged});
}

/// @nodoc
class _$MockExamAnswerSaveRequestCopyWithImpl<
  $Res,
  $Val extends MockExamAnswerSaveRequest
>
    implements $MockExamAnswerSaveRequestCopyWith<$Res> {
  _$MockExamAnswerSaveRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MockExamAnswerSaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? selectedChoiceKey = freezed, Object? isFlagged = null}) {
    return _then(
      _value.copyWith(
            selectedChoiceKey: freezed == selectedChoiceKey
                ? _value.selectedChoiceKey
                : selectedChoiceKey // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$MockExamAnswerSaveRequestImplCopyWith<$Res>
    implements $MockExamAnswerSaveRequestCopyWith<$Res> {
  factory _$$MockExamAnswerSaveRequestImplCopyWith(
    _$MockExamAnswerSaveRequestImpl value,
    $Res Function(_$MockExamAnswerSaveRequestImpl) then,
  ) = __$$MockExamAnswerSaveRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? selectedChoiceKey, bool isFlagged});
}

/// @nodoc
class __$$MockExamAnswerSaveRequestImplCopyWithImpl<$Res>
    extends
        _$MockExamAnswerSaveRequestCopyWithImpl<
          $Res,
          _$MockExamAnswerSaveRequestImpl
        >
    implements _$$MockExamAnswerSaveRequestImplCopyWith<$Res> {
  __$$MockExamAnswerSaveRequestImplCopyWithImpl(
    _$MockExamAnswerSaveRequestImpl _value,
    $Res Function(_$MockExamAnswerSaveRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MockExamAnswerSaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? selectedChoiceKey = freezed, Object? isFlagged = null}) {
    return _then(
      _$MockExamAnswerSaveRequestImpl(
        selectedChoiceKey: freezed == selectedChoiceKey
            ? _value.selectedChoiceKey
            : selectedChoiceKey // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$MockExamAnswerSaveRequestImpl implements _MockExamAnswerSaveRequest {
  const _$MockExamAnswerSaveRequestImpl({
    this.selectedChoiceKey,
    required this.isFlagged,
  });

  factory _$MockExamAnswerSaveRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$MockExamAnswerSaveRequestImplFromJson(json);

  @override
  final String? selectedChoiceKey;
  @override
  final bool isFlagged;

  @override
  String toString() {
    return 'MockExamAnswerSaveRequest(selectedChoiceKey: $selectedChoiceKey, isFlagged: $isFlagged)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamAnswerSaveRequestImpl &&
            (identical(other.selectedChoiceKey, selectedChoiceKey) ||
                other.selectedChoiceKey == selectedChoiceKey) &&
            (identical(other.isFlagged, isFlagged) ||
                other.isFlagged == isFlagged));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, selectedChoiceKey, isFlagged);

  /// Create a copy of MockExamAnswerSaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MockExamAnswerSaveRequestImplCopyWith<_$MockExamAnswerSaveRequestImpl>
  get copyWith =>
      __$$MockExamAnswerSaveRequestImplCopyWithImpl<
        _$MockExamAnswerSaveRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MockExamAnswerSaveRequestImplToJson(this);
  }
}

abstract class _MockExamAnswerSaveRequest implements MockExamAnswerSaveRequest {
  const factory _MockExamAnswerSaveRequest({
    final String? selectedChoiceKey,
    required final bool isFlagged,
  }) = _$MockExamAnswerSaveRequestImpl;

  factory _MockExamAnswerSaveRequest.fromJson(Map<String, dynamic> json) =
      _$MockExamAnswerSaveRequestImpl.fromJson;

  @override
  String? get selectedChoiceKey;
  @override
  bool get isFlagged;

  /// Create a copy of MockExamAnswerSaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamAnswerSaveRequestImplCopyWith<_$MockExamAnswerSaveRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MockExamAnswerSaveResponse _$MockExamAnswerSaveResponseFromJson(
  Map<String, dynamic> json,
) {
  return _MockExamAnswerSaveResponse.fromJson(json);
}

/// @nodoc
mixin _$MockExamAnswerSaveResponse {
  int get questionNumber => throw _privateConstructorUsedError;
  int get remainingSeconds => throw _privateConstructorUsedError;

  /// Serializes this MockExamAnswerSaveResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MockExamAnswerSaveResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MockExamAnswerSaveResponseCopyWith<MockExamAnswerSaveResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MockExamAnswerSaveResponseCopyWith<$Res> {
  factory $MockExamAnswerSaveResponseCopyWith(
    MockExamAnswerSaveResponse value,
    $Res Function(MockExamAnswerSaveResponse) then,
  ) =
      _$MockExamAnswerSaveResponseCopyWithImpl<
        $Res,
        MockExamAnswerSaveResponse
      >;
  @useResult
  $Res call({int questionNumber, int remainingSeconds});
}

/// @nodoc
class _$MockExamAnswerSaveResponseCopyWithImpl<
  $Res,
  $Val extends MockExamAnswerSaveResponse
>
    implements $MockExamAnswerSaveResponseCopyWith<$Res> {
  _$MockExamAnswerSaveResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MockExamAnswerSaveResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? questionNumber = null, Object? remainingSeconds = null}) {
    return _then(
      _value.copyWith(
            questionNumber: null == questionNumber
                ? _value.questionNumber
                : questionNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            remainingSeconds: null == remainingSeconds
                ? _value.remainingSeconds
                : remainingSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MockExamAnswerSaveResponseImplCopyWith<$Res>
    implements $MockExamAnswerSaveResponseCopyWith<$Res> {
  factory _$$MockExamAnswerSaveResponseImplCopyWith(
    _$MockExamAnswerSaveResponseImpl value,
    $Res Function(_$MockExamAnswerSaveResponseImpl) then,
  ) = __$$MockExamAnswerSaveResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int questionNumber, int remainingSeconds});
}

/// @nodoc
class __$$MockExamAnswerSaveResponseImplCopyWithImpl<$Res>
    extends
        _$MockExamAnswerSaveResponseCopyWithImpl<
          $Res,
          _$MockExamAnswerSaveResponseImpl
        >
    implements _$$MockExamAnswerSaveResponseImplCopyWith<$Res> {
  __$$MockExamAnswerSaveResponseImplCopyWithImpl(
    _$MockExamAnswerSaveResponseImpl _value,
    $Res Function(_$MockExamAnswerSaveResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MockExamAnswerSaveResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? questionNumber = null, Object? remainingSeconds = null}) {
    return _then(
      _$MockExamAnswerSaveResponseImpl(
        questionNumber: null == questionNumber
            ? _value.questionNumber
            : questionNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        remainingSeconds: null == remainingSeconds
            ? _value.remainingSeconds
            : remainingSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MockExamAnswerSaveResponseImpl implements _MockExamAnswerSaveResponse {
  const _$MockExamAnswerSaveResponseImpl({
    required this.questionNumber,
    required this.remainingSeconds,
  });

  factory _$MockExamAnswerSaveResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$MockExamAnswerSaveResponseImplFromJson(json);

  @override
  final int questionNumber;
  @override
  final int remainingSeconds;

  @override
  String toString() {
    return 'MockExamAnswerSaveResponse(questionNumber: $questionNumber, remainingSeconds: $remainingSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamAnswerSaveResponseImpl &&
            (identical(other.questionNumber, questionNumber) ||
                other.questionNumber == questionNumber) &&
            (identical(other.remainingSeconds, remainingSeconds) ||
                other.remainingSeconds == remainingSeconds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, questionNumber, remainingSeconds);

  /// Create a copy of MockExamAnswerSaveResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MockExamAnswerSaveResponseImplCopyWith<_$MockExamAnswerSaveResponseImpl>
  get copyWith =>
      __$$MockExamAnswerSaveResponseImplCopyWithImpl<
        _$MockExamAnswerSaveResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MockExamAnswerSaveResponseImplToJson(this);
  }
}

abstract class _MockExamAnswerSaveResponse
    implements MockExamAnswerSaveResponse {
  const factory _MockExamAnswerSaveResponse({
    required final int questionNumber,
    required final int remainingSeconds,
  }) = _$MockExamAnswerSaveResponseImpl;

  factory _MockExamAnswerSaveResponse.fromJson(Map<String, dynamic> json) =
      _$MockExamAnswerSaveResponseImpl.fromJson;

  @override
  int get questionNumber;
  @override
  int get remainingSeconds;

  /// Create a copy of MockExamAnswerSaveResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamAnswerSaveResponseImplCopyWith<_$MockExamAnswerSaveResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MockExamSubmitRequest _$MockExamSubmitRequestFromJson(
  Map<String, dynamic> json,
) {
  return _MockExamSubmitRequest.fromJson(json);
}

/// @nodoc
mixin _$MockExamSubmitRequest {
  List<MockExamAnswerEntry> get answers => throw _privateConstructorUsedError;

  /// Serializes this MockExamSubmitRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MockExamSubmitRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MockExamSubmitRequestCopyWith<MockExamSubmitRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MockExamSubmitRequestCopyWith<$Res> {
  factory $MockExamSubmitRequestCopyWith(
    MockExamSubmitRequest value,
    $Res Function(MockExamSubmitRequest) then,
  ) = _$MockExamSubmitRequestCopyWithImpl<$Res, MockExamSubmitRequest>;
  @useResult
  $Res call({List<MockExamAnswerEntry> answers});
}

/// @nodoc
class _$MockExamSubmitRequestCopyWithImpl<
  $Res,
  $Val extends MockExamSubmitRequest
>
    implements $MockExamSubmitRequestCopyWith<$Res> {
  _$MockExamSubmitRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MockExamSubmitRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? answers = null}) {
    return _then(
      _value.copyWith(
            answers: null == answers
                ? _value.answers
                : answers // ignore: cast_nullable_to_non_nullable
                      as List<MockExamAnswerEntry>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MockExamSubmitRequestImplCopyWith<$Res>
    implements $MockExamSubmitRequestCopyWith<$Res> {
  factory _$$MockExamSubmitRequestImplCopyWith(
    _$MockExamSubmitRequestImpl value,
    $Res Function(_$MockExamSubmitRequestImpl) then,
  ) = __$$MockExamSubmitRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<MockExamAnswerEntry> answers});
}

/// @nodoc
class __$$MockExamSubmitRequestImplCopyWithImpl<$Res>
    extends
        _$MockExamSubmitRequestCopyWithImpl<$Res, _$MockExamSubmitRequestImpl>
    implements _$$MockExamSubmitRequestImplCopyWith<$Res> {
  __$$MockExamSubmitRequestImplCopyWithImpl(
    _$MockExamSubmitRequestImpl _value,
    $Res Function(_$MockExamSubmitRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MockExamSubmitRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? answers = null}) {
    return _then(
      _$MockExamSubmitRequestImpl(
        answers: null == answers
            ? _value._answers
            : answers // ignore: cast_nullable_to_non_nullable
                  as List<MockExamAnswerEntry>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MockExamSubmitRequestImpl implements _MockExamSubmitRequest {
  const _$MockExamSubmitRequestImpl({
    final List<MockExamAnswerEntry> answers = const [],
  }) : _answers = answers;

  factory _$MockExamSubmitRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$MockExamSubmitRequestImplFromJson(json);

  final List<MockExamAnswerEntry> _answers;
  @override
  @JsonKey()
  List<MockExamAnswerEntry> get answers {
    if (_answers is EqualUnmodifiableListView) return _answers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_answers);
  }

  @override
  String toString() {
    return 'MockExamSubmitRequest(answers: $answers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamSubmitRequestImpl &&
            const DeepCollectionEquality().equals(other._answers, _answers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_answers));

  /// Create a copy of MockExamSubmitRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MockExamSubmitRequestImplCopyWith<_$MockExamSubmitRequestImpl>
  get copyWith =>
      __$$MockExamSubmitRequestImplCopyWithImpl<_$MockExamSubmitRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MockExamSubmitRequestImplToJson(this);
  }
}

abstract class _MockExamSubmitRequest implements MockExamSubmitRequest {
  const factory _MockExamSubmitRequest({
    final List<MockExamAnswerEntry> answers,
  }) = _$MockExamSubmitRequestImpl;

  factory _MockExamSubmitRequest.fromJson(Map<String, dynamic> json) =
      _$MockExamSubmitRequestImpl.fromJson;

  @override
  List<MockExamAnswerEntry> get answers;

  /// Create a copy of MockExamSubmitRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamSubmitRequestImplCopyWith<_$MockExamSubmitRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MockExamAnswerEntry _$MockExamAnswerEntryFromJson(Map<String, dynamic> json) {
  return _MockExamAnswerEntry.fromJson(json);
}

/// @nodoc
mixin _$MockExamAnswerEntry {
  int get questionNumber => throw _privateConstructorUsedError;
  String? get selectedChoiceKey => throw _privateConstructorUsedError;
  bool get isFlagged => throw _privateConstructorUsedError;

  /// Serializes this MockExamAnswerEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MockExamAnswerEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MockExamAnswerEntryCopyWith<MockExamAnswerEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MockExamAnswerEntryCopyWith<$Res> {
  factory $MockExamAnswerEntryCopyWith(
    MockExamAnswerEntry value,
    $Res Function(MockExamAnswerEntry) then,
  ) = _$MockExamAnswerEntryCopyWithImpl<$Res, MockExamAnswerEntry>;
  @useResult
  $Res call({int questionNumber, String? selectedChoiceKey, bool isFlagged});
}

/// @nodoc
class _$MockExamAnswerEntryCopyWithImpl<$Res, $Val extends MockExamAnswerEntry>
    implements $MockExamAnswerEntryCopyWith<$Res> {
  _$MockExamAnswerEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MockExamAnswerEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionNumber = null,
    Object? selectedChoiceKey = freezed,
    Object? isFlagged = null,
  }) {
    return _then(
      _value.copyWith(
            questionNumber: null == questionNumber
                ? _value.questionNumber
                : questionNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            selectedChoiceKey: freezed == selectedChoiceKey
                ? _value.selectedChoiceKey
                : selectedChoiceKey // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$MockExamAnswerEntryImplCopyWith<$Res>
    implements $MockExamAnswerEntryCopyWith<$Res> {
  factory _$$MockExamAnswerEntryImplCopyWith(
    _$MockExamAnswerEntryImpl value,
    $Res Function(_$MockExamAnswerEntryImpl) then,
  ) = __$$MockExamAnswerEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int questionNumber, String? selectedChoiceKey, bool isFlagged});
}

/// @nodoc
class __$$MockExamAnswerEntryImplCopyWithImpl<$Res>
    extends _$MockExamAnswerEntryCopyWithImpl<$Res, _$MockExamAnswerEntryImpl>
    implements _$$MockExamAnswerEntryImplCopyWith<$Res> {
  __$$MockExamAnswerEntryImplCopyWithImpl(
    _$MockExamAnswerEntryImpl _value,
    $Res Function(_$MockExamAnswerEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MockExamAnswerEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionNumber = null,
    Object? selectedChoiceKey = freezed,
    Object? isFlagged = null,
  }) {
    return _then(
      _$MockExamAnswerEntryImpl(
        questionNumber: null == questionNumber
            ? _value.questionNumber
            : questionNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        selectedChoiceKey: freezed == selectedChoiceKey
            ? _value.selectedChoiceKey
            : selectedChoiceKey // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$MockExamAnswerEntryImpl implements _MockExamAnswerEntry {
  const _$MockExamAnswerEntryImpl({
    required this.questionNumber,
    this.selectedChoiceKey,
    this.isFlagged = false,
  });

  factory _$MockExamAnswerEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MockExamAnswerEntryImplFromJson(json);

  @override
  final int questionNumber;
  @override
  final String? selectedChoiceKey;
  @override
  @JsonKey()
  final bool isFlagged;

  @override
  String toString() {
    return 'MockExamAnswerEntry(questionNumber: $questionNumber, selectedChoiceKey: $selectedChoiceKey, isFlagged: $isFlagged)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamAnswerEntryImpl &&
            (identical(other.questionNumber, questionNumber) ||
                other.questionNumber == questionNumber) &&
            (identical(other.selectedChoiceKey, selectedChoiceKey) ||
                other.selectedChoiceKey == selectedChoiceKey) &&
            (identical(other.isFlagged, isFlagged) ||
                other.isFlagged == isFlagged));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, questionNumber, selectedChoiceKey, isFlagged);

  /// Create a copy of MockExamAnswerEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MockExamAnswerEntryImplCopyWith<_$MockExamAnswerEntryImpl> get copyWith =>
      __$$MockExamAnswerEntryImplCopyWithImpl<_$MockExamAnswerEntryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MockExamAnswerEntryImplToJson(this);
  }
}

abstract class _MockExamAnswerEntry implements MockExamAnswerEntry {
  const factory _MockExamAnswerEntry({
    required final int questionNumber,
    final String? selectedChoiceKey,
    final bool isFlagged,
  }) = _$MockExamAnswerEntryImpl;

  factory _MockExamAnswerEntry.fromJson(Map<String, dynamic> json) =
      _$MockExamAnswerEntryImpl.fromJson;

  @override
  int get questionNumber;
  @override
  String? get selectedChoiceKey;
  @override
  bool get isFlagged;

  /// Create a copy of MockExamAnswerEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamAnswerEntryImplCopyWith<_$MockExamAnswerEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
