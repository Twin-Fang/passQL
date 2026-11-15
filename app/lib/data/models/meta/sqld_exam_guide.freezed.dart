// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sqld_exam_guide.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SqldExamGuide _$SqldExamGuideFromJson(Map<String, dynamic> json) {
  return _SqldExamGuide.fromJson(json);
}

/// @nodoc
mixin _$SqldExamGuide {
  String get oneLineDefinition => throw _privateConstructorUsedError;
  String get organizerName => throw _privateConstructorUsedError;
  String get certificationNumber => throw _privateConstructorUsedError;
  List<String> get recommendedFor => throw _privateConstructorUsedError;
  List<SqldExamSubject> get subjects => throw _privateConstructorUsedError;
  int get examDurationMinutes => throw _privateConstructorUsedError;
  int get passingTotalScore =>
      throw _privateConstructorUsedError; // 과목 배점 대비 과락 기준 (%, 미만이면 과락)
  int get failingSubjectPercent => throw _privateConstructorUsedError;
  int get examFeeWon => throw _privateConstructorUsedError;
  String get validityDescription => throw _privateConstructorUsedError;
  List<SqldExamFaq> get faqs => throw _privateConstructorUsedError; // 연도 오름차순
  List<SqldYearlyStatistic> get yearlyStatistics =>
      throw _privateConstructorUsedError;
  List<SqldRoundNote> get roundNotes => throw _privateConstructorUsedError;
  List<SqldCertificationComparison> get comparisons =>
      throw _privateConstructorUsedError; // 연도 통계 2건 미만이면 null
  SqldExamInsights? get insights => throw _privateConstructorUsedError;
  List<SqldExamSource> get sources => throw _privateConstructorUsedError;

  /// Serializes this SqldExamGuide to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SqldExamGuide
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SqldExamGuideCopyWith<SqldExamGuide> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SqldExamGuideCopyWith<$Res> {
  factory $SqldExamGuideCopyWith(
    SqldExamGuide value,
    $Res Function(SqldExamGuide) then,
  ) = _$SqldExamGuideCopyWithImpl<$Res, SqldExamGuide>;
  @useResult
  $Res call({
    String oneLineDefinition,
    String organizerName,
    String certificationNumber,
    List<String> recommendedFor,
    List<SqldExamSubject> subjects,
    int examDurationMinutes,
    int passingTotalScore,
    int failingSubjectPercent,
    int examFeeWon,
    String validityDescription,
    List<SqldExamFaq> faqs,
    List<SqldYearlyStatistic> yearlyStatistics,
    List<SqldRoundNote> roundNotes,
    List<SqldCertificationComparison> comparisons,
    SqldExamInsights? insights,
    List<SqldExamSource> sources,
  });

  $SqldExamInsightsCopyWith<$Res>? get insights;
}

/// @nodoc
class _$SqldExamGuideCopyWithImpl<$Res, $Val extends SqldExamGuide>
    implements $SqldExamGuideCopyWith<$Res> {
  _$SqldExamGuideCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SqldExamGuide
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? oneLineDefinition = null,
    Object? organizerName = null,
    Object? certificationNumber = null,
    Object? recommendedFor = null,
    Object? subjects = null,
    Object? examDurationMinutes = null,
    Object? passingTotalScore = null,
    Object? failingSubjectPercent = null,
    Object? examFeeWon = null,
    Object? validityDescription = null,
    Object? faqs = null,
    Object? yearlyStatistics = null,
    Object? roundNotes = null,
    Object? comparisons = null,
    Object? insights = freezed,
    Object? sources = null,
  }) {
    return _then(
      _value.copyWith(
            oneLineDefinition: null == oneLineDefinition
                ? _value.oneLineDefinition
                : oneLineDefinition // ignore: cast_nullable_to_non_nullable
                      as String,
            organizerName: null == organizerName
                ? _value.organizerName
                : organizerName // ignore: cast_nullable_to_non_nullable
                      as String,
            certificationNumber: null == certificationNumber
                ? _value.certificationNumber
                : certificationNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            recommendedFor: null == recommendedFor
                ? _value.recommendedFor
                : recommendedFor // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            subjects: null == subjects
                ? _value.subjects
                : subjects // ignore: cast_nullable_to_non_nullable
                      as List<SqldExamSubject>,
            examDurationMinutes: null == examDurationMinutes
                ? _value.examDurationMinutes
                : examDurationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            passingTotalScore: null == passingTotalScore
                ? _value.passingTotalScore
                : passingTotalScore // ignore: cast_nullable_to_non_nullable
                      as int,
            failingSubjectPercent: null == failingSubjectPercent
                ? _value.failingSubjectPercent
                : failingSubjectPercent // ignore: cast_nullable_to_non_nullable
                      as int,
            examFeeWon: null == examFeeWon
                ? _value.examFeeWon
                : examFeeWon // ignore: cast_nullable_to_non_nullable
                      as int,
            validityDescription: null == validityDescription
                ? _value.validityDescription
                : validityDescription // ignore: cast_nullable_to_non_nullable
                      as String,
            faqs: null == faqs
                ? _value.faqs
                : faqs // ignore: cast_nullable_to_non_nullable
                      as List<SqldExamFaq>,
            yearlyStatistics: null == yearlyStatistics
                ? _value.yearlyStatistics
                : yearlyStatistics // ignore: cast_nullable_to_non_nullable
                      as List<SqldYearlyStatistic>,
            roundNotes: null == roundNotes
                ? _value.roundNotes
                : roundNotes // ignore: cast_nullable_to_non_nullable
                      as List<SqldRoundNote>,
            comparisons: null == comparisons
                ? _value.comparisons
                : comparisons // ignore: cast_nullable_to_non_nullable
                      as List<SqldCertificationComparison>,
            insights: freezed == insights
                ? _value.insights
                : insights // ignore: cast_nullable_to_non_nullable
                      as SqldExamInsights?,
            sources: null == sources
                ? _value.sources
                : sources // ignore: cast_nullable_to_non_nullable
                      as List<SqldExamSource>,
          )
          as $Val,
    );
  }

  /// Create a copy of SqldExamGuide
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SqldExamInsightsCopyWith<$Res>? get insights {
    if (_value.insights == null) {
      return null;
    }

    return $SqldExamInsightsCopyWith<$Res>(_value.insights!, (value) {
      return _then(_value.copyWith(insights: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SqldExamGuideImplCopyWith<$Res>
    implements $SqldExamGuideCopyWith<$Res> {
  factory _$$SqldExamGuideImplCopyWith(
    _$SqldExamGuideImpl value,
    $Res Function(_$SqldExamGuideImpl) then,
  ) = __$$SqldExamGuideImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String oneLineDefinition,
    String organizerName,
    String certificationNumber,
    List<String> recommendedFor,
    List<SqldExamSubject> subjects,
    int examDurationMinutes,
    int passingTotalScore,
    int failingSubjectPercent,
    int examFeeWon,
    String validityDescription,
    List<SqldExamFaq> faqs,
    List<SqldYearlyStatistic> yearlyStatistics,
    List<SqldRoundNote> roundNotes,
    List<SqldCertificationComparison> comparisons,
    SqldExamInsights? insights,
    List<SqldExamSource> sources,
  });

  @override
  $SqldExamInsightsCopyWith<$Res>? get insights;
}

/// @nodoc
class __$$SqldExamGuideImplCopyWithImpl<$Res>
    extends _$SqldExamGuideCopyWithImpl<$Res, _$SqldExamGuideImpl>
    implements _$$SqldExamGuideImplCopyWith<$Res> {
  __$$SqldExamGuideImplCopyWithImpl(
    _$SqldExamGuideImpl _value,
    $Res Function(_$SqldExamGuideImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SqldExamGuide
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? oneLineDefinition = null,
    Object? organizerName = null,
    Object? certificationNumber = null,
    Object? recommendedFor = null,
    Object? subjects = null,
    Object? examDurationMinutes = null,
    Object? passingTotalScore = null,
    Object? failingSubjectPercent = null,
    Object? examFeeWon = null,
    Object? validityDescription = null,
    Object? faqs = null,
    Object? yearlyStatistics = null,
    Object? roundNotes = null,
    Object? comparisons = null,
    Object? insights = freezed,
    Object? sources = null,
  }) {
    return _then(
      _$SqldExamGuideImpl(
        oneLineDefinition: null == oneLineDefinition
            ? _value.oneLineDefinition
            : oneLineDefinition // ignore: cast_nullable_to_non_nullable
                  as String,
        organizerName: null == organizerName
            ? _value.organizerName
            : organizerName // ignore: cast_nullable_to_non_nullable
                  as String,
        certificationNumber: null == certificationNumber
            ? _value.certificationNumber
            : certificationNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        recommendedFor: null == recommendedFor
            ? _value._recommendedFor
            : recommendedFor // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        subjects: null == subjects
            ? _value._subjects
            : subjects // ignore: cast_nullable_to_non_nullable
                  as List<SqldExamSubject>,
        examDurationMinutes: null == examDurationMinutes
            ? _value.examDurationMinutes
            : examDurationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        passingTotalScore: null == passingTotalScore
            ? _value.passingTotalScore
            : passingTotalScore // ignore: cast_nullable_to_non_nullable
                  as int,
        failingSubjectPercent: null == failingSubjectPercent
            ? _value.failingSubjectPercent
            : failingSubjectPercent // ignore: cast_nullable_to_non_nullable
                  as int,
        examFeeWon: null == examFeeWon
            ? _value.examFeeWon
            : examFeeWon // ignore: cast_nullable_to_non_nullable
                  as int,
        validityDescription: null == validityDescription
            ? _value.validityDescription
            : validityDescription // ignore: cast_nullable_to_non_nullable
                  as String,
        faqs: null == faqs
            ? _value._faqs
            : faqs // ignore: cast_nullable_to_non_nullable
                  as List<SqldExamFaq>,
        yearlyStatistics: null == yearlyStatistics
            ? _value._yearlyStatistics
            : yearlyStatistics // ignore: cast_nullable_to_non_nullable
                  as List<SqldYearlyStatistic>,
        roundNotes: null == roundNotes
            ? _value._roundNotes
            : roundNotes // ignore: cast_nullable_to_non_nullable
                  as List<SqldRoundNote>,
        comparisons: null == comparisons
            ? _value._comparisons
            : comparisons // ignore: cast_nullable_to_non_nullable
                  as List<SqldCertificationComparison>,
        insights: freezed == insights
            ? _value.insights
            : insights // ignore: cast_nullable_to_non_nullable
                  as SqldExamInsights?,
        sources: null == sources
            ? _value._sources
            : sources // ignore: cast_nullable_to_non_nullable
                  as List<SqldExamSource>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SqldExamGuideImpl implements _SqldExamGuide {
  const _$SqldExamGuideImpl({
    required this.oneLineDefinition,
    required this.organizerName,
    required this.certificationNumber,
    final List<String> recommendedFor = const <String>[],
    final List<SqldExamSubject> subjects = const <SqldExamSubject>[],
    required this.examDurationMinutes,
    required this.passingTotalScore,
    required this.failingSubjectPercent,
    required this.examFeeWon,
    required this.validityDescription,
    final List<SqldExamFaq> faqs = const <SqldExamFaq>[],
    final List<SqldYearlyStatistic> yearlyStatistics =
        const <SqldYearlyStatistic>[],
    final List<SqldRoundNote> roundNotes = const <SqldRoundNote>[],
    final List<SqldCertificationComparison> comparisons =
        const <SqldCertificationComparison>[],
    this.insights,
    final List<SqldExamSource> sources = const <SqldExamSource>[],
  }) : _recommendedFor = recommendedFor,
       _subjects = subjects,
       _faqs = faqs,
       _yearlyStatistics = yearlyStatistics,
       _roundNotes = roundNotes,
       _comparisons = comparisons,
       _sources = sources;

  factory _$SqldExamGuideImpl.fromJson(Map<String, dynamic> json) =>
      _$$SqldExamGuideImplFromJson(json);

  @override
  final String oneLineDefinition;
  @override
  final String organizerName;
  @override
  final String certificationNumber;
  final List<String> _recommendedFor;
  @override
  @JsonKey()
  List<String> get recommendedFor {
    if (_recommendedFor is EqualUnmodifiableListView) return _recommendedFor;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendedFor);
  }

  final List<SqldExamSubject> _subjects;
  @override
  @JsonKey()
  List<SqldExamSubject> get subjects {
    if (_subjects is EqualUnmodifiableListView) return _subjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subjects);
  }

  @override
  final int examDurationMinutes;
  @override
  final int passingTotalScore;
  // 과목 배점 대비 과락 기준 (%, 미만이면 과락)
  @override
  final int failingSubjectPercent;
  @override
  final int examFeeWon;
  @override
  final String validityDescription;
  final List<SqldExamFaq> _faqs;
  @override
  @JsonKey()
  List<SqldExamFaq> get faqs {
    if (_faqs is EqualUnmodifiableListView) return _faqs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_faqs);
  }

  // 연도 오름차순
  final List<SqldYearlyStatistic> _yearlyStatistics;
  // 연도 오름차순
  @override
  @JsonKey()
  List<SqldYearlyStatistic> get yearlyStatistics {
    if (_yearlyStatistics is EqualUnmodifiableListView)
      return _yearlyStatistics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_yearlyStatistics);
  }

  final List<SqldRoundNote> _roundNotes;
  @override
  @JsonKey()
  List<SqldRoundNote> get roundNotes {
    if (_roundNotes is EqualUnmodifiableListView) return _roundNotes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_roundNotes);
  }

  final List<SqldCertificationComparison> _comparisons;
  @override
  @JsonKey()
  List<SqldCertificationComparison> get comparisons {
    if (_comparisons is EqualUnmodifiableListView) return _comparisons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_comparisons);
  }

  // 연도 통계 2건 미만이면 null
  @override
  final SqldExamInsights? insights;
  final List<SqldExamSource> _sources;
  @override
  @JsonKey()
  List<SqldExamSource> get sources {
    if (_sources is EqualUnmodifiableListView) return _sources;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sources);
  }

  @override
  String toString() {
    return 'SqldExamGuide(oneLineDefinition: $oneLineDefinition, organizerName: $organizerName, certificationNumber: $certificationNumber, recommendedFor: $recommendedFor, subjects: $subjects, examDurationMinutes: $examDurationMinutes, passingTotalScore: $passingTotalScore, failingSubjectPercent: $failingSubjectPercent, examFeeWon: $examFeeWon, validityDescription: $validityDescription, faqs: $faqs, yearlyStatistics: $yearlyStatistics, roundNotes: $roundNotes, comparisons: $comparisons, insights: $insights, sources: $sources)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SqldExamGuideImpl &&
            (identical(other.oneLineDefinition, oneLineDefinition) ||
                other.oneLineDefinition == oneLineDefinition) &&
            (identical(other.organizerName, organizerName) ||
                other.organizerName == organizerName) &&
            (identical(other.certificationNumber, certificationNumber) ||
                other.certificationNumber == certificationNumber) &&
            const DeepCollectionEquality().equals(
              other._recommendedFor,
              _recommendedFor,
            ) &&
            const DeepCollectionEquality().equals(other._subjects, _subjects) &&
            (identical(other.examDurationMinutes, examDurationMinutes) ||
                other.examDurationMinutes == examDurationMinutes) &&
            (identical(other.passingTotalScore, passingTotalScore) ||
                other.passingTotalScore == passingTotalScore) &&
            (identical(other.failingSubjectPercent, failingSubjectPercent) ||
                other.failingSubjectPercent == failingSubjectPercent) &&
            (identical(other.examFeeWon, examFeeWon) ||
                other.examFeeWon == examFeeWon) &&
            (identical(other.validityDescription, validityDescription) ||
                other.validityDescription == validityDescription) &&
            const DeepCollectionEquality().equals(other._faqs, _faqs) &&
            const DeepCollectionEquality().equals(
              other._yearlyStatistics,
              _yearlyStatistics,
            ) &&
            const DeepCollectionEquality().equals(
              other._roundNotes,
              _roundNotes,
            ) &&
            const DeepCollectionEquality().equals(
              other._comparisons,
              _comparisons,
            ) &&
            (identical(other.insights, insights) ||
                other.insights == insights) &&
            const DeepCollectionEquality().equals(other._sources, _sources));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    oneLineDefinition,
    organizerName,
    certificationNumber,
    const DeepCollectionEquality().hash(_recommendedFor),
    const DeepCollectionEquality().hash(_subjects),
    examDurationMinutes,
    passingTotalScore,
    failingSubjectPercent,
    examFeeWon,
    validityDescription,
    const DeepCollectionEquality().hash(_faqs),
    const DeepCollectionEquality().hash(_yearlyStatistics),
    const DeepCollectionEquality().hash(_roundNotes),
    const DeepCollectionEquality().hash(_comparisons),
    insights,
    const DeepCollectionEquality().hash(_sources),
  );

  /// Create a copy of SqldExamGuide
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SqldExamGuideImplCopyWith<_$SqldExamGuideImpl> get copyWith =>
      __$$SqldExamGuideImplCopyWithImpl<_$SqldExamGuideImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SqldExamGuideImplToJson(this);
  }
}

abstract class _SqldExamGuide implements SqldExamGuide {
  const factory _SqldExamGuide({
    required final String oneLineDefinition,
    required final String organizerName,
    required final String certificationNumber,
    final List<String> recommendedFor,
    final List<SqldExamSubject> subjects,
    required final int examDurationMinutes,
    required final int passingTotalScore,
    required final int failingSubjectPercent,
    required final int examFeeWon,
    required final String validityDescription,
    final List<SqldExamFaq> faqs,
    final List<SqldYearlyStatistic> yearlyStatistics,
    final List<SqldRoundNote> roundNotes,
    final List<SqldCertificationComparison> comparisons,
    final SqldExamInsights? insights,
    final List<SqldExamSource> sources,
  }) = _$SqldExamGuideImpl;

  factory _SqldExamGuide.fromJson(Map<String, dynamic> json) =
      _$SqldExamGuideImpl.fromJson;

  @override
  String get oneLineDefinition;
  @override
  String get organizerName;
  @override
  String get certificationNumber;
  @override
  List<String> get recommendedFor;
  @override
  List<SqldExamSubject> get subjects;
  @override
  int get examDurationMinutes;
  @override
  int get passingTotalScore; // 과목 배점 대비 과락 기준 (%, 미만이면 과락)
  @override
  int get failingSubjectPercent;
  @override
  int get examFeeWon;
  @override
  String get validityDescription;
  @override
  List<SqldExamFaq> get faqs; // 연도 오름차순
  @override
  List<SqldYearlyStatistic> get yearlyStatistics;
  @override
  List<SqldRoundNote> get roundNotes;
  @override
  List<SqldCertificationComparison> get comparisons; // 연도 통계 2건 미만이면 null
  @override
  SqldExamInsights? get insights;
  @override
  List<SqldExamSource> get sources;

  /// Create a copy of SqldExamGuide
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SqldExamGuideImplCopyWith<_$SqldExamGuideImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SqldExamSubject _$SqldExamSubjectFromJson(Map<String, dynamic> json) {
  return _SqldExamSubject.fromJson(json);
}

/// @nodoc
mixin _$SqldExamSubject {
  String get name => throw _privateConstructorUsedError;
  int get questionCount => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;

  /// Serializes this SqldExamSubject to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SqldExamSubject
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SqldExamSubjectCopyWith<SqldExamSubject> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SqldExamSubjectCopyWith<$Res> {
  factory $SqldExamSubjectCopyWith(
    SqldExamSubject value,
    $Res Function(SqldExamSubject) then,
  ) = _$SqldExamSubjectCopyWithImpl<$Res, SqldExamSubject>;
  @useResult
  $Res call({String name, int questionCount, int points});
}

/// @nodoc
class _$SqldExamSubjectCopyWithImpl<$Res, $Val extends SqldExamSubject>
    implements $SqldExamSubjectCopyWith<$Res> {
  _$SqldExamSubjectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SqldExamSubject
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? questionCount = null,
    Object? points = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            questionCount: null == questionCount
                ? _value.questionCount
                : questionCount // ignore: cast_nullable_to_non_nullable
                      as int,
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SqldExamSubjectImplCopyWith<$Res>
    implements $SqldExamSubjectCopyWith<$Res> {
  factory _$$SqldExamSubjectImplCopyWith(
    _$SqldExamSubjectImpl value,
    $Res Function(_$SqldExamSubjectImpl) then,
  ) = __$$SqldExamSubjectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, int questionCount, int points});
}

/// @nodoc
class __$$SqldExamSubjectImplCopyWithImpl<$Res>
    extends _$SqldExamSubjectCopyWithImpl<$Res, _$SqldExamSubjectImpl>
    implements _$$SqldExamSubjectImplCopyWith<$Res> {
  __$$SqldExamSubjectImplCopyWithImpl(
    _$SqldExamSubjectImpl _value,
    $Res Function(_$SqldExamSubjectImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SqldExamSubject
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? questionCount = null,
    Object? points = null,
  }) {
    return _then(
      _$SqldExamSubjectImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        questionCount: null == questionCount
            ? _value.questionCount
            : questionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        points: null == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SqldExamSubjectImpl implements _SqldExamSubject {
  const _$SqldExamSubjectImpl({
    required this.name,
    required this.questionCount,
    required this.points,
  });

  factory _$SqldExamSubjectImpl.fromJson(Map<String, dynamic> json) =>
      _$$SqldExamSubjectImplFromJson(json);

  @override
  final String name;
  @override
  final int questionCount;
  @override
  final int points;

  @override
  String toString() {
    return 'SqldExamSubject(name: $name, questionCount: $questionCount, points: $points)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SqldExamSubjectImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.questionCount, questionCount) ||
                other.questionCount == questionCount) &&
            (identical(other.points, points) || other.points == points));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, questionCount, points);

  /// Create a copy of SqldExamSubject
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SqldExamSubjectImplCopyWith<_$SqldExamSubjectImpl> get copyWith =>
      __$$SqldExamSubjectImplCopyWithImpl<_$SqldExamSubjectImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SqldExamSubjectImplToJson(this);
  }
}

abstract class _SqldExamSubject implements SqldExamSubject {
  const factory _SqldExamSubject({
    required final String name,
    required final int questionCount,
    required final int points,
  }) = _$SqldExamSubjectImpl;

  factory _SqldExamSubject.fromJson(Map<String, dynamic> json) =
      _$SqldExamSubjectImpl.fromJson;

  @override
  String get name;
  @override
  int get questionCount;
  @override
  int get points;

  /// Create a copy of SqldExamSubject
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SqldExamSubjectImplCopyWith<_$SqldExamSubjectImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SqldExamFaq _$SqldExamFaqFromJson(Map<String, dynamic> json) {
  return _SqldExamFaq.fromJson(json);
}

/// @nodoc
mixin _$SqldExamFaq {
  String get question => throw _privateConstructorUsedError;
  String get answer => throw _privateConstructorUsedError;

  /// Serializes this SqldExamFaq to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SqldExamFaq
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SqldExamFaqCopyWith<SqldExamFaq> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SqldExamFaqCopyWith<$Res> {
  factory $SqldExamFaqCopyWith(
    SqldExamFaq value,
    $Res Function(SqldExamFaq) then,
  ) = _$SqldExamFaqCopyWithImpl<$Res, SqldExamFaq>;
  @useResult
  $Res call({String question, String answer});
}

/// @nodoc
class _$SqldExamFaqCopyWithImpl<$Res, $Val extends SqldExamFaq>
    implements $SqldExamFaqCopyWith<$Res> {
  _$SqldExamFaqCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SqldExamFaq
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? question = null, Object? answer = null}) {
    return _then(
      _value.copyWith(
            question: null == question
                ? _value.question
                : question // ignore: cast_nullable_to_non_nullable
                      as String,
            answer: null == answer
                ? _value.answer
                : answer // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SqldExamFaqImplCopyWith<$Res>
    implements $SqldExamFaqCopyWith<$Res> {
  factory _$$SqldExamFaqImplCopyWith(
    _$SqldExamFaqImpl value,
    $Res Function(_$SqldExamFaqImpl) then,
  ) = __$$SqldExamFaqImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String question, String answer});
}

/// @nodoc
class __$$SqldExamFaqImplCopyWithImpl<$Res>
    extends _$SqldExamFaqCopyWithImpl<$Res, _$SqldExamFaqImpl>
    implements _$$SqldExamFaqImplCopyWith<$Res> {
  __$$SqldExamFaqImplCopyWithImpl(
    _$SqldExamFaqImpl _value,
    $Res Function(_$SqldExamFaqImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SqldExamFaq
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? question = null, Object? answer = null}) {
    return _then(
      _$SqldExamFaqImpl(
        question: null == question
            ? _value.question
            : question // ignore: cast_nullable_to_non_nullable
                  as String,
        answer: null == answer
            ? _value.answer
            : answer // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SqldExamFaqImpl implements _SqldExamFaq {
  const _$SqldExamFaqImpl({required this.question, required this.answer});

  factory _$SqldExamFaqImpl.fromJson(Map<String, dynamic> json) =>
      _$$SqldExamFaqImplFromJson(json);

  @override
  final String question;
  @override
  final String answer;

  @override
  String toString() {
    return 'SqldExamFaq(question: $question, answer: $answer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SqldExamFaqImpl &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.answer, answer) || other.answer == answer));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, question, answer);

  /// Create a copy of SqldExamFaq
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SqldExamFaqImplCopyWith<_$SqldExamFaqImpl> get copyWith =>
      __$$SqldExamFaqImplCopyWithImpl<_$SqldExamFaqImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SqldExamFaqImplToJson(this);
  }
}

abstract class _SqldExamFaq implements SqldExamFaq {
  const factory _SqldExamFaq({
    required final String question,
    required final String answer,
  }) = _$SqldExamFaqImpl;

  factory _SqldExamFaq.fromJson(Map<String, dynamic> json) =
      _$SqldExamFaqImpl.fromJson;

  @override
  String get question;
  @override
  String get answer;

  /// Create a copy of SqldExamFaq
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SqldExamFaqImplCopyWith<_$SqldExamFaqImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SqldYearlyStatistic _$SqldYearlyStatisticFromJson(Map<String, dynamic> json) {
  return _SqldYearlyStatistic.fromJson(json);
}

/// @nodoc
mixin _$SqldYearlyStatistic {
  int get year => throw _privateConstructorUsedError;
  int get applicantCount => throw _privateConstructorUsedError;
  int get examineeCount => throw _privateConstructorUsedError;
  int get passerCount => throw _privateConstructorUsedError;
  double get passRatePercent => throw _privateConstructorUsedError;

  /// Serializes this SqldYearlyStatistic to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SqldYearlyStatistic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SqldYearlyStatisticCopyWith<SqldYearlyStatistic> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SqldYearlyStatisticCopyWith<$Res> {
  factory $SqldYearlyStatisticCopyWith(
    SqldYearlyStatistic value,
    $Res Function(SqldYearlyStatistic) then,
  ) = _$SqldYearlyStatisticCopyWithImpl<$Res, SqldYearlyStatistic>;
  @useResult
  $Res call({
    int year,
    int applicantCount,
    int examineeCount,
    int passerCount,
    double passRatePercent,
  });
}

/// @nodoc
class _$SqldYearlyStatisticCopyWithImpl<$Res, $Val extends SqldYearlyStatistic>
    implements $SqldYearlyStatisticCopyWith<$Res> {
  _$SqldYearlyStatisticCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SqldYearlyStatistic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? applicantCount = null,
    Object? examineeCount = null,
    Object? passerCount = null,
    Object? passRatePercent = null,
  }) {
    return _then(
      _value.copyWith(
            year: null == year
                ? _value.year
                : year // ignore: cast_nullable_to_non_nullable
                      as int,
            applicantCount: null == applicantCount
                ? _value.applicantCount
                : applicantCount // ignore: cast_nullable_to_non_nullable
                      as int,
            examineeCount: null == examineeCount
                ? _value.examineeCount
                : examineeCount // ignore: cast_nullable_to_non_nullable
                      as int,
            passerCount: null == passerCount
                ? _value.passerCount
                : passerCount // ignore: cast_nullable_to_non_nullable
                      as int,
            passRatePercent: null == passRatePercent
                ? _value.passRatePercent
                : passRatePercent // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SqldYearlyStatisticImplCopyWith<$Res>
    implements $SqldYearlyStatisticCopyWith<$Res> {
  factory _$$SqldYearlyStatisticImplCopyWith(
    _$SqldYearlyStatisticImpl value,
    $Res Function(_$SqldYearlyStatisticImpl) then,
  ) = __$$SqldYearlyStatisticImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int year,
    int applicantCount,
    int examineeCount,
    int passerCount,
    double passRatePercent,
  });
}

/// @nodoc
class __$$SqldYearlyStatisticImplCopyWithImpl<$Res>
    extends _$SqldYearlyStatisticCopyWithImpl<$Res, _$SqldYearlyStatisticImpl>
    implements _$$SqldYearlyStatisticImplCopyWith<$Res> {
  __$$SqldYearlyStatisticImplCopyWithImpl(
    _$SqldYearlyStatisticImpl _value,
    $Res Function(_$SqldYearlyStatisticImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SqldYearlyStatistic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? applicantCount = null,
    Object? examineeCount = null,
    Object? passerCount = null,
    Object? passRatePercent = null,
  }) {
    return _then(
      _$SqldYearlyStatisticImpl(
        year: null == year
            ? _value.year
            : year // ignore: cast_nullable_to_non_nullable
                  as int,
        applicantCount: null == applicantCount
            ? _value.applicantCount
            : applicantCount // ignore: cast_nullable_to_non_nullable
                  as int,
        examineeCount: null == examineeCount
            ? _value.examineeCount
            : examineeCount // ignore: cast_nullable_to_non_nullable
                  as int,
        passerCount: null == passerCount
            ? _value.passerCount
            : passerCount // ignore: cast_nullable_to_non_nullable
                  as int,
        passRatePercent: null == passRatePercent
            ? _value.passRatePercent
            : passRatePercent // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SqldYearlyStatisticImpl implements _SqldYearlyStatistic {
  const _$SqldYearlyStatisticImpl({
    required this.year,
    required this.applicantCount,
    required this.examineeCount,
    required this.passerCount,
    required this.passRatePercent,
  });

  factory _$SqldYearlyStatisticImpl.fromJson(Map<String, dynamic> json) =>
      _$$SqldYearlyStatisticImplFromJson(json);

  @override
  final int year;
  @override
  final int applicantCount;
  @override
  final int examineeCount;
  @override
  final int passerCount;
  @override
  final double passRatePercent;

  @override
  String toString() {
    return 'SqldYearlyStatistic(year: $year, applicantCount: $applicantCount, examineeCount: $examineeCount, passerCount: $passerCount, passRatePercent: $passRatePercent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SqldYearlyStatisticImpl &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.applicantCount, applicantCount) ||
                other.applicantCount == applicantCount) &&
            (identical(other.examineeCount, examineeCount) ||
                other.examineeCount == examineeCount) &&
            (identical(other.passerCount, passerCount) ||
                other.passerCount == passerCount) &&
            (identical(other.passRatePercent, passRatePercent) ||
                other.passRatePercent == passRatePercent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    year,
    applicantCount,
    examineeCount,
    passerCount,
    passRatePercent,
  );

  /// Create a copy of SqldYearlyStatistic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SqldYearlyStatisticImplCopyWith<_$SqldYearlyStatisticImpl> get copyWith =>
      __$$SqldYearlyStatisticImplCopyWithImpl<_$SqldYearlyStatisticImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SqldYearlyStatisticImplToJson(this);
  }
}

abstract class _SqldYearlyStatistic implements SqldYearlyStatistic {
  const factory _SqldYearlyStatistic({
    required final int year,
    required final int applicantCount,
    required final int examineeCount,
    required final int passerCount,
    required final double passRatePercent,
  }) = _$SqldYearlyStatisticImpl;

  factory _SqldYearlyStatistic.fromJson(Map<String, dynamic> json) =
      _$SqldYearlyStatisticImpl.fromJson;

  @override
  int get year;
  @override
  int get applicantCount;
  @override
  int get examineeCount;
  @override
  int get passerCount;
  @override
  double get passRatePercent;

  /// Create a copy of SqldYearlyStatistic
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SqldYearlyStatisticImplCopyWith<_$SqldYearlyStatisticImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SqldRoundNote _$SqldRoundNoteFromJson(Map<String, dynamic> json) {
  return _SqldRoundNote.fromJson(json);
}

/// @nodoc
mixin _$SqldRoundNote {
  int get round => throw _privateConstructorUsedError;
  String get examDate => throw _privateConstructorUsedError;
  String get difficultyNote =>
      throw _privateConstructorUsedError; // 알려진 합격률 (없으면 null)
  double? get passRatePercent =>
      throw _privateConstructorUsedError; // false: 수험생 전언·후기 (화면에 비공식 배지)
  bool get isOfficial => throw _privateConstructorUsedError;

  /// Serializes this SqldRoundNote to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SqldRoundNote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SqldRoundNoteCopyWith<SqldRoundNote> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SqldRoundNoteCopyWith<$Res> {
  factory $SqldRoundNoteCopyWith(
    SqldRoundNote value,
    $Res Function(SqldRoundNote) then,
  ) = _$SqldRoundNoteCopyWithImpl<$Res, SqldRoundNote>;
  @useResult
  $Res call({
    int round,
    String examDate,
    String difficultyNote,
    double? passRatePercent,
    bool isOfficial,
  });
}

/// @nodoc
class _$SqldRoundNoteCopyWithImpl<$Res, $Val extends SqldRoundNote>
    implements $SqldRoundNoteCopyWith<$Res> {
  _$SqldRoundNoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SqldRoundNote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? round = null,
    Object? examDate = null,
    Object? difficultyNote = null,
    Object? passRatePercent = freezed,
    Object? isOfficial = null,
  }) {
    return _then(
      _value.copyWith(
            round: null == round
                ? _value.round
                : round // ignore: cast_nullable_to_non_nullable
                      as int,
            examDate: null == examDate
                ? _value.examDate
                : examDate // ignore: cast_nullable_to_non_nullable
                      as String,
            difficultyNote: null == difficultyNote
                ? _value.difficultyNote
                : difficultyNote // ignore: cast_nullable_to_non_nullable
                      as String,
            passRatePercent: freezed == passRatePercent
                ? _value.passRatePercent
                : passRatePercent // ignore: cast_nullable_to_non_nullable
                      as double?,
            isOfficial: null == isOfficial
                ? _value.isOfficial
                : isOfficial // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SqldRoundNoteImplCopyWith<$Res>
    implements $SqldRoundNoteCopyWith<$Res> {
  factory _$$SqldRoundNoteImplCopyWith(
    _$SqldRoundNoteImpl value,
    $Res Function(_$SqldRoundNoteImpl) then,
  ) = __$$SqldRoundNoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int round,
    String examDate,
    String difficultyNote,
    double? passRatePercent,
    bool isOfficial,
  });
}

/// @nodoc
class __$$SqldRoundNoteImplCopyWithImpl<$Res>
    extends _$SqldRoundNoteCopyWithImpl<$Res, _$SqldRoundNoteImpl>
    implements _$$SqldRoundNoteImplCopyWith<$Res> {
  __$$SqldRoundNoteImplCopyWithImpl(
    _$SqldRoundNoteImpl _value,
    $Res Function(_$SqldRoundNoteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SqldRoundNote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? round = null,
    Object? examDate = null,
    Object? difficultyNote = null,
    Object? passRatePercent = freezed,
    Object? isOfficial = null,
  }) {
    return _then(
      _$SqldRoundNoteImpl(
        round: null == round
            ? _value.round
            : round // ignore: cast_nullable_to_non_nullable
                  as int,
        examDate: null == examDate
            ? _value.examDate
            : examDate // ignore: cast_nullable_to_non_nullable
                  as String,
        difficultyNote: null == difficultyNote
            ? _value.difficultyNote
            : difficultyNote // ignore: cast_nullable_to_non_nullable
                  as String,
        passRatePercent: freezed == passRatePercent
            ? _value.passRatePercent
            : passRatePercent // ignore: cast_nullable_to_non_nullable
                  as double?,
        isOfficial: null == isOfficial
            ? _value.isOfficial
            : isOfficial // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SqldRoundNoteImpl implements _SqldRoundNote {
  const _$SqldRoundNoteImpl({
    required this.round,
    required this.examDate,
    required this.difficultyNote,
    this.passRatePercent,
    this.isOfficial = false,
  });

  factory _$SqldRoundNoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$SqldRoundNoteImplFromJson(json);

  @override
  final int round;
  @override
  final String examDate;
  @override
  final String difficultyNote;
  // 알려진 합격률 (없으면 null)
  @override
  final double? passRatePercent;
  // false: 수험생 전언·후기 (화면에 비공식 배지)
  @override
  @JsonKey()
  final bool isOfficial;

  @override
  String toString() {
    return 'SqldRoundNote(round: $round, examDate: $examDate, difficultyNote: $difficultyNote, passRatePercent: $passRatePercent, isOfficial: $isOfficial)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SqldRoundNoteImpl &&
            (identical(other.round, round) || other.round == round) &&
            (identical(other.examDate, examDate) ||
                other.examDate == examDate) &&
            (identical(other.difficultyNote, difficultyNote) ||
                other.difficultyNote == difficultyNote) &&
            (identical(other.passRatePercent, passRatePercent) ||
                other.passRatePercent == passRatePercent) &&
            (identical(other.isOfficial, isOfficial) ||
                other.isOfficial == isOfficial));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    round,
    examDate,
    difficultyNote,
    passRatePercent,
    isOfficial,
  );

  /// Create a copy of SqldRoundNote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SqldRoundNoteImplCopyWith<_$SqldRoundNoteImpl> get copyWith =>
      __$$SqldRoundNoteImplCopyWithImpl<_$SqldRoundNoteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SqldRoundNoteImplToJson(this);
  }
}

abstract class _SqldRoundNote implements SqldRoundNote {
  const factory _SqldRoundNote({
    required final int round,
    required final String examDate,
    required final String difficultyNote,
    final double? passRatePercent,
    final bool isOfficial,
  }) = _$SqldRoundNoteImpl;

  factory _SqldRoundNote.fromJson(Map<String, dynamic> json) =
      _$SqldRoundNoteImpl.fromJson;

  @override
  int get round;
  @override
  String get examDate;
  @override
  String get difficultyNote; // 알려진 합격률 (없으면 null)
  @override
  double? get passRatePercent; // false: 수험생 전언·후기 (화면에 비공식 배지)
  @override
  bool get isOfficial;

  /// Create a copy of SqldRoundNote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SqldRoundNoteImplCopyWith<_$SqldRoundNoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SqldCertificationComparison _$SqldCertificationComparisonFromJson(
  Map<String, dynamic> json,
) {
  return _SqldCertificationComparison.fromJson(json);
}

/// @nodoc
mixin _$SqldCertificationComparison {
  String get certificationName => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;
  double get passRatePercent => throw _privateConstructorUsedError;

  /// Serializes this SqldCertificationComparison to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SqldCertificationComparison
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SqldCertificationComparisonCopyWith<SqldCertificationComparison>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SqldCertificationComparisonCopyWith<$Res> {
  factory $SqldCertificationComparisonCopyWith(
    SqldCertificationComparison value,
    $Res Function(SqldCertificationComparison) then,
  ) =
      _$SqldCertificationComparisonCopyWithImpl<
        $Res,
        SqldCertificationComparison
      >;
  @useResult
  $Res call({String certificationName, int year, double passRatePercent});
}

/// @nodoc
class _$SqldCertificationComparisonCopyWithImpl<
  $Res,
  $Val extends SqldCertificationComparison
>
    implements $SqldCertificationComparisonCopyWith<$Res> {
  _$SqldCertificationComparisonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SqldCertificationComparison
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? certificationName = null,
    Object? year = null,
    Object? passRatePercent = null,
  }) {
    return _then(
      _value.copyWith(
            certificationName: null == certificationName
                ? _value.certificationName
                : certificationName // ignore: cast_nullable_to_non_nullable
                      as String,
            year: null == year
                ? _value.year
                : year // ignore: cast_nullable_to_non_nullable
                      as int,
            passRatePercent: null == passRatePercent
                ? _value.passRatePercent
                : passRatePercent // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SqldCertificationComparisonImplCopyWith<$Res>
    implements $SqldCertificationComparisonCopyWith<$Res> {
  factory _$$SqldCertificationComparisonImplCopyWith(
    _$SqldCertificationComparisonImpl value,
    $Res Function(_$SqldCertificationComparisonImpl) then,
  ) = __$$SqldCertificationComparisonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String certificationName, int year, double passRatePercent});
}

/// @nodoc
class __$$SqldCertificationComparisonImplCopyWithImpl<$Res>
    extends
        _$SqldCertificationComparisonCopyWithImpl<
          $Res,
          _$SqldCertificationComparisonImpl
        >
    implements _$$SqldCertificationComparisonImplCopyWith<$Res> {
  __$$SqldCertificationComparisonImplCopyWithImpl(
    _$SqldCertificationComparisonImpl _value,
    $Res Function(_$SqldCertificationComparisonImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SqldCertificationComparison
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? certificationName = null,
    Object? year = null,
    Object? passRatePercent = null,
  }) {
    return _then(
      _$SqldCertificationComparisonImpl(
        certificationName: null == certificationName
            ? _value.certificationName
            : certificationName // ignore: cast_nullable_to_non_nullable
                  as String,
        year: null == year
            ? _value.year
            : year // ignore: cast_nullable_to_non_nullable
                  as int,
        passRatePercent: null == passRatePercent
            ? _value.passRatePercent
            : passRatePercent // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SqldCertificationComparisonImpl
    implements _SqldCertificationComparison {
  const _$SqldCertificationComparisonImpl({
    required this.certificationName,
    required this.year,
    required this.passRatePercent,
  });

  factory _$SqldCertificationComparisonImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$SqldCertificationComparisonImplFromJson(json);

  @override
  final String certificationName;
  @override
  final int year;
  @override
  final double passRatePercent;

  @override
  String toString() {
    return 'SqldCertificationComparison(certificationName: $certificationName, year: $year, passRatePercent: $passRatePercent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SqldCertificationComparisonImpl &&
            (identical(other.certificationName, certificationName) ||
                other.certificationName == certificationName) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.passRatePercent, passRatePercent) ||
                other.passRatePercent == passRatePercent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, certificationName, year, passRatePercent);

  /// Create a copy of SqldCertificationComparison
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SqldCertificationComparisonImplCopyWith<_$SqldCertificationComparisonImpl>
  get copyWith =>
      __$$SqldCertificationComparisonImplCopyWithImpl<
        _$SqldCertificationComparisonImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SqldCertificationComparisonImplToJson(this);
  }
}

abstract class _SqldCertificationComparison
    implements SqldCertificationComparison {
  const factory _SqldCertificationComparison({
    required final String certificationName,
    required final int year,
    required final double passRatePercent,
  }) = _$SqldCertificationComparisonImpl;

  factory _SqldCertificationComparison.fromJson(Map<String, dynamic> json) =
      _$SqldCertificationComparisonImpl.fromJson;

  @override
  String get certificationName;
  @override
  int get year;
  @override
  double get passRatePercent;

  /// Create a copy of SqldCertificationComparison
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SqldCertificationComparisonImplCopyWith<_$SqldCertificationComparisonImpl>
  get copyWith => throw _privateConstructorUsedError;
}

SqldExamInsights _$SqldExamInsightsFromJson(Map<String, dynamic> json) {
  return _SqldExamInsights.fromJson(json);
}

/// @nodoc
mixin _$SqldExamInsights {
  int get latestYear => throw _privateConstructorUsedError;
  int get previousYear => throw _privateConstructorUsedError;
  int get growthBaseYear => throw _privateConstructorUsedError;
  double get examineeGrowthMultiple => throw _privateConstructorUsedError;
  double get passRateChangePoints => throw _privateConstructorUsedError;

  /// Serializes this SqldExamInsights to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SqldExamInsights
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SqldExamInsightsCopyWith<SqldExamInsights> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SqldExamInsightsCopyWith<$Res> {
  factory $SqldExamInsightsCopyWith(
    SqldExamInsights value,
    $Res Function(SqldExamInsights) then,
  ) = _$SqldExamInsightsCopyWithImpl<$Res, SqldExamInsights>;
  @useResult
  $Res call({
    int latestYear,
    int previousYear,
    int growthBaseYear,
    double examineeGrowthMultiple,
    double passRateChangePoints,
  });
}

/// @nodoc
class _$SqldExamInsightsCopyWithImpl<$Res, $Val extends SqldExamInsights>
    implements $SqldExamInsightsCopyWith<$Res> {
  _$SqldExamInsightsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SqldExamInsights
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latestYear = null,
    Object? previousYear = null,
    Object? growthBaseYear = null,
    Object? examineeGrowthMultiple = null,
    Object? passRateChangePoints = null,
  }) {
    return _then(
      _value.copyWith(
            latestYear: null == latestYear
                ? _value.latestYear
                : latestYear // ignore: cast_nullable_to_non_nullable
                      as int,
            previousYear: null == previousYear
                ? _value.previousYear
                : previousYear // ignore: cast_nullable_to_non_nullable
                      as int,
            growthBaseYear: null == growthBaseYear
                ? _value.growthBaseYear
                : growthBaseYear // ignore: cast_nullable_to_non_nullable
                      as int,
            examineeGrowthMultiple: null == examineeGrowthMultiple
                ? _value.examineeGrowthMultiple
                : examineeGrowthMultiple // ignore: cast_nullable_to_non_nullable
                      as double,
            passRateChangePoints: null == passRateChangePoints
                ? _value.passRateChangePoints
                : passRateChangePoints // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SqldExamInsightsImplCopyWith<$Res>
    implements $SqldExamInsightsCopyWith<$Res> {
  factory _$$SqldExamInsightsImplCopyWith(
    _$SqldExamInsightsImpl value,
    $Res Function(_$SqldExamInsightsImpl) then,
  ) = __$$SqldExamInsightsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int latestYear,
    int previousYear,
    int growthBaseYear,
    double examineeGrowthMultiple,
    double passRateChangePoints,
  });
}

/// @nodoc
class __$$SqldExamInsightsImplCopyWithImpl<$Res>
    extends _$SqldExamInsightsCopyWithImpl<$Res, _$SqldExamInsightsImpl>
    implements _$$SqldExamInsightsImplCopyWith<$Res> {
  __$$SqldExamInsightsImplCopyWithImpl(
    _$SqldExamInsightsImpl _value,
    $Res Function(_$SqldExamInsightsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SqldExamInsights
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latestYear = null,
    Object? previousYear = null,
    Object? growthBaseYear = null,
    Object? examineeGrowthMultiple = null,
    Object? passRateChangePoints = null,
  }) {
    return _then(
      _$SqldExamInsightsImpl(
        latestYear: null == latestYear
            ? _value.latestYear
            : latestYear // ignore: cast_nullable_to_non_nullable
                  as int,
        previousYear: null == previousYear
            ? _value.previousYear
            : previousYear // ignore: cast_nullable_to_non_nullable
                  as int,
        growthBaseYear: null == growthBaseYear
            ? _value.growthBaseYear
            : growthBaseYear // ignore: cast_nullable_to_non_nullable
                  as int,
        examineeGrowthMultiple: null == examineeGrowthMultiple
            ? _value.examineeGrowthMultiple
            : examineeGrowthMultiple // ignore: cast_nullable_to_non_nullable
                  as double,
        passRateChangePoints: null == passRateChangePoints
            ? _value.passRateChangePoints
            : passRateChangePoints // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SqldExamInsightsImpl implements _SqldExamInsights {
  const _$SqldExamInsightsImpl({
    required this.latestYear,
    required this.previousYear,
    required this.growthBaseYear,
    required this.examineeGrowthMultiple,
    required this.passRateChangePoints,
  });

  factory _$SqldExamInsightsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SqldExamInsightsImplFromJson(json);

  @override
  final int latestYear;
  @override
  final int previousYear;
  @override
  final int growthBaseYear;
  @override
  final double examineeGrowthMultiple;
  @override
  final double passRateChangePoints;

  @override
  String toString() {
    return 'SqldExamInsights(latestYear: $latestYear, previousYear: $previousYear, growthBaseYear: $growthBaseYear, examineeGrowthMultiple: $examineeGrowthMultiple, passRateChangePoints: $passRateChangePoints)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SqldExamInsightsImpl &&
            (identical(other.latestYear, latestYear) ||
                other.latestYear == latestYear) &&
            (identical(other.previousYear, previousYear) ||
                other.previousYear == previousYear) &&
            (identical(other.growthBaseYear, growthBaseYear) ||
                other.growthBaseYear == growthBaseYear) &&
            (identical(other.examineeGrowthMultiple, examineeGrowthMultiple) ||
                other.examineeGrowthMultiple == examineeGrowthMultiple) &&
            (identical(other.passRateChangePoints, passRateChangePoints) ||
                other.passRateChangePoints == passRateChangePoints));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    latestYear,
    previousYear,
    growthBaseYear,
    examineeGrowthMultiple,
    passRateChangePoints,
  );

  /// Create a copy of SqldExamInsights
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SqldExamInsightsImplCopyWith<_$SqldExamInsightsImpl> get copyWith =>
      __$$SqldExamInsightsImplCopyWithImpl<_$SqldExamInsightsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SqldExamInsightsImplToJson(this);
  }
}

abstract class _SqldExamInsights implements SqldExamInsights {
  const factory _SqldExamInsights({
    required final int latestYear,
    required final int previousYear,
    required final int growthBaseYear,
    required final double examineeGrowthMultiple,
    required final double passRateChangePoints,
  }) = _$SqldExamInsightsImpl;

  factory _SqldExamInsights.fromJson(Map<String, dynamic> json) =
      _$SqldExamInsightsImpl.fromJson;

  @override
  int get latestYear;
  @override
  int get previousYear;
  @override
  int get growthBaseYear;
  @override
  double get examineeGrowthMultiple;
  @override
  double get passRateChangePoints;

  /// Create a copy of SqldExamInsights
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SqldExamInsightsImplCopyWith<_$SqldExamInsightsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SqldExamSource _$SqldExamSourceFromJson(Map<String, dynamic> json) {
  return _SqldExamSource.fromJson(json);
}

/// @nodoc
mixin _$SqldExamSource {
  String get name => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  String get checkedDate => throw _privateConstructorUsedError;

  /// Serializes this SqldExamSource to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SqldExamSource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SqldExamSourceCopyWith<SqldExamSource> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SqldExamSourceCopyWith<$Res> {
  factory $SqldExamSourceCopyWith(
    SqldExamSource value,
    $Res Function(SqldExamSource) then,
  ) = _$SqldExamSourceCopyWithImpl<$Res, SqldExamSource>;
  @useResult
  $Res call({String name, String? url, String checkedDate});
}

/// @nodoc
class _$SqldExamSourceCopyWithImpl<$Res, $Val extends SqldExamSource>
    implements $SqldExamSourceCopyWith<$Res> {
  _$SqldExamSourceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SqldExamSource
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? url = freezed,
    Object? checkedDate = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            url: freezed == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String?,
            checkedDate: null == checkedDate
                ? _value.checkedDate
                : checkedDate // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SqldExamSourceImplCopyWith<$Res>
    implements $SqldExamSourceCopyWith<$Res> {
  factory _$$SqldExamSourceImplCopyWith(
    _$SqldExamSourceImpl value,
    $Res Function(_$SqldExamSourceImpl) then,
  ) = __$$SqldExamSourceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String? url, String checkedDate});
}

/// @nodoc
class __$$SqldExamSourceImplCopyWithImpl<$Res>
    extends _$SqldExamSourceCopyWithImpl<$Res, _$SqldExamSourceImpl>
    implements _$$SqldExamSourceImplCopyWith<$Res> {
  __$$SqldExamSourceImplCopyWithImpl(
    _$SqldExamSourceImpl _value,
    $Res Function(_$SqldExamSourceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SqldExamSource
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? url = freezed,
    Object? checkedDate = null,
  }) {
    return _then(
      _$SqldExamSourceImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        url: freezed == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String?,
        checkedDate: null == checkedDate
            ? _value.checkedDate
            : checkedDate // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SqldExamSourceImpl implements _SqldExamSource {
  const _$SqldExamSourceImpl({
    required this.name,
    this.url,
    required this.checkedDate,
  });

  factory _$SqldExamSourceImpl.fromJson(Map<String, dynamic> json) =>
      _$$SqldExamSourceImplFromJson(json);

  @override
  final String name;
  @override
  final String? url;
  @override
  final String checkedDate;

  @override
  String toString() {
    return 'SqldExamSource(name: $name, url: $url, checkedDate: $checkedDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SqldExamSourceImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.checkedDate, checkedDate) ||
                other.checkedDate == checkedDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, url, checkedDate);

  /// Create a copy of SqldExamSource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SqldExamSourceImplCopyWith<_$SqldExamSourceImpl> get copyWith =>
      __$$SqldExamSourceImplCopyWithImpl<_$SqldExamSourceImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SqldExamSourceImplToJson(this);
  }
}

abstract class _SqldExamSource implements SqldExamSource {
  const factory _SqldExamSource({
    required final String name,
    final String? url,
    required final String checkedDate,
  }) = _$SqldExamSourceImpl;

  factory _SqldExamSource.fromJson(Map<String, dynamic> json) =
      _$SqldExamSourceImpl.fromJson;

  @override
  String get name;
  @override
  String? get url;
  @override
  String get checkedDate;

  /// Create a copy of SqldExamSource
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SqldExamSourceImplCopyWith<_$SqldExamSourceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
