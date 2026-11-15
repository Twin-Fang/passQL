// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ox_quiz_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OxCardItem _$OxCardItemFromJson(Map<String, dynamic> json) {
  return _OxCardItem.fromJson(json);
}

/// @nodoc
mixin _$OxCardItem {
  String get cardKey => throw _privateConstructorUsedError;
  String get conceptUuid => throw _privateConstructorUsedError;
  String get conceptTitle => throw _privateConstructorUsedError;
  String get topicName => throw _privateConstructorUsedError;
  String get statement =>
      throw _privateConstructorUsedError; // 정답 (true: O, false: X)
  bool get isTrue => throw _privateConstructorUsedError;
  String get reason =>
      throw _privateConstructorUsedError; // 현재 Leitner 칸 (1~5), 처음 보는 카드면 null
  int? get box => throw _privateConstructorUsedError;

  /// Serializes this OxCardItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OxCardItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OxCardItemCopyWith<OxCardItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OxCardItemCopyWith<$Res> {
  factory $OxCardItemCopyWith(
    OxCardItem value,
    $Res Function(OxCardItem) then,
  ) = _$OxCardItemCopyWithImpl<$Res, OxCardItem>;
  @useResult
  $Res call({
    String cardKey,
    String conceptUuid,
    String conceptTitle,
    String topicName,
    String statement,
    bool isTrue,
    String reason,
    int? box,
  });
}

/// @nodoc
class _$OxCardItemCopyWithImpl<$Res, $Val extends OxCardItem>
    implements $OxCardItemCopyWith<$Res> {
  _$OxCardItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OxCardItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cardKey = null,
    Object? conceptUuid = null,
    Object? conceptTitle = null,
    Object? topicName = null,
    Object? statement = null,
    Object? isTrue = null,
    Object? reason = null,
    Object? box = freezed,
  }) {
    return _then(
      _value.copyWith(
            cardKey: null == cardKey
                ? _value.cardKey
                : cardKey // ignore: cast_nullable_to_non_nullable
                      as String,
            conceptUuid: null == conceptUuid
                ? _value.conceptUuid
                : conceptUuid // ignore: cast_nullable_to_non_nullable
                      as String,
            conceptTitle: null == conceptTitle
                ? _value.conceptTitle
                : conceptTitle // ignore: cast_nullable_to_non_nullable
                      as String,
            topicName: null == topicName
                ? _value.topicName
                : topicName // ignore: cast_nullable_to_non_nullable
                      as String,
            statement: null == statement
                ? _value.statement
                : statement // ignore: cast_nullable_to_non_nullable
                      as String,
            isTrue: null == isTrue
                ? _value.isTrue
                : isTrue // ignore: cast_nullable_to_non_nullable
                      as bool,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
            box: freezed == box
                ? _value.box
                : box // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OxCardItemImplCopyWith<$Res>
    implements $OxCardItemCopyWith<$Res> {
  factory _$$OxCardItemImplCopyWith(
    _$OxCardItemImpl value,
    $Res Function(_$OxCardItemImpl) then,
  ) = __$$OxCardItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String cardKey,
    String conceptUuid,
    String conceptTitle,
    String topicName,
    String statement,
    bool isTrue,
    String reason,
    int? box,
  });
}

/// @nodoc
class __$$OxCardItemImplCopyWithImpl<$Res>
    extends _$OxCardItemCopyWithImpl<$Res, _$OxCardItemImpl>
    implements _$$OxCardItemImplCopyWith<$Res> {
  __$$OxCardItemImplCopyWithImpl(
    _$OxCardItemImpl _value,
    $Res Function(_$OxCardItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OxCardItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cardKey = null,
    Object? conceptUuid = null,
    Object? conceptTitle = null,
    Object? topicName = null,
    Object? statement = null,
    Object? isTrue = null,
    Object? reason = null,
    Object? box = freezed,
  }) {
    return _then(
      _$OxCardItemImpl(
        cardKey: null == cardKey
            ? _value.cardKey
            : cardKey // ignore: cast_nullable_to_non_nullable
                  as String,
        conceptUuid: null == conceptUuid
            ? _value.conceptUuid
            : conceptUuid // ignore: cast_nullable_to_non_nullable
                  as String,
        conceptTitle: null == conceptTitle
            ? _value.conceptTitle
            : conceptTitle // ignore: cast_nullable_to_non_nullable
                  as String,
        topicName: null == topicName
            ? _value.topicName
            : topicName // ignore: cast_nullable_to_non_nullable
                  as String,
        statement: null == statement
            ? _value.statement
            : statement // ignore: cast_nullable_to_non_nullable
                  as String,
        isTrue: null == isTrue
            ? _value.isTrue
            : isTrue // ignore: cast_nullable_to_non_nullable
                  as bool,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
        box: freezed == box
            ? _value.box
            : box // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OxCardItemImpl implements _OxCardItem {
  const _$OxCardItemImpl({
    required this.cardKey,
    this.conceptUuid = '',
    this.conceptTitle = '',
    this.topicName = '',
    required this.statement,
    this.isTrue = false,
    this.reason = '',
    this.box,
  });

  factory _$OxCardItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$OxCardItemImplFromJson(json);

  @override
  final String cardKey;
  @override
  @JsonKey()
  final String conceptUuid;
  @override
  @JsonKey()
  final String conceptTitle;
  @override
  @JsonKey()
  final String topicName;
  @override
  final String statement;
  // 정답 (true: O, false: X)
  @override
  @JsonKey()
  final bool isTrue;
  @override
  @JsonKey()
  final String reason;
  // 현재 Leitner 칸 (1~5), 처음 보는 카드면 null
  @override
  final int? box;

  @override
  String toString() {
    return 'OxCardItem(cardKey: $cardKey, conceptUuid: $conceptUuid, conceptTitle: $conceptTitle, topicName: $topicName, statement: $statement, isTrue: $isTrue, reason: $reason, box: $box)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OxCardItemImpl &&
            (identical(other.cardKey, cardKey) || other.cardKey == cardKey) &&
            (identical(other.conceptUuid, conceptUuid) ||
                other.conceptUuid == conceptUuid) &&
            (identical(other.conceptTitle, conceptTitle) ||
                other.conceptTitle == conceptTitle) &&
            (identical(other.topicName, topicName) ||
                other.topicName == topicName) &&
            (identical(other.statement, statement) ||
                other.statement == statement) &&
            (identical(other.isTrue, isTrue) || other.isTrue == isTrue) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.box, box) || other.box == box));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    cardKey,
    conceptUuid,
    conceptTitle,
    topicName,
    statement,
    isTrue,
    reason,
    box,
  );

  /// Create a copy of OxCardItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OxCardItemImplCopyWith<_$OxCardItemImpl> get copyWith =>
      __$$OxCardItemImplCopyWithImpl<_$OxCardItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OxCardItemImplToJson(this);
  }
}

abstract class _OxCardItem implements OxCardItem {
  const factory _OxCardItem({
    required final String cardKey,
    final String conceptUuid,
    final String conceptTitle,
    final String topicName,
    required final String statement,
    final bool isTrue,
    final String reason,
    final int? box,
  }) = _$OxCardItemImpl;

  factory _OxCardItem.fromJson(Map<String, dynamic> json) =
      _$OxCardItemImpl.fromJson;

  @override
  String get cardKey;
  @override
  String get conceptUuid;
  @override
  String get conceptTitle;
  @override
  String get topicName;
  @override
  String get statement; // 정답 (true: O, false: X)
  @override
  bool get isTrue;
  @override
  String get reason; // 현재 Leitner 칸 (1~5), 처음 보는 카드면 null
  @override
  int? get box;

  /// Create a copy of OxCardItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OxCardItemImplCopyWith<_$OxCardItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OxCardSetResponse _$OxCardSetResponseFromJson(Map<String, dynamic> json) {
  return _OxCardSetResponse.fromJson(json);
}

/// @nodoc
mixin _$OxCardSetResponse {
  List<OxCardItem> get cards => throw _privateConstructorUsedError;
  int get dueCardCount => throw _privateConstructorUsedError;
  int get newCardCount =>
      throw _privateConstructorUsedError; // 오늘 푼 카드 수 (같은 카드 여러 번은 1장)
  int get todayAnsweredCount => throw _privateConstructorUsedError;
  int get dailyGoalCount =>
      throw _privateConstructorUsedError; // 잠긴 단원(무료)에 카드가 더 있음
  bool get hasLockedTopics => throw _privateConstructorUsedError;

  /// Serializes this OxCardSetResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OxCardSetResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OxCardSetResponseCopyWith<OxCardSetResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OxCardSetResponseCopyWith<$Res> {
  factory $OxCardSetResponseCopyWith(
    OxCardSetResponse value,
    $Res Function(OxCardSetResponse) then,
  ) = _$OxCardSetResponseCopyWithImpl<$Res, OxCardSetResponse>;
  @useResult
  $Res call({
    List<OxCardItem> cards,
    int dueCardCount,
    int newCardCount,
    int todayAnsweredCount,
    int dailyGoalCount,
    bool hasLockedTopics,
  });
}

/// @nodoc
class _$OxCardSetResponseCopyWithImpl<$Res, $Val extends OxCardSetResponse>
    implements $OxCardSetResponseCopyWith<$Res> {
  _$OxCardSetResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OxCardSetResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cards = null,
    Object? dueCardCount = null,
    Object? newCardCount = null,
    Object? todayAnsweredCount = null,
    Object? dailyGoalCount = null,
    Object? hasLockedTopics = null,
  }) {
    return _then(
      _value.copyWith(
            cards: null == cards
                ? _value.cards
                : cards // ignore: cast_nullable_to_non_nullable
                      as List<OxCardItem>,
            dueCardCount: null == dueCardCount
                ? _value.dueCardCount
                : dueCardCount // ignore: cast_nullable_to_non_nullable
                      as int,
            newCardCount: null == newCardCount
                ? _value.newCardCount
                : newCardCount // ignore: cast_nullable_to_non_nullable
                      as int,
            todayAnsweredCount: null == todayAnsweredCount
                ? _value.todayAnsweredCount
                : todayAnsweredCount // ignore: cast_nullable_to_non_nullable
                      as int,
            dailyGoalCount: null == dailyGoalCount
                ? _value.dailyGoalCount
                : dailyGoalCount // ignore: cast_nullable_to_non_nullable
                      as int,
            hasLockedTopics: null == hasLockedTopics
                ? _value.hasLockedTopics
                : hasLockedTopics // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OxCardSetResponseImplCopyWith<$Res>
    implements $OxCardSetResponseCopyWith<$Res> {
  factory _$$OxCardSetResponseImplCopyWith(
    _$OxCardSetResponseImpl value,
    $Res Function(_$OxCardSetResponseImpl) then,
  ) = __$$OxCardSetResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<OxCardItem> cards,
    int dueCardCount,
    int newCardCount,
    int todayAnsweredCount,
    int dailyGoalCount,
    bool hasLockedTopics,
  });
}

/// @nodoc
class __$$OxCardSetResponseImplCopyWithImpl<$Res>
    extends _$OxCardSetResponseCopyWithImpl<$Res, _$OxCardSetResponseImpl>
    implements _$$OxCardSetResponseImplCopyWith<$Res> {
  __$$OxCardSetResponseImplCopyWithImpl(
    _$OxCardSetResponseImpl _value,
    $Res Function(_$OxCardSetResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OxCardSetResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cards = null,
    Object? dueCardCount = null,
    Object? newCardCount = null,
    Object? todayAnsweredCount = null,
    Object? dailyGoalCount = null,
    Object? hasLockedTopics = null,
  }) {
    return _then(
      _$OxCardSetResponseImpl(
        cards: null == cards
            ? _value._cards
            : cards // ignore: cast_nullable_to_non_nullable
                  as List<OxCardItem>,
        dueCardCount: null == dueCardCount
            ? _value.dueCardCount
            : dueCardCount // ignore: cast_nullable_to_non_nullable
                  as int,
        newCardCount: null == newCardCount
            ? _value.newCardCount
            : newCardCount // ignore: cast_nullable_to_non_nullable
                  as int,
        todayAnsweredCount: null == todayAnsweredCount
            ? _value.todayAnsweredCount
            : todayAnsweredCount // ignore: cast_nullable_to_non_nullable
                  as int,
        dailyGoalCount: null == dailyGoalCount
            ? _value.dailyGoalCount
            : dailyGoalCount // ignore: cast_nullable_to_non_nullable
                  as int,
        hasLockedTopics: null == hasLockedTopics
            ? _value.hasLockedTopics
            : hasLockedTopics // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OxCardSetResponseImpl implements _OxCardSetResponse {
  const _$OxCardSetResponseImpl({
    final List<OxCardItem> cards = const [],
    this.dueCardCount = 0,
    this.newCardCount = 0,
    this.todayAnsweredCount = 0,
    this.dailyGoalCount = 0,
    this.hasLockedTopics = false,
  }) : _cards = cards;

  factory _$OxCardSetResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$OxCardSetResponseImplFromJson(json);

  final List<OxCardItem> _cards;
  @override
  @JsonKey()
  List<OxCardItem> get cards {
    if (_cards is EqualUnmodifiableListView) return _cards;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cards);
  }

  @override
  @JsonKey()
  final int dueCardCount;
  @override
  @JsonKey()
  final int newCardCount;
  // 오늘 푼 카드 수 (같은 카드 여러 번은 1장)
  @override
  @JsonKey()
  final int todayAnsweredCount;
  @override
  @JsonKey()
  final int dailyGoalCount;
  // 잠긴 단원(무료)에 카드가 더 있음
  @override
  @JsonKey()
  final bool hasLockedTopics;

  @override
  String toString() {
    return 'OxCardSetResponse(cards: $cards, dueCardCount: $dueCardCount, newCardCount: $newCardCount, todayAnsweredCount: $todayAnsweredCount, dailyGoalCount: $dailyGoalCount, hasLockedTopics: $hasLockedTopics)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OxCardSetResponseImpl &&
            const DeepCollectionEquality().equals(other._cards, _cards) &&
            (identical(other.dueCardCount, dueCardCount) ||
                other.dueCardCount == dueCardCount) &&
            (identical(other.newCardCount, newCardCount) ||
                other.newCardCount == newCardCount) &&
            (identical(other.todayAnsweredCount, todayAnsweredCount) ||
                other.todayAnsweredCount == todayAnsweredCount) &&
            (identical(other.dailyGoalCount, dailyGoalCount) ||
                other.dailyGoalCount == dailyGoalCount) &&
            (identical(other.hasLockedTopics, hasLockedTopics) ||
                other.hasLockedTopics == hasLockedTopics));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_cards),
    dueCardCount,
    newCardCount,
    todayAnsweredCount,
    dailyGoalCount,
    hasLockedTopics,
  );

  /// Create a copy of OxCardSetResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OxCardSetResponseImplCopyWith<_$OxCardSetResponseImpl> get copyWith =>
      __$$OxCardSetResponseImplCopyWithImpl<_$OxCardSetResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OxCardSetResponseImplToJson(this);
  }
}

abstract class _OxCardSetResponse implements OxCardSetResponse {
  const factory _OxCardSetResponse({
    final List<OxCardItem> cards,
    final int dueCardCount,
    final int newCardCount,
    final int todayAnsweredCount,
    final int dailyGoalCount,
    final bool hasLockedTopics,
  }) = _$OxCardSetResponseImpl;

  factory _OxCardSetResponse.fromJson(Map<String, dynamic> json) =
      _$OxCardSetResponseImpl.fromJson;

  @override
  List<OxCardItem> get cards;
  @override
  int get dueCardCount;
  @override
  int get newCardCount; // 오늘 푼 카드 수 (같은 카드 여러 번은 1장)
  @override
  int get todayAnsweredCount;
  @override
  int get dailyGoalCount; // 잠긴 단원(무료)에 카드가 더 있음
  @override
  bool get hasLockedTopics;

  /// Create a copy of OxCardSetResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OxCardSetResponseImplCopyWith<_$OxCardSetResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OxAnswerRequest _$OxAnswerRequestFromJson(Map<String, dynamic> json) {
  return _OxAnswerRequest.fromJson(json);
}

/// @nodoc
mixin _$OxAnswerRequest {
  String get cardKey => throw _privateConstructorUsedError;
  bool get isCorrect => throw _privateConstructorUsedError;

  /// Serializes this OxAnswerRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OxAnswerRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OxAnswerRequestCopyWith<OxAnswerRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OxAnswerRequestCopyWith<$Res> {
  factory $OxAnswerRequestCopyWith(
    OxAnswerRequest value,
    $Res Function(OxAnswerRequest) then,
  ) = _$OxAnswerRequestCopyWithImpl<$Res, OxAnswerRequest>;
  @useResult
  $Res call({String cardKey, bool isCorrect});
}

/// @nodoc
class _$OxAnswerRequestCopyWithImpl<$Res, $Val extends OxAnswerRequest>
    implements $OxAnswerRequestCopyWith<$Res> {
  _$OxAnswerRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OxAnswerRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? cardKey = null, Object? isCorrect = null}) {
    return _then(
      _value.copyWith(
            cardKey: null == cardKey
                ? _value.cardKey
                : cardKey // ignore: cast_nullable_to_non_nullable
                      as String,
            isCorrect: null == isCorrect
                ? _value.isCorrect
                : isCorrect // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OxAnswerRequestImplCopyWith<$Res>
    implements $OxAnswerRequestCopyWith<$Res> {
  factory _$$OxAnswerRequestImplCopyWith(
    _$OxAnswerRequestImpl value,
    $Res Function(_$OxAnswerRequestImpl) then,
  ) = __$$OxAnswerRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String cardKey, bool isCorrect});
}

/// @nodoc
class __$$OxAnswerRequestImplCopyWithImpl<$Res>
    extends _$OxAnswerRequestCopyWithImpl<$Res, _$OxAnswerRequestImpl>
    implements _$$OxAnswerRequestImplCopyWith<$Res> {
  __$$OxAnswerRequestImplCopyWithImpl(
    _$OxAnswerRequestImpl _value,
    $Res Function(_$OxAnswerRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OxAnswerRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? cardKey = null, Object? isCorrect = null}) {
    return _then(
      _$OxAnswerRequestImpl(
        cardKey: null == cardKey
            ? _value.cardKey
            : cardKey // ignore: cast_nullable_to_non_nullable
                  as String,
        isCorrect: null == isCorrect
            ? _value.isCorrect
            : isCorrect // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OxAnswerRequestImpl implements _OxAnswerRequest {
  const _$OxAnswerRequestImpl({required this.cardKey, required this.isCorrect});

  factory _$OxAnswerRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$OxAnswerRequestImplFromJson(json);

  @override
  final String cardKey;
  @override
  final bool isCorrect;

  @override
  String toString() {
    return 'OxAnswerRequest(cardKey: $cardKey, isCorrect: $isCorrect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OxAnswerRequestImpl &&
            (identical(other.cardKey, cardKey) || other.cardKey == cardKey) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, cardKey, isCorrect);

  /// Create a copy of OxAnswerRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OxAnswerRequestImplCopyWith<_$OxAnswerRequestImpl> get copyWith =>
      __$$OxAnswerRequestImplCopyWithImpl<_$OxAnswerRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OxAnswerRequestImplToJson(this);
  }
}

abstract class _OxAnswerRequest implements OxAnswerRequest {
  const factory _OxAnswerRequest({
    required final String cardKey,
    required final bool isCorrect,
  }) = _$OxAnswerRequestImpl;

  factory _OxAnswerRequest.fromJson(Map<String, dynamic> json) =
      _$OxAnswerRequestImpl.fromJson;

  @override
  String get cardKey;
  @override
  bool get isCorrect;

  /// Create a copy of OxAnswerRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OxAnswerRequestImplCopyWith<_$OxAnswerRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OxAnswerResponse _$OxAnswerResponseFromJson(Map<String, dynamic> json) {
  return _OxAnswerResponse.fromJson(json);
}

/// @nodoc
mixin _$OxAnswerResponse {
  String get cardKey => throw _privateConstructorUsedError;
  int get box => throw _privateConstructorUsedError;
  DateTime? get nextReviewDate => throw _privateConstructorUsedError;
  int get correctStreak => throw _privateConstructorUsedError;
  int get todayAnsweredCount => throw _privateConstructorUsedError;

  /// Serializes this OxAnswerResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OxAnswerResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OxAnswerResponseCopyWith<OxAnswerResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OxAnswerResponseCopyWith<$Res> {
  factory $OxAnswerResponseCopyWith(
    OxAnswerResponse value,
    $Res Function(OxAnswerResponse) then,
  ) = _$OxAnswerResponseCopyWithImpl<$Res, OxAnswerResponse>;
  @useResult
  $Res call({
    String cardKey,
    int box,
    DateTime? nextReviewDate,
    int correctStreak,
    int todayAnsweredCount,
  });
}

/// @nodoc
class _$OxAnswerResponseCopyWithImpl<$Res, $Val extends OxAnswerResponse>
    implements $OxAnswerResponseCopyWith<$Res> {
  _$OxAnswerResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OxAnswerResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cardKey = null,
    Object? box = null,
    Object? nextReviewDate = freezed,
    Object? correctStreak = null,
    Object? todayAnsweredCount = null,
  }) {
    return _then(
      _value.copyWith(
            cardKey: null == cardKey
                ? _value.cardKey
                : cardKey // ignore: cast_nullable_to_non_nullable
                      as String,
            box: null == box
                ? _value.box
                : box // ignore: cast_nullable_to_non_nullable
                      as int,
            nextReviewDate: freezed == nextReviewDate
                ? _value.nextReviewDate
                : nextReviewDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            correctStreak: null == correctStreak
                ? _value.correctStreak
                : correctStreak // ignore: cast_nullable_to_non_nullable
                      as int,
            todayAnsweredCount: null == todayAnsweredCount
                ? _value.todayAnsweredCount
                : todayAnsweredCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OxAnswerResponseImplCopyWith<$Res>
    implements $OxAnswerResponseCopyWith<$Res> {
  factory _$$OxAnswerResponseImplCopyWith(
    _$OxAnswerResponseImpl value,
    $Res Function(_$OxAnswerResponseImpl) then,
  ) = __$$OxAnswerResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String cardKey,
    int box,
    DateTime? nextReviewDate,
    int correctStreak,
    int todayAnsweredCount,
  });
}

/// @nodoc
class __$$OxAnswerResponseImplCopyWithImpl<$Res>
    extends _$OxAnswerResponseCopyWithImpl<$Res, _$OxAnswerResponseImpl>
    implements _$$OxAnswerResponseImplCopyWith<$Res> {
  __$$OxAnswerResponseImplCopyWithImpl(
    _$OxAnswerResponseImpl _value,
    $Res Function(_$OxAnswerResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OxAnswerResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cardKey = null,
    Object? box = null,
    Object? nextReviewDate = freezed,
    Object? correctStreak = null,
    Object? todayAnsweredCount = null,
  }) {
    return _then(
      _$OxAnswerResponseImpl(
        cardKey: null == cardKey
            ? _value.cardKey
            : cardKey // ignore: cast_nullable_to_non_nullable
                  as String,
        box: null == box
            ? _value.box
            : box // ignore: cast_nullable_to_non_nullable
                  as int,
        nextReviewDate: freezed == nextReviewDate
            ? _value.nextReviewDate
            : nextReviewDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        correctStreak: null == correctStreak
            ? _value.correctStreak
            : correctStreak // ignore: cast_nullable_to_non_nullable
                  as int,
        todayAnsweredCount: null == todayAnsweredCount
            ? _value.todayAnsweredCount
            : todayAnsweredCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OxAnswerResponseImpl implements _OxAnswerResponse {
  const _$OxAnswerResponseImpl({
    required this.cardKey,
    this.box = 1,
    this.nextReviewDate,
    this.correctStreak = 0,
    this.todayAnsweredCount = 0,
  });

  factory _$OxAnswerResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$OxAnswerResponseImplFromJson(json);

  @override
  final String cardKey;
  @override
  @JsonKey()
  final int box;
  @override
  final DateTime? nextReviewDate;
  @override
  @JsonKey()
  final int correctStreak;
  @override
  @JsonKey()
  final int todayAnsweredCount;

  @override
  String toString() {
    return 'OxAnswerResponse(cardKey: $cardKey, box: $box, nextReviewDate: $nextReviewDate, correctStreak: $correctStreak, todayAnsweredCount: $todayAnsweredCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OxAnswerResponseImpl &&
            (identical(other.cardKey, cardKey) || other.cardKey == cardKey) &&
            (identical(other.box, box) || other.box == box) &&
            (identical(other.nextReviewDate, nextReviewDate) ||
                other.nextReviewDate == nextReviewDate) &&
            (identical(other.correctStreak, correctStreak) ||
                other.correctStreak == correctStreak) &&
            (identical(other.todayAnsweredCount, todayAnsweredCount) ||
                other.todayAnsweredCount == todayAnsweredCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    cardKey,
    box,
    nextReviewDate,
    correctStreak,
    todayAnsweredCount,
  );

  /// Create a copy of OxAnswerResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OxAnswerResponseImplCopyWith<_$OxAnswerResponseImpl> get copyWith =>
      __$$OxAnswerResponseImplCopyWithImpl<_$OxAnswerResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OxAnswerResponseImplToJson(this);
  }
}

abstract class _OxAnswerResponse implements OxAnswerResponse {
  const factory _OxAnswerResponse({
    required final String cardKey,
    final int box,
    final DateTime? nextReviewDate,
    final int correctStreak,
    final int todayAnsweredCount,
  }) = _$OxAnswerResponseImpl;

  factory _OxAnswerResponse.fromJson(Map<String, dynamic> json) =
      _$OxAnswerResponseImpl.fromJson;

  @override
  String get cardKey;
  @override
  int get box;
  @override
  DateTime? get nextReviewDate;
  @override
  int get correctStreak;
  @override
  int get todayAnsweredCount;

  /// Create a copy of OxAnswerResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OxAnswerResponseImplCopyWith<_$OxAnswerResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
