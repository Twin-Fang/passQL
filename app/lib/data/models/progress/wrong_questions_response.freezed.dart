// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wrong_questions_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WrongQuestionItem _$WrongQuestionItemFromJson(Map<String, dynamic> json) {
  return _WrongQuestionItem.fromJson(json);
}

/// @nodoc
mixin _$WrongQuestionItem {
  String get questionUuid => throw _privateConstructorUsedError;
  String get stemPreview => throw _privateConstructorUsedError;
  String? get topicName => throw _privateConstructorUsedError;
  DateTime? get lastWrongAt =>
      throw _privateConstructorUsedError; // 틀린 횟수 (구버전 서버면 0 > 표시 안 함, #1081)
  int get wrongCount =>
      throw _privateConstructorUsedError; // 정리됨: 그 문제 최신 제출이 정답 (#1081)
  bool get isResolved =>
      throw _privateConstructorUsedError; // 과목 (토픽 data_modeling 이면 1과목, #1081)
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  MockExamSubject get subject => throw _privateConstructorUsedError;

  /// Serializes this WrongQuestionItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WrongQuestionItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WrongQuestionItemCopyWith<WrongQuestionItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WrongQuestionItemCopyWith<$Res> {
  factory $WrongQuestionItemCopyWith(
    WrongQuestionItem value,
    $Res Function(WrongQuestionItem) then,
  ) = _$WrongQuestionItemCopyWithImpl<$Res, WrongQuestionItem>;
  @useResult
  $Res call({
    String questionUuid,
    String stemPreview,
    String? topicName,
    DateTime? lastWrongAt,
    int wrongCount,
    bool isResolved,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) MockExamSubject subject,
  });
}

/// @nodoc
class _$WrongQuestionItemCopyWithImpl<$Res, $Val extends WrongQuestionItem>
    implements $WrongQuestionItemCopyWith<$Res> {
  _$WrongQuestionItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WrongQuestionItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionUuid = null,
    Object? stemPreview = null,
    Object? topicName = freezed,
    Object? lastWrongAt = freezed,
    Object? wrongCount = null,
    Object? isResolved = null,
    Object? subject = null,
  }) {
    return _then(
      _value.copyWith(
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
            lastWrongAt: freezed == lastWrongAt
                ? _value.lastWrongAt
                : lastWrongAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            wrongCount: null == wrongCount
                ? _value.wrongCount
                : wrongCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isResolved: null == isResolved
                ? _value.isResolved
                : isResolved // ignore: cast_nullable_to_non_nullable
                      as bool,
            subject: null == subject
                ? _value.subject
                : subject // ignore: cast_nullable_to_non_nullable
                      as MockExamSubject,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WrongQuestionItemImplCopyWith<$Res>
    implements $WrongQuestionItemCopyWith<$Res> {
  factory _$$WrongQuestionItemImplCopyWith(
    _$WrongQuestionItemImpl value,
    $Res Function(_$WrongQuestionItemImpl) then,
  ) = __$$WrongQuestionItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String questionUuid,
    String stemPreview,
    String? topicName,
    DateTime? lastWrongAt,
    int wrongCount,
    bool isResolved,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) MockExamSubject subject,
  });
}

/// @nodoc
class __$$WrongQuestionItemImplCopyWithImpl<$Res>
    extends _$WrongQuestionItemCopyWithImpl<$Res, _$WrongQuestionItemImpl>
    implements _$$WrongQuestionItemImplCopyWith<$Res> {
  __$$WrongQuestionItemImplCopyWithImpl(
    _$WrongQuestionItemImpl _value,
    $Res Function(_$WrongQuestionItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WrongQuestionItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionUuid = null,
    Object? stemPreview = null,
    Object? topicName = freezed,
    Object? lastWrongAt = freezed,
    Object? wrongCount = null,
    Object? isResolved = null,
    Object? subject = null,
  }) {
    return _then(
      _$WrongQuestionItemImpl(
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
        lastWrongAt: freezed == lastWrongAt
            ? _value.lastWrongAt
            : lastWrongAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        wrongCount: null == wrongCount
            ? _value.wrongCount
            : wrongCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isResolved: null == isResolved
            ? _value.isResolved
            : isResolved // ignore: cast_nullable_to_non_nullable
                  as bool,
        subject: null == subject
            ? _value.subject
            : subject // ignore: cast_nullable_to_non_nullable
                  as MockExamSubject,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WrongQuestionItemImpl implements _WrongQuestionItem {
  const _$WrongQuestionItemImpl({
    required this.questionUuid,
    required this.stemPreview,
    this.topicName,
    this.lastWrongAt,
    this.wrongCount = 0,
    this.isResolved = false,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown)
    this.subject = MockExamSubject.unknown,
  });

  factory _$WrongQuestionItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$WrongQuestionItemImplFromJson(json);

  @override
  final String questionUuid;
  @override
  final String stemPreview;
  @override
  final String? topicName;
  @override
  final DateTime? lastWrongAt;
  // 틀린 횟수 (구버전 서버면 0 > 표시 안 함, #1081)
  @override
  @JsonKey()
  final int wrongCount;
  // 정리됨: 그 문제 최신 제출이 정답 (#1081)
  @override
  @JsonKey()
  final bool isResolved;
  // 과목 (토픽 data_modeling 이면 1과목, #1081)
  @override
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  final MockExamSubject subject;

  @override
  String toString() {
    return 'WrongQuestionItem(questionUuid: $questionUuid, stemPreview: $stemPreview, topicName: $topicName, lastWrongAt: $lastWrongAt, wrongCount: $wrongCount, isResolved: $isResolved, subject: $subject)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WrongQuestionItemImpl &&
            (identical(other.questionUuid, questionUuid) ||
                other.questionUuid == questionUuid) &&
            (identical(other.stemPreview, stemPreview) ||
                other.stemPreview == stemPreview) &&
            (identical(other.topicName, topicName) ||
                other.topicName == topicName) &&
            (identical(other.lastWrongAt, lastWrongAt) ||
                other.lastWrongAt == lastWrongAt) &&
            (identical(other.wrongCount, wrongCount) ||
                other.wrongCount == wrongCount) &&
            (identical(other.isResolved, isResolved) ||
                other.isResolved == isResolved) &&
            (identical(other.subject, subject) || other.subject == subject));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    questionUuid,
    stemPreview,
    topicName,
    lastWrongAt,
    wrongCount,
    isResolved,
    subject,
  );

  /// Create a copy of WrongQuestionItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WrongQuestionItemImplCopyWith<_$WrongQuestionItemImpl> get copyWith =>
      __$$WrongQuestionItemImplCopyWithImpl<_$WrongQuestionItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WrongQuestionItemImplToJson(this);
  }
}

abstract class _WrongQuestionItem implements WrongQuestionItem {
  const factory _WrongQuestionItem({
    required final String questionUuid,
    required final String stemPreview,
    final String? topicName,
    final DateTime? lastWrongAt,
    final int wrongCount,
    final bool isResolved,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown)
    final MockExamSubject subject,
  }) = _$WrongQuestionItemImpl;

  factory _WrongQuestionItem.fromJson(Map<String, dynamic> json) =
      _$WrongQuestionItemImpl.fromJson;

  @override
  String get questionUuid;
  @override
  String get stemPreview;
  @override
  String? get topicName;
  @override
  DateTime? get lastWrongAt; // 틀린 횟수 (구버전 서버면 0 > 표시 안 함, #1081)
  @override
  int get wrongCount; // 정리됨: 그 문제 최신 제출이 정답 (#1081)
  @override
  bool get isResolved; // 과목 (토픽 data_modeling 이면 1과목, #1081)
  @override
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  MockExamSubject get subject;

  /// Create a copy of WrongQuestionItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WrongQuestionItemImplCopyWith<_$WrongQuestionItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WrongQuestionsResponse _$WrongQuestionsResponseFromJson(
  Map<String, dynamic> json,
) {
  return _WrongQuestionsResponse.fromJson(json);
}

/// @nodoc
mixin _$WrongQuestionsResponse {
  List<WrongQuestionItem> get items => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;

  /// Serializes this WrongQuestionsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WrongQuestionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WrongQuestionsResponseCopyWith<WrongQuestionsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WrongQuestionsResponseCopyWith<$Res> {
  factory $WrongQuestionsResponseCopyWith(
    WrongQuestionsResponse value,
    $Res Function(WrongQuestionsResponse) then,
  ) = _$WrongQuestionsResponseCopyWithImpl<$Res, WrongQuestionsResponse>;
  @useResult
  $Res call({List<WrongQuestionItem> items, int totalCount});
}

/// @nodoc
class _$WrongQuestionsResponseCopyWithImpl<
  $Res,
  $Val extends WrongQuestionsResponse
>
    implements $WrongQuestionsResponseCopyWith<$Res> {
  _$WrongQuestionsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WrongQuestionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? items = null, Object? totalCount = null}) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<WrongQuestionItem>,
            totalCount: null == totalCount
                ? _value.totalCount
                : totalCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WrongQuestionsResponseImplCopyWith<$Res>
    implements $WrongQuestionsResponseCopyWith<$Res> {
  factory _$$WrongQuestionsResponseImplCopyWith(
    _$WrongQuestionsResponseImpl value,
    $Res Function(_$WrongQuestionsResponseImpl) then,
  ) = __$$WrongQuestionsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<WrongQuestionItem> items, int totalCount});
}

/// @nodoc
class __$$WrongQuestionsResponseImplCopyWithImpl<$Res>
    extends
        _$WrongQuestionsResponseCopyWithImpl<$Res, _$WrongQuestionsResponseImpl>
    implements _$$WrongQuestionsResponseImplCopyWith<$Res> {
  __$$WrongQuestionsResponseImplCopyWithImpl(
    _$WrongQuestionsResponseImpl _value,
    $Res Function(_$WrongQuestionsResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WrongQuestionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? items = null, Object? totalCount = null}) {
    return _then(
      _$WrongQuestionsResponseImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<WrongQuestionItem>,
        totalCount: null == totalCount
            ? _value.totalCount
            : totalCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WrongQuestionsResponseImpl implements _WrongQuestionsResponse {
  const _$WrongQuestionsResponseImpl({
    final List<WrongQuestionItem> items = const [],
    this.totalCount = 0,
  }) : _items = items;

  factory _$WrongQuestionsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$WrongQuestionsResponseImplFromJson(json);

  final List<WrongQuestionItem> _items;
  @override
  @JsonKey()
  List<WrongQuestionItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final int totalCount;

  @override
  String toString() {
    return 'WrongQuestionsResponse(items: $items, totalCount: $totalCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WrongQuestionsResponseImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    totalCount,
  );

  /// Create a copy of WrongQuestionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WrongQuestionsResponseImplCopyWith<_$WrongQuestionsResponseImpl>
  get copyWith =>
      __$$WrongQuestionsResponseImplCopyWithImpl<_$WrongQuestionsResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WrongQuestionsResponseImplToJson(this);
  }
}

abstract class _WrongQuestionsResponse implements WrongQuestionsResponse {
  const factory _WrongQuestionsResponse({
    final List<WrongQuestionItem> items,
    final int totalCount,
  }) = _$WrongQuestionsResponseImpl;

  factory _WrongQuestionsResponse.fromJson(Map<String, dynamic> json) =
      _$WrongQuestionsResponseImpl.fromJson;

  @override
  List<WrongQuestionItem> get items;
  @override
  int get totalCount;

  /// Create a copy of WrongQuestionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WrongQuestionsResponseImplCopyWith<_$WrongQuestionsResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

WrongQuestionRetrySetResponse _$WrongQuestionRetrySetResponseFromJson(
  Map<String, dynamic> json,
) {
  return _WrongQuestionRetrySetResponse.fromJson(json);
}

/// @nodoc
mixin _$WrongQuestionRetrySetResponse {
  List<String> get questionUuids => throw _privateConstructorUsedError;

  /// Serializes this WrongQuestionRetrySetResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WrongQuestionRetrySetResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WrongQuestionRetrySetResponseCopyWith<WrongQuestionRetrySetResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WrongQuestionRetrySetResponseCopyWith<$Res> {
  factory $WrongQuestionRetrySetResponseCopyWith(
    WrongQuestionRetrySetResponse value,
    $Res Function(WrongQuestionRetrySetResponse) then,
  ) =
      _$WrongQuestionRetrySetResponseCopyWithImpl<
        $Res,
        WrongQuestionRetrySetResponse
      >;
  @useResult
  $Res call({List<String> questionUuids});
}

/// @nodoc
class _$WrongQuestionRetrySetResponseCopyWithImpl<
  $Res,
  $Val extends WrongQuestionRetrySetResponse
>
    implements $WrongQuestionRetrySetResponseCopyWith<$Res> {
  _$WrongQuestionRetrySetResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WrongQuestionRetrySetResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? questionUuids = null}) {
    return _then(
      _value.copyWith(
            questionUuids: null == questionUuids
                ? _value.questionUuids
                : questionUuids // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WrongQuestionRetrySetResponseImplCopyWith<$Res>
    implements $WrongQuestionRetrySetResponseCopyWith<$Res> {
  factory _$$WrongQuestionRetrySetResponseImplCopyWith(
    _$WrongQuestionRetrySetResponseImpl value,
    $Res Function(_$WrongQuestionRetrySetResponseImpl) then,
  ) = __$$WrongQuestionRetrySetResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> questionUuids});
}

/// @nodoc
class __$$WrongQuestionRetrySetResponseImplCopyWithImpl<$Res>
    extends
        _$WrongQuestionRetrySetResponseCopyWithImpl<
          $Res,
          _$WrongQuestionRetrySetResponseImpl
        >
    implements _$$WrongQuestionRetrySetResponseImplCopyWith<$Res> {
  __$$WrongQuestionRetrySetResponseImplCopyWithImpl(
    _$WrongQuestionRetrySetResponseImpl _value,
    $Res Function(_$WrongQuestionRetrySetResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WrongQuestionRetrySetResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? questionUuids = null}) {
    return _then(
      _$WrongQuestionRetrySetResponseImpl(
        questionUuids: null == questionUuids
            ? _value._questionUuids
            : questionUuids // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WrongQuestionRetrySetResponseImpl
    implements _WrongQuestionRetrySetResponse {
  const _$WrongQuestionRetrySetResponseImpl({
    final List<String> questionUuids = const [],
  }) : _questionUuids = questionUuids;

  factory _$WrongQuestionRetrySetResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$WrongQuestionRetrySetResponseImplFromJson(json);

  final List<String> _questionUuids;
  @override
  @JsonKey()
  List<String> get questionUuids {
    if (_questionUuids is EqualUnmodifiableListView) return _questionUuids;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questionUuids);
  }

  @override
  String toString() {
    return 'WrongQuestionRetrySetResponse(questionUuids: $questionUuids)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WrongQuestionRetrySetResponseImpl &&
            const DeepCollectionEquality().equals(
              other._questionUuids,
              _questionUuids,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_questionUuids),
  );

  /// Create a copy of WrongQuestionRetrySetResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WrongQuestionRetrySetResponseImplCopyWith<
    _$WrongQuestionRetrySetResponseImpl
  >
  get copyWith =>
      __$$WrongQuestionRetrySetResponseImplCopyWithImpl<
        _$WrongQuestionRetrySetResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WrongQuestionRetrySetResponseImplToJson(this);
  }
}

abstract class _WrongQuestionRetrySetResponse
    implements WrongQuestionRetrySetResponse {
  const factory _WrongQuestionRetrySetResponse({
    final List<String> questionUuids,
  }) = _$WrongQuestionRetrySetResponseImpl;

  factory _WrongQuestionRetrySetResponse.fromJson(Map<String, dynamic> json) =
      _$WrongQuestionRetrySetResponseImpl.fromJson;

  @override
  List<String> get questionUuids;

  /// Create a copy of WrongQuestionRetrySetResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WrongQuestionRetrySetResponseImplCopyWith<
    _$WrongQuestionRetrySetResponseImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
