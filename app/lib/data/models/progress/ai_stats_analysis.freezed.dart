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
  List<AiAnalysisAction> get actions =>
      throw _privateConstructorUsedError; // 판정 기간 표기 (예: 최근 90일 기준, 옛 서버면 빈 값)
  String get periodLabel => throw _privateConstructorUsedError;
  AiExamForecast? get forecast =>
      throw _privateConstructorUsedError; // 예상 점수 근거 부족 안내 (예: 1과목 2문제 더 풀면 예상 점수를 알려 드려요)
  String? get forecastHint => throw _privateConstructorUsedError;
  AiRepeatedWrong? get repeatedWrong => throw _privateConstructorUsedError;
  AiAnalysisReadiness? get readiness =>
      throw _privateConstructorUsedError; // 모두 안정권일 때 다음 목표 한 줄
  String? get nextGoal => throw _privateConstructorUsedError;

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
    String periodLabel,
    AiExamForecast? forecast,
    String? forecastHint,
    AiRepeatedWrong? repeatedWrong,
    AiAnalysisReadiness? readiness,
    String? nextGoal,
  });

  $AiAnalysisStrengthCopyWith<$Res>? get strength;
  $AiExamForecastCopyWith<$Res>? get forecast;
  $AiRepeatedWrongCopyWith<$Res>? get repeatedWrong;
  $AiAnalysisReadinessCopyWith<$Res>? get readiness;
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
    Object? periodLabel = null,
    Object? forecast = freezed,
    Object? forecastHint = freezed,
    Object? repeatedWrong = freezed,
    Object? readiness = freezed,
    Object? nextGoal = freezed,
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
            periodLabel: null == periodLabel
                ? _value.periodLabel
                : periodLabel // ignore: cast_nullable_to_non_nullable
                      as String,
            forecast: freezed == forecast
                ? _value.forecast
                : forecast // ignore: cast_nullable_to_non_nullable
                      as AiExamForecast?,
            forecastHint: freezed == forecastHint
                ? _value.forecastHint
                : forecastHint // ignore: cast_nullable_to_non_nullable
                      as String?,
            repeatedWrong: freezed == repeatedWrong
                ? _value.repeatedWrong
                : repeatedWrong // ignore: cast_nullable_to_non_nullable
                      as AiRepeatedWrong?,
            readiness: freezed == readiness
                ? _value.readiness
                : readiness // ignore: cast_nullable_to_non_nullable
                      as AiAnalysisReadiness?,
            nextGoal: freezed == nextGoal
                ? _value.nextGoal
                : nextGoal // ignore: cast_nullable_to_non_nullable
                      as String?,
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

  /// Create a copy of AiStatsAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AiExamForecastCopyWith<$Res>? get forecast {
    if (_value.forecast == null) {
      return null;
    }

    return $AiExamForecastCopyWith<$Res>(_value.forecast!, (value) {
      return _then(_value.copyWith(forecast: value) as $Val);
    });
  }

  /// Create a copy of AiStatsAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AiRepeatedWrongCopyWith<$Res>? get repeatedWrong {
    if (_value.repeatedWrong == null) {
      return null;
    }

    return $AiRepeatedWrongCopyWith<$Res>(_value.repeatedWrong!, (value) {
      return _then(_value.copyWith(repeatedWrong: value) as $Val);
    });
  }

  /// Create a copy of AiStatsAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AiAnalysisReadinessCopyWith<$Res>? get readiness {
    if (_value.readiness == null) {
      return null;
    }

    return $AiAnalysisReadinessCopyWith<$Res>(_value.readiness!, (value) {
      return _then(_value.copyWith(readiness: value) as $Val);
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
    String periodLabel,
    AiExamForecast? forecast,
    String? forecastHint,
    AiRepeatedWrong? repeatedWrong,
    AiAnalysisReadiness? readiness,
    String? nextGoal,
  });

  @override
  $AiAnalysisStrengthCopyWith<$Res>? get strength;
  @override
  $AiExamForecastCopyWith<$Res>? get forecast;
  @override
  $AiRepeatedWrongCopyWith<$Res>? get repeatedWrong;
  @override
  $AiAnalysisReadinessCopyWith<$Res>? get readiness;
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
    Object? periodLabel = null,
    Object? forecast = freezed,
    Object? forecastHint = freezed,
    Object? repeatedWrong = freezed,
    Object? readiness = freezed,
    Object? nextGoal = freezed,
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
        periodLabel: null == periodLabel
            ? _value.periodLabel
            : periodLabel // ignore: cast_nullable_to_non_nullable
                  as String,
        forecast: freezed == forecast
            ? _value.forecast
            : forecast // ignore: cast_nullable_to_non_nullable
                  as AiExamForecast?,
        forecastHint: freezed == forecastHint
            ? _value.forecastHint
            : forecastHint // ignore: cast_nullable_to_non_nullable
                  as String?,
        repeatedWrong: freezed == repeatedWrong
            ? _value.repeatedWrong
            : repeatedWrong // ignore: cast_nullable_to_non_nullable
                  as AiRepeatedWrong?,
        readiness: freezed == readiness
            ? _value.readiness
            : readiness // ignore: cast_nullable_to_non_nullable
                  as AiAnalysisReadiness?,
        nextGoal: freezed == nextGoal
            ? _value.nextGoal
            : nextGoal // ignore: cast_nullable_to_non_nullable
                  as String?,
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
    this.periodLabel = '',
    this.forecast,
    this.forecastHint,
    this.repeatedWrong,
    this.readiness,
    this.nextGoal,
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

  // 판정 기간 표기 (예: 최근 90일 기준, 옛 서버면 빈 값)
  @override
  @JsonKey()
  final String periodLabel;
  @override
  final AiExamForecast? forecast;
  // 예상 점수 근거 부족 안내 (예: 1과목 2문제 더 풀면 예상 점수를 알려 드려요)
  @override
  final String? forecastHint;
  @override
  final AiRepeatedWrong? repeatedWrong;
  @override
  final AiAnalysisReadiness? readiness;
  // 모두 안정권일 때 다음 목표 한 줄
  @override
  final String? nextGoal;

  @override
  String toString() {
    return 'AiStatsAnalysis(headline: $headline, findings: $findings, trend: $trend, strength: $strength, actions: $actions, periodLabel: $periodLabel, forecast: $forecast, forecastHint: $forecastHint, repeatedWrong: $repeatedWrong, readiness: $readiness, nextGoal: $nextGoal)';
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
            const DeepCollectionEquality().equals(other._actions, _actions) &&
            (identical(other.periodLabel, periodLabel) ||
                other.periodLabel == periodLabel) &&
            (identical(other.forecast, forecast) ||
                other.forecast == forecast) &&
            (identical(other.forecastHint, forecastHint) ||
                other.forecastHint == forecastHint) &&
            (identical(other.repeatedWrong, repeatedWrong) ||
                other.repeatedWrong == repeatedWrong) &&
            (identical(other.readiness, readiness) ||
                other.readiness == readiness) &&
            (identical(other.nextGoal, nextGoal) ||
                other.nextGoal == nextGoal));
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
    periodLabel,
    forecast,
    forecastHint,
    repeatedWrong,
    readiness,
    nextGoal,
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
    final String periodLabel,
    final AiExamForecast? forecast,
    final String? forecastHint,
    final AiRepeatedWrong? repeatedWrong,
    final AiAnalysisReadiness? readiness,
    final String? nextGoal,
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
  List<AiAnalysisAction> get actions; // 판정 기간 표기 (예: 최근 90일 기준, 옛 서버면 빈 값)
  @override
  String get periodLabel;
  @override
  AiExamForecast? get forecast; // 예상 점수 근거 부족 안내 (예: 1과목 2문제 더 풀면 예상 점수를 알려 드려요)
  @override
  String? get forecastHint;
  @override
  AiRepeatedWrong? get repeatedWrong;
  @override
  AiAnalysisReadiness? get readiness; // 모두 안정권일 때 다음 목표 한 줄
  @override
  String? get nextGoal;

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
  String? get insight =>
      throw _privateConstructorUsedError; // 열 수 있는 개념 학습 단원 (없으면 null, #862)
  String? get conceptTopicUuid => throw _privateConstructorUsedError;

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
    String? conceptTopicUuid,
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
    Object? conceptTopicUuid = freezed,
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
            conceptTopicUuid: freezed == conceptTopicUuid
                ? _value.conceptTopicUuid
                : conceptTopicUuid // ignore: cast_nullable_to_non_nullable
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
    String? conceptTopicUuid,
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
    Object? conceptTopicUuid = freezed,
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
        conceptTopicUuid: freezed == conceptTopicUuid
            ? _value.conceptTopicUuid
            : conceptTopicUuid // ignore: cast_nullable_to_non_nullable
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
    this.conceptTopicUuid,
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
  // 열 수 있는 개념 학습 단원 (없으면 null, #862)
  @override
  final String? conceptTopicUuid;

  @override
  String toString() {
    return 'AiAnalysisFinding(topicUuid: $topicUuid, topicName: $topicName, kind: $kind, solvedCount: $solvedCount, correctRatePercent: $correctRatePercent, evidence: $evidence, insight: $insight, conceptTopicUuid: $conceptTopicUuid)';
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
            (identical(other.insight, insight) || other.insight == insight) &&
            (identical(other.conceptTopicUuid, conceptTopicUuid) ||
                other.conceptTopicUuid == conceptTopicUuid));
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
    conceptTopicUuid,
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
    final String? conceptTopicUuid,
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
  String? get insight; // 열 수 있는 개념 학습 단원 (없으면 null, #862)
  @override
  String? get conceptTopicUuid;

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

AiExamForecast _$AiExamForecastFromJson(Map<String, dynamic> json) {
  return _AiExamForecast.fromJson(json);
}

/// @nodoc
mixin _$AiExamForecast {
  // 100점 환산 (문항당 2점)
  int get expectedScore => throw _privateConstructorUsedError;
  int get subjectOneExpectedCount => throw _privateConstructorUsedError;
  int get subjectOneQuestionCount =>
      throw _privateConstructorUsedError; // 40% 미만 (과락)
  bool get isSubjectOneFailRisk => throw _privateConstructorUsedError;
  int get subjectTwoExpectedCount => throw _privateConstructorUsedError;
  int get subjectTwoQuestionCount => throw _privateConstructorUsedError;
  bool get isSubjectTwoFailRisk => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: AiForecastVerdict.unknown)
  AiForecastVerdict get verdict => throw _privateConstructorUsedError;
  String get verdictLabel =>
      throw _privateConstructorUsedError; // 예: 1과목 예상 6/10 · 2과목 예상 26/40
  String get summary =>
      throw _privateConstructorUsedError; // 예: 합격선까지 2문제 더 맞히면 돼요 / 과락 경고
  String get detail => throw _privateConstructorUsedError;

  /// Serializes this AiExamForecast to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiExamForecast
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiExamForecastCopyWith<AiExamForecast> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiExamForecastCopyWith<$Res> {
  factory $AiExamForecastCopyWith(
    AiExamForecast value,
    $Res Function(AiExamForecast) then,
  ) = _$AiExamForecastCopyWithImpl<$Res, AiExamForecast>;
  @useResult
  $Res call({
    int expectedScore,
    int subjectOneExpectedCount,
    int subjectOneQuestionCount,
    bool isSubjectOneFailRisk,
    int subjectTwoExpectedCount,
    int subjectTwoQuestionCount,
    bool isSubjectTwoFailRisk,
    @JsonKey(unknownEnumValue: AiForecastVerdict.unknown)
    AiForecastVerdict verdict,
    String verdictLabel,
    String summary,
    String detail,
  });
}

/// @nodoc
class _$AiExamForecastCopyWithImpl<$Res, $Val extends AiExamForecast>
    implements $AiExamForecastCopyWith<$Res> {
  _$AiExamForecastCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiExamForecast
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? expectedScore = null,
    Object? subjectOneExpectedCount = null,
    Object? subjectOneQuestionCount = null,
    Object? isSubjectOneFailRisk = null,
    Object? subjectTwoExpectedCount = null,
    Object? subjectTwoQuestionCount = null,
    Object? isSubjectTwoFailRisk = null,
    Object? verdict = null,
    Object? verdictLabel = null,
    Object? summary = null,
    Object? detail = null,
  }) {
    return _then(
      _value.copyWith(
            expectedScore: null == expectedScore
                ? _value.expectedScore
                : expectedScore // ignore: cast_nullable_to_non_nullable
                      as int,
            subjectOneExpectedCount: null == subjectOneExpectedCount
                ? _value.subjectOneExpectedCount
                : subjectOneExpectedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            subjectOneQuestionCount: null == subjectOneQuestionCount
                ? _value.subjectOneQuestionCount
                : subjectOneQuestionCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isSubjectOneFailRisk: null == isSubjectOneFailRisk
                ? _value.isSubjectOneFailRisk
                : isSubjectOneFailRisk // ignore: cast_nullable_to_non_nullable
                      as bool,
            subjectTwoExpectedCount: null == subjectTwoExpectedCount
                ? _value.subjectTwoExpectedCount
                : subjectTwoExpectedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            subjectTwoQuestionCount: null == subjectTwoQuestionCount
                ? _value.subjectTwoQuestionCount
                : subjectTwoQuestionCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isSubjectTwoFailRisk: null == isSubjectTwoFailRisk
                ? _value.isSubjectTwoFailRisk
                : isSubjectTwoFailRisk // ignore: cast_nullable_to_non_nullable
                      as bool,
            verdict: null == verdict
                ? _value.verdict
                : verdict // ignore: cast_nullable_to_non_nullable
                      as AiForecastVerdict,
            verdictLabel: null == verdictLabel
                ? _value.verdictLabel
                : verdictLabel // ignore: cast_nullable_to_non_nullable
                      as String,
            summary: null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as String,
            detail: null == detail
                ? _value.detail
                : detail // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AiExamForecastImplCopyWith<$Res>
    implements $AiExamForecastCopyWith<$Res> {
  factory _$$AiExamForecastImplCopyWith(
    _$AiExamForecastImpl value,
    $Res Function(_$AiExamForecastImpl) then,
  ) = __$$AiExamForecastImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int expectedScore,
    int subjectOneExpectedCount,
    int subjectOneQuestionCount,
    bool isSubjectOneFailRisk,
    int subjectTwoExpectedCount,
    int subjectTwoQuestionCount,
    bool isSubjectTwoFailRisk,
    @JsonKey(unknownEnumValue: AiForecastVerdict.unknown)
    AiForecastVerdict verdict,
    String verdictLabel,
    String summary,
    String detail,
  });
}

/// @nodoc
class __$$AiExamForecastImplCopyWithImpl<$Res>
    extends _$AiExamForecastCopyWithImpl<$Res, _$AiExamForecastImpl>
    implements _$$AiExamForecastImplCopyWith<$Res> {
  __$$AiExamForecastImplCopyWithImpl(
    _$AiExamForecastImpl _value,
    $Res Function(_$AiExamForecastImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AiExamForecast
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? expectedScore = null,
    Object? subjectOneExpectedCount = null,
    Object? subjectOneQuestionCount = null,
    Object? isSubjectOneFailRisk = null,
    Object? subjectTwoExpectedCount = null,
    Object? subjectTwoQuestionCount = null,
    Object? isSubjectTwoFailRisk = null,
    Object? verdict = null,
    Object? verdictLabel = null,
    Object? summary = null,
    Object? detail = null,
  }) {
    return _then(
      _$AiExamForecastImpl(
        expectedScore: null == expectedScore
            ? _value.expectedScore
            : expectedScore // ignore: cast_nullable_to_non_nullable
                  as int,
        subjectOneExpectedCount: null == subjectOneExpectedCount
            ? _value.subjectOneExpectedCount
            : subjectOneExpectedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        subjectOneQuestionCount: null == subjectOneQuestionCount
            ? _value.subjectOneQuestionCount
            : subjectOneQuestionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isSubjectOneFailRisk: null == isSubjectOneFailRisk
            ? _value.isSubjectOneFailRisk
            : isSubjectOneFailRisk // ignore: cast_nullable_to_non_nullable
                  as bool,
        subjectTwoExpectedCount: null == subjectTwoExpectedCount
            ? _value.subjectTwoExpectedCount
            : subjectTwoExpectedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        subjectTwoQuestionCount: null == subjectTwoQuestionCount
            ? _value.subjectTwoQuestionCount
            : subjectTwoQuestionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isSubjectTwoFailRisk: null == isSubjectTwoFailRisk
            ? _value.isSubjectTwoFailRisk
            : isSubjectTwoFailRisk // ignore: cast_nullable_to_non_nullable
                  as bool,
        verdict: null == verdict
            ? _value.verdict
            : verdict // ignore: cast_nullable_to_non_nullable
                  as AiForecastVerdict,
        verdictLabel: null == verdictLabel
            ? _value.verdictLabel
            : verdictLabel // ignore: cast_nullable_to_non_nullable
                  as String,
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as String,
        detail: null == detail
            ? _value.detail
            : detail // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AiExamForecastImpl implements _AiExamForecast {
  const _$AiExamForecastImpl({
    this.expectedScore = 0,
    this.subjectOneExpectedCount = 0,
    this.subjectOneQuestionCount = 0,
    this.isSubjectOneFailRisk = false,
    this.subjectTwoExpectedCount = 0,
    this.subjectTwoQuestionCount = 0,
    this.isSubjectTwoFailRisk = false,
    @JsonKey(unknownEnumValue: AiForecastVerdict.unknown)
    this.verdict = AiForecastVerdict.unknown,
    this.verdictLabel = '',
    this.summary = '',
    this.detail = '',
  });

  factory _$AiExamForecastImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiExamForecastImplFromJson(json);

  // 100점 환산 (문항당 2점)
  @override
  @JsonKey()
  final int expectedScore;
  @override
  @JsonKey()
  final int subjectOneExpectedCount;
  @override
  @JsonKey()
  final int subjectOneQuestionCount;
  // 40% 미만 (과락)
  @override
  @JsonKey()
  final bool isSubjectOneFailRisk;
  @override
  @JsonKey()
  final int subjectTwoExpectedCount;
  @override
  @JsonKey()
  final int subjectTwoQuestionCount;
  @override
  @JsonKey()
  final bool isSubjectTwoFailRisk;
  @override
  @JsonKey(unknownEnumValue: AiForecastVerdict.unknown)
  final AiForecastVerdict verdict;
  @override
  @JsonKey()
  final String verdictLabel;
  // 예: 1과목 예상 6/10 · 2과목 예상 26/40
  @override
  @JsonKey()
  final String summary;
  // 예: 합격선까지 2문제 더 맞히면 돼요 / 과락 경고
  @override
  @JsonKey()
  final String detail;

  @override
  String toString() {
    return 'AiExamForecast(expectedScore: $expectedScore, subjectOneExpectedCount: $subjectOneExpectedCount, subjectOneQuestionCount: $subjectOneQuestionCount, isSubjectOneFailRisk: $isSubjectOneFailRisk, subjectTwoExpectedCount: $subjectTwoExpectedCount, subjectTwoQuestionCount: $subjectTwoQuestionCount, isSubjectTwoFailRisk: $isSubjectTwoFailRisk, verdict: $verdict, verdictLabel: $verdictLabel, summary: $summary, detail: $detail)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiExamForecastImpl &&
            (identical(other.expectedScore, expectedScore) ||
                other.expectedScore == expectedScore) &&
            (identical(
                  other.subjectOneExpectedCount,
                  subjectOneExpectedCount,
                ) ||
                other.subjectOneExpectedCount == subjectOneExpectedCount) &&
            (identical(
                  other.subjectOneQuestionCount,
                  subjectOneQuestionCount,
                ) ||
                other.subjectOneQuestionCount == subjectOneQuestionCount) &&
            (identical(other.isSubjectOneFailRisk, isSubjectOneFailRisk) ||
                other.isSubjectOneFailRisk == isSubjectOneFailRisk) &&
            (identical(
                  other.subjectTwoExpectedCount,
                  subjectTwoExpectedCount,
                ) ||
                other.subjectTwoExpectedCount == subjectTwoExpectedCount) &&
            (identical(
                  other.subjectTwoQuestionCount,
                  subjectTwoQuestionCount,
                ) ||
                other.subjectTwoQuestionCount == subjectTwoQuestionCount) &&
            (identical(other.isSubjectTwoFailRisk, isSubjectTwoFailRisk) ||
                other.isSubjectTwoFailRisk == isSubjectTwoFailRisk) &&
            (identical(other.verdict, verdict) || other.verdict == verdict) &&
            (identical(other.verdictLabel, verdictLabel) ||
                other.verdictLabel == verdictLabel) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.detail, detail) || other.detail == detail));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    expectedScore,
    subjectOneExpectedCount,
    subjectOneQuestionCount,
    isSubjectOneFailRisk,
    subjectTwoExpectedCount,
    subjectTwoQuestionCount,
    isSubjectTwoFailRisk,
    verdict,
    verdictLabel,
    summary,
    detail,
  );

  /// Create a copy of AiExamForecast
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiExamForecastImplCopyWith<_$AiExamForecastImpl> get copyWith =>
      __$$AiExamForecastImplCopyWithImpl<_$AiExamForecastImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AiExamForecastImplToJson(this);
  }
}

abstract class _AiExamForecast implements AiExamForecast {
  const factory _AiExamForecast({
    final int expectedScore,
    final int subjectOneExpectedCount,
    final int subjectOneQuestionCount,
    final bool isSubjectOneFailRisk,
    final int subjectTwoExpectedCount,
    final int subjectTwoQuestionCount,
    final bool isSubjectTwoFailRisk,
    @JsonKey(unknownEnumValue: AiForecastVerdict.unknown)
    final AiForecastVerdict verdict,
    final String verdictLabel,
    final String summary,
    final String detail,
  }) = _$AiExamForecastImpl;

  factory _AiExamForecast.fromJson(Map<String, dynamic> json) =
      _$AiExamForecastImpl.fromJson;

  // 100점 환산 (문항당 2점)
  @override
  int get expectedScore;
  @override
  int get subjectOneExpectedCount;
  @override
  int get subjectOneQuestionCount; // 40% 미만 (과락)
  @override
  bool get isSubjectOneFailRisk;
  @override
  int get subjectTwoExpectedCount;
  @override
  int get subjectTwoQuestionCount;
  @override
  bool get isSubjectTwoFailRisk;
  @override
  @JsonKey(unknownEnumValue: AiForecastVerdict.unknown)
  AiForecastVerdict get verdict;
  @override
  String get verdictLabel; // 예: 1과목 예상 6/10 · 2과목 예상 26/40
  @override
  String get summary; // 예: 합격선까지 2문제 더 맞히면 돼요 / 과락 경고
  @override
  String get detail;

  /// Create a copy of AiExamForecast
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiExamForecastImplCopyWith<_$AiExamForecastImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AiRepeatedWrong _$AiRepeatedWrongFromJson(Map<String, dynamic> json) {
  return _AiRepeatedWrong.fromJson(json);
}

/// @nodoc
mixin _$AiRepeatedWrong {
  int get questionCount =>
      throw _privateConstructorUsedError; // 그중 마지막 시도도 오답인 문제 수
  int get unresolvedCount => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;

  /// Serializes this AiRepeatedWrong to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiRepeatedWrong
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiRepeatedWrongCopyWith<AiRepeatedWrong> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiRepeatedWrongCopyWith<$Res> {
  factory $AiRepeatedWrongCopyWith(
    AiRepeatedWrong value,
    $Res Function(AiRepeatedWrong) then,
  ) = _$AiRepeatedWrongCopyWithImpl<$Res, AiRepeatedWrong>;
  @useResult
  $Res call({int questionCount, int unresolvedCount, String text});
}

/// @nodoc
class _$AiRepeatedWrongCopyWithImpl<$Res, $Val extends AiRepeatedWrong>
    implements $AiRepeatedWrongCopyWith<$Res> {
  _$AiRepeatedWrongCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiRepeatedWrong
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionCount = null,
    Object? unresolvedCount = null,
    Object? text = null,
  }) {
    return _then(
      _value.copyWith(
            questionCount: null == questionCount
                ? _value.questionCount
                : questionCount // ignore: cast_nullable_to_non_nullable
                      as int,
            unresolvedCount: null == unresolvedCount
                ? _value.unresolvedCount
                : unresolvedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AiRepeatedWrongImplCopyWith<$Res>
    implements $AiRepeatedWrongCopyWith<$Res> {
  factory _$$AiRepeatedWrongImplCopyWith(
    _$AiRepeatedWrongImpl value,
    $Res Function(_$AiRepeatedWrongImpl) then,
  ) = __$$AiRepeatedWrongImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int questionCount, int unresolvedCount, String text});
}

/// @nodoc
class __$$AiRepeatedWrongImplCopyWithImpl<$Res>
    extends _$AiRepeatedWrongCopyWithImpl<$Res, _$AiRepeatedWrongImpl>
    implements _$$AiRepeatedWrongImplCopyWith<$Res> {
  __$$AiRepeatedWrongImplCopyWithImpl(
    _$AiRepeatedWrongImpl _value,
    $Res Function(_$AiRepeatedWrongImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AiRepeatedWrong
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionCount = null,
    Object? unresolvedCount = null,
    Object? text = null,
  }) {
    return _then(
      _$AiRepeatedWrongImpl(
        questionCount: null == questionCount
            ? _value.questionCount
            : questionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        unresolvedCount: null == unresolvedCount
            ? _value.unresolvedCount
            : unresolvedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AiRepeatedWrongImpl implements _AiRepeatedWrong {
  const _$AiRepeatedWrongImpl({
    this.questionCount = 0,
    this.unresolvedCount = 0,
    this.text = '',
  });

  factory _$AiRepeatedWrongImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiRepeatedWrongImplFromJson(json);

  @override
  @JsonKey()
  final int questionCount;
  // 그중 마지막 시도도 오답인 문제 수
  @override
  @JsonKey()
  final int unresolvedCount;
  @override
  @JsonKey()
  final String text;

  @override
  String toString() {
    return 'AiRepeatedWrong(questionCount: $questionCount, unresolvedCount: $unresolvedCount, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiRepeatedWrongImpl &&
            (identical(other.questionCount, questionCount) ||
                other.questionCount == questionCount) &&
            (identical(other.unresolvedCount, unresolvedCount) ||
                other.unresolvedCount == unresolvedCount) &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, questionCount, unresolvedCount, text);

  /// Create a copy of AiRepeatedWrong
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiRepeatedWrongImplCopyWith<_$AiRepeatedWrongImpl> get copyWith =>
      __$$AiRepeatedWrongImplCopyWithImpl<_$AiRepeatedWrongImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AiRepeatedWrongImplToJson(this);
  }
}

abstract class _AiRepeatedWrong implements AiRepeatedWrong {
  const factory _AiRepeatedWrong({
    final int questionCount,
    final int unresolvedCount,
    final String text,
  }) = _$AiRepeatedWrongImpl;

  factory _AiRepeatedWrong.fromJson(Map<String, dynamic> json) =
      _$AiRepeatedWrongImpl.fromJson;

  @override
  int get questionCount; // 그중 마지막 시도도 오답인 문제 수
  @override
  int get unresolvedCount;
  @override
  String get text;

  /// Create a copy of AiRepeatedWrong
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiRepeatedWrongImplCopyWith<_$AiRepeatedWrongImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AiAnalysisReadiness _$AiAnalysisReadinessFromJson(Map<String, dynamic> json) {
  return _AiAnalysisReadiness.fromJson(json);
}

/// @nodoc
mixin _$AiAnalysisReadiness {
  String get message =>
      throw _privateConstructorUsedError; // 진행 대상 토픽 짧은 이름 (토픽 없으면 null)
  String? get topicName => throw _privateConstructorUsedError;
  int get solvedCount => throw _privateConstructorUsedError;
  int get targetCount => throw _privateConstructorUsedError;

  /// Serializes this AiAnalysisReadiness to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiAnalysisReadiness
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiAnalysisReadinessCopyWith<AiAnalysisReadiness> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiAnalysisReadinessCopyWith<$Res> {
  factory $AiAnalysisReadinessCopyWith(
    AiAnalysisReadiness value,
    $Res Function(AiAnalysisReadiness) then,
  ) = _$AiAnalysisReadinessCopyWithImpl<$Res, AiAnalysisReadiness>;
  @useResult
  $Res call({
    String message,
    String? topicName,
    int solvedCount,
    int targetCount,
  });
}

/// @nodoc
class _$AiAnalysisReadinessCopyWithImpl<$Res, $Val extends AiAnalysisReadiness>
    implements $AiAnalysisReadinessCopyWith<$Res> {
  _$AiAnalysisReadinessCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiAnalysisReadiness
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? topicName = freezed,
    Object? solvedCount = null,
    Object? targetCount = null,
  }) {
    return _then(
      _value.copyWith(
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            topicName: freezed == topicName
                ? _value.topicName
                : topicName // ignore: cast_nullable_to_non_nullable
                      as String?,
            solvedCount: null == solvedCount
                ? _value.solvedCount
                : solvedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            targetCount: null == targetCount
                ? _value.targetCount
                : targetCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AiAnalysisReadinessImplCopyWith<$Res>
    implements $AiAnalysisReadinessCopyWith<$Res> {
  factory _$$AiAnalysisReadinessImplCopyWith(
    _$AiAnalysisReadinessImpl value,
    $Res Function(_$AiAnalysisReadinessImpl) then,
  ) = __$$AiAnalysisReadinessImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String message,
    String? topicName,
    int solvedCount,
    int targetCount,
  });
}

/// @nodoc
class __$$AiAnalysisReadinessImplCopyWithImpl<$Res>
    extends _$AiAnalysisReadinessCopyWithImpl<$Res, _$AiAnalysisReadinessImpl>
    implements _$$AiAnalysisReadinessImplCopyWith<$Res> {
  __$$AiAnalysisReadinessImplCopyWithImpl(
    _$AiAnalysisReadinessImpl _value,
    $Res Function(_$AiAnalysisReadinessImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AiAnalysisReadiness
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? topicName = freezed,
    Object? solvedCount = null,
    Object? targetCount = null,
  }) {
    return _then(
      _$AiAnalysisReadinessImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        topicName: freezed == topicName
            ? _value.topicName
            : topicName // ignore: cast_nullable_to_non_nullable
                  as String?,
        solvedCount: null == solvedCount
            ? _value.solvedCount
            : solvedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        targetCount: null == targetCount
            ? _value.targetCount
            : targetCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AiAnalysisReadinessImpl implements _AiAnalysisReadiness {
  const _$AiAnalysisReadinessImpl({
    this.message = '',
    this.topicName,
    this.solvedCount = 0,
    this.targetCount = 0,
  });

  factory _$AiAnalysisReadinessImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiAnalysisReadinessImplFromJson(json);

  @override
  @JsonKey()
  final String message;
  // 진행 대상 토픽 짧은 이름 (토픽 없으면 null)
  @override
  final String? topicName;
  @override
  @JsonKey()
  final int solvedCount;
  @override
  @JsonKey()
  final int targetCount;

  @override
  String toString() {
    return 'AiAnalysisReadiness(message: $message, topicName: $topicName, solvedCount: $solvedCount, targetCount: $targetCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiAnalysisReadinessImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.topicName, topicName) ||
                other.topicName == topicName) &&
            (identical(other.solvedCount, solvedCount) ||
                other.solvedCount == solvedCount) &&
            (identical(other.targetCount, targetCount) ||
                other.targetCount == targetCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, message, topicName, solvedCount, targetCount);

  /// Create a copy of AiAnalysisReadiness
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiAnalysisReadinessImplCopyWith<_$AiAnalysisReadinessImpl> get copyWith =>
      __$$AiAnalysisReadinessImplCopyWithImpl<_$AiAnalysisReadinessImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AiAnalysisReadinessImplToJson(this);
  }
}

abstract class _AiAnalysisReadiness implements AiAnalysisReadiness {
  const factory _AiAnalysisReadiness({
    final String message,
    final String? topicName,
    final int solvedCount,
    final int targetCount,
  }) = _$AiAnalysisReadinessImpl;

  factory _AiAnalysisReadiness.fromJson(Map<String, dynamic> json) =
      _$AiAnalysisReadinessImpl.fromJson;

  @override
  String get message; // 진행 대상 토픽 짧은 이름 (토픽 없으면 null)
  @override
  String? get topicName;
  @override
  int get solvedCount;
  @override
  int get targetCount;

  /// Create a copy of AiAnalysisReadiness
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiAnalysisReadinessImplCopyWith<_$AiAnalysisReadinessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
