// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feedback_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FeedbackItem _$FeedbackItemFromJson(Map<String, dynamic> json) {
  return _FeedbackItem.fromJson(json);
}

/// @nodoc
mixin _$FeedbackItem {
  String get feedbackUuid => throw _privateConstructorUsedError;
  String get content =>
      throw _privateConstructorUsedError; // 서버에 상태가 추가돼도 앱이 깨지지 않도록 모르는 값은 대기로 본다.
  @JsonKey(unknownEnumValue: FeedbackStatus.pending)
  FeedbackStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this FeedbackItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeedbackItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedbackItemCopyWith<FeedbackItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedbackItemCopyWith<$Res> {
  factory $FeedbackItemCopyWith(
    FeedbackItem value,
    $Res Function(FeedbackItem) then,
  ) = _$FeedbackItemCopyWithImpl<$Res, FeedbackItem>;
  @useResult
  $Res call({
    String feedbackUuid,
    String content,
    @JsonKey(unknownEnumValue: FeedbackStatus.pending) FeedbackStatus status,
    DateTime createdAt,
  });
}

/// @nodoc
class _$FeedbackItemCopyWithImpl<$Res, $Val extends FeedbackItem>
    implements $FeedbackItemCopyWith<$Res> {
  _$FeedbackItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedbackItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feedbackUuid = null,
    Object? content = null,
    Object? status = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            feedbackUuid: null == feedbackUuid
                ? _value.feedbackUuid
                : feedbackUuid // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as FeedbackStatus,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FeedbackItemImplCopyWith<$Res>
    implements $FeedbackItemCopyWith<$Res> {
  factory _$$FeedbackItemImplCopyWith(
    _$FeedbackItemImpl value,
    $Res Function(_$FeedbackItemImpl) then,
  ) = __$$FeedbackItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String feedbackUuid,
    String content,
    @JsonKey(unknownEnumValue: FeedbackStatus.pending) FeedbackStatus status,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$FeedbackItemImplCopyWithImpl<$Res>
    extends _$FeedbackItemCopyWithImpl<$Res, _$FeedbackItemImpl>
    implements _$$FeedbackItemImplCopyWith<$Res> {
  __$$FeedbackItemImplCopyWithImpl(
    _$FeedbackItemImpl _value,
    $Res Function(_$FeedbackItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FeedbackItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feedbackUuid = null,
    Object? content = null,
    Object? status = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$FeedbackItemImpl(
        feedbackUuid: null == feedbackUuid
            ? _value.feedbackUuid
            : feedbackUuid // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as FeedbackStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FeedbackItemImpl implements _FeedbackItem {
  const _$FeedbackItemImpl({
    required this.feedbackUuid,
    required this.content,
    @JsonKey(unknownEnumValue: FeedbackStatus.pending)
    this.status = FeedbackStatus.pending,
    required this.createdAt,
  });

  factory _$FeedbackItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedbackItemImplFromJson(json);

  @override
  final String feedbackUuid;
  @override
  final String content;
  // 서버에 상태가 추가돼도 앱이 깨지지 않도록 모르는 값은 대기로 본다.
  @override
  @JsonKey(unknownEnumValue: FeedbackStatus.pending)
  final FeedbackStatus status;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'FeedbackItem(feedbackUuid: $feedbackUuid, content: $content, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedbackItemImpl &&
            (identical(other.feedbackUuid, feedbackUuid) ||
                other.feedbackUuid == feedbackUuid) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, feedbackUuid, content, status, createdAt);

  /// Create a copy of FeedbackItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedbackItemImplCopyWith<_$FeedbackItemImpl> get copyWith =>
      __$$FeedbackItemImplCopyWithImpl<_$FeedbackItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedbackItemImplToJson(this);
  }
}

abstract class _FeedbackItem implements FeedbackItem {
  const factory _FeedbackItem({
    required final String feedbackUuid,
    required final String content,
    @JsonKey(unknownEnumValue: FeedbackStatus.pending)
    final FeedbackStatus status,
    required final DateTime createdAt,
  }) = _$FeedbackItemImpl;

  factory _FeedbackItem.fromJson(Map<String, dynamic> json) =
      _$FeedbackItemImpl.fromJson;

  @override
  String get feedbackUuid;
  @override
  String get content; // 서버에 상태가 추가돼도 앱이 깨지지 않도록 모르는 값은 대기로 본다.
  @override
  @JsonKey(unknownEnumValue: FeedbackStatus.pending)
  FeedbackStatus get status;
  @override
  DateTime get createdAt;

  /// Create a copy of FeedbackItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedbackItemImplCopyWith<_$FeedbackItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FeedbackListResponse _$FeedbackListResponseFromJson(Map<String, dynamic> json) {
  return _FeedbackListResponse.fromJson(json);
}

/// @nodoc
mixin _$FeedbackListResponse {
  List<FeedbackItem> get items => throw _privateConstructorUsedError;

  /// Serializes this FeedbackListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeedbackListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedbackListResponseCopyWith<FeedbackListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedbackListResponseCopyWith<$Res> {
  factory $FeedbackListResponseCopyWith(
    FeedbackListResponse value,
    $Res Function(FeedbackListResponse) then,
  ) = _$FeedbackListResponseCopyWithImpl<$Res, FeedbackListResponse>;
  @useResult
  $Res call({List<FeedbackItem> items});
}

/// @nodoc
class _$FeedbackListResponseCopyWithImpl<
  $Res,
  $Val extends FeedbackListResponse
>
    implements $FeedbackListResponseCopyWith<$Res> {
  _$FeedbackListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedbackListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? items = null}) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<FeedbackItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FeedbackListResponseImplCopyWith<$Res>
    implements $FeedbackListResponseCopyWith<$Res> {
  factory _$$FeedbackListResponseImplCopyWith(
    _$FeedbackListResponseImpl value,
    $Res Function(_$FeedbackListResponseImpl) then,
  ) = __$$FeedbackListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<FeedbackItem> items});
}

/// @nodoc
class __$$FeedbackListResponseImplCopyWithImpl<$Res>
    extends _$FeedbackListResponseCopyWithImpl<$Res, _$FeedbackListResponseImpl>
    implements _$$FeedbackListResponseImplCopyWith<$Res> {
  __$$FeedbackListResponseImplCopyWithImpl(
    _$FeedbackListResponseImpl _value,
    $Res Function(_$FeedbackListResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FeedbackListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? items = null}) {
    return _then(
      _$FeedbackListResponseImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<FeedbackItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FeedbackListResponseImpl implements _FeedbackListResponse {
  const _$FeedbackListResponseImpl({final List<FeedbackItem> items = const []})
    : _items = items;

  factory _$FeedbackListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedbackListResponseImplFromJson(json);

  final List<FeedbackItem> _items;
  @override
  @JsonKey()
  List<FeedbackItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'FeedbackListResponse(items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedbackListResponseImpl &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_items));

  /// Create a copy of FeedbackListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedbackListResponseImplCopyWith<_$FeedbackListResponseImpl>
  get copyWith =>
      __$$FeedbackListResponseImplCopyWithImpl<_$FeedbackListResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedbackListResponseImplToJson(this);
  }
}

abstract class _FeedbackListResponse implements FeedbackListResponse {
  const factory _FeedbackListResponse({final List<FeedbackItem> items}) =
      _$FeedbackListResponseImpl;

  factory _FeedbackListResponse.fromJson(Map<String, dynamic> json) =
      _$FeedbackListResponseImpl.fromJson;

  @override
  List<FeedbackItem> get items;

  /// Create a copy of FeedbackListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedbackListResponseImplCopyWith<_$FeedbackListResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
