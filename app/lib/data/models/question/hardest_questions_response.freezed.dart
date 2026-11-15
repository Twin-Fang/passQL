// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hardest_questions_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

HardestQuestionItem _$HardestQuestionItemFromJson(Map<String, dynamic> json) {
  return _HardestQuestionItem.fromJson(json);
}

/// @nodoc
mixin _$HardestQuestionItem {
  int get rank => throw _privateConstructorUsedError;
  String get questionUuid => throw _privateConstructorUsedError;
  String get stemPreview => throw _privateConstructorUsedError;
  String? get topicName => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  MockExamSubject get subject => throw _privateConstructorUsedError; // 첫 제출 오답률 (%, 소수 1자리)
  double get wrongRatePercent =>
      throw _privateConstructorUsedError; // 첫 제출 회원 수
  int get attemptCount => throw _privateConstructorUsedError;

  /// Serializes this HardestQuestionItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HardestQuestionItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HardestQuestionItemCopyWith<HardestQuestionItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HardestQuestionItemCopyWith<$Res> {
  factory $HardestQuestionItemCopyWith(
    HardestQuestionItem value,
    $Res Function(HardestQuestionItem) then,
  ) = _$HardestQuestionItemCopyWithImpl<$Res, HardestQuestionItem>;
  @useResult
  $Res call({
    int rank,
    String questionUuid,
    String stemPreview,
    String? topicName,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) MockExamSubject subject,
    double wrongRatePercent,
    int attemptCount,
  });
}

/// @nodoc
class _$HardestQuestionItemCopyWithImpl<$Res, $Val extends HardestQuestionItem>
    implements $HardestQuestionItemCopyWith<$Res> {
  _$HardestQuestionItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HardestQuestionItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rank = null,
    Object? questionUuid = null,
    Object? stemPreview = null,
    Object? topicName = freezed,
    Object? subject = null,
    Object? wrongRatePercent = null,
    Object? attemptCount = null,
  }) {
    return _then(
      _value.copyWith(
            rank: null == rank
                ? _value.rank
                : rank // ignore: cast_nullable_to_non_nullable
                      as int,
            questionUuid: null == questionUuid
                ? _value.questionUuid
                : questionUuid // ignore: cast_nullable_to_non_nullable
                      as String,
            stemPreview: null == stemPreview
                ? _value.stemPreview
                : stemPreview // ignore: cast_nullable_to_non_nullable
                      as String,
            topicName: freezed == topicName
                ? _value.topicName
                : topicName // ignore: cast_nullable_to_non_nullable
                      as String?,
            subject: null == subject
                ? _value.subject
                : subject // ignore: cast_nullable_to_non_nullable
                      as MockExamSubject,
            wrongRatePercent: null == wrongRatePercent
                ? _value.wrongRatePercent
                : wrongRatePercent // ignore: cast_nullable_to_non_nullable
                      as double,
            attemptCount: null == attemptCount
                ? _value.attemptCount
                : attemptCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HardestQuestionItemImplCopyWith<$Res>
    implements $HardestQuestionItemCopyWith<$Res> {
  factory _$$HardestQuestionItemImplCopyWith(
    _$HardestQuestionItemImpl value,
    $Res Function(_$HardestQuestionItemImpl) then,
  ) = __$$HardestQuestionItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int rank,
    String questionUuid,
    String stemPreview,
    String? topicName,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) MockExamSubject subject,
    double wrongRatePercent,
    int attemptCount,
  });
}

/// @nodoc
class __$$HardestQuestionItemImplCopyWithImpl<$Res>
    extends _$HardestQuestionItemCopyWithImpl<$Res, _$HardestQuestionItemImpl>
    implements _$$HardestQuestionItemImplCopyWith<$Res> {
  __$$HardestQuestionItemImplCopyWithImpl(
    _$HardestQuestionItemImpl _value,
    $Res Function(_$HardestQuestionItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HardestQuestionItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rank = null,
    Object? questionUuid = null,
    Object? stemPreview = null,
    Object? topicName = freezed,
    Object? subject = null,
    Object? wrongRatePercent = null,
    Object? attemptCount = null,
  }) {
    return _then(
      _$HardestQuestionItemImpl(
        rank: null == rank
            ? _value.rank
            : rank // ignore: cast_nullable_to_non_nullable
                  as int,
        questionUuid: null == questionUuid
            ? _value.questionUuid
            : questionUuid // ignore: cast_nullable_to_non_nullable
                  as String,
        stemPreview: null == stemPreview
            ? _value.stemPreview
            : stemPreview // ignore: cast_nullable_to_non_nullable
                  as String,
        topicName: freezed == topicName
            ? _value.topicName
            : topicName // ignore: cast_nullable_to_non_nullable
                  as String?,
        subject: null == subject
            ? _value.subject
            : subject // ignore: cast_nullable_to_non_nullable
                  as MockExamSubject,
        wrongRatePercent: null == wrongRatePercent
            ? _value.wrongRatePercent
            : wrongRatePercent // ignore: cast_nullable_to_non_nullable
                  as double,
        attemptCount: null == attemptCount
            ? _value.attemptCount
            : attemptCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HardestQuestionItemImpl implements _HardestQuestionItem {
  const _$HardestQuestionItemImpl({
    required this.rank,
    required this.questionUuid,
    required this.stemPreview,
    this.topicName,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown)
    this.subject = MockExamSubject.unknown,
    this.wrongRatePercent = 0,
    this.attemptCount = 0,
  });

  factory _$HardestQuestionItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$HardestQuestionItemImplFromJson(json);

  @override
  final int rank;
  @override
  final String questionUuid;
  @override
  final String stemPreview;
  @override
  final String? topicName;
  @override
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  final MockExamSubject subject;
  // 첫 제출 오답률 (%, 소수 1자리)
  @override
  @JsonKey()
  final double wrongRatePercent;
  // 첫 제출 회원 수
  @override
  @JsonKey()
  final int attemptCount;

  @override
  String toString() {
    return 'HardestQuestionItem(rank: $rank, questionUuid: $questionUuid, stemPreview: $stemPreview, topicName: $topicName, subject: $subject, wrongRatePercent: $wrongRatePercent, attemptCount: $attemptCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HardestQuestionItemImpl &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.questionUuid, questionUuid) ||
                other.questionUuid == questionUuid) &&
            (identical(other.stemPreview, stemPreview) ||
                other.stemPreview == stemPreview) &&
            (identical(other.topicName, topicName) ||
                other.topicName == topicName) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.wrongRatePercent, wrongRatePercent) ||
                other.wrongRatePercent == wrongRatePercent) &&
            (identical(other.attemptCount, attemptCount) ||
                other.attemptCount == attemptCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    rank,
    questionUuid,
    stemPreview,
    topicName,
    subject,
    wrongRatePercent,
    attemptCount,
  );

  /// Create a copy of HardestQuestionItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HardestQuestionItemImplCopyWith<_$HardestQuestionItemImpl> get copyWith =>
      __$$HardestQuestionItemImplCopyWithImpl<_$HardestQuestionItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$HardestQuestionItemImplToJson(this);
  }
}

abstract class _HardestQuestionItem implements HardestQuestionItem {
  const factory _HardestQuestionItem({
    required final int rank,
    required final String questionUuid,
    required final String stemPreview,
    final String? topicName,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown)
    final MockExamSubject subject,
    final double wrongRatePercent,
    final int attemptCount,
  }) = _$HardestQuestionItemImpl;

  factory _HardestQuestionItem.fromJson(Map<String, dynamic> json) =
      _$HardestQuestionItemImpl.fromJson;

  @override
  int get rank;
  @override
  String get questionUuid;
  @override
  String get stemPreview;
  @override
  String? get topicName;
  @override
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  MockExamSubject get subject; // 첫 제출 오답률 (%, 소수 1자리)
  @override
  double get wrongRatePercent; // 첫 제출 회원 수
  @override
  int get attemptCount;

  /// Create a copy of HardestQuestionItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HardestQuestionItemImplCopyWith<_$HardestQuestionItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HardestQuestionsResponse _$HardestQuestionsResponseFromJson(
  Map<String, dynamic> json,
) {
  return _HardestQuestionsResponse.fromJson(json);
}

/// @nodoc
mixin _$HardestQuestionsResponse {
  List<HardestQuestionItem> get items => throw _privateConstructorUsedError;
  DateTime? get aggregatedAt =>
      throw _privateConstructorUsedError; // 목록에 넣는 최소 첫 제출 회원 수
  int get minimumAttemptCount => throw _privateConstructorUsedError;

  /// Serializes this HardestQuestionsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HardestQuestionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HardestQuestionsResponseCopyWith<HardestQuestionsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HardestQuestionsResponseCopyWith<$Res> {
  factory $HardestQuestionsResponseCopyWith(
    HardestQuestionsResponse value,
    $Res Function(HardestQuestionsResponse) then,
  ) = _$HardestQuestionsResponseCopyWithImpl<$Res, HardestQuestionsResponse>;
  @useResult
  $Res call({
    List<HardestQuestionItem> items,
    DateTime? aggregatedAt,
    int minimumAttemptCount,
  });
}

/// @nodoc
class _$HardestQuestionsResponseCopyWithImpl<
  $Res,
  $Val extends HardestQuestionsResponse
>
    implements $HardestQuestionsResponseCopyWith<$Res> {
  _$HardestQuestionsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HardestQuestionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? aggregatedAt = freezed,
    Object? minimumAttemptCount = null,
  }) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<HardestQuestionItem>,
            aggregatedAt: freezed == aggregatedAt
                ? _value.aggregatedAt
                : aggregatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            minimumAttemptCount: null == minimumAttemptCount
                ? _value.minimumAttemptCount
                : minimumAttemptCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HardestQuestionsResponseImplCopyWith<$Res>
    implements $HardestQuestionsResponseCopyWith<$Res> {
  factory _$$HardestQuestionsResponseImplCopyWith(
    _$HardestQuestionsResponseImpl value,
    $Res Function(_$HardestQuestionsResponseImpl) then,
  ) = __$$HardestQuestionsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<HardestQuestionItem> items,
    DateTime? aggregatedAt,
    int minimumAttemptCount,
  });
}

/// @nodoc
class __$$HardestQuestionsResponseImplCopyWithImpl<$Res>
    extends
        _$HardestQuestionsResponseCopyWithImpl<
          $Res,
          _$HardestQuestionsResponseImpl
        >
    implements _$$HardestQuestionsResponseImplCopyWith<$Res> {
  __$$HardestQuestionsResponseImplCopyWithImpl(
    _$HardestQuestionsResponseImpl _value,
    $Res Function(_$HardestQuestionsResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HardestQuestionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? aggregatedAt = freezed,
    Object? minimumAttemptCount = null,
  }) {
    return _then(
      _$HardestQuestionsResponseImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<HardestQuestionItem>,
        aggregatedAt: freezed == aggregatedAt
            ? _value.aggregatedAt
            : aggregatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        minimumAttemptCount: null == minimumAttemptCount
            ? _value.minimumAttemptCount
            : minimumAttemptCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HardestQuestionsResponseImpl implements _HardestQuestionsResponse {
  const _$HardestQuestionsResponseImpl({
    final List<HardestQuestionItem> items = const [],
    this.aggregatedAt,
    this.minimumAttemptCount = 0,
  }) : _items = items;

  factory _$HardestQuestionsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$HardestQuestionsResponseImplFromJson(json);

  final List<HardestQuestionItem> _items;
  @override
  @JsonKey()
  List<HardestQuestionItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final DateTime? aggregatedAt;
  // 목록에 넣는 최소 첫 제출 회원 수
  @override
  @JsonKey()
  final int minimumAttemptCount;

  @override
  String toString() {
    return 'HardestQuestionsResponse(items: $items, aggregatedAt: $aggregatedAt, minimumAttemptCount: $minimumAttemptCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HardestQuestionsResponseImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.aggregatedAt, aggregatedAt) ||
                other.aggregatedAt == aggregatedAt) &&
            (identical(other.minimumAttemptCount, minimumAttemptCount) ||
                other.minimumAttemptCount == minimumAttemptCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    aggregatedAt,
    minimumAttemptCount,
  );

  /// Create a copy of HardestQuestionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HardestQuestionsResponseImplCopyWith<_$HardestQuestionsResponseImpl>
  get copyWith =>
      __$$HardestQuestionsResponseImplCopyWithImpl<
        _$HardestQuestionsResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HardestQuestionsResponseImplToJson(this);
  }
}

abstract class _HardestQuestionsResponse implements HardestQuestionsResponse {
  const factory _HardestQuestionsResponse({
    final List<HardestQuestionItem> items,
    final DateTime? aggregatedAt,
    final int minimumAttemptCount,
  }) = _$HardestQuestionsResponseImpl;

  factory _HardestQuestionsResponse.fromJson(Map<String, dynamic> json) =
      _$HardestQuestionsResponseImpl.fromJson;

  @override
  List<HardestQuestionItem> get items;
  @override
  DateTime? get aggregatedAt; // 목록에 넣는 최소 첫 제출 회원 수
  @override
  int get minimumAttemptCount;

  /// Create a copy of HardestQuestionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HardestQuestionsResponseImplCopyWith<_$HardestQuestionsResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
