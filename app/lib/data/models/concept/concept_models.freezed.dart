// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'concept_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ConceptTopicListResponse _$ConceptTopicListResponseFromJson(
  Map<String, dynamic> json,
) {
  return _ConceptTopicListResponse.fromJson(json);
}

/// @nodoc
mixin _$ConceptTopicListResponse {
  bool get isAvailable => throw _privateConstructorUsedError;
  int get freeTopicCount => throw _privateConstructorUsedError;
  List<ConceptTopicSummary> get topics => throw _privateConstructorUsedError;

  /// Serializes this ConceptTopicListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConceptTopicListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConceptTopicListResponseCopyWith<ConceptTopicListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConceptTopicListResponseCopyWith<$Res> {
  factory $ConceptTopicListResponseCopyWith(
    ConceptTopicListResponse value,
    $Res Function(ConceptTopicListResponse) then,
  ) = _$ConceptTopicListResponseCopyWithImpl<$Res, ConceptTopicListResponse>;
  @useResult
  $Res call({
    bool isAvailable,
    int freeTopicCount,
    List<ConceptTopicSummary> topics,
  });
}

/// @nodoc
class _$ConceptTopicListResponseCopyWithImpl<
  $Res,
  $Val extends ConceptTopicListResponse
>
    implements $ConceptTopicListResponseCopyWith<$Res> {
  _$ConceptTopicListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConceptTopicListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isAvailable = null,
    Object? freeTopicCount = null,
    Object? topics = null,
  }) {
    return _then(
      _value.copyWith(
            isAvailable: null == isAvailable
                ? _value.isAvailable
                : isAvailable // ignore: cast_nullable_to_non_nullable
                      as bool,
            freeTopicCount: null == freeTopicCount
                ? _value.freeTopicCount
                : freeTopicCount // ignore: cast_nullable_to_non_nullable
                      as int,
            topics: null == topics
                ? _value.topics
                : topics // ignore: cast_nullable_to_non_nullable
                      as List<ConceptTopicSummary>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConceptTopicListResponseImplCopyWith<$Res>
    implements $ConceptTopicListResponseCopyWith<$Res> {
  factory _$$ConceptTopicListResponseImplCopyWith(
    _$ConceptTopicListResponseImpl value,
    $Res Function(_$ConceptTopicListResponseImpl) then,
  ) = __$$ConceptTopicListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isAvailable,
    int freeTopicCount,
    List<ConceptTopicSummary> topics,
  });
}

/// @nodoc
class __$$ConceptTopicListResponseImplCopyWithImpl<$Res>
    extends
        _$ConceptTopicListResponseCopyWithImpl<
          $Res,
          _$ConceptTopicListResponseImpl
        >
    implements _$$ConceptTopicListResponseImplCopyWith<$Res> {
  __$$ConceptTopicListResponseImplCopyWithImpl(
    _$ConceptTopicListResponseImpl _value,
    $Res Function(_$ConceptTopicListResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConceptTopicListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isAvailable = null,
    Object? freeTopicCount = null,
    Object? topics = null,
  }) {
    return _then(
      _$ConceptTopicListResponseImpl(
        isAvailable: null == isAvailable
            ? _value.isAvailable
            : isAvailable // ignore: cast_nullable_to_non_nullable
                  as bool,
        freeTopicCount: null == freeTopicCount
            ? _value.freeTopicCount
            : freeTopicCount // ignore: cast_nullable_to_non_nullable
                  as int,
        topics: null == topics
            ? _value._topics
            : topics // ignore: cast_nullable_to_non_nullable
                  as List<ConceptTopicSummary>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConceptTopicListResponseImpl implements _ConceptTopicListResponse {
  const _$ConceptTopicListResponseImpl({
    this.isAvailable = false,
    this.freeTopicCount = 2,
    final List<ConceptTopicSummary> topics = const [],
  }) : _topics = topics;

  factory _$ConceptTopicListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConceptTopicListResponseImplFromJson(json);

  @override
  @JsonKey()
  final bool isAvailable;
  @override
  @JsonKey()
  final int freeTopicCount;
  final List<ConceptTopicSummary> _topics;
  @override
  @JsonKey()
  List<ConceptTopicSummary> get topics {
    if (_topics is EqualUnmodifiableListView) return _topics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topics);
  }

  @override
  String toString() {
    return 'ConceptTopicListResponse(isAvailable: $isAvailable, freeTopicCount: $freeTopicCount, topics: $topics)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConceptTopicListResponseImpl &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.freeTopicCount, freeTopicCount) ||
                other.freeTopicCount == freeTopicCount) &&
            const DeepCollectionEquality().equals(other._topics, _topics));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    isAvailable,
    freeTopicCount,
    const DeepCollectionEquality().hash(_topics),
  );

  /// Create a copy of ConceptTopicListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConceptTopicListResponseImplCopyWith<_$ConceptTopicListResponseImpl>
  get copyWith =>
      __$$ConceptTopicListResponseImplCopyWithImpl<
        _$ConceptTopicListResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConceptTopicListResponseImplToJson(this);
  }
}

abstract class _ConceptTopicListResponse implements ConceptTopicListResponse {
  const factory _ConceptTopicListResponse({
    final bool isAvailable,
    final int freeTopicCount,
    final List<ConceptTopicSummary> topics,
  }) = _$ConceptTopicListResponseImpl;

  factory _ConceptTopicListResponse.fromJson(Map<String, dynamic> json) =
      _$ConceptTopicListResponseImpl.fromJson;

  @override
  bool get isAvailable;
  @override
  int get freeTopicCount;
  @override
  List<ConceptTopicSummary> get topics;

  /// Create a copy of ConceptTopicListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConceptTopicListResponseImplCopyWith<_$ConceptTopicListResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ConceptTopicSummary _$ConceptTopicSummaryFromJson(Map<String, dynamic> json) {
  return _ConceptTopicSummary.fromJson(json);
}

/// @nodoc
mixin _$ConceptTopicSummary {
  String get topicUuid => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  int get orderIndex => throw _privateConstructorUsedError;
  int get conceptCount => throw _privateConstructorUsedError;
  int get completedCount => throw _privateConstructorUsedError;
  bool get isLocked => throw _privateConstructorUsedError;

  /// Serializes this ConceptTopicSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConceptTopicSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConceptTopicSummaryCopyWith<ConceptTopicSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConceptTopicSummaryCopyWith<$Res> {
  factory $ConceptTopicSummaryCopyWith(
    ConceptTopicSummary value,
    $Res Function(ConceptTopicSummary) then,
  ) = _$ConceptTopicSummaryCopyWithImpl<$Res, ConceptTopicSummary>;
  @useResult
  $Res call({
    String topicUuid,
    String displayName,
    int orderIndex,
    int conceptCount,
    int completedCount,
    bool isLocked,
  });
}

/// @nodoc
class _$ConceptTopicSummaryCopyWithImpl<$Res, $Val extends ConceptTopicSummary>
    implements $ConceptTopicSummaryCopyWith<$Res> {
  _$ConceptTopicSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConceptTopicSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topicUuid = null,
    Object? displayName = null,
    Object? orderIndex = null,
    Object? conceptCount = null,
    Object? completedCount = null,
    Object? isLocked = null,
  }) {
    return _then(
      _value.copyWith(
            topicUuid: null == topicUuid
                ? _value.topicUuid
                : topicUuid // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
            orderIndex: null == orderIndex
                ? _value.orderIndex
                : orderIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            conceptCount: null == conceptCount
                ? _value.conceptCount
                : conceptCount // ignore: cast_nullable_to_non_nullable
                      as int,
            completedCount: null == completedCount
                ? _value.completedCount
                : completedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isLocked: null == isLocked
                ? _value.isLocked
                : isLocked // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConceptTopicSummaryImplCopyWith<$Res>
    implements $ConceptTopicSummaryCopyWith<$Res> {
  factory _$$ConceptTopicSummaryImplCopyWith(
    _$ConceptTopicSummaryImpl value,
    $Res Function(_$ConceptTopicSummaryImpl) then,
  ) = __$$ConceptTopicSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String topicUuid,
    String displayName,
    int orderIndex,
    int conceptCount,
    int completedCount,
    bool isLocked,
  });
}

/// @nodoc
class __$$ConceptTopicSummaryImplCopyWithImpl<$Res>
    extends _$ConceptTopicSummaryCopyWithImpl<$Res, _$ConceptTopicSummaryImpl>
    implements _$$ConceptTopicSummaryImplCopyWith<$Res> {
  __$$ConceptTopicSummaryImplCopyWithImpl(
    _$ConceptTopicSummaryImpl _value,
    $Res Function(_$ConceptTopicSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConceptTopicSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topicUuid = null,
    Object? displayName = null,
    Object? orderIndex = null,
    Object? conceptCount = null,
    Object? completedCount = null,
    Object? isLocked = null,
  }) {
    return _then(
      _$ConceptTopicSummaryImpl(
        topicUuid: null == topicUuid
            ? _value.topicUuid
            : topicUuid // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
        orderIndex: null == orderIndex
            ? _value.orderIndex
            : orderIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        conceptCount: null == conceptCount
            ? _value.conceptCount
            : conceptCount // ignore: cast_nullable_to_non_nullable
                  as int,
        completedCount: null == completedCount
            ? _value.completedCount
            : completedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isLocked: null == isLocked
            ? _value.isLocked
            : isLocked // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConceptTopicSummaryImpl implements _ConceptTopicSummary {
  const _$ConceptTopicSummaryImpl({
    required this.topicUuid,
    required this.displayName,
    this.orderIndex = 0,
    this.conceptCount = 0,
    this.completedCount = 0,
    this.isLocked = false,
  });

  factory _$ConceptTopicSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConceptTopicSummaryImplFromJson(json);

  @override
  final String topicUuid;
  @override
  final String displayName;
  @override
  @JsonKey()
  final int orderIndex;
  @override
  @JsonKey()
  final int conceptCount;
  @override
  @JsonKey()
  final int completedCount;
  @override
  @JsonKey()
  final bool isLocked;

  @override
  String toString() {
    return 'ConceptTopicSummary(topicUuid: $topicUuid, displayName: $displayName, orderIndex: $orderIndex, conceptCount: $conceptCount, completedCount: $completedCount, isLocked: $isLocked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConceptTopicSummaryImpl &&
            (identical(other.topicUuid, topicUuid) ||
                other.topicUuid == topicUuid) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.orderIndex, orderIndex) ||
                other.orderIndex == orderIndex) &&
            (identical(other.conceptCount, conceptCount) ||
                other.conceptCount == conceptCount) &&
            (identical(other.completedCount, completedCount) ||
                other.completedCount == completedCount) &&
            (identical(other.isLocked, isLocked) ||
                other.isLocked == isLocked));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    topicUuid,
    displayName,
    orderIndex,
    conceptCount,
    completedCount,
    isLocked,
  );

  /// Create a copy of ConceptTopicSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConceptTopicSummaryImplCopyWith<_$ConceptTopicSummaryImpl> get copyWith =>
      __$$ConceptTopicSummaryImplCopyWithImpl<_$ConceptTopicSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConceptTopicSummaryImplToJson(this);
  }
}

abstract class _ConceptTopicSummary implements ConceptTopicSummary {
  const factory _ConceptTopicSummary({
    required final String topicUuid,
    required final String displayName,
    final int orderIndex,
    final int conceptCount,
    final int completedCount,
    final bool isLocked,
  }) = _$ConceptTopicSummaryImpl;

  factory _ConceptTopicSummary.fromJson(Map<String, dynamic> json) =
      _$ConceptTopicSummaryImpl.fromJson;

  @override
  String get topicUuid;
  @override
  String get displayName;
  @override
  int get orderIndex;
  @override
  int get conceptCount;
  @override
  int get completedCount;
  @override
  bool get isLocked;

  /// Create a copy of ConceptTopicSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConceptTopicSummaryImplCopyWith<_$ConceptTopicSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConceptListResponse _$ConceptListResponseFromJson(Map<String, dynamic> json) {
  return _ConceptListResponse.fromJson(json);
}

/// @nodoc
mixin _$ConceptListResponse {
  String get topicUuid => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  bool get isLocked => throw _privateConstructorUsedError;
  List<ConceptSummary> get concepts => throw _privateConstructorUsedError;

  /// Serializes this ConceptListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConceptListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConceptListResponseCopyWith<ConceptListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConceptListResponseCopyWith<$Res> {
  factory $ConceptListResponseCopyWith(
    ConceptListResponse value,
    $Res Function(ConceptListResponse) then,
  ) = _$ConceptListResponseCopyWithImpl<$Res, ConceptListResponse>;
  @useResult
  $Res call({
    String topicUuid,
    String displayName,
    bool isLocked,
    List<ConceptSummary> concepts,
  });
}

/// @nodoc
class _$ConceptListResponseCopyWithImpl<$Res, $Val extends ConceptListResponse>
    implements $ConceptListResponseCopyWith<$Res> {
  _$ConceptListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConceptListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topicUuid = null,
    Object? displayName = null,
    Object? isLocked = null,
    Object? concepts = null,
  }) {
    return _then(
      _value.copyWith(
            topicUuid: null == topicUuid
                ? _value.topicUuid
                : topicUuid // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
            isLocked: null == isLocked
                ? _value.isLocked
                : isLocked // ignore: cast_nullable_to_non_nullable
                      as bool,
            concepts: null == concepts
                ? _value.concepts
                : concepts // ignore: cast_nullable_to_non_nullable
                      as List<ConceptSummary>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConceptListResponseImplCopyWith<$Res>
    implements $ConceptListResponseCopyWith<$Res> {
  factory _$$ConceptListResponseImplCopyWith(
    _$ConceptListResponseImpl value,
    $Res Function(_$ConceptListResponseImpl) then,
  ) = __$$ConceptListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String topicUuid,
    String displayName,
    bool isLocked,
    List<ConceptSummary> concepts,
  });
}

/// @nodoc
class __$$ConceptListResponseImplCopyWithImpl<$Res>
    extends _$ConceptListResponseCopyWithImpl<$Res, _$ConceptListResponseImpl>
    implements _$$ConceptListResponseImplCopyWith<$Res> {
  __$$ConceptListResponseImplCopyWithImpl(
    _$ConceptListResponseImpl _value,
    $Res Function(_$ConceptListResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConceptListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topicUuid = null,
    Object? displayName = null,
    Object? isLocked = null,
    Object? concepts = null,
  }) {
    return _then(
      _$ConceptListResponseImpl(
        topicUuid: null == topicUuid
            ? _value.topicUuid
            : topicUuid // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
        isLocked: null == isLocked
            ? _value.isLocked
            : isLocked // ignore: cast_nullable_to_non_nullable
                  as bool,
        concepts: null == concepts
            ? _value._concepts
            : concepts // ignore: cast_nullable_to_non_nullable
                  as List<ConceptSummary>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConceptListResponseImpl implements _ConceptListResponse {
  const _$ConceptListResponseImpl({
    required this.topicUuid,
    required this.displayName,
    this.isLocked = false,
    final List<ConceptSummary> concepts = const [],
  }) : _concepts = concepts;

  factory _$ConceptListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConceptListResponseImplFromJson(json);

  @override
  final String topicUuid;
  @override
  final String displayName;
  @override
  @JsonKey()
  final bool isLocked;
  final List<ConceptSummary> _concepts;
  @override
  @JsonKey()
  List<ConceptSummary> get concepts {
    if (_concepts is EqualUnmodifiableListView) return _concepts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_concepts);
  }

  @override
  String toString() {
    return 'ConceptListResponse(topicUuid: $topicUuid, displayName: $displayName, isLocked: $isLocked, concepts: $concepts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConceptListResponseImpl &&
            (identical(other.topicUuid, topicUuid) ||
                other.topicUuid == topicUuid) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.isLocked, isLocked) ||
                other.isLocked == isLocked) &&
            const DeepCollectionEquality().equals(other._concepts, _concepts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    topicUuid,
    displayName,
    isLocked,
    const DeepCollectionEquality().hash(_concepts),
  );

  /// Create a copy of ConceptListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConceptListResponseImplCopyWith<_$ConceptListResponseImpl> get copyWith =>
      __$$ConceptListResponseImplCopyWithImpl<_$ConceptListResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConceptListResponseImplToJson(this);
  }
}

abstract class _ConceptListResponse implements ConceptListResponse {
  const factory _ConceptListResponse({
    required final String topicUuid,
    required final String displayName,
    final bool isLocked,
    final List<ConceptSummary> concepts,
  }) = _$ConceptListResponseImpl;

  factory _ConceptListResponse.fromJson(Map<String, dynamic> json) =
      _$ConceptListResponseImpl.fromJson;

  @override
  String get topicUuid;
  @override
  String get displayName;
  @override
  bool get isLocked;
  @override
  List<ConceptSummary> get concepts;

  /// Create a copy of ConceptListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConceptListResponseImplCopyWith<_$ConceptListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConceptSummary _$ConceptSummaryFromJson(Map<String, dynamic> json) {
  return _ConceptSummary.fromJson(json);
}

/// @nodoc
mixin _$ConceptSummary {
  String get conceptUuid => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get summary => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: ConceptStatus.notStarted)
  ConceptStatus get status => throw _privateConstructorUsedError;
  int get checkCorrectCount => throw _privateConstructorUsedError;
  int get checkQuestionCount => throw _privateConstructorUsedError;

  /// Serializes this ConceptSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConceptSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConceptSummaryCopyWith<ConceptSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConceptSummaryCopyWith<$Res> {
  factory $ConceptSummaryCopyWith(
    ConceptSummary value,
    $Res Function(ConceptSummary) then,
  ) = _$ConceptSummaryCopyWithImpl<$Res, ConceptSummary>;
  @useResult
  $Res call({
    String conceptUuid,
    String title,
    String? summary,
    @JsonKey(unknownEnumValue: ConceptStatus.notStarted) ConceptStatus status,
    int checkCorrectCount,
    int checkQuestionCount,
  });
}

/// @nodoc
class _$ConceptSummaryCopyWithImpl<$Res, $Val extends ConceptSummary>
    implements $ConceptSummaryCopyWith<$Res> {
  _$ConceptSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConceptSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conceptUuid = null,
    Object? title = null,
    Object? summary = freezed,
    Object? status = null,
    Object? checkCorrectCount = null,
    Object? checkQuestionCount = null,
  }) {
    return _then(
      _value.copyWith(
            conceptUuid: null == conceptUuid
                ? _value.conceptUuid
                : conceptUuid // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            summary: freezed == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ConceptStatus,
            checkCorrectCount: null == checkCorrectCount
                ? _value.checkCorrectCount
                : checkCorrectCount // ignore: cast_nullable_to_non_nullable
                      as int,
            checkQuestionCount: null == checkQuestionCount
                ? _value.checkQuestionCount
                : checkQuestionCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConceptSummaryImplCopyWith<$Res>
    implements $ConceptSummaryCopyWith<$Res> {
  factory _$$ConceptSummaryImplCopyWith(
    _$ConceptSummaryImpl value,
    $Res Function(_$ConceptSummaryImpl) then,
  ) = __$$ConceptSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String conceptUuid,
    String title,
    String? summary,
    @JsonKey(unknownEnumValue: ConceptStatus.notStarted) ConceptStatus status,
    int checkCorrectCount,
    int checkQuestionCount,
  });
}

/// @nodoc
class __$$ConceptSummaryImplCopyWithImpl<$Res>
    extends _$ConceptSummaryCopyWithImpl<$Res, _$ConceptSummaryImpl>
    implements _$$ConceptSummaryImplCopyWith<$Res> {
  __$$ConceptSummaryImplCopyWithImpl(
    _$ConceptSummaryImpl _value,
    $Res Function(_$ConceptSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConceptSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conceptUuid = null,
    Object? title = null,
    Object? summary = freezed,
    Object? status = null,
    Object? checkCorrectCount = null,
    Object? checkQuestionCount = null,
  }) {
    return _then(
      _$ConceptSummaryImpl(
        conceptUuid: null == conceptUuid
            ? _value.conceptUuid
            : conceptUuid // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        summary: freezed == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ConceptStatus,
        checkCorrectCount: null == checkCorrectCount
            ? _value.checkCorrectCount
            : checkCorrectCount // ignore: cast_nullable_to_non_nullable
                  as int,
        checkQuestionCount: null == checkQuestionCount
            ? _value.checkQuestionCount
            : checkQuestionCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConceptSummaryImpl implements _ConceptSummary {
  const _$ConceptSummaryImpl({
    required this.conceptUuid,
    required this.title,
    this.summary,
    @JsonKey(unknownEnumValue: ConceptStatus.notStarted)
    this.status = ConceptStatus.notStarted,
    this.checkCorrectCount = 0,
    this.checkQuestionCount = 0,
  });

  factory _$ConceptSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConceptSummaryImplFromJson(json);

  @override
  final String conceptUuid;
  @override
  final String title;
  @override
  final String? summary;
  @override
  @JsonKey(unknownEnumValue: ConceptStatus.notStarted)
  final ConceptStatus status;
  @override
  @JsonKey()
  final int checkCorrectCount;
  @override
  @JsonKey()
  final int checkQuestionCount;

  @override
  String toString() {
    return 'ConceptSummary(conceptUuid: $conceptUuid, title: $title, summary: $summary, status: $status, checkCorrectCount: $checkCorrectCount, checkQuestionCount: $checkQuestionCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConceptSummaryImpl &&
            (identical(other.conceptUuid, conceptUuid) ||
                other.conceptUuid == conceptUuid) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.checkCorrectCount, checkCorrectCount) ||
                other.checkCorrectCount == checkCorrectCount) &&
            (identical(other.checkQuestionCount, checkQuestionCount) ||
                other.checkQuestionCount == checkQuestionCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    conceptUuid,
    title,
    summary,
    status,
    checkCorrectCount,
    checkQuestionCount,
  );

  /// Create a copy of ConceptSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConceptSummaryImplCopyWith<_$ConceptSummaryImpl> get copyWith =>
      __$$ConceptSummaryImplCopyWithImpl<_$ConceptSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConceptSummaryImplToJson(this);
  }
}

abstract class _ConceptSummary implements ConceptSummary {
  const factory _ConceptSummary({
    required final String conceptUuid,
    required final String title,
    final String? summary,
    @JsonKey(unknownEnumValue: ConceptStatus.notStarted)
    final ConceptStatus status,
    final int checkCorrectCount,
    final int checkQuestionCount,
  }) = _$ConceptSummaryImpl;

  factory _ConceptSummary.fromJson(Map<String, dynamic> json) =
      _$ConceptSummaryImpl.fromJson;

  @override
  String get conceptUuid;
  @override
  String get title;
  @override
  String? get summary;
  @override
  @JsonKey(unknownEnumValue: ConceptStatus.notStarted)
  ConceptStatus get status;
  @override
  int get checkCorrectCount;
  @override
  int get checkQuestionCount;

  /// Create a copy of ConceptSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConceptSummaryImplCopyWith<_$ConceptSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConceptDetailResponse _$ConceptDetailResponseFromJson(
  Map<String, dynamic> json,
) {
  return _ConceptDetailResponse.fromJson(json);
}

/// @nodoc
mixin _$ConceptDetailResponse {
  String get conceptUuid => throw _privateConstructorUsedError;
  String get topicUuid => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get summary => throw _privateConstructorUsedError;
  String? get coreMd => throw _privateConstructorUsedError;
  List<ConceptDetailSection> get detailSections =>
      throw _privateConstructorUsedError;
  String? get previousConceptUuid => throw _privateConstructorUsedError;
  String? get nextConceptUuid => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: ConceptStudyMode.read)
  ConceptStudyMode get lastMode => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: ConceptReadingDepth.core)
  ConceptReadingDepth get lastDepth => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  int get checkCorrectCount => throw _privateConstructorUsedError;
  List<String> get relatedQuestionUuids => throw _privateConstructorUsedError;

  /// Serializes this ConceptDetailResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConceptDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConceptDetailResponseCopyWith<ConceptDetailResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConceptDetailResponseCopyWith<$Res> {
  factory $ConceptDetailResponseCopyWith(
    ConceptDetailResponse value,
    $Res Function(ConceptDetailResponse) then,
  ) = _$ConceptDetailResponseCopyWithImpl<$Res, ConceptDetailResponse>;
  @useResult
  $Res call({
    String conceptUuid,
    String topicUuid,
    String title,
    String? summary,
    String? coreMd,
    List<ConceptDetailSection> detailSections,
    String? previousConceptUuid,
    String? nextConceptUuid,
    @JsonKey(unknownEnumValue: ConceptStudyMode.read) ConceptStudyMode lastMode,
    @JsonKey(unknownEnumValue: ConceptReadingDepth.core)
    ConceptReadingDepth lastDepth,
    bool isRead,
    int checkCorrectCount,
    List<String> relatedQuestionUuids,
  });
}

/// @nodoc
class _$ConceptDetailResponseCopyWithImpl<
  $Res,
  $Val extends ConceptDetailResponse
>
    implements $ConceptDetailResponseCopyWith<$Res> {
  _$ConceptDetailResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConceptDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conceptUuid = null,
    Object? topicUuid = null,
    Object? title = null,
    Object? summary = freezed,
    Object? coreMd = freezed,
    Object? detailSections = null,
    Object? previousConceptUuid = freezed,
    Object? nextConceptUuid = freezed,
    Object? lastMode = null,
    Object? lastDepth = null,
    Object? isRead = null,
    Object? checkCorrectCount = null,
    Object? relatedQuestionUuids = null,
  }) {
    return _then(
      _value.copyWith(
            conceptUuid: null == conceptUuid
                ? _value.conceptUuid
                : conceptUuid // ignore: cast_nullable_to_non_nullable
                      as String,
            topicUuid: null == topicUuid
                ? _value.topicUuid
                : topicUuid // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            summary: freezed == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as String?,
            coreMd: freezed == coreMd
                ? _value.coreMd
                : coreMd // ignore: cast_nullable_to_non_nullable
                      as String?,
            detailSections: null == detailSections
                ? _value.detailSections
                : detailSections // ignore: cast_nullable_to_non_nullable
                      as List<ConceptDetailSection>,
            previousConceptUuid: freezed == previousConceptUuid
                ? _value.previousConceptUuid
                : previousConceptUuid // ignore: cast_nullable_to_non_nullable
                      as String?,
            nextConceptUuid: freezed == nextConceptUuid
                ? _value.nextConceptUuid
                : nextConceptUuid // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastMode: null == lastMode
                ? _value.lastMode
                : lastMode // ignore: cast_nullable_to_non_nullable
                      as ConceptStudyMode,
            lastDepth: null == lastDepth
                ? _value.lastDepth
                : lastDepth // ignore: cast_nullable_to_non_nullable
                      as ConceptReadingDepth,
            isRead: null == isRead
                ? _value.isRead
                : isRead // ignore: cast_nullable_to_non_nullable
                      as bool,
            checkCorrectCount: null == checkCorrectCount
                ? _value.checkCorrectCount
                : checkCorrectCount // ignore: cast_nullable_to_non_nullable
                      as int,
            relatedQuestionUuids: null == relatedQuestionUuids
                ? _value.relatedQuestionUuids
                : relatedQuestionUuids // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConceptDetailResponseImplCopyWith<$Res>
    implements $ConceptDetailResponseCopyWith<$Res> {
  factory _$$ConceptDetailResponseImplCopyWith(
    _$ConceptDetailResponseImpl value,
    $Res Function(_$ConceptDetailResponseImpl) then,
  ) = __$$ConceptDetailResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String conceptUuid,
    String topicUuid,
    String title,
    String? summary,
    String? coreMd,
    List<ConceptDetailSection> detailSections,
    String? previousConceptUuid,
    String? nextConceptUuid,
    @JsonKey(unknownEnumValue: ConceptStudyMode.read) ConceptStudyMode lastMode,
    @JsonKey(unknownEnumValue: ConceptReadingDepth.core)
    ConceptReadingDepth lastDepth,
    bool isRead,
    int checkCorrectCount,
    List<String> relatedQuestionUuids,
  });
}

/// @nodoc
class __$$ConceptDetailResponseImplCopyWithImpl<$Res>
    extends
        _$ConceptDetailResponseCopyWithImpl<$Res, _$ConceptDetailResponseImpl>
    implements _$$ConceptDetailResponseImplCopyWith<$Res> {
  __$$ConceptDetailResponseImplCopyWithImpl(
    _$ConceptDetailResponseImpl _value,
    $Res Function(_$ConceptDetailResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConceptDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conceptUuid = null,
    Object? topicUuid = null,
    Object? title = null,
    Object? summary = freezed,
    Object? coreMd = freezed,
    Object? detailSections = null,
    Object? previousConceptUuid = freezed,
    Object? nextConceptUuid = freezed,
    Object? lastMode = null,
    Object? lastDepth = null,
    Object? isRead = null,
    Object? checkCorrectCount = null,
    Object? relatedQuestionUuids = null,
  }) {
    return _then(
      _$ConceptDetailResponseImpl(
        conceptUuid: null == conceptUuid
            ? _value.conceptUuid
            : conceptUuid // ignore: cast_nullable_to_non_nullable
                  as String,
        topicUuid: null == topicUuid
            ? _value.topicUuid
            : topicUuid // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        summary: freezed == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as String?,
        coreMd: freezed == coreMd
            ? _value.coreMd
            : coreMd // ignore: cast_nullable_to_non_nullable
                  as String?,
        detailSections: null == detailSections
            ? _value._detailSections
            : detailSections // ignore: cast_nullable_to_non_nullable
                  as List<ConceptDetailSection>,
        previousConceptUuid: freezed == previousConceptUuid
            ? _value.previousConceptUuid
            : previousConceptUuid // ignore: cast_nullable_to_non_nullable
                  as String?,
        nextConceptUuid: freezed == nextConceptUuid
            ? _value.nextConceptUuid
            : nextConceptUuid // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastMode: null == lastMode
            ? _value.lastMode
            : lastMode // ignore: cast_nullable_to_non_nullable
                  as ConceptStudyMode,
        lastDepth: null == lastDepth
            ? _value.lastDepth
            : lastDepth // ignore: cast_nullable_to_non_nullable
                  as ConceptReadingDepth,
        isRead: null == isRead
            ? _value.isRead
            : isRead // ignore: cast_nullable_to_non_nullable
                  as bool,
        checkCorrectCount: null == checkCorrectCount
            ? _value.checkCorrectCount
            : checkCorrectCount // ignore: cast_nullable_to_non_nullable
                  as int,
        relatedQuestionUuids: null == relatedQuestionUuids
            ? _value._relatedQuestionUuids
            : relatedQuestionUuids // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConceptDetailResponseImpl implements _ConceptDetailResponse {
  const _$ConceptDetailResponseImpl({
    required this.conceptUuid,
    required this.topicUuid,
    required this.title,
    this.summary,
    this.coreMd,
    final List<ConceptDetailSection> detailSections = const [],
    this.previousConceptUuid,
    this.nextConceptUuid,
    @JsonKey(unknownEnumValue: ConceptStudyMode.read)
    this.lastMode = ConceptStudyMode.read,
    @JsonKey(unknownEnumValue: ConceptReadingDepth.core)
    this.lastDepth = ConceptReadingDepth.core,
    this.isRead = false,
    this.checkCorrectCount = 0,
    final List<String> relatedQuestionUuids = const [],
  }) : _detailSections = detailSections,
       _relatedQuestionUuids = relatedQuestionUuids;

  factory _$ConceptDetailResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConceptDetailResponseImplFromJson(json);

  @override
  final String conceptUuid;
  @override
  final String topicUuid;
  @override
  final String title;
  @override
  final String? summary;
  @override
  final String? coreMd;
  final List<ConceptDetailSection> _detailSections;
  @override
  @JsonKey()
  List<ConceptDetailSection> get detailSections {
    if (_detailSections is EqualUnmodifiableListView) return _detailSections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_detailSections);
  }

  @override
  final String? previousConceptUuid;
  @override
  final String? nextConceptUuid;
  @override
  @JsonKey(unknownEnumValue: ConceptStudyMode.read)
  final ConceptStudyMode lastMode;
  @override
  @JsonKey(unknownEnumValue: ConceptReadingDepth.core)
  final ConceptReadingDepth lastDepth;
  @override
  @JsonKey()
  final bool isRead;
  @override
  @JsonKey()
  final int checkCorrectCount;
  final List<String> _relatedQuestionUuids;
  @override
  @JsonKey()
  List<String> get relatedQuestionUuids {
    if (_relatedQuestionUuids is EqualUnmodifiableListView)
      return _relatedQuestionUuids;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_relatedQuestionUuids);
  }

  @override
  String toString() {
    return 'ConceptDetailResponse(conceptUuid: $conceptUuid, topicUuid: $topicUuid, title: $title, summary: $summary, coreMd: $coreMd, detailSections: $detailSections, previousConceptUuid: $previousConceptUuid, nextConceptUuid: $nextConceptUuid, lastMode: $lastMode, lastDepth: $lastDepth, isRead: $isRead, checkCorrectCount: $checkCorrectCount, relatedQuestionUuids: $relatedQuestionUuids)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConceptDetailResponseImpl &&
            (identical(other.conceptUuid, conceptUuid) ||
                other.conceptUuid == conceptUuid) &&
            (identical(other.topicUuid, topicUuid) ||
                other.topicUuid == topicUuid) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.coreMd, coreMd) || other.coreMd == coreMd) &&
            const DeepCollectionEquality().equals(
              other._detailSections,
              _detailSections,
            ) &&
            (identical(other.previousConceptUuid, previousConceptUuid) ||
                other.previousConceptUuid == previousConceptUuid) &&
            (identical(other.nextConceptUuid, nextConceptUuid) ||
                other.nextConceptUuid == nextConceptUuid) &&
            (identical(other.lastMode, lastMode) ||
                other.lastMode == lastMode) &&
            (identical(other.lastDepth, lastDepth) ||
                other.lastDepth == lastDepth) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.checkCorrectCount, checkCorrectCount) ||
                other.checkCorrectCount == checkCorrectCount) &&
            const DeepCollectionEquality().equals(
              other._relatedQuestionUuids,
              _relatedQuestionUuids,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    conceptUuid,
    topicUuid,
    title,
    summary,
    coreMd,
    const DeepCollectionEquality().hash(_detailSections),
    previousConceptUuid,
    nextConceptUuid,
    lastMode,
    lastDepth,
    isRead,
    checkCorrectCount,
    const DeepCollectionEquality().hash(_relatedQuestionUuids),
  );

  /// Create a copy of ConceptDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConceptDetailResponseImplCopyWith<_$ConceptDetailResponseImpl>
  get copyWith =>
      __$$ConceptDetailResponseImplCopyWithImpl<_$ConceptDetailResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConceptDetailResponseImplToJson(this);
  }
}

abstract class _ConceptDetailResponse implements ConceptDetailResponse {
  const factory _ConceptDetailResponse({
    required final String conceptUuid,
    required final String topicUuid,
    required final String title,
    final String? summary,
    final String? coreMd,
    final List<ConceptDetailSection> detailSections,
    final String? previousConceptUuid,
    final String? nextConceptUuid,
    @JsonKey(unknownEnumValue: ConceptStudyMode.read)
    final ConceptStudyMode lastMode,
    @JsonKey(unknownEnumValue: ConceptReadingDepth.core)
    final ConceptReadingDepth lastDepth,
    final bool isRead,
    final int checkCorrectCount,
    final List<String> relatedQuestionUuids,
  }) = _$ConceptDetailResponseImpl;

  factory _ConceptDetailResponse.fromJson(Map<String, dynamic> json) =
      _$ConceptDetailResponseImpl.fromJson;

  @override
  String get conceptUuid;
  @override
  String get topicUuid;
  @override
  String get title;
  @override
  String? get summary;
  @override
  String? get coreMd;
  @override
  List<ConceptDetailSection> get detailSections;
  @override
  String? get previousConceptUuid;
  @override
  String? get nextConceptUuid;
  @override
  @JsonKey(unknownEnumValue: ConceptStudyMode.read)
  ConceptStudyMode get lastMode;
  @override
  @JsonKey(unknownEnumValue: ConceptReadingDepth.core)
  ConceptReadingDepth get lastDepth;
  @override
  bool get isRead;
  @override
  int get checkCorrectCount;
  @override
  List<String> get relatedQuestionUuids;

  /// Create a copy of ConceptDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConceptDetailResponseImplCopyWith<_$ConceptDetailResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ConceptDetailSection _$ConceptDetailSectionFromJson(Map<String, dynamic> json) {
  return _ConceptDetailSection.fromJson(json);
}

/// @nodoc
mixin _$ConceptDetailSection {
  String get anchor => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get bodyMd => throw _privateConstructorUsedError;

  /// Serializes this ConceptDetailSection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConceptDetailSection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConceptDetailSectionCopyWith<ConceptDetailSection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConceptDetailSectionCopyWith<$Res> {
  factory $ConceptDetailSectionCopyWith(
    ConceptDetailSection value,
    $Res Function(ConceptDetailSection) then,
  ) = _$ConceptDetailSectionCopyWithImpl<$Res, ConceptDetailSection>;
  @useResult
  $Res call({String anchor, String title, String bodyMd});
}

/// @nodoc
class _$ConceptDetailSectionCopyWithImpl<
  $Res,
  $Val extends ConceptDetailSection
>
    implements $ConceptDetailSectionCopyWith<$Res> {
  _$ConceptDetailSectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConceptDetailSection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? anchor = null,
    Object? title = null,
    Object? bodyMd = null,
  }) {
    return _then(
      _value.copyWith(
            anchor: null == anchor
                ? _value.anchor
                : anchor // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            bodyMd: null == bodyMd
                ? _value.bodyMd
                : bodyMd // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConceptDetailSectionImplCopyWith<$Res>
    implements $ConceptDetailSectionCopyWith<$Res> {
  factory _$$ConceptDetailSectionImplCopyWith(
    _$ConceptDetailSectionImpl value,
    $Res Function(_$ConceptDetailSectionImpl) then,
  ) = __$$ConceptDetailSectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String anchor, String title, String bodyMd});
}

/// @nodoc
class __$$ConceptDetailSectionImplCopyWithImpl<$Res>
    extends _$ConceptDetailSectionCopyWithImpl<$Res, _$ConceptDetailSectionImpl>
    implements _$$ConceptDetailSectionImplCopyWith<$Res> {
  __$$ConceptDetailSectionImplCopyWithImpl(
    _$ConceptDetailSectionImpl _value,
    $Res Function(_$ConceptDetailSectionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConceptDetailSection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? anchor = null,
    Object? title = null,
    Object? bodyMd = null,
  }) {
    return _then(
      _$ConceptDetailSectionImpl(
        anchor: null == anchor
            ? _value.anchor
            : anchor // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        bodyMd: null == bodyMd
            ? _value.bodyMd
            : bodyMd // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConceptDetailSectionImpl implements _ConceptDetailSection {
  const _$ConceptDetailSectionImpl({
    required this.anchor,
    required this.title,
    this.bodyMd = '',
  });

  factory _$ConceptDetailSectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConceptDetailSectionImplFromJson(json);

  @override
  final String anchor;
  @override
  final String title;
  @override
  @JsonKey()
  final String bodyMd;

  @override
  String toString() {
    return 'ConceptDetailSection(anchor: $anchor, title: $title, bodyMd: $bodyMd)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConceptDetailSectionImpl &&
            (identical(other.anchor, anchor) || other.anchor == anchor) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.bodyMd, bodyMd) || other.bodyMd == bodyMd));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, anchor, title, bodyMd);

  /// Create a copy of ConceptDetailSection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConceptDetailSectionImplCopyWith<_$ConceptDetailSectionImpl>
  get copyWith =>
      __$$ConceptDetailSectionImplCopyWithImpl<_$ConceptDetailSectionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConceptDetailSectionImplToJson(this);
  }
}

abstract class _ConceptDetailSection implements ConceptDetailSection {
  const factory _ConceptDetailSection({
    required final String anchor,
    required final String title,
    final String bodyMd,
  }) = _$ConceptDetailSectionImpl;

  factory _ConceptDetailSection.fromJson(Map<String, dynamic> json) =
      _$ConceptDetailSectionImpl.fromJson;

  @override
  String get anchor;
  @override
  String get title;
  @override
  String get bodyMd;

  /// Create a copy of ConceptDetailSection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConceptDetailSectionImplCopyWith<_$ConceptDetailSectionImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ConceptCheckQuestionResponse _$ConceptCheckQuestionResponseFromJson(
  Map<String, dynamic> json,
) {
  return _ConceptCheckQuestionResponse.fromJson(json);
}

/// @nodoc
mixin _$ConceptCheckQuestionResponse {
  String get questionUuid => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  String get stem => throw _privateConstructorUsedError;
  String? get stemSql => throw _privateConstructorUsedError;
  List<ConceptCheckChoiceResponse> get choices =>
      throw _privateConstructorUsedError;

  /// Serializes this ConceptCheckQuestionResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConceptCheckQuestionResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConceptCheckQuestionResponseCopyWith<ConceptCheckQuestionResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConceptCheckQuestionResponseCopyWith<$Res> {
  factory $ConceptCheckQuestionResponseCopyWith(
    ConceptCheckQuestionResponse value,
    $Res Function(ConceptCheckQuestionResponse) then,
  ) =
      _$ConceptCheckQuestionResponseCopyWithImpl<
        $Res,
        ConceptCheckQuestionResponse
      >;
  @useResult
  $Res call({
    String questionUuid,
    int sortOrder,
    String stem,
    String? stemSql,
    List<ConceptCheckChoiceResponse> choices,
  });
}

/// @nodoc
class _$ConceptCheckQuestionResponseCopyWithImpl<
  $Res,
  $Val extends ConceptCheckQuestionResponse
>
    implements $ConceptCheckQuestionResponseCopyWith<$Res> {
  _$ConceptCheckQuestionResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConceptCheckQuestionResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionUuid = null,
    Object? sortOrder = null,
    Object? stem = null,
    Object? stemSql = freezed,
    Object? choices = null,
  }) {
    return _then(
      _value.copyWith(
            questionUuid: null == questionUuid
                ? _value.questionUuid
                : questionUuid // ignore: cast_nullable_to_non_nullable
                      as String,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            stem: null == stem
                ? _value.stem
                : stem // ignore: cast_nullable_to_non_nullable
                      as String,
            stemSql: freezed == stemSql
                ? _value.stemSql
                : stemSql // ignore: cast_nullable_to_non_nullable
                      as String?,
            choices: null == choices
                ? _value.choices
                : choices // ignore: cast_nullable_to_non_nullable
                      as List<ConceptCheckChoiceResponse>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConceptCheckQuestionResponseImplCopyWith<$Res>
    implements $ConceptCheckQuestionResponseCopyWith<$Res> {
  factory _$$ConceptCheckQuestionResponseImplCopyWith(
    _$ConceptCheckQuestionResponseImpl value,
    $Res Function(_$ConceptCheckQuestionResponseImpl) then,
  ) = __$$ConceptCheckQuestionResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String questionUuid,
    int sortOrder,
    String stem,
    String? stemSql,
    List<ConceptCheckChoiceResponse> choices,
  });
}

/// @nodoc
class __$$ConceptCheckQuestionResponseImplCopyWithImpl<$Res>
    extends
        _$ConceptCheckQuestionResponseCopyWithImpl<
          $Res,
          _$ConceptCheckQuestionResponseImpl
        >
    implements _$$ConceptCheckQuestionResponseImplCopyWith<$Res> {
  __$$ConceptCheckQuestionResponseImplCopyWithImpl(
    _$ConceptCheckQuestionResponseImpl _value,
    $Res Function(_$ConceptCheckQuestionResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConceptCheckQuestionResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionUuid = null,
    Object? sortOrder = null,
    Object? stem = null,
    Object? stemSql = freezed,
    Object? choices = null,
  }) {
    return _then(
      _$ConceptCheckQuestionResponseImpl(
        questionUuid: null == questionUuid
            ? _value.questionUuid
            : questionUuid // ignore: cast_nullable_to_non_nullable
                  as String,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        stem: null == stem
            ? _value.stem
            : stem // ignore: cast_nullable_to_non_nullable
                  as String,
        stemSql: freezed == stemSql
            ? _value.stemSql
            : stemSql // ignore: cast_nullable_to_non_nullable
                  as String?,
        choices: null == choices
            ? _value._choices
            : choices // ignore: cast_nullable_to_non_nullable
                  as List<ConceptCheckChoiceResponse>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConceptCheckQuestionResponseImpl
    implements _ConceptCheckQuestionResponse {
  const _$ConceptCheckQuestionResponseImpl({
    required this.questionUuid,
    this.sortOrder = 0,
    required this.stem,
    this.stemSql,
    final List<ConceptCheckChoiceResponse> choices = const [],
  }) : _choices = choices;

  factory _$ConceptCheckQuestionResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$ConceptCheckQuestionResponseImplFromJson(json);

  @override
  final String questionUuid;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  final String stem;
  @override
  final String? stemSql;
  final List<ConceptCheckChoiceResponse> _choices;
  @override
  @JsonKey()
  List<ConceptCheckChoiceResponse> get choices {
    if (_choices is EqualUnmodifiableListView) return _choices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_choices);
  }

  @override
  String toString() {
    return 'ConceptCheckQuestionResponse(questionUuid: $questionUuid, sortOrder: $sortOrder, stem: $stem, stemSql: $stemSql, choices: $choices)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConceptCheckQuestionResponseImpl &&
            (identical(other.questionUuid, questionUuid) ||
                other.questionUuid == questionUuid) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.stem, stem) || other.stem == stem) &&
            (identical(other.stemSql, stemSql) || other.stemSql == stemSql) &&
            const DeepCollectionEquality().equals(other._choices, _choices));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    questionUuid,
    sortOrder,
    stem,
    stemSql,
    const DeepCollectionEquality().hash(_choices),
  );

  /// Create a copy of ConceptCheckQuestionResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConceptCheckQuestionResponseImplCopyWith<
    _$ConceptCheckQuestionResponseImpl
  >
  get copyWith =>
      __$$ConceptCheckQuestionResponseImplCopyWithImpl<
        _$ConceptCheckQuestionResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConceptCheckQuestionResponseImplToJson(this);
  }
}

abstract class _ConceptCheckQuestionResponse
    implements ConceptCheckQuestionResponse {
  const factory _ConceptCheckQuestionResponse({
    required final String questionUuid,
    final int sortOrder,
    required final String stem,
    final String? stemSql,
    final List<ConceptCheckChoiceResponse> choices,
  }) = _$ConceptCheckQuestionResponseImpl;

  factory _ConceptCheckQuestionResponse.fromJson(Map<String, dynamic> json) =
      _$ConceptCheckQuestionResponseImpl.fromJson;

  @override
  String get questionUuid;
  @override
  int get sortOrder;
  @override
  String get stem;
  @override
  String? get stemSql;
  @override
  List<ConceptCheckChoiceResponse> get choices;

  /// Create a copy of ConceptCheckQuestionResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConceptCheckQuestionResponseImplCopyWith<
    _$ConceptCheckQuestionResponseImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

ConceptCheckChoiceResponse _$ConceptCheckChoiceResponseFromJson(
  Map<String, dynamic> json,
) {
  return _ConceptCheckChoiceResponse.fromJson(json);
}

/// @nodoc
mixin _$ConceptCheckChoiceResponse {
  String get choiceKey => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;

  /// Serializes this ConceptCheckChoiceResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConceptCheckChoiceResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConceptCheckChoiceResponseCopyWith<ConceptCheckChoiceResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConceptCheckChoiceResponseCopyWith<$Res> {
  factory $ConceptCheckChoiceResponseCopyWith(
    ConceptCheckChoiceResponse value,
    $Res Function(ConceptCheckChoiceResponse) then,
  ) =
      _$ConceptCheckChoiceResponseCopyWithImpl<
        $Res,
        ConceptCheckChoiceResponse
      >;
  @useResult
  $Res call({String choiceKey, String body});
}

/// @nodoc
class _$ConceptCheckChoiceResponseCopyWithImpl<
  $Res,
  $Val extends ConceptCheckChoiceResponse
>
    implements $ConceptCheckChoiceResponseCopyWith<$Res> {
  _$ConceptCheckChoiceResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConceptCheckChoiceResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? choiceKey = null, Object? body = null}) {
    return _then(
      _value.copyWith(
            choiceKey: null == choiceKey
                ? _value.choiceKey
                : choiceKey // ignore: cast_nullable_to_non_nullable
                      as String,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConceptCheckChoiceResponseImplCopyWith<$Res>
    implements $ConceptCheckChoiceResponseCopyWith<$Res> {
  factory _$$ConceptCheckChoiceResponseImplCopyWith(
    _$ConceptCheckChoiceResponseImpl value,
    $Res Function(_$ConceptCheckChoiceResponseImpl) then,
  ) = __$$ConceptCheckChoiceResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String choiceKey, String body});
}

/// @nodoc
class __$$ConceptCheckChoiceResponseImplCopyWithImpl<$Res>
    extends
        _$ConceptCheckChoiceResponseCopyWithImpl<
          $Res,
          _$ConceptCheckChoiceResponseImpl
        >
    implements _$$ConceptCheckChoiceResponseImplCopyWith<$Res> {
  __$$ConceptCheckChoiceResponseImplCopyWithImpl(
    _$ConceptCheckChoiceResponseImpl _value,
    $Res Function(_$ConceptCheckChoiceResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConceptCheckChoiceResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? choiceKey = null, Object? body = null}) {
    return _then(
      _$ConceptCheckChoiceResponseImpl(
        choiceKey: null == choiceKey
            ? _value.choiceKey
            : choiceKey // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConceptCheckChoiceResponseImpl implements _ConceptCheckChoiceResponse {
  const _$ConceptCheckChoiceResponseImpl({
    required this.choiceKey,
    required this.body,
  });

  factory _$ConceptCheckChoiceResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$ConceptCheckChoiceResponseImplFromJson(json);

  @override
  final String choiceKey;
  @override
  final String body;

  @override
  String toString() {
    return 'ConceptCheckChoiceResponse(choiceKey: $choiceKey, body: $body)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConceptCheckChoiceResponseImpl &&
            (identical(other.choiceKey, choiceKey) ||
                other.choiceKey == choiceKey) &&
            (identical(other.body, body) || other.body == body));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, choiceKey, body);

  /// Create a copy of ConceptCheckChoiceResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConceptCheckChoiceResponseImplCopyWith<_$ConceptCheckChoiceResponseImpl>
  get copyWith =>
      __$$ConceptCheckChoiceResponseImplCopyWithImpl<
        _$ConceptCheckChoiceResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConceptCheckChoiceResponseImplToJson(this);
  }
}

abstract class _ConceptCheckChoiceResponse
    implements ConceptCheckChoiceResponse {
  const factory _ConceptCheckChoiceResponse({
    required final String choiceKey,
    required final String body,
  }) = _$ConceptCheckChoiceResponseImpl;

  factory _ConceptCheckChoiceResponse.fromJson(Map<String, dynamic> json) =
      _$ConceptCheckChoiceResponseImpl.fromJson;

  @override
  String get choiceKey;
  @override
  String get body;

  /// Create a copy of ConceptCheckChoiceResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConceptCheckChoiceResponseImplCopyWith<_$ConceptCheckChoiceResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ConceptCheckAnswerRequest _$ConceptCheckAnswerRequestFromJson(
  Map<String, dynamic> json,
) {
  return _ConceptCheckAnswerRequest.fromJson(json);
}

/// @nodoc
mixin _$ConceptCheckAnswerRequest {
  String get choiceKey => throw _privateConstructorUsedError;

  /// Serializes this ConceptCheckAnswerRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConceptCheckAnswerRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConceptCheckAnswerRequestCopyWith<ConceptCheckAnswerRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConceptCheckAnswerRequestCopyWith<$Res> {
  factory $ConceptCheckAnswerRequestCopyWith(
    ConceptCheckAnswerRequest value,
    $Res Function(ConceptCheckAnswerRequest) then,
  ) = _$ConceptCheckAnswerRequestCopyWithImpl<$Res, ConceptCheckAnswerRequest>;
  @useResult
  $Res call({String choiceKey});
}

/// @nodoc
class _$ConceptCheckAnswerRequestCopyWithImpl<
  $Res,
  $Val extends ConceptCheckAnswerRequest
>
    implements $ConceptCheckAnswerRequestCopyWith<$Res> {
  _$ConceptCheckAnswerRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConceptCheckAnswerRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? choiceKey = null}) {
    return _then(
      _value.copyWith(
            choiceKey: null == choiceKey
                ? _value.choiceKey
                : choiceKey // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConceptCheckAnswerRequestImplCopyWith<$Res>
    implements $ConceptCheckAnswerRequestCopyWith<$Res> {
  factory _$$ConceptCheckAnswerRequestImplCopyWith(
    _$ConceptCheckAnswerRequestImpl value,
    $Res Function(_$ConceptCheckAnswerRequestImpl) then,
  ) = __$$ConceptCheckAnswerRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String choiceKey});
}

/// @nodoc
class __$$ConceptCheckAnswerRequestImplCopyWithImpl<$Res>
    extends
        _$ConceptCheckAnswerRequestCopyWithImpl<
          $Res,
          _$ConceptCheckAnswerRequestImpl
        >
    implements _$$ConceptCheckAnswerRequestImplCopyWith<$Res> {
  __$$ConceptCheckAnswerRequestImplCopyWithImpl(
    _$ConceptCheckAnswerRequestImpl _value,
    $Res Function(_$ConceptCheckAnswerRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConceptCheckAnswerRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? choiceKey = null}) {
    return _then(
      _$ConceptCheckAnswerRequestImpl(
        choiceKey: null == choiceKey
            ? _value.choiceKey
            : choiceKey // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConceptCheckAnswerRequestImpl implements _ConceptCheckAnswerRequest {
  const _$ConceptCheckAnswerRequestImpl({required this.choiceKey});

  factory _$ConceptCheckAnswerRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConceptCheckAnswerRequestImplFromJson(json);

  @override
  final String choiceKey;

  @override
  String toString() {
    return 'ConceptCheckAnswerRequest(choiceKey: $choiceKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConceptCheckAnswerRequestImpl &&
            (identical(other.choiceKey, choiceKey) ||
                other.choiceKey == choiceKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, choiceKey);

  /// Create a copy of ConceptCheckAnswerRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConceptCheckAnswerRequestImplCopyWith<_$ConceptCheckAnswerRequestImpl>
  get copyWith =>
      __$$ConceptCheckAnswerRequestImplCopyWithImpl<
        _$ConceptCheckAnswerRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConceptCheckAnswerRequestImplToJson(this);
  }
}

abstract class _ConceptCheckAnswerRequest implements ConceptCheckAnswerRequest {
  const factory _ConceptCheckAnswerRequest({required final String choiceKey}) =
      _$ConceptCheckAnswerRequestImpl;

  factory _ConceptCheckAnswerRequest.fromJson(Map<String, dynamic> json) =
      _$ConceptCheckAnswerRequestImpl.fromJson;

  @override
  String get choiceKey;

  /// Create a copy of ConceptCheckAnswerRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConceptCheckAnswerRequestImplCopyWith<_$ConceptCheckAnswerRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ConceptCheckAnswerResponse _$ConceptCheckAnswerResponseFromJson(
  Map<String, dynamic> json,
) {
  return _ConceptCheckAnswerResponse.fromJson(json);
}

/// @nodoc
mixin _$ConceptCheckAnswerResponse {
  bool get isCorrect => throw _privateConstructorUsedError;
  String get correctKey => throw _privateConstructorUsedError;
  String get explanation => throw _privateConstructorUsedError;
  String get rereadAnchor => throw _privateConstructorUsedError;
  Map<String, String> get rationaleByChoiceKey =>
      throw _privateConstructorUsedError;
  int get checkCorrectCount => throw _privateConstructorUsedError;
  int get checkSolvedCount => throw _privateConstructorUsedError;

  /// Serializes this ConceptCheckAnswerResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConceptCheckAnswerResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConceptCheckAnswerResponseCopyWith<ConceptCheckAnswerResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConceptCheckAnswerResponseCopyWith<$Res> {
  factory $ConceptCheckAnswerResponseCopyWith(
    ConceptCheckAnswerResponse value,
    $Res Function(ConceptCheckAnswerResponse) then,
  ) =
      _$ConceptCheckAnswerResponseCopyWithImpl<
        $Res,
        ConceptCheckAnswerResponse
      >;
  @useResult
  $Res call({
    bool isCorrect,
    String correctKey,
    String explanation,
    String rereadAnchor,
    Map<String, String> rationaleByChoiceKey,
    int checkCorrectCount,
    int checkSolvedCount,
  });
}

/// @nodoc
class _$ConceptCheckAnswerResponseCopyWithImpl<
  $Res,
  $Val extends ConceptCheckAnswerResponse
>
    implements $ConceptCheckAnswerResponseCopyWith<$Res> {
  _$ConceptCheckAnswerResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConceptCheckAnswerResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isCorrect = null,
    Object? correctKey = null,
    Object? explanation = null,
    Object? rereadAnchor = null,
    Object? rationaleByChoiceKey = null,
    Object? checkCorrectCount = null,
    Object? checkSolvedCount = null,
  }) {
    return _then(
      _value.copyWith(
            isCorrect: null == isCorrect
                ? _value.isCorrect
                : isCorrect // ignore: cast_nullable_to_non_nullable
                      as bool,
            correctKey: null == correctKey
                ? _value.correctKey
                : correctKey // ignore: cast_nullable_to_non_nullable
                      as String,
            explanation: null == explanation
                ? _value.explanation
                : explanation // ignore: cast_nullable_to_non_nullable
                      as String,
            rereadAnchor: null == rereadAnchor
                ? _value.rereadAnchor
                : rereadAnchor // ignore: cast_nullable_to_non_nullable
                      as String,
            rationaleByChoiceKey: null == rationaleByChoiceKey
                ? _value.rationaleByChoiceKey
                : rationaleByChoiceKey // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            checkCorrectCount: null == checkCorrectCount
                ? _value.checkCorrectCount
                : checkCorrectCount // ignore: cast_nullable_to_non_nullable
                      as int,
            checkSolvedCount: null == checkSolvedCount
                ? _value.checkSolvedCount
                : checkSolvedCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConceptCheckAnswerResponseImplCopyWith<$Res>
    implements $ConceptCheckAnswerResponseCopyWith<$Res> {
  factory _$$ConceptCheckAnswerResponseImplCopyWith(
    _$ConceptCheckAnswerResponseImpl value,
    $Res Function(_$ConceptCheckAnswerResponseImpl) then,
  ) = __$$ConceptCheckAnswerResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isCorrect,
    String correctKey,
    String explanation,
    String rereadAnchor,
    Map<String, String> rationaleByChoiceKey,
    int checkCorrectCount,
    int checkSolvedCount,
  });
}

/// @nodoc
class __$$ConceptCheckAnswerResponseImplCopyWithImpl<$Res>
    extends
        _$ConceptCheckAnswerResponseCopyWithImpl<
          $Res,
          _$ConceptCheckAnswerResponseImpl
        >
    implements _$$ConceptCheckAnswerResponseImplCopyWith<$Res> {
  __$$ConceptCheckAnswerResponseImplCopyWithImpl(
    _$ConceptCheckAnswerResponseImpl _value,
    $Res Function(_$ConceptCheckAnswerResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConceptCheckAnswerResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isCorrect = null,
    Object? correctKey = null,
    Object? explanation = null,
    Object? rereadAnchor = null,
    Object? rationaleByChoiceKey = null,
    Object? checkCorrectCount = null,
    Object? checkSolvedCount = null,
  }) {
    return _then(
      _$ConceptCheckAnswerResponseImpl(
        isCorrect: null == isCorrect
            ? _value.isCorrect
            : isCorrect // ignore: cast_nullable_to_non_nullable
                  as bool,
        correctKey: null == correctKey
            ? _value.correctKey
            : correctKey // ignore: cast_nullable_to_non_nullable
                  as String,
        explanation: null == explanation
            ? _value.explanation
            : explanation // ignore: cast_nullable_to_non_nullable
                  as String,
        rereadAnchor: null == rereadAnchor
            ? _value.rereadAnchor
            : rereadAnchor // ignore: cast_nullable_to_non_nullable
                  as String,
        rationaleByChoiceKey: null == rationaleByChoiceKey
            ? _value._rationaleByChoiceKey
            : rationaleByChoiceKey // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        checkCorrectCount: null == checkCorrectCount
            ? _value.checkCorrectCount
            : checkCorrectCount // ignore: cast_nullable_to_non_nullable
                  as int,
        checkSolvedCount: null == checkSolvedCount
            ? _value.checkSolvedCount
            : checkSolvedCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConceptCheckAnswerResponseImpl implements _ConceptCheckAnswerResponse {
  const _$ConceptCheckAnswerResponseImpl({
    this.isCorrect = false,
    required this.correctKey,
    this.explanation = '',
    this.rereadAnchor = '',
    final Map<String, String> rationaleByChoiceKey = const {},
    this.checkCorrectCount = 0,
    this.checkSolvedCount = 0,
  }) : _rationaleByChoiceKey = rationaleByChoiceKey;

  factory _$ConceptCheckAnswerResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$ConceptCheckAnswerResponseImplFromJson(json);

  @override
  @JsonKey()
  final bool isCorrect;
  @override
  final String correctKey;
  @override
  @JsonKey()
  final String explanation;
  @override
  @JsonKey()
  final String rereadAnchor;
  final Map<String, String> _rationaleByChoiceKey;
  @override
  @JsonKey()
  Map<String, String> get rationaleByChoiceKey {
    if (_rationaleByChoiceKey is EqualUnmodifiableMapView)
      return _rationaleByChoiceKey;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_rationaleByChoiceKey);
  }

  @override
  @JsonKey()
  final int checkCorrectCount;
  @override
  @JsonKey()
  final int checkSolvedCount;

  @override
  String toString() {
    return 'ConceptCheckAnswerResponse(isCorrect: $isCorrect, correctKey: $correctKey, explanation: $explanation, rereadAnchor: $rereadAnchor, rationaleByChoiceKey: $rationaleByChoiceKey, checkCorrectCount: $checkCorrectCount, checkSolvedCount: $checkSolvedCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConceptCheckAnswerResponseImpl &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect) &&
            (identical(other.correctKey, correctKey) ||
                other.correctKey == correctKey) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation) &&
            (identical(other.rereadAnchor, rereadAnchor) ||
                other.rereadAnchor == rereadAnchor) &&
            const DeepCollectionEquality().equals(
              other._rationaleByChoiceKey,
              _rationaleByChoiceKey,
            ) &&
            (identical(other.checkCorrectCount, checkCorrectCount) ||
                other.checkCorrectCount == checkCorrectCount) &&
            (identical(other.checkSolvedCount, checkSolvedCount) ||
                other.checkSolvedCount == checkSolvedCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    isCorrect,
    correctKey,
    explanation,
    rereadAnchor,
    const DeepCollectionEquality().hash(_rationaleByChoiceKey),
    checkCorrectCount,
    checkSolvedCount,
  );

  /// Create a copy of ConceptCheckAnswerResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConceptCheckAnswerResponseImplCopyWith<_$ConceptCheckAnswerResponseImpl>
  get copyWith =>
      __$$ConceptCheckAnswerResponseImplCopyWithImpl<
        _$ConceptCheckAnswerResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConceptCheckAnswerResponseImplToJson(this);
  }
}

abstract class _ConceptCheckAnswerResponse
    implements ConceptCheckAnswerResponse {
  const factory _ConceptCheckAnswerResponse({
    final bool isCorrect,
    required final String correctKey,
    final String explanation,
    final String rereadAnchor,
    final Map<String, String> rationaleByChoiceKey,
    final int checkCorrectCount,
    final int checkSolvedCount,
  }) = _$ConceptCheckAnswerResponseImpl;

  factory _ConceptCheckAnswerResponse.fromJson(Map<String, dynamic> json) =
      _$ConceptCheckAnswerResponseImpl.fromJson;

  @override
  bool get isCorrect;
  @override
  String get correctKey;
  @override
  String get explanation;
  @override
  String get rereadAnchor;
  @override
  Map<String, String> get rationaleByChoiceKey;
  @override
  int get checkCorrectCount;
  @override
  int get checkSolvedCount;

  /// Create a copy of ConceptCheckAnswerResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConceptCheckAnswerResponseImplCopyWith<_$ConceptCheckAnswerResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ConceptProgressRequest _$ConceptProgressRequestFromJson(
  Map<String, dynamic> json,
) {
  return _ConceptProgressRequest.fromJson(json);
}

/// @nodoc
mixin _$ConceptProgressRequest {
  bool? get isRead => throw _privateConstructorUsedError;
  ConceptStudyMode? get lastMode => throw _privateConstructorUsedError;
  ConceptReadingDepth? get lastDepth => throw _privateConstructorUsedError;

  /// Serializes this ConceptProgressRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConceptProgressRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConceptProgressRequestCopyWith<ConceptProgressRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConceptProgressRequestCopyWith<$Res> {
  factory $ConceptProgressRequestCopyWith(
    ConceptProgressRequest value,
    $Res Function(ConceptProgressRequest) then,
  ) = _$ConceptProgressRequestCopyWithImpl<$Res, ConceptProgressRequest>;
  @useResult
  $Res call({
    bool? isRead,
    ConceptStudyMode? lastMode,
    ConceptReadingDepth? lastDepth,
  });
}

/// @nodoc
class _$ConceptProgressRequestCopyWithImpl<
  $Res,
  $Val extends ConceptProgressRequest
>
    implements $ConceptProgressRequestCopyWith<$Res> {
  _$ConceptProgressRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConceptProgressRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isRead = freezed,
    Object? lastMode = freezed,
    Object? lastDepth = freezed,
  }) {
    return _then(
      _value.copyWith(
            isRead: freezed == isRead
                ? _value.isRead
                : isRead // ignore: cast_nullable_to_non_nullable
                      as bool?,
            lastMode: freezed == lastMode
                ? _value.lastMode
                : lastMode // ignore: cast_nullable_to_non_nullable
                      as ConceptStudyMode?,
            lastDepth: freezed == lastDepth
                ? _value.lastDepth
                : lastDepth // ignore: cast_nullable_to_non_nullable
                      as ConceptReadingDepth?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConceptProgressRequestImplCopyWith<$Res>
    implements $ConceptProgressRequestCopyWith<$Res> {
  factory _$$ConceptProgressRequestImplCopyWith(
    _$ConceptProgressRequestImpl value,
    $Res Function(_$ConceptProgressRequestImpl) then,
  ) = __$$ConceptProgressRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool? isRead,
    ConceptStudyMode? lastMode,
    ConceptReadingDepth? lastDepth,
  });
}

/// @nodoc
class __$$ConceptProgressRequestImplCopyWithImpl<$Res>
    extends
        _$ConceptProgressRequestCopyWithImpl<$Res, _$ConceptProgressRequestImpl>
    implements _$$ConceptProgressRequestImplCopyWith<$Res> {
  __$$ConceptProgressRequestImplCopyWithImpl(
    _$ConceptProgressRequestImpl _value,
    $Res Function(_$ConceptProgressRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConceptProgressRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isRead = freezed,
    Object? lastMode = freezed,
    Object? lastDepth = freezed,
  }) {
    return _then(
      _$ConceptProgressRequestImpl(
        isRead: freezed == isRead
            ? _value.isRead
            : isRead // ignore: cast_nullable_to_non_nullable
                  as bool?,
        lastMode: freezed == lastMode
            ? _value.lastMode
            : lastMode // ignore: cast_nullable_to_non_nullable
                  as ConceptStudyMode?,
        lastDepth: freezed == lastDepth
            ? _value.lastDepth
            : lastDepth // ignore: cast_nullable_to_non_nullable
                  as ConceptReadingDepth?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConceptProgressRequestImpl implements _ConceptProgressRequest {
  const _$ConceptProgressRequestImpl({
    this.isRead,
    this.lastMode,
    this.lastDepth,
  });

  factory _$ConceptProgressRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConceptProgressRequestImplFromJson(json);

  @override
  final bool? isRead;
  @override
  final ConceptStudyMode? lastMode;
  @override
  final ConceptReadingDepth? lastDepth;

  @override
  String toString() {
    return 'ConceptProgressRequest(isRead: $isRead, lastMode: $lastMode, lastDepth: $lastDepth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConceptProgressRequestImpl &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.lastMode, lastMode) ||
                other.lastMode == lastMode) &&
            (identical(other.lastDepth, lastDepth) ||
                other.lastDepth == lastDepth));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, isRead, lastMode, lastDepth);

  /// Create a copy of ConceptProgressRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConceptProgressRequestImplCopyWith<_$ConceptProgressRequestImpl>
  get copyWith =>
      __$$ConceptProgressRequestImplCopyWithImpl<_$ConceptProgressRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConceptProgressRequestImplToJson(this);
  }
}

abstract class _ConceptProgressRequest implements ConceptProgressRequest {
  const factory _ConceptProgressRequest({
    final bool? isRead,
    final ConceptStudyMode? lastMode,
    final ConceptReadingDepth? lastDepth,
  }) = _$ConceptProgressRequestImpl;

  factory _ConceptProgressRequest.fromJson(Map<String, dynamic> json) =
      _$ConceptProgressRequestImpl.fromJson;

  @override
  bool? get isRead;
  @override
  ConceptStudyMode? get lastMode;
  @override
  ConceptReadingDepth? get lastDepth;

  /// Create a copy of ConceptProgressRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConceptProgressRequestImplCopyWith<_$ConceptProgressRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
