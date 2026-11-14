// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exam_answer_round_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExamAnswerRoundResponse _$ExamAnswerRoundResponseFromJson(
  Map<String, dynamic> json,
) {
  return _ExamAnswerRoundResponse.fromJson(json);
}

/// @nodoc
mixin _$ExamAnswerRoundResponse {
  // 회차 정보: `round` 묶음, 없으면 최상위 칸에서 읽음
  @JsonKey(readValue: _readRoundJson)
  ExamAnswerRound get round => throw _privateConstructorUsedError;
  List<ExamAnswerItem> get items => throw _privateConstructorUsedError;
  int get participantCount => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ExamAnswerRoundResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamAnswerRoundResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamAnswerRoundResponseCopyWith<ExamAnswerRoundResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamAnswerRoundResponseCopyWith<$Res> {
  factory $ExamAnswerRoundResponseCopyWith(
    ExamAnswerRoundResponse value,
    $Res Function(ExamAnswerRoundResponse) then,
  ) = _$ExamAnswerRoundResponseCopyWithImpl<$Res, ExamAnswerRoundResponse>;
  @useResult
  $Res call({
    @JsonKey(readValue: _readRoundJson) ExamAnswerRound round,
    List<ExamAnswerItem> items,
    int participantCount,
    DateTime? updatedAt,
  });

  $ExamAnswerRoundCopyWith<$Res> get round;
}

/// @nodoc
class _$ExamAnswerRoundResponseCopyWithImpl<
  $Res,
  $Val extends ExamAnswerRoundResponse
>
    implements $ExamAnswerRoundResponseCopyWith<$Res> {
  _$ExamAnswerRoundResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamAnswerRoundResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? round = null,
    Object? items = null,
    Object? participantCount = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            round: null == round
                ? _value.round
                : round // ignore: cast_nullable_to_non_nullable
                      as ExamAnswerRound,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<ExamAnswerItem>,
            participantCount: null == participantCount
                ? _value.participantCount
                : participantCount // ignore: cast_nullable_to_non_nullable
                      as int,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of ExamAnswerRoundResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExamAnswerRoundCopyWith<$Res> get round {
    return $ExamAnswerRoundCopyWith<$Res>(_value.round, (value) {
      return _then(_value.copyWith(round: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ExamAnswerRoundResponseImplCopyWith<$Res>
    implements $ExamAnswerRoundResponseCopyWith<$Res> {
  factory _$$ExamAnswerRoundResponseImplCopyWith(
    _$ExamAnswerRoundResponseImpl value,
    $Res Function(_$ExamAnswerRoundResponseImpl) then,
  ) = __$$ExamAnswerRoundResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(readValue: _readRoundJson) ExamAnswerRound round,
    List<ExamAnswerItem> items,
    int participantCount,
    DateTime? updatedAt,
  });

  @override
  $ExamAnswerRoundCopyWith<$Res> get round;
}

/// @nodoc
class __$$ExamAnswerRoundResponseImplCopyWithImpl<$Res>
    extends
        _$ExamAnswerRoundResponseCopyWithImpl<
          $Res,
          _$ExamAnswerRoundResponseImpl
        >
    implements _$$ExamAnswerRoundResponseImplCopyWith<$Res> {
  __$$ExamAnswerRoundResponseImplCopyWithImpl(
    _$ExamAnswerRoundResponseImpl _value,
    $Res Function(_$ExamAnswerRoundResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamAnswerRoundResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? round = null,
    Object? items = null,
    Object? participantCount = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$ExamAnswerRoundResponseImpl(
        round: null == round
            ? _value.round
            : round // ignore: cast_nullable_to_non_nullable
                  as ExamAnswerRound,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<ExamAnswerItem>,
        participantCount: null == participantCount
            ? _value.participantCount
            : participantCount // ignore: cast_nullable_to_non_nullable
                  as int,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamAnswerRoundResponseImpl implements _ExamAnswerRoundResponse {
  const _$ExamAnswerRoundResponseImpl({
    @JsonKey(readValue: _readRoundJson) required this.round,
    final List<ExamAnswerItem> items = const [],
    this.participantCount = 0,
    this.updatedAt,
  }) : _items = items;

  factory _$ExamAnswerRoundResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamAnswerRoundResponseImplFromJson(json);

  // 회차 정보: `round` 묶음, 없으면 최상위 칸에서 읽음
  @override
  @JsonKey(readValue: _readRoundJson)
  final ExamAnswerRound round;
  final List<ExamAnswerItem> _items;
  @override
  @JsonKey()
  List<ExamAnswerItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final int participantCount;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ExamAnswerRoundResponse(round: $round, items: $items, participantCount: $participantCount, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamAnswerRoundResponseImpl &&
            (identical(other.round, round) || other.round == round) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.participantCount, participantCount) ||
                other.participantCount == participantCount) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    round,
    const DeepCollectionEquality().hash(_items),
    participantCount,
    updatedAt,
  );

  /// Create a copy of ExamAnswerRoundResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamAnswerRoundResponseImplCopyWith<_$ExamAnswerRoundResponseImpl>
  get copyWith =>
      __$$ExamAnswerRoundResponseImplCopyWithImpl<
        _$ExamAnswerRoundResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamAnswerRoundResponseImplToJson(this);
  }
}

abstract class _ExamAnswerRoundResponse implements ExamAnswerRoundResponse {
  const factory _ExamAnswerRoundResponse({
    @JsonKey(readValue: _readRoundJson) required final ExamAnswerRound round,
    final List<ExamAnswerItem> items,
    final int participantCount,
    final DateTime? updatedAt,
  }) = _$ExamAnswerRoundResponseImpl;

  factory _ExamAnswerRoundResponse.fromJson(Map<String, dynamic> json) =
      _$ExamAnswerRoundResponseImpl.fromJson;

  // 회차 정보: `round` 묶음, 없으면 최상위 칸에서 읽음
  @override
  @JsonKey(readValue: _readRoundJson)
  ExamAnswerRound get round;
  @override
  List<ExamAnswerItem> get items;
  @override
  int get participantCount;
  @override
  DateTime? get updatedAt;

  /// Create a copy of ExamAnswerRoundResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamAnswerRoundResponseImplCopyWith<_$ExamAnswerRoundResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ExamAnswerRound _$ExamAnswerRoundFromJson(Map<String, dynamic> json) {
  return _ExamAnswerRound.fromJson(json);
}

/// @nodoc
mixin _$ExamAnswerRound {
  String get certType => throw _privateConstructorUsedError;
  int get roundNumber => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get examDate => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: ExamAnswerRoundStatus.unknown)
  ExamAnswerRoundStatus get status => throw _privateConstructorUsedError;
  String? get notice => throw _privateConstructorUsedError;

  /// Serializes this ExamAnswerRound to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamAnswerRound
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamAnswerRoundCopyWith<ExamAnswerRound> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamAnswerRoundCopyWith<$Res> {
  factory $ExamAnswerRoundCopyWith(
    ExamAnswerRound value,
    $Res Function(ExamAnswerRound) then,
  ) = _$ExamAnswerRoundCopyWithImpl<$Res, ExamAnswerRound>;
  @useResult
  $Res call({
    String certType,
    int roundNumber,
    String title,
    String? examDate,
    @JsonKey(unknownEnumValue: ExamAnswerRoundStatus.unknown)
    ExamAnswerRoundStatus status,
    String? notice,
  });
}

/// @nodoc
class _$ExamAnswerRoundCopyWithImpl<$Res, $Val extends ExamAnswerRound>
    implements $ExamAnswerRoundCopyWith<$Res> {
  _$ExamAnswerRoundCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamAnswerRound
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? certType = null,
    Object? roundNumber = null,
    Object? title = null,
    Object? examDate = freezed,
    Object? status = null,
    Object? notice = freezed,
  }) {
    return _then(
      _value.copyWith(
            certType: null == certType
                ? _value.certType
                : certType // ignore: cast_nullable_to_non_nullable
                      as String,
            roundNumber: null == roundNumber
                ? _value.roundNumber
                : roundNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            examDate: freezed == examDate
                ? _value.examDate
                : examDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ExamAnswerRoundStatus,
            notice: freezed == notice
                ? _value.notice
                : notice // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExamAnswerRoundImplCopyWith<$Res>
    implements $ExamAnswerRoundCopyWith<$Res> {
  factory _$$ExamAnswerRoundImplCopyWith(
    _$ExamAnswerRoundImpl value,
    $Res Function(_$ExamAnswerRoundImpl) then,
  ) = __$$ExamAnswerRoundImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String certType,
    int roundNumber,
    String title,
    String? examDate,
    @JsonKey(unknownEnumValue: ExamAnswerRoundStatus.unknown)
    ExamAnswerRoundStatus status,
    String? notice,
  });
}

/// @nodoc
class __$$ExamAnswerRoundImplCopyWithImpl<$Res>
    extends _$ExamAnswerRoundCopyWithImpl<$Res, _$ExamAnswerRoundImpl>
    implements _$$ExamAnswerRoundImplCopyWith<$Res> {
  __$$ExamAnswerRoundImplCopyWithImpl(
    _$ExamAnswerRoundImpl _value,
    $Res Function(_$ExamAnswerRoundImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamAnswerRound
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? certType = null,
    Object? roundNumber = null,
    Object? title = null,
    Object? examDate = freezed,
    Object? status = null,
    Object? notice = freezed,
  }) {
    return _then(
      _$ExamAnswerRoundImpl(
        certType: null == certType
            ? _value.certType
            : certType // ignore: cast_nullable_to_non_nullable
                  as String,
        roundNumber: null == roundNumber
            ? _value.roundNumber
            : roundNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        examDate: freezed == examDate
            ? _value.examDate
            : examDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ExamAnswerRoundStatus,
        notice: freezed == notice
            ? _value.notice
            : notice // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamAnswerRoundImpl implements _ExamAnswerRound {
  const _$ExamAnswerRoundImpl({
    required this.certType,
    required this.roundNumber,
    this.title = '',
    this.examDate,
    @JsonKey(unknownEnumValue: ExamAnswerRoundStatus.unknown)
    this.status = ExamAnswerRoundStatus.unknown,
    this.notice,
  });

  factory _$ExamAnswerRoundImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamAnswerRoundImplFromJson(json);

  @override
  final String certType;
  @override
  final int roundNumber;
  @override
  @JsonKey()
  final String title;
  @override
  final String? examDate;
  @override
  @JsonKey(unknownEnumValue: ExamAnswerRoundStatus.unknown)
  final ExamAnswerRoundStatus status;
  @override
  final String? notice;

  @override
  String toString() {
    return 'ExamAnswerRound(certType: $certType, roundNumber: $roundNumber, title: $title, examDate: $examDate, status: $status, notice: $notice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamAnswerRoundImpl &&
            (identical(other.certType, certType) ||
                other.certType == certType) &&
            (identical(other.roundNumber, roundNumber) ||
                other.roundNumber == roundNumber) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.examDate, examDate) ||
                other.examDate == examDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notice, notice) || other.notice == notice));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    certType,
    roundNumber,
    title,
    examDate,
    status,
    notice,
  );

  /// Create a copy of ExamAnswerRound
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamAnswerRoundImplCopyWith<_$ExamAnswerRoundImpl> get copyWith =>
      __$$ExamAnswerRoundImplCopyWithImpl<_$ExamAnswerRoundImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamAnswerRoundImplToJson(this);
  }
}

abstract class _ExamAnswerRound implements ExamAnswerRound {
  const factory _ExamAnswerRound({
    required final String certType,
    required final int roundNumber,
    final String title,
    final String? examDate,
    @JsonKey(unknownEnumValue: ExamAnswerRoundStatus.unknown)
    final ExamAnswerRoundStatus status,
    final String? notice,
  }) = _$ExamAnswerRoundImpl;

  factory _ExamAnswerRound.fromJson(Map<String, dynamic> json) =
      _$ExamAnswerRoundImpl.fromJson;

  @override
  String get certType;
  @override
  int get roundNumber;
  @override
  String get title;
  @override
  String? get examDate;
  @override
  @JsonKey(unknownEnumValue: ExamAnswerRoundStatus.unknown)
  ExamAnswerRoundStatus get status;
  @override
  String? get notice;

  /// Create a copy of ExamAnswerRound
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamAnswerRoundImplCopyWith<_$ExamAnswerRoundImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExamAnswerItem _$ExamAnswerItemFromJson(Map<String, dynamic> json) {
  return _ExamAnswerItem.fromJson(json);
}

/// @nodoc
mixin _$ExamAnswerItem {
  int get questionNo => throw _privateConstructorUsedError;
  int get subjectNo => throw _privateConstructorUsedError;
  String get conceptTitle => throw _privateConstructorUsedError;
  @ExamAnswerStringListConverter()
  List<String> get conceptTags => throw _privateConstructorUsedError; // 우리 토픽 코드 (개념 학습·문제 풀기 연결, 없으면 연결 버튼 없음)
  String? get topicCode =>
      throw _privateConstructorUsedError; // 표시용 정답 1~4 (공식·확정·우세면 운영 정답, 아니면 득표 1위, 표 없으면 null)
  int? get answer => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: ExamAnswerItemStatus.unknown)
  ExamAnswerItemStatus get answerStatus => throw _privateConstructorUsedError; // 복수 정답 (예: 2,3)
  @ExamAnswerIntListConverter()
  List<int> get alternativeAnswers => throw _privateConstructorUsedError; // 보기 1~4 득표 (0번 칸 = 보기 1)
  @ExamAnswerTallyConverter()
  List<int> get tally => throw _privateConstructorUsedError;
  int get voteCount => throw _privateConstructorUsedError; // 표시 정답 득표 비율 0~1
  double get agreementRate => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;

  /// Serializes this ExamAnswerItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamAnswerItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamAnswerItemCopyWith<ExamAnswerItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamAnswerItemCopyWith<$Res> {
  factory $ExamAnswerItemCopyWith(
    ExamAnswerItem value,
    $Res Function(ExamAnswerItem) then,
  ) = _$ExamAnswerItemCopyWithImpl<$Res, ExamAnswerItem>;
  @useResult
  $Res call({
    int questionNo,
    int subjectNo,
    String conceptTitle,
    @ExamAnswerStringListConverter() List<String> conceptTags,
    String? topicCode,
    int? answer,
    @JsonKey(unknownEnumValue: ExamAnswerItemStatus.unknown)
    ExamAnswerItemStatus answerStatus,
    @ExamAnswerIntListConverter() List<int> alternativeAnswers,
    @ExamAnswerTallyConverter() List<int> tally,
    int voteCount,
    double agreementRate,
    String? note,
  });
}

/// @nodoc
class _$ExamAnswerItemCopyWithImpl<$Res, $Val extends ExamAnswerItem>
    implements $ExamAnswerItemCopyWith<$Res> {
  _$ExamAnswerItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamAnswerItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionNo = null,
    Object? subjectNo = null,
    Object? conceptTitle = null,
    Object? conceptTags = null,
    Object? topicCode = freezed,
    Object? answer = freezed,
    Object? answerStatus = null,
    Object? alternativeAnswers = null,
    Object? tally = null,
    Object? voteCount = null,
    Object? agreementRate = null,
    Object? note = freezed,
  }) {
    return _then(
      _value.copyWith(
            questionNo: null == questionNo
                ? _value.questionNo
                : questionNo // ignore: cast_nullable_to_non_nullable
                      as int,
            subjectNo: null == subjectNo
                ? _value.subjectNo
                : subjectNo // ignore: cast_nullable_to_non_nullable
                      as int,
            conceptTitle: null == conceptTitle
                ? _value.conceptTitle
                : conceptTitle // ignore: cast_nullable_to_non_nullable
                      as String,
            conceptTags: null == conceptTags
                ? _value.conceptTags
                : conceptTags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            topicCode: freezed == topicCode
                ? _value.topicCode
                : topicCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            answer: freezed == answer
                ? _value.answer
                : answer // ignore: cast_nullable_to_non_nullable
                      as int?,
            answerStatus: null == answerStatus
                ? _value.answerStatus
                : answerStatus // ignore: cast_nullable_to_non_nullable
                      as ExamAnswerItemStatus,
            alternativeAnswers: null == alternativeAnswers
                ? _value.alternativeAnswers
                : alternativeAnswers // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            tally: null == tally
                ? _value.tally
                : tally // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            voteCount: null == voteCount
                ? _value.voteCount
                : voteCount // ignore: cast_nullable_to_non_nullable
                      as int,
            agreementRate: null == agreementRate
                ? _value.agreementRate
                : agreementRate // ignore: cast_nullable_to_non_nullable
                      as double,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExamAnswerItemImplCopyWith<$Res>
    implements $ExamAnswerItemCopyWith<$Res> {
  factory _$$ExamAnswerItemImplCopyWith(
    _$ExamAnswerItemImpl value,
    $Res Function(_$ExamAnswerItemImpl) then,
  ) = __$$ExamAnswerItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int questionNo,
    int subjectNo,
    String conceptTitle,
    @ExamAnswerStringListConverter() List<String> conceptTags,
    String? topicCode,
    int? answer,
    @JsonKey(unknownEnumValue: ExamAnswerItemStatus.unknown)
    ExamAnswerItemStatus answerStatus,
    @ExamAnswerIntListConverter() List<int> alternativeAnswers,
    @ExamAnswerTallyConverter() List<int> tally,
    int voteCount,
    double agreementRate,
    String? note,
  });
}

/// @nodoc
class __$$ExamAnswerItemImplCopyWithImpl<$Res>
    extends _$ExamAnswerItemCopyWithImpl<$Res, _$ExamAnswerItemImpl>
    implements _$$ExamAnswerItemImplCopyWith<$Res> {
  __$$ExamAnswerItemImplCopyWithImpl(
    _$ExamAnswerItemImpl _value,
    $Res Function(_$ExamAnswerItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamAnswerItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionNo = null,
    Object? subjectNo = null,
    Object? conceptTitle = null,
    Object? conceptTags = null,
    Object? topicCode = freezed,
    Object? answer = freezed,
    Object? answerStatus = null,
    Object? alternativeAnswers = null,
    Object? tally = null,
    Object? voteCount = null,
    Object? agreementRate = null,
    Object? note = freezed,
  }) {
    return _then(
      _$ExamAnswerItemImpl(
        questionNo: null == questionNo
            ? _value.questionNo
            : questionNo // ignore: cast_nullable_to_non_nullable
                  as int,
        subjectNo: null == subjectNo
            ? _value.subjectNo
            : subjectNo // ignore: cast_nullable_to_non_nullable
                  as int,
        conceptTitle: null == conceptTitle
            ? _value.conceptTitle
            : conceptTitle // ignore: cast_nullable_to_non_nullable
                  as String,
        conceptTags: null == conceptTags
            ? _value._conceptTags
            : conceptTags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        topicCode: freezed == topicCode
            ? _value.topicCode
            : topicCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        answer: freezed == answer
            ? _value.answer
            : answer // ignore: cast_nullable_to_non_nullable
                  as int?,
        answerStatus: null == answerStatus
            ? _value.answerStatus
            : answerStatus // ignore: cast_nullable_to_non_nullable
                  as ExamAnswerItemStatus,
        alternativeAnswers: null == alternativeAnswers
            ? _value._alternativeAnswers
            : alternativeAnswers // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        tally: null == tally
            ? _value._tally
            : tally // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        voteCount: null == voteCount
            ? _value.voteCount
            : voteCount // ignore: cast_nullable_to_non_nullable
                  as int,
        agreementRate: null == agreementRate
            ? _value.agreementRate
            : agreementRate // ignore: cast_nullable_to_non_nullable
                  as double,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamAnswerItemImpl implements _ExamAnswerItem {
  const _$ExamAnswerItemImpl({
    required this.questionNo,
    required this.subjectNo,
    this.conceptTitle = '',
    @ExamAnswerStringListConverter() final List<String> conceptTags = const [],
    this.topicCode,
    this.answer,
    @JsonKey(unknownEnumValue: ExamAnswerItemStatus.unknown)
    this.answerStatus = ExamAnswerItemStatus.undecided,
    @ExamAnswerIntListConverter() final List<int> alternativeAnswers = const [],
    @ExamAnswerTallyConverter() final List<int> tally = const [0, 0, 0, 0],
    this.voteCount = 0,
    this.agreementRate = 0,
    this.note,
  }) : _conceptTags = conceptTags,
       _alternativeAnswers = alternativeAnswers,
       _tally = tally;

  factory _$ExamAnswerItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamAnswerItemImplFromJson(json);

  @override
  final int questionNo;
  @override
  final int subjectNo;
  @override
  @JsonKey()
  final String conceptTitle;
  final List<String> _conceptTags;
  @override
  @JsonKey()
  @ExamAnswerStringListConverter()
  List<String> get conceptTags {
    if (_conceptTags is EqualUnmodifiableListView) return _conceptTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_conceptTags);
  }

  // 우리 토픽 코드 (개념 학습·문제 풀기 연결, 없으면 연결 버튼 없음)
  @override
  final String? topicCode;
  // 표시용 정답 1~4 (공식·확정·우세면 운영 정답, 아니면 득표 1위, 표 없으면 null)
  @override
  final int? answer;
  @override
  @JsonKey(unknownEnumValue: ExamAnswerItemStatus.unknown)
  final ExamAnswerItemStatus answerStatus;
  // 복수 정답 (예: 2,3)
  final List<int> _alternativeAnswers;
  // 복수 정답 (예: 2,3)
  @override
  @JsonKey()
  @ExamAnswerIntListConverter()
  List<int> get alternativeAnswers {
    if (_alternativeAnswers is EqualUnmodifiableListView)
      return _alternativeAnswers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alternativeAnswers);
  }

  // 보기 1~4 득표 (0번 칸 = 보기 1)
  final List<int> _tally;
  // 보기 1~4 득표 (0번 칸 = 보기 1)
  @override
  @JsonKey()
  @ExamAnswerTallyConverter()
  List<int> get tally {
    if (_tally is EqualUnmodifiableListView) return _tally;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tally);
  }

  @override
  @JsonKey()
  final int voteCount;
  // 표시 정답 득표 비율 0~1
  @override
  @JsonKey()
  final double agreementRate;
  @override
  final String? note;

  @override
  String toString() {
    return 'ExamAnswerItem(questionNo: $questionNo, subjectNo: $subjectNo, conceptTitle: $conceptTitle, conceptTags: $conceptTags, topicCode: $topicCode, answer: $answer, answerStatus: $answerStatus, alternativeAnswers: $alternativeAnswers, tally: $tally, voteCount: $voteCount, agreementRate: $agreementRate, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamAnswerItemImpl &&
            (identical(other.questionNo, questionNo) ||
                other.questionNo == questionNo) &&
            (identical(other.subjectNo, subjectNo) ||
                other.subjectNo == subjectNo) &&
            (identical(other.conceptTitle, conceptTitle) ||
                other.conceptTitle == conceptTitle) &&
            const DeepCollectionEquality().equals(
              other._conceptTags,
              _conceptTags,
            ) &&
            (identical(other.topicCode, topicCode) ||
                other.topicCode == topicCode) &&
            (identical(other.answer, answer) || other.answer == answer) &&
            (identical(other.answerStatus, answerStatus) ||
                other.answerStatus == answerStatus) &&
            const DeepCollectionEquality().equals(
              other._alternativeAnswers,
              _alternativeAnswers,
            ) &&
            const DeepCollectionEquality().equals(other._tally, _tally) &&
            (identical(other.voteCount, voteCount) ||
                other.voteCount == voteCount) &&
            (identical(other.agreementRate, agreementRate) ||
                other.agreementRate == agreementRate) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    questionNo,
    subjectNo,
    conceptTitle,
    const DeepCollectionEquality().hash(_conceptTags),
    topicCode,
    answer,
    answerStatus,
    const DeepCollectionEquality().hash(_alternativeAnswers),
    const DeepCollectionEquality().hash(_tally),
    voteCount,
    agreementRate,
    note,
  );

  /// Create a copy of ExamAnswerItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamAnswerItemImplCopyWith<_$ExamAnswerItemImpl> get copyWith =>
      __$$ExamAnswerItemImplCopyWithImpl<_$ExamAnswerItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamAnswerItemImplToJson(this);
  }
}

abstract class _ExamAnswerItem implements ExamAnswerItem {
  const factory _ExamAnswerItem({
    required final int questionNo,
    required final int subjectNo,
    final String conceptTitle,
    @ExamAnswerStringListConverter() final List<String> conceptTags,
    final String? topicCode,
    final int? answer,
    @JsonKey(unknownEnumValue: ExamAnswerItemStatus.unknown)
    final ExamAnswerItemStatus answerStatus,
    @ExamAnswerIntListConverter() final List<int> alternativeAnswers,
    @ExamAnswerTallyConverter() final List<int> tally,
    final int voteCount,
    final double agreementRate,
    final String? note,
  }) = _$ExamAnswerItemImpl;

  factory _ExamAnswerItem.fromJson(Map<String, dynamic> json) =
      _$ExamAnswerItemImpl.fromJson;

  @override
  int get questionNo;
  @override
  int get subjectNo;
  @override
  String get conceptTitle;
  @override
  @ExamAnswerStringListConverter()
  List<String> get conceptTags; // 우리 토픽 코드 (개념 학습·문제 풀기 연결, 없으면 연결 버튼 없음)
  @override
  String? get topicCode; // 표시용 정답 1~4 (공식·확정·우세면 운영 정답, 아니면 득표 1위, 표 없으면 null)
  @override
  int? get answer;
  @override
  @JsonKey(unknownEnumValue: ExamAnswerItemStatus.unknown)
  ExamAnswerItemStatus get answerStatus; // 복수 정답 (예: 2,3)
  @override
  @ExamAnswerIntListConverter()
  List<int> get alternativeAnswers; // 보기 1~4 득표 (0번 칸 = 보기 1)
  @override
  @ExamAnswerTallyConverter()
  List<int> get tally;
  @override
  int get voteCount; // 표시 정답 득표 비율 0~1
  @override
  double get agreementRate;
  @override
  String? get note;

  /// Create a copy of ExamAnswerItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamAnswerItemImplCopyWith<_$ExamAnswerItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
