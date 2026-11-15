// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'question_bookmark_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

QuestionBookmarkItem _$QuestionBookmarkItemFromJson(Map<String, dynamic> json) {
  return _QuestionBookmarkItem.fromJson(json);
}

/// @nodoc
mixin _$QuestionBookmarkItem {
  String get questionUuid => throw _privateConstructorUsedError;
  String get stemPreview => throw _privateConstructorUsedError;
  String? get topicName => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  MockExamSubject get subject => throw _privateConstructorUsedError;
  DateTime? get bookmarkedAt => throw _privateConstructorUsedError;

  /// Serializes this QuestionBookmarkItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuestionBookmarkItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuestionBookmarkItemCopyWith<QuestionBookmarkItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionBookmarkItemCopyWith<$Res> {
  factory $QuestionBookmarkItemCopyWith(
    QuestionBookmarkItem value,
    $Res Function(QuestionBookmarkItem) then,
  ) = _$QuestionBookmarkItemCopyWithImpl<$Res, QuestionBookmarkItem>;
  @useResult
  $Res call({
    String questionUuid,
    String stemPreview,
    String? topicName,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) MockExamSubject subject,
    DateTime? bookmarkedAt,
  });
}

/// @nodoc
class _$QuestionBookmarkItemCopyWithImpl<
  $Res,
  $Val extends QuestionBookmarkItem
>
    implements $QuestionBookmarkItemCopyWith<$Res> {
  _$QuestionBookmarkItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuestionBookmarkItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionUuid = null,
    Object? stemPreview = null,
    Object? topicName = freezed,
    Object? subject = null,
    Object? bookmarkedAt = freezed,
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
            subject: null == subject
                ? _value.subject
                : subject // ignore: cast_nullable_to_non_nullable
                      as MockExamSubject,
            bookmarkedAt: freezed == bookmarkedAt
                ? _value.bookmarkedAt
                : bookmarkedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuestionBookmarkItemImplCopyWith<$Res>
    implements $QuestionBookmarkItemCopyWith<$Res> {
  factory _$$QuestionBookmarkItemImplCopyWith(
    _$QuestionBookmarkItemImpl value,
    $Res Function(_$QuestionBookmarkItemImpl) then,
  ) = __$$QuestionBookmarkItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String questionUuid,
    String stemPreview,
    String? topicName,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown) MockExamSubject subject,
    DateTime? bookmarkedAt,
  });
}

/// @nodoc
class __$$QuestionBookmarkItemImplCopyWithImpl<$Res>
    extends _$QuestionBookmarkItemCopyWithImpl<$Res, _$QuestionBookmarkItemImpl>
    implements _$$QuestionBookmarkItemImplCopyWith<$Res> {
  __$$QuestionBookmarkItemImplCopyWithImpl(
    _$QuestionBookmarkItemImpl _value,
    $Res Function(_$QuestionBookmarkItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuestionBookmarkItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionUuid = null,
    Object? stemPreview = null,
    Object? topicName = freezed,
    Object? subject = null,
    Object? bookmarkedAt = freezed,
  }) {
    return _then(
      _$QuestionBookmarkItemImpl(
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
        bookmarkedAt: freezed == bookmarkedAt
            ? _value.bookmarkedAt
            : bookmarkedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QuestionBookmarkItemImpl implements _QuestionBookmarkItem {
  const _$QuestionBookmarkItemImpl({
    required this.questionUuid,
    required this.stemPreview,
    this.topicName,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown)
    this.subject = MockExamSubject.unknown,
    this.bookmarkedAt,
  });

  factory _$QuestionBookmarkItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuestionBookmarkItemImplFromJson(json);

  @override
  final String questionUuid;
  @override
  final String stemPreview;
  @override
  final String? topicName;
  @override
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  final MockExamSubject subject;
  @override
  final DateTime? bookmarkedAt;

  @override
  String toString() {
    return 'QuestionBookmarkItem(questionUuid: $questionUuid, stemPreview: $stemPreview, topicName: $topicName, subject: $subject, bookmarkedAt: $bookmarkedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionBookmarkItemImpl &&
            (identical(other.questionUuid, questionUuid) ||
                other.questionUuid == questionUuid) &&
            (identical(other.stemPreview, stemPreview) ||
                other.stemPreview == stemPreview) &&
            (identical(other.topicName, topicName) ||
                other.topicName == topicName) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.bookmarkedAt, bookmarkedAt) ||
                other.bookmarkedAt == bookmarkedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    questionUuid,
    stemPreview,
    topicName,
    subject,
    bookmarkedAt,
  );

  /// Create a copy of QuestionBookmarkItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionBookmarkItemImplCopyWith<_$QuestionBookmarkItemImpl>
  get copyWith =>
      __$$QuestionBookmarkItemImplCopyWithImpl<_$QuestionBookmarkItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$QuestionBookmarkItemImplToJson(this);
  }
}

abstract class _QuestionBookmarkItem implements QuestionBookmarkItem {
  const factory _QuestionBookmarkItem({
    required final String questionUuid,
    required final String stemPreview,
    final String? topicName,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown)
    final MockExamSubject subject,
    final DateTime? bookmarkedAt,
  }) = _$QuestionBookmarkItemImpl;

  factory _QuestionBookmarkItem.fromJson(Map<String, dynamic> json) =
      _$QuestionBookmarkItemImpl.fromJson;

  @override
  String get questionUuid;
  @override
  String get stemPreview;
  @override
  String? get topicName;
  @override
  @JsonKey(unknownEnumValue: MockExamSubject.unknown)
  MockExamSubject get subject;
  @override
  DateTime? get bookmarkedAt;

  /// Create a copy of QuestionBookmarkItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuestionBookmarkItemImplCopyWith<_$QuestionBookmarkItemImpl>
  get copyWith => throw _privateConstructorUsedError;
}

QuestionBookmarksResponse _$QuestionBookmarksResponseFromJson(
  Map<String, dynamic> json,
) {
  return _QuestionBookmarksResponse.fromJson(json);
}

/// @nodoc
mixin _$QuestionBookmarksResponse {
  List<QuestionBookmarkItem> get items => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  bool get hasNext => throw _privateConstructorUsedError;

  /// Serializes this QuestionBookmarksResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuestionBookmarksResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuestionBookmarksResponseCopyWith<QuestionBookmarksResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionBookmarksResponseCopyWith<$Res> {
  factory $QuestionBookmarksResponseCopyWith(
    QuestionBookmarksResponse value,
    $Res Function(QuestionBookmarksResponse) then,
  ) = _$QuestionBookmarksResponseCopyWithImpl<$Res, QuestionBookmarksResponse>;
  @useResult
  $Res call({
    List<QuestionBookmarkItem> items,
    int totalCount,
    int page,
    bool hasNext,
  });
}

/// @nodoc
class _$QuestionBookmarksResponseCopyWithImpl<
  $Res,
  $Val extends QuestionBookmarksResponse
>
    implements $QuestionBookmarksResponseCopyWith<$Res> {
  _$QuestionBookmarksResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuestionBookmarksResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? totalCount = null,
    Object? page = null,
    Object? hasNext = null,
  }) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<QuestionBookmarkItem>,
            totalCount: null == totalCount
                ? _value.totalCount
                : totalCount // ignore: cast_nullable_to_non_nullable
                      as int,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            hasNext: null == hasNext
                ? _value.hasNext
                : hasNext // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuestionBookmarksResponseImplCopyWith<$Res>
    implements $QuestionBookmarksResponseCopyWith<$Res> {
  factory _$$QuestionBookmarksResponseImplCopyWith(
    _$QuestionBookmarksResponseImpl value,
    $Res Function(_$QuestionBookmarksResponseImpl) then,
  ) = __$$QuestionBookmarksResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<QuestionBookmarkItem> items,
    int totalCount,
    int page,
    bool hasNext,
  });
}

/// @nodoc
class __$$QuestionBookmarksResponseImplCopyWithImpl<$Res>
    extends
        _$QuestionBookmarksResponseCopyWithImpl<
          $Res,
          _$QuestionBookmarksResponseImpl
        >
    implements _$$QuestionBookmarksResponseImplCopyWith<$Res> {
  __$$QuestionBookmarksResponseImplCopyWithImpl(
    _$QuestionBookmarksResponseImpl _value,
    $Res Function(_$QuestionBookmarksResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuestionBookmarksResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? totalCount = null,
    Object? page = null,
    Object? hasNext = null,
  }) {
    return _then(
      _$QuestionBookmarksResponseImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<QuestionBookmarkItem>,
        totalCount: null == totalCount
            ? _value.totalCount
            : totalCount // ignore: cast_nullable_to_non_nullable
                  as int,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        hasNext: null == hasNext
            ? _value.hasNext
            : hasNext // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QuestionBookmarksResponseImpl implements _QuestionBookmarksResponse {
  const _$QuestionBookmarksResponseImpl({
    final List<QuestionBookmarkItem> items = const [],
    this.totalCount = 0,
    this.page = 0,
    this.hasNext = false,
  }) : _items = items;

  factory _$QuestionBookmarksResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuestionBookmarksResponseImplFromJson(json);

  final List<QuestionBookmarkItem> _items;
  @override
  @JsonKey()
  List<QuestionBookmarkItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final int totalCount;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final bool hasNext;

  @override
  String toString() {
    return 'QuestionBookmarksResponse(items: $items, totalCount: $totalCount, page: $page, hasNext: $hasNext)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionBookmarksResponseImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.hasNext, hasNext) || other.hasNext == hasNext));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    totalCount,
    page,
    hasNext,
  );

  /// Create a copy of QuestionBookmarksResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionBookmarksResponseImplCopyWith<_$QuestionBookmarksResponseImpl>
  get copyWith =>
      __$$QuestionBookmarksResponseImplCopyWithImpl<
        _$QuestionBookmarksResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuestionBookmarksResponseImplToJson(this);
  }
}

abstract class _QuestionBookmarksResponse implements QuestionBookmarksResponse {
  const factory _QuestionBookmarksResponse({
    final List<QuestionBookmarkItem> items,
    final int totalCount,
    final int page,
    final bool hasNext,
  }) = _$QuestionBookmarksResponseImpl;

  factory _QuestionBookmarksResponse.fromJson(Map<String, dynamic> json) =
      _$QuestionBookmarksResponseImpl.fromJson;

  @override
  List<QuestionBookmarkItem> get items;
  @override
  int get totalCount;
  @override
  int get page;
  @override
  bool get hasNext;

  /// Create a copy of QuestionBookmarksResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuestionBookmarksResponseImplCopyWith<_$QuestionBookmarksResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

QuestionBookmarkStatusResponse _$QuestionBookmarkStatusResponseFromJson(
  Map<String, dynamic> json,
) {
  return _QuestionBookmarkStatusResponse.fromJson(json);
}

/// @nodoc
mixin _$QuestionBookmarkStatusResponse {
  String get questionUuid => throw _privateConstructorUsedError;
  bool get isBookmarked => throw _privateConstructorUsedError;

  /// Serializes this QuestionBookmarkStatusResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuestionBookmarkStatusResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuestionBookmarkStatusResponseCopyWith<QuestionBookmarkStatusResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionBookmarkStatusResponseCopyWith<$Res> {
  factory $QuestionBookmarkStatusResponseCopyWith(
    QuestionBookmarkStatusResponse value,
    $Res Function(QuestionBookmarkStatusResponse) then,
  ) =
      _$QuestionBookmarkStatusResponseCopyWithImpl<
        $Res,
        QuestionBookmarkStatusResponse
      >;
  @useResult
  $Res call({String questionUuid, bool isBookmarked});
}

/// @nodoc
class _$QuestionBookmarkStatusResponseCopyWithImpl<
  $Res,
  $Val extends QuestionBookmarkStatusResponse
>
    implements $QuestionBookmarkStatusResponseCopyWith<$Res> {
  _$QuestionBookmarkStatusResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuestionBookmarkStatusResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? questionUuid = null, Object? isBookmarked = null}) {
    return _then(
      _value.copyWith(
            questionUuid: null == questionUuid
                ? _value.questionUuid
                : questionUuid // ignore: cast_nullable_to_non_nullable
                      as String,
            isBookmarked: null == isBookmarked
                ? _value.isBookmarked
                : isBookmarked // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuestionBookmarkStatusResponseImplCopyWith<$Res>
    implements $QuestionBookmarkStatusResponseCopyWith<$Res> {
  factory _$$QuestionBookmarkStatusResponseImplCopyWith(
    _$QuestionBookmarkStatusResponseImpl value,
    $Res Function(_$QuestionBookmarkStatusResponseImpl) then,
  ) = __$$QuestionBookmarkStatusResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String questionUuid, bool isBookmarked});
}

/// @nodoc
class __$$QuestionBookmarkStatusResponseImplCopyWithImpl<$Res>
    extends
        _$QuestionBookmarkStatusResponseCopyWithImpl<
          $Res,
          _$QuestionBookmarkStatusResponseImpl
        >
    implements _$$QuestionBookmarkStatusResponseImplCopyWith<$Res> {
  __$$QuestionBookmarkStatusResponseImplCopyWithImpl(
    _$QuestionBookmarkStatusResponseImpl _value,
    $Res Function(_$QuestionBookmarkStatusResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuestionBookmarkStatusResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? questionUuid = null, Object? isBookmarked = null}) {
    return _then(
      _$QuestionBookmarkStatusResponseImpl(
        questionUuid: null == questionUuid
            ? _value.questionUuid
            : questionUuid // ignore: cast_nullable_to_non_nullable
                  as String,
        isBookmarked: null == isBookmarked
            ? _value.isBookmarked
            : isBookmarked // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QuestionBookmarkStatusResponseImpl
    implements _QuestionBookmarkStatusResponse {
  const _$QuestionBookmarkStatusResponseImpl({
    required this.questionUuid,
    this.isBookmarked = false,
  });

  factory _$QuestionBookmarkStatusResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$QuestionBookmarkStatusResponseImplFromJson(json);

  @override
  final String questionUuid;
  @override
  @JsonKey()
  final bool isBookmarked;

  @override
  String toString() {
    return 'QuestionBookmarkStatusResponse(questionUuid: $questionUuid, isBookmarked: $isBookmarked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionBookmarkStatusResponseImpl &&
            (identical(other.questionUuid, questionUuid) ||
                other.questionUuid == questionUuid) &&
            (identical(other.isBookmarked, isBookmarked) ||
                other.isBookmarked == isBookmarked));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, questionUuid, isBookmarked);

  /// Create a copy of QuestionBookmarkStatusResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionBookmarkStatusResponseImplCopyWith<
    _$QuestionBookmarkStatusResponseImpl
  >
  get copyWith =>
      __$$QuestionBookmarkStatusResponseImplCopyWithImpl<
        _$QuestionBookmarkStatusResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuestionBookmarkStatusResponseImplToJson(this);
  }
}

abstract class _QuestionBookmarkStatusResponse
    implements QuestionBookmarkStatusResponse {
  const factory _QuestionBookmarkStatusResponse({
    required final String questionUuid,
    final bool isBookmarked,
  }) = _$QuestionBookmarkStatusResponseImpl;

  factory _QuestionBookmarkStatusResponse.fromJson(Map<String, dynamic> json) =
      _$QuestionBookmarkStatusResponseImpl.fromJson;

  @override
  String get questionUuid;
  @override
  bool get isBookmarked;

  /// Create a copy of QuestionBookmarkStatusResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuestionBookmarkStatusResponseImplCopyWith<
    _$QuestionBookmarkStatusResponseImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

QuestionBookmarkPracticeSetResponse
_$QuestionBookmarkPracticeSetResponseFromJson(Map<String, dynamic> json) {
  return _QuestionBookmarkPracticeSetResponse.fromJson(json);
}

/// @nodoc
mixin _$QuestionBookmarkPracticeSetResponse {
  List<String> get questionUuids => throw _privateConstructorUsedError;

  /// Serializes this QuestionBookmarkPracticeSetResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuestionBookmarkPracticeSetResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuestionBookmarkPracticeSetResponseCopyWith<
    QuestionBookmarkPracticeSetResponse
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionBookmarkPracticeSetResponseCopyWith<$Res> {
  factory $QuestionBookmarkPracticeSetResponseCopyWith(
    QuestionBookmarkPracticeSetResponse value,
    $Res Function(QuestionBookmarkPracticeSetResponse) then,
  ) =
      _$QuestionBookmarkPracticeSetResponseCopyWithImpl<
        $Res,
        QuestionBookmarkPracticeSetResponse
      >;
  @useResult
  $Res call({List<String> questionUuids});
}

/// @nodoc
class _$QuestionBookmarkPracticeSetResponseCopyWithImpl<
  $Res,
  $Val extends QuestionBookmarkPracticeSetResponse
>
    implements $QuestionBookmarkPracticeSetResponseCopyWith<$Res> {
  _$QuestionBookmarkPracticeSetResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuestionBookmarkPracticeSetResponse
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
abstract class _$$QuestionBookmarkPracticeSetResponseImplCopyWith<$Res>
    implements $QuestionBookmarkPracticeSetResponseCopyWith<$Res> {
  factory _$$QuestionBookmarkPracticeSetResponseImplCopyWith(
    _$QuestionBookmarkPracticeSetResponseImpl value,
    $Res Function(_$QuestionBookmarkPracticeSetResponseImpl) then,
  ) = __$$QuestionBookmarkPracticeSetResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> questionUuids});
}

/// @nodoc
class __$$QuestionBookmarkPracticeSetResponseImplCopyWithImpl<$Res>
    extends
        _$QuestionBookmarkPracticeSetResponseCopyWithImpl<
          $Res,
          _$QuestionBookmarkPracticeSetResponseImpl
        >
    implements _$$QuestionBookmarkPracticeSetResponseImplCopyWith<$Res> {
  __$$QuestionBookmarkPracticeSetResponseImplCopyWithImpl(
    _$QuestionBookmarkPracticeSetResponseImpl _value,
    $Res Function(_$QuestionBookmarkPracticeSetResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuestionBookmarkPracticeSetResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? questionUuids = null}) {
    return _then(
      _$QuestionBookmarkPracticeSetResponseImpl(
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
class _$QuestionBookmarkPracticeSetResponseImpl
    implements _QuestionBookmarkPracticeSetResponse {
  const _$QuestionBookmarkPracticeSetResponseImpl({
    final List<String> questionUuids = const [],
  }) : _questionUuids = questionUuids;

  factory _$QuestionBookmarkPracticeSetResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$QuestionBookmarkPracticeSetResponseImplFromJson(json);

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
    return 'QuestionBookmarkPracticeSetResponse(questionUuids: $questionUuids)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionBookmarkPracticeSetResponseImpl &&
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

  /// Create a copy of QuestionBookmarkPracticeSetResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionBookmarkPracticeSetResponseImplCopyWith<
    _$QuestionBookmarkPracticeSetResponseImpl
  >
  get copyWith =>
      __$$QuestionBookmarkPracticeSetResponseImplCopyWithImpl<
        _$QuestionBookmarkPracticeSetResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuestionBookmarkPracticeSetResponseImplToJson(this);
  }
}

abstract class _QuestionBookmarkPracticeSetResponse
    implements QuestionBookmarkPracticeSetResponse {
  const factory _QuestionBookmarkPracticeSetResponse({
    final List<String> questionUuids,
  }) = _$QuestionBookmarkPracticeSetResponseImpl;

  factory _QuestionBookmarkPracticeSetResponse.fromJson(
    Map<String, dynamic> json,
  ) = _$QuestionBookmarkPracticeSetResponseImpl.fromJson;

  @override
  List<String> get questionUuids;

  /// Create a copy of QuestionBookmarkPracticeSetResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuestionBookmarkPracticeSetResponseImplCopyWith<
    _$QuestionBookmarkPracticeSetResponseImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
