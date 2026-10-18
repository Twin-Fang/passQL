// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exam_trend_report_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExamTrendReportResponse _$ExamTrendReportResponseFromJson(
  Map<String, dynamic> json,
) {
  return _ExamTrendReportResponse.fromJson(json);
}

/// @nodoc
mixin _$ExamTrendReportResponse {
  String get title => throw _privateConstructorUsedError;
  String get basisDescription => throw _privateConstructorUsedError;
  String get updatedDate => throw _privateConstructorUsedError;
  String get summary => throw _privateConstructorUsedError;
  int get latestTrendQuestionCount => throw _privateConstructorUsedError;
  List<ExamTrendSubjectShare> get subjectShares =>
      throw _privateConstructorUsedError;
  List<ExamTrendPattern> get risingPatterns =>
      throw _privateConstructorUsedError;
  List<ExamTrendConcept> get frequentConcepts =>
      throw _privateConstructorUsedError;
  List<String> get studyTips => throw _privateConstructorUsedError;
  List<LatestTrendTopicCount> get latestTrendTopics =>
      throw _privateConstructorUsedError;

  /// Serializes this ExamTrendReportResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamTrendReportResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamTrendReportResponseCopyWith<ExamTrendReportResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamTrendReportResponseCopyWith<$Res> {
  factory $ExamTrendReportResponseCopyWith(
    ExamTrendReportResponse value,
    $Res Function(ExamTrendReportResponse) then,
  ) = _$ExamTrendReportResponseCopyWithImpl<$Res, ExamTrendReportResponse>;
  @useResult
  $Res call({
    String title,
    String basisDescription,
    String updatedDate,
    String summary,
    int latestTrendQuestionCount,
    List<ExamTrendSubjectShare> subjectShares,
    List<ExamTrendPattern> risingPatterns,
    List<ExamTrendConcept> frequentConcepts,
    List<String> studyTips,
    List<LatestTrendTopicCount> latestTrendTopics,
  });
}

/// @nodoc
class _$ExamTrendReportResponseCopyWithImpl<
  $Res,
  $Val extends ExamTrendReportResponse
>
    implements $ExamTrendReportResponseCopyWith<$Res> {
  _$ExamTrendReportResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamTrendReportResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? basisDescription = null,
    Object? updatedDate = null,
    Object? summary = null,
    Object? latestTrendQuestionCount = null,
    Object? subjectShares = null,
    Object? risingPatterns = null,
    Object? frequentConcepts = null,
    Object? studyTips = null,
    Object? latestTrendTopics = null,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            basisDescription: null == basisDescription
                ? _value.basisDescription
                : basisDescription // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedDate: null == updatedDate
                ? _value.updatedDate
                : updatedDate // ignore: cast_nullable_to_non_nullable
                      as String,
            summary: null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as String,
            latestTrendQuestionCount: null == latestTrendQuestionCount
                ? _value.latestTrendQuestionCount
                : latestTrendQuestionCount // ignore: cast_nullable_to_non_nullable
                      as int,
            subjectShares: null == subjectShares
                ? _value.subjectShares
                : subjectShares // ignore: cast_nullable_to_non_nullable
                      as List<ExamTrendSubjectShare>,
            risingPatterns: null == risingPatterns
                ? _value.risingPatterns
                : risingPatterns // ignore: cast_nullable_to_non_nullable
                      as List<ExamTrendPattern>,
            frequentConcepts: null == frequentConcepts
                ? _value.frequentConcepts
                : frequentConcepts // ignore: cast_nullable_to_non_nullable
                      as List<ExamTrendConcept>,
            studyTips: null == studyTips
                ? _value.studyTips
                : studyTips // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            latestTrendTopics: null == latestTrendTopics
                ? _value.latestTrendTopics
                : latestTrendTopics // ignore: cast_nullable_to_non_nullable
                      as List<LatestTrendTopicCount>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExamTrendReportResponseImplCopyWith<$Res>
    implements $ExamTrendReportResponseCopyWith<$Res> {
  factory _$$ExamTrendReportResponseImplCopyWith(
    _$ExamTrendReportResponseImpl value,
    $Res Function(_$ExamTrendReportResponseImpl) then,
  ) = __$$ExamTrendReportResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String title,
    String basisDescription,
    String updatedDate,
    String summary,
    int latestTrendQuestionCount,
    List<ExamTrendSubjectShare> subjectShares,
    List<ExamTrendPattern> risingPatterns,
    List<ExamTrendConcept> frequentConcepts,
    List<String> studyTips,
    List<LatestTrendTopicCount> latestTrendTopics,
  });
}

/// @nodoc
class __$$ExamTrendReportResponseImplCopyWithImpl<$Res>
    extends
        _$ExamTrendReportResponseCopyWithImpl<
          $Res,
          _$ExamTrendReportResponseImpl
        >
    implements _$$ExamTrendReportResponseImplCopyWith<$Res> {
  __$$ExamTrendReportResponseImplCopyWithImpl(
    _$ExamTrendReportResponseImpl _value,
    $Res Function(_$ExamTrendReportResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamTrendReportResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? basisDescription = null,
    Object? updatedDate = null,
    Object? summary = null,
    Object? latestTrendQuestionCount = null,
    Object? subjectShares = null,
    Object? risingPatterns = null,
    Object? frequentConcepts = null,
    Object? studyTips = null,
    Object? latestTrendTopics = null,
  }) {
    return _then(
      _$ExamTrendReportResponseImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        basisDescription: null == basisDescription
            ? _value.basisDescription
            : basisDescription // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedDate: null == updatedDate
            ? _value.updatedDate
            : updatedDate // ignore: cast_nullable_to_non_nullable
                  as String,
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as String,
        latestTrendQuestionCount: null == latestTrendQuestionCount
            ? _value.latestTrendQuestionCount
            : latestTrendQuestionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        subjectShares: null == subjectShares
            ? _value._subjectShares
            : subjectShares // ignore: cast_nullable_to_non_nullable
                  as List<ExamTrendSubjectShare>,
        risingPatterns: null == risingPatterns
            ? _value._risingPatterns
            : risingPatterns // ignore: cast_nullable_to_non_nullable
                  as List<ExamTrendPattern>,
        frequentConcepts: null == frequentConcepts
            ? _value._frequentConcepts
            : frequentConcepts // ignore: cast_nullable_to_non_nullable
                  as List<ExamTrendConcept>,
        studyTips: null == studyTips
            ? _value._studyTips
            : studyTips // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        latestTrendTopics: null == latestTrendTopics
            ? _value._latestTrendTopics
            : latestTrendTopics // ignore: cast_nullable_to_non_nullable
                  as List<LatestTrendTopicCount>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamTrendReportResponseImpl implements _ExamTrendReportResponse {
  const _$ExamTrendReportResponseImpl({
    required this.title,
    required this.basisDescription,
    required this.updatedDate,
    required this.summary,
    this.latestTrendQuestionCount = 0,
    final List<ExamTrendSubjectShare> subjectShares = const [],
    final List<ExamTrendPattern> risingPatterns = const [],
    final List<ExamTrendConcept> frequentConcepts = const [],
    final List<String> studyTips = const [],
    final List<LatestTrendTopicCount> latestTrendTopics = const [],
  }) : _subjectShares = subjectShares,
       _risingPatterns = risingPatterns,
       _frequentConcepts = frequentConcepts,
       _studyTips = studyTips,
       _latestTrendTopics = latestTrendTopics;

  factory _$ExamTrendReportResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamTrendReportResponseImplFromJson(json);

  @override
  final String title;
  @override
  final String basisDescription;
  @override
  final String updatedDate;
  @override
  final String summary;
  @override
  @JsonKey()
  final int latestTrendQuestionCount;
  final List<ExamTrendSubjectShare> _subjectShares;
  @override
  @JsonKey()
  List<ExamTrendSubjectShare> get subjectShares {
    if (_subjectShares is EqualUnmodifiableListView) return _subjectShares;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subjectShares);
  }

  final List<ExamTrendPattern> _risingPatterns;
  @override
  @JsonKey()
  List<ExamTrendPattern> get risingPatterns {
    if (_risingPatterns is EqualUnmodifiableListView) return _risingPatterns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_risingPatterns);
  }

  final List<ExamTrendConcept> _frequentConcepts;
  @override
  @JsonKey()
  List<ExamTrendConcept> get frequentConcepts {
    if (_frequentConcepts is EqualUnmodifiableListView)
      return _frequentConcepts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_frequentConcepts);
  }

  final List<String> _studyTips;
  @override
  @JsonKey()
  List<String> get studyTips {
    if (_studyTips is EqualUnmodifiableListView) return _studyTips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_studyTips);
  }

  final List<LatestTrendTopicCount> _latestTrendTopics;
  @override
  @JsonKey()
  List<LatestTrendTopicCount> get latestTrendTopics {
    if (_latestTrendTopics is EqualUnmodifiableListView)
      return _latestTrendTopics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_latestTrendTopics);
  }

  @override
  String toString() {
    return 'ExamTrendReportResponse(title: $title, basisDescription: $basisDescription, updatedDate: $updatedDate, summary: $summary, latestTrendQuestionCount: $latestTrendQuestionCount, subjectShares: $subjectShares, risingPatterns: $risingPatterns, frequentConcepts: $frequentConcepts, studyTips: $studyTips, latestTrendTopics: $latestTrendTopics)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamTrendReportResponseImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.basisDescription, basisDescription) ||
                other.basisDescription == basisDescription) &&
            (identical(other.updatedDate, updatedDate) ||
                other.updatedDate == updatedDate) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(
                  other.latestTrendQuestionCount,
                  latestTrendQuestionCount,
                ) ||
                other.latestTrendQuestionCount == latestTrendQuestionCount) &&
            const DeepCollectionEquality().equals(
              other._subjectShares,
              _subjectShares,
            ) &&
            const DeepCollectionEquality().equals(
              other._risingPatterns,
              _risingPatterns,
            ) &&
            const DeepCollectionEquality().equals(
              other._frequentConcepts,
              _frequentConcepts,
            ) &&
            const DeepCollectionEquality().equals(
              other._studyTips,
              _studyTips,
            ) &&
            const DeepCollectionEquality().equals(
              other._latestTrendTopics,
              _latestTrendTopics,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    basisDescription,
    updatedDate,
    summary,
    latestTrendQuestionCount,
    const DeepCollectionEquality().hash(_subjectShares),
    const DeepCollectionEquality().hash(_risingPatterns),
    const DeepCollectionEquality().hash(_frequentConcepts),
    const DeepCollectionEquality().hash(_studyTips),
    const DeepCollectionEquality().hash(_latestTrendTopics),
  );

  /// Create a copy of ExamTrendReportResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamTrendReportResponseImplCopyWith<_$ExamTrendReportResponseImpl>
  get copyWith =>
      __$$ExamTrendReportResponseImplCopyWithImpl<
        _$ExamTrendReportResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamTrendReportResponseImplToJson(this);
  }
}

abstract class _ExamTrendReportResponse implements ExamTrendReportResponse {
  const factory _ExamTrendReportResponse({
    required final String title,
    required final String basisDescription,
    required final String updatedDate,
    required final String summary,
    final int latestTrendQuestionCount,
    final List<ExamTrendSubjectShare> subjectShares,
    final List<ExamTrendPattern> risingPatterns,
    final List<ExamTrendConcept> frequentConcepts,
    final List<String> studyTips,
    final List<LatestTrendTopicCount> latestTrendTopics,
  }) = _$ExamTrendReportResponseImpl;

  factory _ExamTrendReportResponse.fromJson(Map<String, dynamic> json) =
      _$ExamTrendReportResponseImpl.fromJson;

  @override
  String get title;
  @override
  String get basisDescription;
  @override
  String get updatedDate;
  @override
  String get summary;
  @override
  int get latestTrendQuestionCount;
  @override
  List<ExamTrendSubjectShare> get subjectShares;
  @override
  List<ExamTrendPattern> get risingPatterns;
  @override
  List<ExamTrendConcept> get frequentConcepts;
  @override
  List<String> get studyTips;
  @override
  List<LatestTrendTopicCount> get latestTrendTopics;

  /// Create a copy of ExamTrendReportResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamTrendReportResponseImplCopyWith<_$ExamTrendReportResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ExamTrendSubjectShare _$ExamTrendSubjectShareFromJson(
  Map<String, dynamic> json,
) {
  return _ExamTrendSubjectShare.fromJson(json);
}

/// @nodoc
mixin _$ExamTrendSubjectShare {
  String get subjectName => throw _privateConstructorUsedError;
  int get questionCount => throw _privateConstructorUsedError;
  int get percent => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  /// Serializes this ExamTrendSubjectShare to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamTrendSubjectShare
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamTrendSubjectShareCopyWith<ExamTrendSubjectShare> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamTrendSubjectShareCopyWith<$Res> {
  factory $ExamTrendSubjectShareCopyWith(
    ExamTrendSubjectShare value,
    $Res Function(ExamTrendSubjectShare) then,
  ) = _$ExamTrendSubjectShareCopyWithImpl<$Res, ExamTrendSubjectShare>;
  @useResult
  $Res call({
    String subjectName,
    int questionCount,
    int percent,
    String description,
  });
}

/// @nodoc
class _$ExamTrendSubjectShareCopyWithImpl<
  $Res,
  $Val extends ExamTrendSubjectShare
>
    implements $ExamTrendSubjectShareCopyWith<$Res> {
  _$ExamTrendSubjectShareCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamTrendSubjectShare
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subjectName = null,
    Object? questionCount = null,
    Object? percent = null,
    Object? description = null,
  }) {
    return _then(
      _value.copyWith(
            subjectName: null == subjectName
                ? _value.subjectName
                : subjectName // ignore: cast_nullable_to_non_nullable
                      as String,
            questionCount: null == questionCount
                ? _value.questionCount
                : questionCount // ignore: cast_nullable_to_non_nullable
                      as int,
            percent: null == percent
                ? _value.percent
                : percent // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$ExamTrendSubjectShareImplCopyWith<$Res>
    implements $ExamTrendSubjectShareCopyWith<$Res> {
  factory _$$ExamTrendSubjectShareImplCopyWith(
    _$ExamTrendSubjectShareImpl value,
    $Res Function(_$ExamTrendSubjectShareImpl) then,
  ) = __$$ExamTrendSubjectShareImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String subjectName,
    int questionCount,
    int percent,
    String description,
  });
}

/// @nodoc
class __$$ExamTrendSubjectShareImplCopyWithImpl<$Res>
    extends
        _$ExamTrendSubjectShareCopyWithImpl<$Res, _$ExamTrendSubjectShareImpl>
    implements _$$ExamTrendSubjectShareImplCopyWith<$Res> {
  __$$ExamTrendSubjectShareImplCopyWithImpl(
    _$ExamTrendSubjectShareImpl _value,
    $Res Function(_$ExamTrendSubjectShareImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamTrendSubjectShare
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subjectName = null,
    Object? questionCount = null,
    Object? percent = null,
    Object? description = null,
  }) {
    return _then(
      _$ExamTrendSubjectShareImpl(
        subjectName: null == subjectName
            ? _value.subjectName
            : subjectName // ignore: cast_nullable_to_non_nullable
                  as String,
        questionCount: null == questionCount
            ? _value.questionCount
            : questionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        percent: null == percent
            ? _value.percent
            : percent // ignore: cast_nullable_to_non_nullable
                  as int,
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
class _$ExamTrendSubjectShareImpl implements _ExamTrendSubjectShare {
  const _$ExamTrendSubjectShareImpl({
    required this.subjectName,
    required this.questionCount,
    required this.percent,
    required this.description,
  });

  factory _$ExamTrendSubjectShareImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamTrendSubjectShareImplFromJson(json);

  @override
  final String subjectName;
  @override
  final int questionCount;
  @override
  final int percent;
  @override
  final String description;

  @override
  String toString() {
    return 'ExamTrendSubjectShare(subjectName: $subjectName, questionCount: $questionCount, percent: $percent, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamTrendSubjectShareImpl &&
            (identical(other.subjectName, subjectName) ||
                other.subjectName == subjectName) &&
            (identical(other.questionCount, questionCount) ||
                other.questionCount == questionCount) &&
            (identical(other.percent, percent) || other.percent == percent) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    subjectName,
    questionCount,
    percent,
    description,
  );

  /// Create a copy of ExamTrendSubjectShare
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamTrendSubjectShareImplCopyWith<_$ExamTrendSubjectShareImpl>
  get copyWith =>
      __$$ExamTrendSubjectShareImplCopyWithImpl<_$ExamTrendSubjectShareImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamTrendSubjectShareImplToJson(this);
  }
}

abstract class _ExamTrendSubjectShare implements ExamTrendSubjectShare {
  const factory _ExamTrendSubjectShare({
    required final String subjectName,
    required final int questionCount,
    required final int percent,
    required final String description,
  }) = _$ExamTrendSubjectShareImpl;

  factory _ExamTrendSubjectShare.fromJson(Map<String, dynamic> json) =
      _$ExamTrendSubjectShareImpl.fromJson;

  @override
  String get subjectName;
  @override
  int get questionCount;
  @override
  int get percent;
  @override
  String get description;

  /// Create a copy of ExamTrendSubjectShare
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamTrendSubjectShareImplCopyWith<_$ExamTrendSubjectShareImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ExamTrendPattern _$ExamTrendPatternFromJson(Map<String, dynamic> json) {
  return _ExamTrendPattern.fromJson(json);
}

/// @nodoc
mixin _$ExamTrendPattern {
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get examRoundsText => throw _privateConstructorUsedError;
  String get topicCode =>
      throw _privateConstructorUsedError; // 최신 경향 문제 없는 토픽이면 null
  String? get topicName => throw _privateConstructorUsedError;
  int get latestTrendQuestionCount => throw _privateConstructorUsedError;

  /// Serializes this ExamTrendPattern to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamTrendPattern
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamTrendPatternCopyWith<ExamTrendPattern> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamTrendPatternCopyWith<$Res> {
  factory $ExamTrendPatternCopyWith(
    ExamTrendPattern value,
    $Res Function(ExamTrendPattern) then,
  ) = _$ExamTrendPatternCopyWithImpl<$Res, ExamTrendPattern>;
  @useResult
  $Res call({
    String title,
    String description,
    String examRoundsText,
    String topicCode,
    String? topicName,
    int latestTrendQuestionCount,
  });
}

/// @nodoc
class _$ExamTrendPatternCopyWithImpl<$Res, $Val extends ExamTrendPattern>
    implements $ExamTrendPatternCopyWith<$Res> {
  _$ExamTrendPatternCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamTrendPattern
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? examRoundsText = null,
    Object? topicCode = null,
    Object? topicName = freezed,
    Object? latestTrendQuestionCount = null,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            examRoundsText: null == examRoundsText
                ? _value.examRoundsText
                : examRoundsText // ignore: cast_nullable_to_non_nullable
                      as String,
            topicCode: null == topicCode
                ? _value.topicCode
                : topicCode // ignore: cast_nullable_to_non_nullable
                      as String,
            topicName: freezed == topicName
                ? _value.topicName
                : topicName // ignore: cast_nullable_to_non_nullable
                      as String?,
            latestTrendQuestionCount: null == latestTrendQuestionCount
                ? _value.latestTrendQuestionCount
                : latestTrendQuestionCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExamTrendPatternImplCopyWith<$Res>
    implements $ExamTrendPatternCopyWith<$Res> {
  factory _$$ExamTrendPatternImplCopyWith(
    _$ExamTrendPatternImpl value,
    $Res Function(_$ExamTrendPatternImpl) then,
  ) = __$$ExamTrendPatternImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String title,
    String description,
    String examRoundsText,
    String topicCode,
    String? topicName,
    int latestTrendQuestionCount,
  });
}

/// @nodoc
class __$$ExamTrendPatternImplCopyWithImpl<$Res>
    extends _$ExamTrendPatternCopyWithImpl<$Res, _$ExamTrendPatternImpl>
    implements _$$ExamTrendPatternImplCopyWith<$Res> {
  __$$ExamTrendPatternImplCopyWithImpl(
    _$ExamTrendPatternImpl _value,
    $Res Function(_$ExamTrendPatternImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamTrendPattern
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? examRoundsText = null,
    Object? topicCode = null,
    Object? topicName = freezed,
    Object? latestTrendQuestionCount = null,
  }) {
    return _then(
      _$ExamTrendPatternImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        examRoundsText: null == examRoundsText
            ? _value.examRoundsText
            : examRoundsText // ignore: cast_nullable_to_non_nullable
                  as String,
        topicCode: null == topicCode
            ? _value.topicCode
            : topicCode // ignore: cast_nullable_to_non_nullable
                  as String,
        topicName: freezed == topicName
            ? _value.topicName
            : topicName // ignore: cast_nullable_to_non_nullable
                  as String?,
        latestTrendQuestionCount: null == latestTrendQuestionCount
            ? _value.latestTrendQuestionCount
            : latestTrendQuestionCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamTrendPatternImpl implements _ExamTrendPattern {
  const _$ExamTrendPatternImpl({
    required this.title,
    required this.description,
    required this.examRoundsText,
    required this.topicCode,
    this.topicName,
    this.latestTrendQuestionCount = 0,
  });

  factory _$ExamTrendPatternImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamTrendPatternImplFromJson(json);

  @override
  final String title;
  @override
  final String description;
  @override
  final String examRoundsText;
  @override
  final String topicCode;
  // 최신 경향 문제 없는 토픽이면 null
  @override
  final String? topicName;
  @override
  @JsonKey()
  final int latestTrendQuestionCount;

  @override
  String toString() {
    return 'ExamTrendPattern(title: $title, description: $description, examRoundsText: $examRoundsText, topicCode: $topicCode, topicName: $topicName, latestTrendQuestionCount: $latestTrendQuestionCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamTrendPatternImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.examRoundsText, examRoundsText) ||
                other.examRoundsText == examRoundsText) &&
            (identical(other.topicCode, topicCode) ||
                other.topicCode == topicCode) &&
            (identical(other.topicName, topicName) ||
                other.topicName == topicName) &&
            (identical(
                  other.latestTrendQuestionCount,
                  latestTrendQuestionCount,
                ) ||
                other.latestTrendQuestionCount == latestTrendQuestionCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    description,
    examRoundsText,
    topicCode,
    topicName,
    latestTrendQuestionCount,
  );

  /// Create a copy of ExamTrendPattern
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamTrendPatternImplCopyWith<_$ExamTrendPatternImpl> get copyWith =>
      __$$ExamTrendPatternImplCopyWithImpl<_$ExamTrendPatternImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamTrendPatternImplToJson(this);
  }
}

abstract class _ExamTrendPattern implements ExamTrendPattern {
  const factory _ExamTrendPattern({
    required final String title,
    required final String description,
    required final String examRoundsText,
    required final String topicCode,
    final String? topicName,
    final int latestTrendQuestionCount,
  }) = _$ExamTrendPatternImpl;

  factory _ExamTrendPattern.fromJson(Map<String, dynamic> json) =
      _$ExamTrendPatternImpl.fromJson;

  @override
  String get title;
  @override
  String get description;
  @override
  String get examRoundsText;
  @override
  String get topicCode; // 최신 경향 문제 없는 토픽이면 null
  @override
  String? get topicName;
  @override
  int get latestTrendQuestionCount;

  /// Create a copy of ExamTrendPattern
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamTrendPatternImplCopyWith<_$ExamTrendPatternImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExamTrendConcept _$ExamTrendConceptFromJson(Map<String, dynamic> json) {
  return _ExamTrendConcept.fromJson(json);
}

/// @nodoc
mixin _$ExamTrendConcept {
  int get rank => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get frequencyText => throw _privateConstructorUsedError;
  String get topicCode =>
      throw _privateConstructorUsedError; // 최신 경향 문제 없는 토픽이면 null
  String? get topicName => throw _privateConstructorUsedError;
  int get latestTrendQuestionCount => throw _privateConstructorUsedError;

  /// Serializes this ExamTrendConcept to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamTrendConcept
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamTrendConceptCopyWith<ExamTrendConcept> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamTrendConceptCopyWith<$Res> {
  factory $ExamTrendConceptCopyWith(
    ExamTrendConcept value,
    $Res Function(ExamTrendConcept) then,
  ) = _$ExamTrendConceptCopyWithImpl<$Res, ExamTrendConcept>;
  @useResult
  $Res call({
    int rank,
    String name,
    String description,
    String frequencyText,
    String topicCode,
    String? topicName,
    int latestTrendQuestionCount,
  });
}

/// @nodoc
class _$ExamTrendConceptCopyWithImpl<$Res, $Val extends ExamTrendConcept>
    implements $ExamTrendConceptCopyWith<$Res> {
  _$ExamTrendConceptCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamTrendConcept
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rank = null,
    Object? name = null,
    Object? description = null,
    Object? frequencyText = null,
    Object? topicCode = null,
    Object? topicName = freezed,
    Object? latestTrendQuestionCount = null,
  }) {
    return _then(
      _value.copyWith(
            rank: null == rank
                ? _value.rank
                : rank // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            frequencyText: null == frequencyText
                ? _value.frequencyText
                : frequencyText // ignore: cast_nullable_to_non_nullable
                      as String,
            topicCode: null == topicCode
                ? _value.topicCode
                : topicCode // ignore: cast_nullable_to_non_nullable
                      as String,
            topicName: freezed == topicName
                ? _value.topicName
                : topicName // ignore: cast_nullable_to_non_nullable
                      as String?,
            latestTrendQuestionCount: null == latestTrendQuestionCount
                ? _value.latestTrendQuestionCount
                : latestTrendQuestionCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExamTrendConceptImplCopyWith<$Res>
    implements $ExamTrendConceptCopyWith<$Res> {
  factory _$$ExamTrendConceptImplCopyWith(
    _$ExamTrendConceptImpl value,
    $Res Function(_$ExamTrendConceptImpl) then,
  ) = __$$ExamTrendConceptImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int rank,
    String name,
    String description,
    String frequencyText,
    String topicCode,
    String? topicName,
    int latestTrendQuestionCount,
  });
}

/// @nodoc
class __$$ExamTrendConceptImplCopyWithImpl<$Res>
    extends _$ExamTrendConceptCopyWithImpl<$Res, _$ExamTrendConceptImpl>
    implements _$$ExamTrendConceptImplCopyWith<$Res> {
  __$$ExamTrendConceptImplCopyWithImpl(
    _$ExamTrendConceptImpl _value,
    $Res Function(_$ExamTrendConceptImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamTrendConcept
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rank = null,
    Object? name = null,
    Object? description = null,
    Object? frequencyText = null,
    Object? topicCode = null,
    Object? topicName = freezed,
    Object? latestTrendQuestionCount = null,
  }) {
    return _then(
      _$ExamTrendConceptImpl(
        rank: null == rank
            ? _value.rank
            : rank // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        frequencyText: null == frequencyText
            ? _value.frequencyText
            : frequencyText // ignore: cast_nullable_to_non_nullable
                  as String,
        topicCode: null == topicCode
            ? _value.topicCode
            : topicCode // ignore: cast_nullable_to_non_nullable
                  as String,
        topicName: freezed == topicName
            ? _value.topicName
            : topicName // ignore: cast_nullable_to_non_nullable
                  as String?,
        latestTrendQuestionCount: null == latestTrendQuestionCount
            ? _value.latestTrendQuestionCount
            : latestTrendQuestionCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamTrendConceptImpl implements _ExamTrendConcept {
  const _$ExamTrendConceptImpl({
    required this.rank,
    required this.name,
    required this.description,
    required this.frequencyText,
    required this.topicCode,
    this.topicName,
    this.latestTrendQuestionCount = 0,
  });

  factory _$ExamTrendConceptImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamTrendConceptImplFromJson(json);

  @override
  final int rank;
  @override
  final String name;
  @override
  final String description;
  @override
  final String frequencyText;
  @override
  final String topicCode;
  // 최신 경향 문제 없는 토픽이면 null
  @override
  final String? topicName;
  @override
  @JsonKey()
  final int latestTrendQuestionCount;

  @override
  String toString() {
    return 'ExamTrendConcept(rank: $rank, name: $name, description: $description, frequencyText: $frequencyText, topicCode: $topicCode, topicName: $topicName, latestTrendQuestionCount: $latestTrendQuestionCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamTrendConceptImpl &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.frequencyText, frequencyText) ||
                other.frequencyText == frequencyText) &&
            (identical(other.topicCode, topicCode) ||
                other.topicCode == topicCode) &&
            (identical(other.topicName, topicName) ||
                other.topicName == topicName) &&
            (identical(
                  other.latestTrendQuestionCount,
                  latestTrendQuestionCount,
                ) ||
                other.latestTrendQuestionCount == latestTrendQuestionCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    rank,
    name,
    description,
    frequencyText,
    topicCode,
    topicName,
    latestTrendQuestionCount,
  );

  /// Create a copy of ExamTrendConcept
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamTrendConceptImplCopyWith<_$ExamTrendConceptImpl> get copyWith =>
      __$$ExamTrendConceptImplCopyWithImpl<_$ExamTrendConceptImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamTrendConceptImplToJson(this);
  }
}

abstract class _ExamTrendConcept implements ExamTrendConcept {
  const factory _ExamTrendConcept({
    required final int rank,
    required final String name,
    required final String description,
    required final String frequencyText,
    required final String topicCode,
    final String? topicName,
    final int latestTrendQuestionCount,
  }) = _$ExamTrendConceptImpl;

  factory _ExamTrendConcept.fromJson(Map<String, dynamic> json) =
      _$ExamTrendConceptImpl.fromJson;

  @override
  int get rank;
  @override
  String get name;
  @override
  String get description;
  @override
  String get frequencyText;
  @override
  String get topicCode; // 최신 경향 문제 없는 토픽이면 null
  @override
  String? get topicName;
  @override
  int get latestTrendQuestionCount;

  /// Create a copy of ExamTrendConcept
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamTrendConceptImplCopyWith<_$ExamTrendConceptImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LatestTrendTopicCount _$LatestTrendTopicCountFromJson(
  Map<String, dynamic> json,
) {
  return _LatestTrendTopicCount.fromJson(json);
}

/// @nodoc
mixin _$LatestTrendTopicCount {
  String get topicCode => throw _privateConstructorUsedError;
  String get topicName => throw _privateConstructorUsedError;
  int get latestTrendQuestionCount => throw _privateConstructorUsedError;

  /// Serializes this LatestTrendTopicCount to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LatestTrendTopicCount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LatestTrendTopicCountCopyWith<LatestTrendTopicCount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LatestTrendTopicCountCopyWith<$Res> {
  factory $LatestTrendTopicCountCopyWith(
    LatestTrendTopicCount value,
    $Res Function(LatestTrendTopicCount) then,
  ) = _$LatestTrendTopicCountCopyWithImpl<$Res, LatestTrendTopicCount>;
  @useResult
  $Res call({String topicCode, String topicName, int latestTrendQuestionCount});
}

/// @nodoc
class _$LatestTrendTopicCountCopyWithImpl<
  $Res,
  $Val extends LatestTrendTopicCount
>
    implements $LatestTrendTopicCountCopyWith<$Res> {
  _$LatestTrendTopicCountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LatestTrendTopicCount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topicCode = null,
    Object? topicName = null,
    Object? latestTrendQuestionCount = null,
  }) {
    return _then(
      _value.copyWith(
            topicCode: null == topicCode
                ? _value.topicCode
                : topicCode // ignore: cast_nullable_to_non_nullable
                      as String,
            topicName: null == topicName
                ? _value.topicName
                : topicName // ignore: cast_nullable_to_non_nullable
                      as String,
            latestTrendQuestionCount: null == latestTrendQuestionCount
                ? _value.latestTrendQuestionCount
                : latestTrendQuestionCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LatestTrendTopicCountImplCopyWith<$Res>
    implements $LatestTrendTopicCountCopyWith<$Res> {
  factory _$$LatestTrendTopicCountImplCopyWith(
    _$LatestTrendTopicCountImpl value,
    $Res Function(_$LatestTrendTopicCountImpl) then,
  ) = __$$LatestTrendTopicCountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String topicCode, String topicName, int latestTrendQuestionCount});
}

/// @nodoc
class __$$LatestTrendTopicCountImplCopyWithImpl<$Res>
    extends
        _$LatestTrendTopicCountCopyWithImpl<$Res, _$LatestTrendTopicCountImpl>
    implements _$$LatestTrendTopicCountImplCopyWith<$Res> {
  __$$LatestTrendTopicCountImplCopyWithImpl(
    _$LatestTrendTopicCountImpl _value,
    $Res Function(_$LatestTrendTopicCountImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LatestTrendTopicCount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topicCode = null,
    Object? topicName = null,
    Object? latestTrendQuestionCount = null,
  }) {
    return _then(
      _$LatestTrendTopicCountImpl(
        topicCode: null == topicCode
            ? _value.topicCode
            : topicCode // ignore: cast_nullable_to_non_nullable
                  as String,
        topicName: null == topicName
            ? _value.topicName
            : topicName // ignore: cast_nullable_to_non_nullable
                  as String,
        latestTrendQuestionCount: null == latestTrendQuestionCount
            ? _value.latestTrendQuestionCount
            : latestTrendQuestionCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LatestTrendTopicCountImpl implements _LatestTrendTopicCount {
  const _$LatestTrendTopicCountImpl({
    required this.topicCode,
    required this.topicName,
    this.latestTrendQuestionCount = 0,
  });

  factory _$LatestTrendTopicCountImpl.fromJson(Map<String, dynamic> json) =>
      _$$LatestTrendTopicCountImplFromJson(json);

  @override
  final String topicCode;
  @override
  final String topicName;
  @override
  @JsonKey()
  final int latestTrendQuestionCount;

  @override
  String toString() {
    return 'LatestTrendTopicCount(topicCode: $topicCode, topicName: $topicName, latestTrendQuestionCount: $latestTrendQuestionCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LatestTrendTopicCountImpl &&
            (identical(other.topicCode, topicCode) ||
                other.topicCode == topicCode) &&
            (identical(other.topicName, topicName) ||
                other.topicName == topicName) &&
            (identical(
                  other.latestTrendQuestionCount,
                  latestTrendQuestionCount,
                ) ||
                other.latestTrendQuestionCount == latestTrendQuestionCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, topicCode, topicName, latestTrendQuestionCount);

  /// Create a copy of LatestTrendTopicCount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LatestTrendTopicCountImplCopyWith<_$LatestTrendTopicCountImpl>
  get copyWith =>
      __$$LatestTrendTopicCountImplCopyWithImpl<_$LatestTrendTopicCountImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LatestTrendTopicCountImplToJson(this);
  }
}

abstract class _LatestTrendTopicCount implements LatestTrendTopicCount {
  const factory _LatestTrendTopicCount({
    required final String topicCode,
    required final String topicName,
    final int latestTrendQuestionCount,
  }) = _$LatestTrendTopicCountImpl;

  factory _LatestTrendTopicCount.fromJson(Map<String, dynamic> json) =
      _$LatestTrendTopicCountImpl.fromJson;

  @override
  String get topicCode;
  @override
  String get topicName;
  @override
  int get latestTrendQuestionCount;

  /// Create a copy of LatestTrendTopicCount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LatestTrendTopicCountImplCopyWith<_$LatestTrendTopicCountImpl>
  get copyWith => throw _privateConstructorUsedError;
}
