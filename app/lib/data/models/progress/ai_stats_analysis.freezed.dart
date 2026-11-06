// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_stats_analysis.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AiStatsAnalysis _$AiStatsAnalysisFromJson(Map<String, dynamic> json) {
  return _AiStatsAnalysis.fromJson(json);
}

/// @nodoc
mixin _$AiStatsAnalysis {
  String get headline => throw _privateConstructorUsedError;
  List<AiAnalysisFinding> get findings =>
      throw _privateConstructorUsedError; // 이번 주 정답률 변화 한 줄 (비교할 기록 없으면 null)
  String? get trend => throw _privateConstructorUsedError;
  AiAnalysisStrength? get strength => throw _privateConstructorUsedError;
  List<AiAnalysisAction> get actions => throw _privateConstructorUsedError;

  /// Serializes this AiStatsAnalysis to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiStatsAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiStatsAnalysisCopyWith<AiStatsAnalysis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiStatsAnalysisCopyWith<$Res> {
  factory $AiStatsAnalysisCopyWith(
    AiStatsAnalysis value,
    $Res Function(AiStatsAnalysis) then,
  ) = _$AiStatsAnalysisCopyWithImpl<$Res, AiStatsAnalysis>;
  @useResult
  $Res call({
    String headline,
    List<AiAnalysisFinding> findings,
    String? trend,
    AiAnalysisStrength? strength,
    List<AiAnalysisAction> actions,
  });

  $AiAnalysisStrengthCopyWith<$Res>? get strength;
}

/// @nodoc
class _$AiStatsAnalysisCopyWithImpl<$Res, $Val extends AiStatsAnalysis>
    implements $AiStatsAnalysisCopyWith<$Res> {
  _$AiStatsAnalysisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiStatsAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? headline = null,
    Object? findings = null,
    Object? trend = freezed,
    Object? strength = freezed,
    Object? actions = null,
  }) {
    return _then(
      _value.copyWith(
            headline: null == headline
                ? _value.headline
                : headline // ignore: cast_nullable_to_non_nullable
                      as String,
            findings: null == findings
                ? _value.findings
                : findings // ignore: cast_nullable_to_non_nullable
                      as List<AiAnalysisFinding>,
            trend: freezed == trend
                ? _value.trend
                : trend // ignore: cast_nullable_to_non_nullable
                      as String?,
            strength: freezed == strength
                ? _value.strength
                : strength // ignore: cast_nullable_to_non_nullable
                      as AiAnalysisStrength?,
            actions: null == actions
                ? _value.actions
                : actions // ignore: cast_nullable_to_non_nullable
                      as List<AiAnalysisAction>,
          )
          as $Val,
    );
  }

  /// Create a copy of AiStatsAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AiAnalysisStrengthCopyWith<$Res>? get strength {
    if (_value.strength == null) {
      return null;
    }

    return $AiAnalysisStrengthCopyWith<$Res>(_value.strength!, (value) {
      return _then(_value.copyWith(strength: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AiStatsAnalysisImplCopyWith<$Res>
    implements $AiStatsAnalysisCopyWith<$Res> {
  factory _$$AiStatsAnalysisImplCopyWith(
    _$AiStatsAnalysisImpl value,
    $Res Function(_$AiStatsAnalysisImpl) then,
  ) = __$$AiStatsAnalysisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String headline,
    List<AiAnalysisFinding> findings,
    String? trend,
    AiAnalysisStrength? strength,
    List<AiAnalysisAction> actions,
  });

  @override
  $AiAnalysisStrengthCopyWith<$Res>? get strength;
}

/// @nodoc
class __$$AiStatsAnalysisImplCopyWithImpl<$Res>
    extends _$AiStatsAnalysisCopyWithImpl<$Res, _$AiStatsAnalysisImpl>
    implements _$$AiStatsAnalysisImplCopyWith<$Res> {
  __$$AiStatsAnalysisImplCopyWithImpl(
    _$AiStatsAnalysisImpl _value,
    $Res Function(_$AiStatsAnalysisImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AiStatsAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? headline = null,
    Object? findings = null,
    Object? trend = freezed,
    Object? strength = freezed,
    Object? actions = null,
  }) {
    return _then(
      _$AiStatsAnalysisImpl(
        headline: null == headline
            ? _value.headline
            : headline // ignore: cast_nullable_to_non_nullable
                  as String,
        findings: null == findings
            ? _value._findings
            : findings // ignore: cast_nullable_to_non_nullable
                  as List<AiAnalysisFinding>,
        trend: freezed == trend
            ? _value.trend
            : trend // ignore: cast_nullable_to_non_nullable
                  as String?,
        strength: freezed == strength
            ? _value.strength
            : strength // ignore: cast_nullable_to_non_nullable
                  as AiAnalysisStrength?,
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
class _$AiStatsAnalysisImpl implements _AiStatsAnalysis {
  const _$AiStatsAnalysisImpl({
    this.headline = '',
    final List<AiAnalysisFinding> findings = const [],
    this.trend,
    this.strength,
    final List<AiAnalysisAction> actions = const [],
  }) : _findings = findings,
       _actions = actions;

  factory _$AiStatsAnalysisImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiStatsAnalysisImplFromJson(json);

  @override
  @JsonKey()
  final String headline;
  final List<AiAnalysisFinding> _findings;
  @override
  @JsonKey()
  List<AiAnalysisFinding> get findings {
    if (_findings is EqualUnmodifiableListView) return _findings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_findings);
  }

  // 이번 주 정답률 변화 한 줄 (비교할 기록 없으면 null)
  @override
  final String? trend;
  @override
  final AiAnalysisStrength? strength;
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
    return 'AiStatsAnalysis(headline: $headline, findings: $findings, trend: $trend, strength: $strength, actions: $actions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiStatsAnalysisImpl &&
            (identical(other.headline, headline) ||
                other.headline == headline) &&
            const DeepCollectionEquality().equals(other._findings, _findings) &&
            (identical(other.trend, trend) || other.trend == trend) &&
            (identical(other.strength, strength) ||
                other.strength == strength) &&
            const DeepCollectionEquality().equals(other._actions, _actions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    headline,
    const DeepCollectionEquality().hash(_findings),
    trend,
    strength,
    const DeepCollectionEquality().hash(_actions),
  );

  /// Create a copy of AiStatsAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiStatsAnalysisImplCopyWith<_$AiStatsAnalysisImpl> get copyWith =>
      __$$AiStatsAnalysisImplCopyWithImpl<_$AiStatsAnalysisImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AiStatsAnalysisImplToJson(this);
  }
}

abstract class _AiStatsAnalysis implements AiStatsAnalysis {
  const factory _AiStatsAnalysis({
    final String headline,
    final List<AiAnalysisFinding> findings,
    final String? trend,
    final AiAnalysisStrength? strength,
    final List<AiAnalysisAction> actions,
  }) = _$AiStatsAnalysisImpl;

  factory _AiStatsAnalysis.fromJson(Map<String, dynamic> json) =
      _$AiStatsAnalysisImpl.fromJson;

  @override
  String get headline;
  @override
  List<AiAnalysisFinding> get findings; // 이번 주 정답률 변화 한 줄 (비교할 기록 없으면 null)
  @override
  String? get trend;
  @override
  AiAnalysisStrength? get strength;
  @override
  List<AiAnalysisAction> get actions;

  /// Create a copy of AiStatsAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiStatsAnalysisImplCopyWith<_$AiStatsAnalysisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AiAnalysisFinding _$AiAnalysisFindingFromJson(Map<String, dynamic> json) {
  return _AiAnalysisFinding.fromJson(json);
}

/// @nodoc
mixin _$AiAnalysisFinding {
  String get topicUuid => throw _privateConstructorUsedError; // 서버가 줄인 표시 이름
  String get topicName => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: AiFindingKind.unknown)
  AiFindingKind get kind => throw _privateConstructorUsedError;
  int get solvedCount => throw _privateConstructorUsedError;
  int get correctRatePercent =>
      throw _privateConstructorUsedError; // 숫자 근거 한 줄 (예: 6문제 중 3문제 정답 (50%))
  String get evidence =>
      throw _privateConstructorUsedError; // AI 오답 패턴 한 줄 (LLM 실패·근거 부족이면 null)
  String? get insight => throw _privateConstructorUsedError;

  /// Serializes this AiAnalysisFinding to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiAnalysisFinding
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiAnalysisFindingCopyWith<AiAnalysisFinding> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiAnalysisFindingCopyWith<$Res> {
  factory $AiAnalysisFindingCopyWith(
    AiAnalysisFinding value,
    $Res Function(AiAnalysisFinding) then,
  ) = _$AiAnalysisFindingCopyWithImpl<$Res, AiAnalysisFinding>;
  @useResult
  $Res call({
    String topicUuid,
    String topicName,
    @JsonKey(unknownEnumValue: AiFindingKind.unknown) AiFindingKind kind,
    int solvedCount,
    int correctRatePercent,
    String evidence,
    String? insight,
  });
}

/// @nodoc
class _$AiAnalysisFindingCopyWithImpl<$Res, $Val extends AiAnalysisFinding>
    implements $AiAnalysisFindingCopyWith<$Res> {
  _$AiAnalysisFindingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiAnalysisFinding
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topicUuid = null,
    Object? topicName = null,
    Object? kind = null,
    Object? solvedCount = null,
    Object? correctRatePercent = null,
    Object? evidence = null,
    Object? insight = freezed,
  }) {
    return _then(
      _value.copyWith(
            topicUuid: null == topicUuid
                ? _value.topicUuid
                : topicUuid // ignore: cast_nullable_to_non_nullable
                      as String,
            topicName: null == topicName
                ? _value.topicName
                : topicName // ignore: cast_nullable_to_non_nullable
                      as String,
            kind: null == kind
                ? _value.kind
                : kind // ignore: cast_nullable_to_non_nullable
                      as AiFindingKind,
            solvedCount: null == solvedCount
                ? _value.solvedCount
                : solvedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            correctRatePercent: null == correctRatePercent
                ? _value.correctRatePercent
                : correctRatePercent // ignore: cast_nullable_to_non_nullable
                      as int,
            evidence: null == evidence
                ? _value.evidence
                : evidence // ignore: cast_nullable_to_non_nullable
                      as String,
            insight: freezed == insight
                ? _value.insight
                : insight // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AiAnalysisFindingImplCopyWith<$Res>
    implements $AiAnalysisFindingCopyWith<$Res> {
  factory _$$AiAnalysisFindingImplCopyWith(
    _$AiAnalysisFindingImpl value,
    $Res Function(_$AiAnalysisFindingImpl) then,
  ) = __$$AiAnalysisFindingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String topicUuid,
    String topicName,
    @JsonKey(unknownEnumValue: AiFindingKind.unknown) AiFindingKind kind,
    int solvedCount,
    int correctRatePercent,
    String evidence,
    String? insight,
  });
}

/// @nodoc
class __$$AiAnalysisFindingImplCopyWithImpl<$Res>
    extends _$AiAnalysisFindingCopyWithImpl<$Res, _$AiAnalysisFindingImpl>
    implements _$$AiAnalysisFindingImplCopyWith<$Res> {
  __$$AiAnalysisFindingImplCopyWithImpl(
    _$AiAnalysisFindingImpl _value,
    $Res Function(_$AiAnalysisFindingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AiAnalysisFinding
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topicUuid = null,
    Object? topicName = null,
    Object? kind = null,
    Object? solvedCount = null,
    Object? correctRatePercent = null,
    Object? evidence = null,
    Object? insight = freezed,
  }) {
    return _then(
      _$AiAnalysisFindingImpl(
        topicUuid: null == topicUuid
            ? _value.topicUuid
            : topicUuid // ignore: cast_nullable_to_non_nullable
                  as String,
        topicName: null == topicName
            ? _value.topicName
            : topicName // ignore: cast_nullable_to_non_nullable
                  as String,
        kind: null == kind
            ? _value.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as AiFindingKind,
        solvedCount: null == solvedCount
            ? _value.solvedCount
            : solvedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        correctRatePercent: null == correctRatePercent
            ? _value.correctRatePercent
            : correctRatePercent // ignore: cast_nullable_to_non_nullable
                  as int,
        evidence: null == evidence
            ? _value.evidence
            : evidence // ignore: cast_nullable_to_non_nullable
                  as String,
        insight: freezed == insight
            ? _value.insight
            : insight // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AiAnalysisFindingImpl implements _AiAnalysisFinding {
  const _$AiAnalysisFindingImpl({
    this.topicUuid = '',
    this.topicName = '',
    @JsonKey(unknownEnumValue: AiFindingKind.unknown)
    this.kind = AiFindingKind.unknown,
    this.solvedCount = 0,
    this.correctRatePercent = 0,
    this.evidence = '',
    this.insight,
  });

  factory _$AiAnalysisFindingImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiAnalysisFindingImplFromJson(json);

  @override
  @JsonKey()
  final String topicUuid;
  // 서버가 줄인 표시 이름
  @override
  @JsonKey()
  final String topicName;
  @override
  @JsonKey(unknownEnumValue: AiFindingKind.unknown)
  final AiFindingKind kind;
  @override
  @JsonKey()
  final int solvedCount;
  @override
  @JsonKey()
  final int correctRatePercent;
  // 숫자 근거 한 줄 (예: 6문제 중 3문제 정답 (50%))
  @override
  @JsonKey()
  final String evidence;
  // AI 오답 패턴 한 줄 (LLM 실패·근거 부족이면 null)
  @override
  final String? insight;

  @override
  String toString() {
    return 'AiAnalysisFinding(topicUuid: $topicUuid, topicName: $topicName, kind: $kind, solvedCount: $solvedCount, correctRatePercent: $correctRatePercent, evidence: $evidence, insight: $insight)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiAnalysisFindingImpl &&
            (identical(other.topicUuid, topicUuid) ||
                other.topicUuid == topicUuid) &&
            (identical(other.topicName, topicName) ||
                other.topicName == topicName) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.solvedCount, solvedCount) ||
                other.solvedCount == solvedCount) &&
            (identical(other.correctRatePercent, correctRatePercent) ||
                other.correctRatePercent == correctRatePercent) &&
            (identical(other.evidence, evidence) ||
                other.evidence == evidence) &&
            (identical(other.insight, insight) || other.insight == insight));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    topicUuid,
    topicName,
    kind,
    solvedCount,
    correctRatePercent,
    evidence,
    insight,
  );

  /// Create a copy of AiAnalysisFinding
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiAnalysisFindingImplCopyWith<_$AiAnalysisFindingImpl> get copyWith =>
      __$$AiAnalysisFindingImplCopyWithImpl<_$AiAnalysisFindingImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AiAnalysisFindingImplToJson(this);
  }
}

abstract class _AiAnalysisFinding implements AiAnalysisFinding {
  const factory _AiAnalysisFinding({
    final String topicUuid,
    final String topicName,
    @JsonKey(unknownEnumValue: AiFindingKind.unknown) final AiFindingKind kind,
    final int solvedCount,
    final int correctRatePercent,
    final String evidence,
    final String? insight,
  }) = _$AiAnalysisFindingImpl;

  factory _AiAnalysisFinding.fromJson(Map<String, dynamic> json) =
      _$AiAnalysisFindingImpl.fromJson;

  @override
  String get topicUuid; // 서버가 줄인 표시 이름
  @override
  String get topicName;
  @override
  @JsonKey(unknownEnumValue: AiFindingKind.unknown)
  AiFindingKind get kind;
  @override
  int get solvedCount;
  @override
  int get correctRatePercent; // 숫자 근거 한 줄 (예: 6문제 중 3문제 정답 (50%))
  @override
  String get evidence; // AI 오답 패턴 한 줄 (LLM 실패·근거 부족이면 null)
  @override
  String? get insight;

  /// Create a copy of AiAnalysisFinding
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiAnalysisFindingImplCopyWith<_$AiAnalysisFindingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AiAnalysisStrength _$AiAnalysisStrengthFromJson(Map<String, dynamic> json) {
  return _AiAnalysisStrength.fromJson(json);
}

/// @nodoc
mixin _$AiAnalysisStrength {
  String get topicUuid => throw _privateConstructorUsedError;
  String get topicName => throw _privateConstructorUsedError;
  int get correctRatePercent => throw _privateConstructorUsedError;

  /// Serializes this AiAnalysisStrength to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiAnalysisStrength
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiAnalysisStrengthCopyWith<AiAnalysisStrength> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiAnalysisStrengthCopyWith<$Res> {
  factory $AiAnalysisStrengthCopyWith(
    AiAnalysisStrength value,
    $Res Function(AiAnalysisStrength) then,
  ) = _$AiAnalysisStrengthCopyWithImpl<$Res, AiAnalysisStrength>;
  @useResult
  $Res call({String topicUuid, String topicName, int correctRatePercent});
}

/// @nodoc
class _$AiAnalysisStrengthCopyWithImpl<$Res, $Val extends AiAnalysisStrength>
    implements $AiAnalysisStrengthCopyWith<$Res> {
  _$AiAnalysisStrengthCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiAnalysisStrength
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topicUuid = null,
    Object? topicName = null,
    Object? correctRatePercent = null,
  }) {
    return _then(
      _value.copyWith(
            topicUuid: null == topicUuid
                ? _value.topicUuid
                : topicUuid // ignore: cast_nullable_to_non_nullable
                      as String,
            topicName: null == topicName
                ? _value.topicName
                : topicName // ignore: cast_nullable_to_non_nullable
                      as String,
            correctRatePercent: null == correctRatePercent
                ? _value.correctRatePercent
                : correctRatePercent // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AiAnalysisStrengthImplCopyWith<$Res>
    implements $AiAnalysisStrengthCopyWith<$Res> {
  factory _$$AiAnalysisStrengthImplCopyWith(
    _$AiAnalysisStrengthImpl value,
    $Res Function(_$AiAnalysisStrengthImpl) then,
  ) = __$$AiAnalysisStrengthImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String topicUuid, String topicName, int correctRatePercent});
}

/// @nodoc
class __$$AiAnalysisStrengthImplCopyWithImpl<$Res>
    extends _$AiAnalysisStrengthCopyWithImpl<$Res, _$AiAnalysisStrengthImpl>
    implements _$$AiAnalysisStrengthImplCopyWith<$Res> {
  __$$AiAnalysisStrengthImplCopyWithImpl(
    _$AiAnalysisStrengthImpl _value,
    $Res Function(_$AiAnalysisStrengthImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AiAnalysisStrength
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topicUuid = null,
    Object? topicName = null,
    Object? correctRatePercent = null,
  }) {
    return _then(
      _$AiAnalysisStrengthImpl(
        topicUuid: null == topicUuid
            ? _value.topicUuid
            : topicUuid // ignore: cast_nullable_to_non_nullable
                  as String,
        topicName: null == topicName
            ? _value.topicName
            : topicName // ignore: cast_nullable_to_non_nullable
                  as String,
        correctRatePercent: null == correctRatePercent
            ? _value.correctRatePercent
            : correctRatePercent // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AiAnalysisStrengthImpl implements _AiAnalysisStrength {
  const _$AiAnalysisStrengthImpl({
    this.topicUuid = '',
    this.topicName = '',
    this.correctRatePercent = 0,
  });

  factory _$AiAnalysisStrengthImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiAnalysisStrengthImplFromJson(json);

  @override
  @JsonKey()
  final String topicUuid;
  @override
  @JsonKey()
  final String topicName;
  @override
  @JsonKey()
  final int correctRatePercent;

  @override
  String toString() {
    return 'AiAnalysisStrength(topicUuid: $topicUuid, topicName: $topicName, correctRatePercent: $correctRatePercent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiAnalysisStrengthImpl &&
            (identical(other.topicUuid, topicUuid) ||
                other.topicUuid == topicUuid) &&
            (identical(other.topicName, topicName) ||
                other.topicName == topicName) &&
            (identical(other.correctRatePercent, correctRatePercent) ||
                other.correctRatePercent == correctRatePercent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, topicUuid, topicName, correctRatePercent);

  /// Create a copy of AiAnalysisStrength
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiAnalysisStrengthImplCopyWith<_$AiAnalysisStrengthImpl> get copyWith =>
      __$$AiAnalysisStrengthImplCopyWithImpl<_$AiAnalysisStrengthImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AiAnalysisStrengthImplToJson(this);
  }
}

abstract class _AiAnalysisStrength implements AiAnalysisStrength {
  const factory _AiAnalysisStrength({
    final String topicUuid,
    final String topicName,
    final int correctRatePercent,
  }) = _$AiAnalysisStrengthImpl;

  factory _AiAnalysisStrength.fromJson(Map<String, dynamic> json) =
      _$AiAnalysisStrengthImpl.fromJson;

  @override
  String get topicUuid;
  @override
  String get topicName;
  @override
  int get correctRatePercent;

  /// Create a copy of AiAnalysisStrength
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiAnalysisStrengthImplCopyWith<_$AiAnalysisStrengthImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AiAnalysisAction _$AiAnalysisActionFromJson(Map<String, dynamic> json) {
  return _AiAnalysisAction.fromJson(json);
}

/// @nodoc
mixin _$AiAnalysisAction {
  @JsonKey(unknownEnumValue: AiAnalysisActionType.unknown)
  AiAnalysisActionType get type => throw _privateConstructorUsedError;
  String? get topicUuid => throw _privateConstructorUsedError;
  String? get topicName =>
      throw _privateConstructorUsedError; // 문구용 문제 수 (화면 이동에는 안 씀)
  int get count => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;

  /// Serializes this AiAnalysisAction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiAnalysisAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiAnalysisActionCopyWith<AiAnalysisAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiAnalysisActionCopyWith<$Res> {
  factory $AiAnalysisActionCopyWith(
    AiAnalysisAction value,
    $Res Function(AiAnalysisAction) then,
  ) = _$AiAnalysisActionCopyWithImpl<$Res, AiAnalysisAction>;
  @useResult
  $Res call({
    @JsonKey(unknownEnumValue: AiAnalysisActionType.unknown)
    AiAnalysisActionType type,
    String? topicUuid,
    String? topicName,
    int count,
    String label,
  });
}

/// @nodoc
class _$AiAnalysisActionCopyWithImpl<$Res, $Val extends AiAnalysisAction>
    implements $AiAnalysisActionCopyWith<$Res> {
  _$AiAnalysisActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiAnalysisAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? topicUuid = freezed,
    Object? topicName = freezed,
    Object? count = null,
    Object? label = null,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as AiAnalysisActionType,
            topicUuid: freezed == topicUuid
                ? _value.topicUuid
                : topicUuid // ignore: cast_nullable_to_non_nullable
                      as String?,
            topicName: freezed == topicName
                ? _value.topicName
                : topicName // ignore: cast_nullable_to_non_nullable
                      as String?,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AiAnalysisActionImplCopyWith<$Res>
    implements $AiAnalysisActionCopyWith<$Res> {
  factory _$$AiAnalysisActionImplCopyWith(
    _$AiAnalysisActionImpl value,
    $Res Function(_$AiAnalysisActionImpl) then,
  ) = __$$AiAnalysisActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(unknownEnumValue: AiAnalysisActionType.unknown)
    AiAnalysisActionType type,
    String? topicUuid,
    String? topicName,
    int count,
    String label,
  });
}

/// @nodoc
class __$$AiAnalysisActionImplCopyWithImpl<$Res>
    extends _$AiAnalysisActionCopyWithImpl<$Res, _$AiAnalysisActionImpl>
    implements _$$AiAnalysisActionImplCopyWith<$Res> {
  __$$AiAnalysisActionImplCopyWithImpl(
    _$AiAnalysisActionImpl _value,
    $Res Function(_$AiAnalysisActionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AiAnalysisAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? topicUuid = freezed,
    Object? topicName = freezed,
    Object? count = null,
    Object? label = null,
  }) {
    return _then(
      _$AiAnalysisActionImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as AiAnalysisActionType,
        topicUuid: freezed == topicUuid
            ? _value.topicUuid
            : topicUuid // ignore: cast_nullable_to_non_nullable
                  as String?,
        topicName: freezed == topicName
            ? _value.topicName
            : topicName // ignore: cast_nullable_to_non_nullable
                  as String?,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AiAnalysisActionImpl implements _AiAnalysisAction {
  const _$AiAnalysisActionImpl({
    @JsonKey(unknownEnumValue: AiAnalysisActionType.unknown)
    this.type = AiAnalysisActionType.unknown,
    this.topicUuid,
    this.topicName,
    this.count = 0,
    this.label = '',
  });

  factory _$AiAnalysisActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiAnalysisActionImplFromJson(json);

  @override
  @JsonKey(unknownEnumValue: AiAnalysisActionType.unknown)
  final AiAnalysisActionType type;
  @override
  final String? topicUuid;
  @override
  final String? topicName;
  // 문구용 문제 수 (화면 이동에는 안 씀)
  @override
  @JsonKey()
  final int count;
  @override
  @JsonKey()
  final String label;

  @override
  String toString() {
    return 'AiAnalysisAction(type: $type, topicUuid: $topicUuid, topicName: $topicName, count: $count, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiAnalysisActionImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.topicUuid, topicUuid) ||
                other.topicUuid == topicUuid) &&
            (identical(other.topicName, topicName) ||
                other.topicName == topicName) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.label, label) || other.label == label));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, topicUuid, topicName, count, label);

  /// Create a copy of AiAnalysisAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiAnalysisActionImplCopyWith<_$AiAnalysisActionImpl> get copyWith =>
      __$$AiAnalysisActionImplCopyWithImpl<_$AiAnalysisActionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AiAnalysisActionImplToJson(this);
  }
}

abstract class _AiAnalysisAction implements AiAnalysisAction {
  const factory _AiAnalysisAction({
    @JsonKey(unknownEnumValue: AiAnalysisActionType.unknown)
    final AiAnalysisActionType type,
    final String? topicUuid,
    final String? topicName,
    final int count,
    final String label,
  }) = _$AiAnalysisActionImpl;

  factory _AiAnalysisAction.fromJson(Map<String, dynamic> json) =
      _$AiAnalysisActionImpl.fromJson;

  @override
  @JsonKey(unknownEnumValue: AiAnalysisActionType.unknown)
  AiAnalysisActionType get type;
  @override
  String? get topicUuid;
  @override
  String? get topicName; // 문구용 문제 수 (화면 이동에는 안 씀)
  @override
  int get count;
  @override
  String get label;

  /// Create a copy of AiAnalysisAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiAnalysisActionImplCopyWith<_$AiAnalysisActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
