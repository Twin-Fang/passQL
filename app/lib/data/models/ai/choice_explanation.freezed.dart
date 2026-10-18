// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'choice_explanation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChoiceExplanation _$ChoiceExplanationFromJson(Map<String, dynamic> json) {
  return _ChoiceExplanation.fromJson(json);
}

/// @nodoc
mixin _$ChoiceExplanation {
  String get selectedChoiceKey => throw _privateConstructorUsedError;
  String get correctChoiceKey => throw _privateConstructorUsedError;
  bool get isSelectedCorrect =>
      throw _privateConstructorUsedError; // 서버가 choiceKey 로 조립한 판정. 화면은 표시 라벨(#512)로 다시 조립해서 씀
  String get verdict => throw _privateConstructorUsedError;
  String get correctReason => throw _privateConstructorUsedError;
  List<KeyConcept> get keyConcepts => throw _privateConstructorUsedError;
  List<String> get confusingPoints => throw _privateConstructorUsedError;
  List<ChoiceAnalysis> get choiceAnalyses => throw _privateConstructorUsedError;
  String get examTip => throw _privateConstructorUsedError;

  /// Serializes this ChoiceExplanation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChoiceExplanation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChoiceExplanationCopyWith<ChoiceExplanation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChoiceExplanationCopyWith<$Res> {
  factory $ChoiceExplanationCopyWith(
    ChoiceExplanation value,
    $Res Function(ChoiceExplanation) then,
  ) = _$ChoiceExplanationCopyWithImpl<$Res, ChoiceExplanation>;
  @useResult
  $Res call({
    String selectedChoiceKey,
    String correctChoiceKey,
    bool isSelectedCorrect,
    String verdict,
    String correctReason,
    List<KeyConcept> keyConcepts,
    List<String> confusingPoints,
    List<ChoiceAnalysis> choiceAnalyses,
    String examTip,
  });
}

/// @nodoc
class _$ChoiceExplanationCopyWithImpl<$Res, $Val extends ChoiceExplanation>
    implements $ChoiceExplanationCopyWith<$Res> {
  _$ChoiceExplanationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChoiceExplanation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedChoiceKey = null,
    Object? correctChoiceKey = null,
    Object? isSelectedCorrect = null,
    Object? verdict = null,
    Object? correctReason = null,
    Object? keyConcepts = null,
    Object? confusingPoints = null,
    Object? choiceAnalyses = null,
    Object? examTip = null,
  }) {
    return _then(
      _value.copyWith(
            selectedChoiceKey: null == selectedChoiceKey
                ? _value.selectedChoiceKey
                : selectedChoiceKey // ignore: cast_nullable_to_non_nullable
                      as String,
            correctChoiceKey: null == correctChoiceKey
                ? _value.correctChoiceKey
                : correctChoiceKey // ignore: cast_nullable_to_non_nullable
                      as String,
            isSelectedCorrect: null == isSelectedCorrect
                ? _value.isSelectedCorrect
                : isSelectedCorrect // ignore: cast_nullable_to_non_nullable
                      as bool,
            verdict: null == verdict
                ? _value.verdict
                : verdict // ignore: cast_nullable_to_non_nullable
                      as String,
            correctReason: null == correctReason
                ? _value.correctReason
                : correctReason // ignore: cast_nullable_to_non_nullable
                      as String,
            keyConcepts: null == keyConcepts
                ? _value.keyConcepts
                : keyConcepts // ignore: cast_nullable_to_non_nullable
                      as List<KeyConcept>,
            confusingPoints: null == confusingPoints
                ? _value.confusingPoints
                : confusingPoints // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            choiceAnalyses: null == choiceAnalyses
                ? _value.choiceAnalyses
                : choiceAnalyses // ignore: cast_nullable_to_non_nullable
                      as List<ChoiceAnalysis>,
            examTip: null == examTip
                ? _value.examTip
                : examTip // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChoiceExplanationImplCopyWith<$Res>
    implements $ChoiceExplanationCopyWith<$Res> {
  factory _$$ChoiceExplanationImplCopyWith(
    _$ChoiceExplanationImpl value,
    $Res Function(_$ChoiceExplanationImpl) then,
  ) = __$$ChoiceExplanationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String selectedChoiceKey,
    String correctChoiceKey,
    bool isSelectedCorrect,
    String verdict,
    String correctReason,
    List<KeyConcept> keyConcepts,
    List<String> confusingPoints,
    List<ChoiceAnalysis> choiceAnalyses,
    String examTip,
  });
}

/// @nodoc
class __$$ChoiceExplanationImplCopyWithImpl<$Res>
    extends _$ChoiceExplanationCopyWithImpl<$Res, _$ChoiceExplanationImpl>
    implements _$$ChoiceExplanationImplCopyWith<$Res> {
  __$$ChoiceExplanationImplCopyWithImpl(
    _$ChoiceExplanationImpl _value,
    $Res Function(_$ChoiceExplanationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChoiceExplanation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedChoiceKey = null,
    Object? correctChoiceKey = null,
    Object? isSelectedCorrect = null,
    Object? verdict = null,
    Object? correctReason = null,
    Object? keyConcepts = null,
    Object? confusingPoints = null,
    Object? choiceAnalyses = null,
    Object? examTip = null,
  }) {
    return _then(
      _$ChoiceExplanationImpl(
        selectedChoiceKey: null == selectedChoiceKey
            ? _value.selectedChoiceKey
            : selectedChoiceKey // ignore: cast_nullable_to_non_nullable
                  as String,
        correctChoiceKey: null == correctChoiceKey
            ? _value.correctChoiceKey
            : correctChoiceKey // ignore: cast_nullable_to_non_nullable
                  as String,
        isSelectedCorrect: null == isSelectedCorrect
            ? _value.isSelectedCorrect
            : isSelectedCorrect // ignore: cast_nullable_to_non_nullable
                  as bool,
        verdict: null == verdict
            ? _value.verdict
            : verdict // ignore: cast_nullable_to_non_nullable
                  as String,
        correctReason: null == correctReason
            ? _value.correctReason
            : correctReason // ignore: cast_nullable_to_non_nullable
                  as String,
        keyConcepts: null == keyConcepts
            ? _value._keyConcepts
            : keyConcepts // ignore: cast_nullable_to_non_nullable
                  as List<KeyConcept>,
        confusingPoints: null == confusingPoints
            ? _value._confusingPoints
            : confusingPoints // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        choiceAnalyses: null == choiceAnalyses
            ? _value._choiceAnalyses
            : choiceAnalyses // ignore: cast_nullable_to_non_nullable
                  as List<ChoiceAnalysis>,
        examTip: null == examTip
            ? _value.examTip
            : examTip // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChoiceExplanationImpl implements _ChoiceExplanation {
  const _$ChoiceExplanationImpl({
    this.selectedChoiceKey = '',
    this.correctChoiceKey = '',
    this.isSelectedCorrect = false,
    this.verdict = '',
    this.correctReason = '',
    final List<KeyConcept> keyConcepts = const [],
    final List<String> confusingPoints = const [],
    final List<ChoiceAnalysis> choiceAnalyses = const [],
    this.examTip = '',
  }) : _keyConcepts = keyConcepts,
       _confusingPoints = confusingPoints,
       _choiceAnalyses = choiceAnalyses;

  factory _$ChoiceExplanationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChoiceExplanationImplFromJson(json);

  @override
  @JsonKey()
  final String selectedChoiceKey;
  @override
  @JsonKey()
  final String correctChoiceKey;
  @override
  @JsonKey()
  final bool isSelectedCorrect;
  // 서버가 choiceKey 로 조립한 판정. 화면은 표시 라벨(#512)로 다시 조립해서 씀
  @override
  @JsonKey()
  final String verdict;
  @override
  @JsonKey()
  final String correctReason;
  final List<KeyConcept> _keyConcepts;
  @override
  @JsonKey()
  List<KeyConcept> get keyConcepts {
    if (_keyConcepts is EqualUnmodifiableListView) return _keyConcepts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keyConcepts);
  }

  final List<String> _confusingPoints;
  @override
  @JsonKey()
  List<String> get confusingPoints {
    if (_confusingPoints is EqualUnmodifiableListView) return _confusingPoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_confusingPoints);
  }

  final List<ChoiceAnalysis> _choiceAnalyses;
  @override
  @JsonKey()
  List<ChoiceAnalysis> get choiceAnalyses {
    if (_choiceAnalyses is EqualUnmodifiableListView) return _choiceAnalyses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_choiceAnalyses);
  }

  @override
  @JsonKey()
  final String examTip;

  @override
  String toString() {
    return 'ChoiceExplanation(selectedChoiceKey: $selectedChoiceKey, correctChoiceKey: $correctChoiceKey, isSelectedCorrect: $isSelectedCorrect, verdict: $verdict, correctReason: $correctReason, keyConcepts: $keyConcepts, confusingPoints: $confusingPoints, choiceAnalyses: $choiceAnalyses, examTip: $examTip)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChoiceExplanationImpl &&
            (identical(other.selectedChoiceKey, selectedChoiceKey) ||
                other.selectedChoiceKey == selectedChoiceKey) &&
            (identical(other.correctChoiceKey, correctChoiceKey) ||
                other.correctChoiceKey == correctChoiceKey) &&
            (identical(other.isSelectedCorrect, isSelectedCorrect) ||
                other.isSelectedCorrect == isSelectedCorrect) &&
            (identical(other.verdict, verdict) || other.verdict == verdict) &&
            (identical(other.correctReason, correctReason) ||
                other.correctReason == correctReason) &&
            const DeepCollectionEquality().equals(
              other._keyConcepts,
              _keyConcepts,
            ) &&
            const DeepCollectionEquality().equals(
              other._confusingPoints,
              _confusingPoints,
            ) &&
            const DeepCollectionEquality().equals(
              other._choiceAnalyses,
              _choiceAnalyses,
            ) &&
            (identical(other.examTip, examTip) || other.examTip == examTip));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    selectedChoiceKey,
    correctChoiceKey,
    isSelectedCorrect,
    verdict,
    correctReason,
    const DeepCollectionEquality().hash(_keyConcepts),
    const DeepCollectionEquality().hash(_confusingPoints),
    const DeepCollectionEquality().hash(_choiceAnalyses),
    examTip,
  );

  /// Create a copy of ChoiceExplanation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChoiceExplanationImplCopyWith<_$ChoiceExplanationImpl> get copyWith =>
      __$$ChoiceExplanationImplCopyWithImpl<_$ChoiceExplanationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChoiceExplanationImplToJson(this);
  }
}

abstract class _ChoiceExplanation implements ChoiceExplanation {
  const factory _ChoiceExplanation({
    final String selectedChoiceKey,
    final String correctChoiceKey,
    final bool isSelectedCorrect,
    final String verdict,
    final String correctReason,
    final List<KeyConcept> keyConcepts,
    final List<String> confusingPoints,
    final List<ChoiceAnalysis> choiceAnalyses,
    final String examTip,
  }) = _$ChoiceExplanationImpl;

  factory _ChoiceExplanation.fromJson(Map<String, dynamic> json) =
      _$ChoiceExplanationImpl.fromJson;

  @override
  String get selectedChoiceKey;
  @override
  String get correctChoiceKey;
  @override
  bool get isSelectedCorrect; // 서버가 choiceKey 로 조립한 판정. 화면은 표시 라벨(#512)로 다시 조립해서 씀
  @override
  String get verdict;
  @override
  String get correctReason;
  @override
  List<KeyConcept> get keyConcepts;
  @override
  List<String> get confusingPoints;
  @override
  List<ChoiceAnalysis> get choiceAnalyses;
  @override
  String get examTip;

  /// Create a copy of ChoiceExplanation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChoiceExplanationImplCopyWith<_$ChoiceExplanationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

KeyConcept _$KeyConceptFromJson(Map<String, dynamic> json) {
  return _KeyConcept.fromJson(json);
}

/// @nodoc
mixin _$KeyConcept {
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  /// Serializes this KeyConcept to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KeyConcept
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KeyConceptCopyWith<KeyConcept> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KeyConceptCopyWith<$Res> {
  factory $KeyConceptCopyWith(
    KeyConcept value,
    $Res Function(KeyConcept) then,
  ) = _$KeyConceptCopyWithImpl<$Res, KeyConcept>;
  @useResult
  $Res call({String name, String description});
}

/// @nodoc
class _$KeyConceptCopyWithImpl<$Res, $Val extends KeyConcept>
    implements $KeyConceptCopyWith<$Res> {
  _$KeyConceptCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KeyConcept
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? description = null}) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$KeyConceptImplCopyWith<$Res>
    implements $KeyConceptCopyWith<$Res> {
  factory _$$KeyConceptImplCopyWith(
    _$KeyConceptImpl value,
    $Res Function(_$KeyConceptImpl) then,
  ) = __$$KeyConceptImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String description});
}

/// @nodoc
class __$$KeyConceptImplCopyWithImpl<$Res>
    extends _$KeyConceptCopyWithImpl<$Res, _$KeyConceptImpl>
    implements _$$KeyConceptImplCopyWith<$Res> {
  __$$KeyConceptImplCopyWithImpl(
    _$KeyConceptImpl _value,
    $Res Function(_$KeyConceptImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of KeyConcept
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? description = null}) {
    return _then(
      _$KeyConceptImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$KeyConceptImpl implements _KeyConcept {
  const _$KeyConceptImpl({this.name = '', this.description = ''});

  factory _$KeyConceptImpl.fromJson(Map<String, dynamic> json) =>
      _$$KeyConceptImplFromJson(json);

  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final String description;

  @override
  String toString() {
    return 'KeyConcept(name: $name, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KeyConceptImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, description);

  /// Create a copy of KeyConcept
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KeyConceptImplCopyWith<_$KeyConceptImpl> get copyWith =>
      __$$KeyConceptImplCopyWithImpl<_$KeyConceptImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$KeyConceptImplToJson(this);
  }
}

abstract class _KeyConcept implements KeyConcept {
  const factory _KeyConcept({final String name, final String description}) =
      _$KeyConceptImpl;

  factory _KeyConcept.fromJson(Map<String, dynamic> json) =
      _$KeyConceptImpl.fromJson;

  @override
  String get name;
  @override
  String get description;

  /// Create a copy of KeyConcept
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KeyConceptImplCopyWith<_$KeyConceptImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChoiceAnalysis _$ChoiceAnalysisFromJson(Map<String, dynamic> json) {
  return _ChoiceAnalysis.fromJson(json);
}

/// @nodoc
mixin _$ChoiceAnalysis {
  String get choiceKey => throw _privateConstructorUsedError;
  bool get isCorrect => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;

  /// Serializes this ChoiceAnalysis to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChoiceAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChoiceAnalysisCopyWith<ChoiceAnalysis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChoiceAnalysisCopyWith<$Res> {
  factory $ChoiceAnalysisCopyWith(
    ChoiceAnalysis value,
    $Res Function(ChoiceAnalysis) then,
  ) = _$ChoiceAnalysisCopyWithImpl<$Res, ChoiceAnalysis>;
  @useResult
  $Res call({String choiceKey, bool isCorrect, String reason});
}

/// @nodoc
class _$ChoiceAnalysisCopyWithImpl<$Res, $Val extends ChoiceAnalysis>
    implements $ChoiceAnalysisCopyWith<$Res> {
  _$ChoiceAnalysisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChoiceAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? choiceKey = null,
    Object? isCorrect = null,
    Object? reason = null,
  }) {
    return _then(
      _value.copyWith(
            choiceKey: null == choiceKey
                ? _value.choiceKey
                : choiceKey // ignore: cast_nullable_to_non_nullable
                      as String,
            isCorrect: null == isCorrect
                ? _value.isCorrect
                : isCorrect // ignore: cast_nullable_to_non_nullable
                      as bool,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChoiceAnalysisImplCopyWith<$Res>
    implements $ChoiceAnalysisCopyWith<$Res> {
  factory _$$ChoiceAnalysisImplCopyWith(
    _$ChoiceAnalysisImpl value,
    $Res Function(_$ChoiceAnalysisImpl) then,
  ) = __$$ChoiceAnalysisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String choiceKey, bool isCorrect, String reason});
}

/// @nodoc
class __$$ChoiceAnalysisImplCopyWithImpl<$Res>
    extends _$ChoiceAnalysisCopyWithImpl<$Res, _$ChoiceAnalysisImpl>
    implements _$$ChoiceAnalysisImplCopyWith<$Res> {
  __$$ChoiceAnalysisImplCopyWithImpl(
    _$ChoiceAnalysisImpl _value,
    $Res Function(_$ChoiceAnalysisImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChoiceAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? choiceKey = null,
    Object? isCorrect = null,
    Object? reason = null,
  }) {
    return _then(
      _$ChoiceAnalysisImpl(
        choiceKey: null == choiceKey
            ? _value.choiceKey
            : choiceKey // ignore: cast_nullable_to_non_nullable
                  as String,
        isCorrect: null == isCorrect
            ? _value.isCorrect
            : isCorrect // ignore: cast_nullable_to_non_nullable
                  as bool,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChoiceAnalysisImpl implements _ChoiceAnalysis {
  const _$ChoiceAnalysisImpl({
    this.choiceKey = '',
    this.isCorrect = false,
    this.reason = '',
  });

  factory _$ChoiceAnalysisImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChoiceAnalysisImplFromJson(json);

  @override
  @JsonKey()
  final String choiceKey;
  @override
  @JsonKey()
  final bool isCorrect;
  @override
  @JsonKey()
  final String reason;

  @override
  String toString() {
    return 'ChoiceAnalysis(choiceKey: $choiceKey, isCorrect: $isCorrect, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChoiceAnalysisImpl &&
            (identical(other.choiceKey, choiceKey) ||
                other.choiceKey == choiceKey) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, choiceKey, isCorrect, reason);

  /// Create a copy of ChoiceAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChoiceAnalysisImplCopyWith<_$ChoiceAnalysisImpl> get copyWith =>
      __$$ChoiceAnalysisImplCopyWithImpl<_$ChoiceAnalysisImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChoiceAnalysisImplToJson(this);
  }
}

abstract class _ChoiceAnalysis implements ChoiceAnalysis {
  const factory _ChoiceAnalysis({
    final String choiceKey,
    final bool isCorrect,
    final String reason,
  }) = _$ChoiceAnalysisImpl;

  factory _ChoiceAnalysis.fromJson(Map<String, dynamic> json) =
      _$ChoiceAnalysisImpl.fromJson;

  @override
  String get choiceKey;
  @override
  bool get isCorrect;
  @override
  String get reason;

  /// Create a copy of ChoiceAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChoiceAnalysisImplCopyWith<_$ChoiceAnalysisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
