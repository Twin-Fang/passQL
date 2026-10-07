// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_set_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DailySetTodayResponse _$DailySetTodayResponseFromJson(
  Map<String, dynamic> json,
) {
  return _DailySetTodayResponse.fromJson(json);
}

/// @nodoc
mixin _$DailySetTodayResponse {
  List<QuestionSummary> get questions => throw _privateConstructorUsedError;
  bool get alreadyCompleted =>
      throw _privateConstructorUsedError; // 이미 완료했을 때의 정답 수. 아직이면 null.
  int? get correctCount =>
      throw _privateConstructorUsedError; // 이미 완료했을 때 문제별 정답 여부(questions 순서). 기록을 못 찾은 문제는 null.
  List<bool?>? get results => throw _privateConstructorUsedError;

  /// Serializes this DailySetTodayResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailySetTodayResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailySetTodayResponseCopyWith<DailySetTodayResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailySetTodayResponseCopyWith<$Res> {
  factory $DailySetTodayResponseCopyWith(
    DailySetTodayResponse value,
    $Res Function(DailySetTodayResponse) then,
  ) = _$DailySetTodayResponseCopyWithImpl<$Res, DailySetTodayResponse>;
  @useResult
  $Res call({
    List<QuestionSummary> questions,
    bool alreadyCompleted,
    int? correctCount,
    List<bool?>? results,
  });
}

/// @nodoc
class _$DailySetTodayResponseCopyWithImpl<
  $Res,
  $Val extends DailySetTodayResponse
>
    implements $DailySetTodayResponseCopyWith<$Res> {
  _$DailySetTodayResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailySetTodayResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questions = null,
    Object? alreadyCompleted = null,
    Object? correctCount = freezed,
    Object? results = freezed,
  }) {
    return _then(
      _value.copyWith(
            questions: null == questions
                ? _value.questions
                : questions // ignore: cast_nullable_to_non_nullable
                      as List<QuestionSummary>,
            alreadyCompleted: null == alreadyCompleted
                ? _value.alreadyCompleted
                : alreadyCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            correctCount: freezed == correctCount
                ? _value.correctCount
                : correctCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            results: freezed == results
                ? _value.results
                : results // ignore: cast_nullable_to_non_nullable
                      as List<bool?>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailySetTodayResponseImplCopyWith<$Res>
    implements $DailySetTodayResponseCopyWith<$Res> {
  factory _$$DailySetTodayResponseImplCopyWith(
    _$DailySetTodayResponseImpl value,
    $Res Function(_$DailySetTodayResponseImpl) then,
  ) = __$$DailySetTodayResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<QuestionSummary> questions,
    bool alreadyCompleted,
    int? correctCount,
    List<bool?>? results,
  });
}

/// @nodoc
class __$$DailySetTodayResponseImplCopyWithImpl<$Res>
    extends
        _$DailySetTodayResponseCopyWithImpl<$Res, _$DailySetTodayResponseImpl>
    implements _$$DailySetTodayResponseImplCopyWith<$Res> {
  __$$DailySetTodayResponseImplCopyWithImpl(
    _$DailySetTodayResponseImpl _value,
    $Res Function(_$DailySetTodayResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailySetTodayResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questions = null,
    Object? alreadyCompleted = null,
    Object? correctCount = freezed,
    Object? results = freezed,
  }) {
    return _then(
      _$DailySetTodayResponseImpl(
        questions: null == questions
            ? _value._questions
            : questions // ignore: cast_nullable_to_non_nullable
                  as List<QuestionSummary>,
        alreadyCompleted: null == alreadyCompleted
            ? _value.alreadyCompleted
            : alreadyCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        correctCount: freezed == correctCount
            ? _value.correctCount
            : correctCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        results: freezed == results
            ? _value._results
            : results // ignore: cast_nullable_to_non_nullable
                  as List<bool?>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailySetTodayResponseImpl implements _DailySetTodayResponse {
  const _$DailySetTodayResponseImpl({
    final List<QuestionSummary> questions = const [],
    this.alreadyCompleted = false,
    this.correctCount,
    final List<bool?>? results,
  }) : _questions = questions,
       _results = results;

  factory _$DailySetTodayResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailySetTodayResponseImplFromJson(json);

  final List<QuestionSummary> _questions;
  @override
  @JsonKey()
  List<QuestionSummary> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  @override
  @JsonKey()
  final bool alreadyCompleted;
  // 이미 완료했을 때의 정답 수. 아직이면 null.
  @override
  final int? correctCount;
  // 이미 완료했을 때 문제별 정답 여부(questions 순서). 기록을 못 찾은 문제는 null.
  final List<bool?>? _results;
  // 이미 완료했을 때 문제별 정답 여부(questions 순서). 기록을 못 찾은 문제는 null.
  @override
  List<bool?>? get results {
    final value = _results;
    if (value == null) return null;
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'DailySetTodayResponse(questions: $questions, alreadyCompleted: $alreadyCompleted, correctCount: $correctCount, results: $results)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailySetTodayResponseImpl &&
            const DeepCollectionEquality().equals(
              other._questions,
              _questions,
            ) &&
            (identical(other.alreadyCompleted, alreadyCompleted) ||
                other.alreadyCompleted == alreadyCompleted) &&
            (identical(other.correctCount, correctCount) ||
                other.correctCount == correctCount) &&
            const DeepCollectionEquality().equals(other._results, _results));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_questions),
    alreadyCompleted,
    correctCount,
    const DeepCollectionEquality().hash(_results),
  );

  /// Create a copy of DailySetTodayResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailySetTodayResponseImplCopyWith<_$DailySetTodayResponseImpl>
  get copyWith =>
      __$$DailySetTodayResponseImplCopyWithImpl<_$DailySetTodayResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DailySetTodayResponseImplToJson(this);
  }
}

abstract class _DailySetTodayResponse implements DailySetTodayResponse {
  const factory _DailySetTodayResponse({
    final List<QuestionSummary> questions,
    final bool alreadyCompleted,
    final int? correctCount,
    final List<bool?>? results,
  }) = _$DailySetTodayResponseImpl;

  factory _DailySetTodayResponse.fromJson(Map<String, dynamic> json) =
      _$DailySetTodayResponseImpl.fromJson;

  @override
  List<QuestionSummary> get questions;
  @override
  bool get alreadyCompleted; // 이미 완료했을 때의 정답 수. 아직이면 null.
  @override
  int? get correctCount; // 이미 완료했을 때 문제별 정답 여부(questions 순서). 기록을 못 찾은 문제는 null.
  @override
  List<bool?>? get results;

  /// Create a copy of DailySetTodayResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailySetTodayResponseImplCopyWith<_$DailySetTodayResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

DailySetCompleteResponse _$DailySetCompleteResponseFromJson(
  Map<String, dynamic> json,
) {
  return _DailySetCompleteResponse.fromJson(json);
}

/// @nodoc
mixin _$DailySetCompleteResponse {
  int get correctCount => throw _privateConstructorUsedError;
  int get rank => throw _privateConstructorUsedError;
  int get totalParticipants => throw _privateConstructorUsedError;

  /// Serializes this DailySetCompleteResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailySetCompleteResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailySetCompleteResponseCopyWith<DailySetCompleteResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailySetCompleteResponseCopyWith<$Res> {
  factory $DailySetCompleteResponseCopyWith(
    DailySetCompleteResponse value,
    $Res Function(DailySetCompleteResponse) then,
  ) = _$DailySetCompleteResponseCopyWithImpl<$Res, DailySetCompleteResponse>;
  @useResult
  $Res call({int correctCount, int rank, int totalParticipants});
}

/// @nodoc
class _$DailySetCompleteResponseCopyWithImpl<
  $Res,
  $Val extends DailySetCompleteResponse
>
    implements $DailySetCompleteResponseCopyWith<$Res> {
  _$DailySetCompleteResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailySetCompleteResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? correctCount = null,
    Object? rank = null,
    Object? totalParticipants = null,
  }) {
    return _then(
      _value.copyWith(
            correctCount: null == correctCount
                ? _value.correctCount
                : correctCount // ignore: cast_nullable_to_non_nullable
                      as int,
            rank: null == rank
                ? _value.rank
                : rank // ignore: cast_nullable_to_non_nullable
                      as int,
            totalParticipants: null == totalParticipants
                ? _value.totalParticipants
                : totalParticipants // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailySetCompleteResponseImplCopyWith<$Res>
    implements $DailySetCompleteResponseCopyWith<$Res> {
  factory _$$DailySetCompleteResponseImplCopyWith(
    _$DailySetCompleteResponseImpl value,
    $Res Function(_$DailySetCompleteResponseImpl) then,
  ) = __$$DailySetCompleteResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int correctCount, int rank, int totalParticipants});
}

/// @nodoc
class __$$DailySetCompleteResponseImplCopyWithImpl<$Res>
    extends
        _$DailySetCompleteResponseCopyWithImpl<
          $Res,
          _$DailySetCompleteResponseImpl
        >
    implements _$$DailySetCompleteResponseImplCopyWith<$Res> {
  __$$DailySetCompleteResponseImplCopyWithImpl(
    _$DailySetCompleteResponseImpl _value,
    $Res Function(_$DailySetCompleteResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailySetCompleteResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? correctCount = null,
    Object? rank = null,
    Object? totalParticipants = null,
  }) {
    return _then(
      _$DailySetCompleteResponseImpl(
        correctCount: null == correctCount
            ? _value.correctCount
            : correctCount // ignore: cast_nullable_to_non_nullable
                  as int,
        rank: null == rank
            ? _value.rank
            : rank // ignore: cast_nullable_to_non_nullable
                  as int,
        totalParticipants: null == totalParticipants
            ? _value.totalParticipants
            : totalParticipants // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailySetCompleteResponseImpl implements _DailySetCompleteResponse {
  const _$DailySetCompleteResponseImpl({
    required this.correctCount,
    required this.rank,
    required this.totalParticipants,
  });

  factory _$DailySetCompleteResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailySetCompleteResponseImplFromJson(json);

  @override
  final int correctCount;
  @override
  final int rank;
  @override
  final int totalParticipants;

  @override
  String toString() {
    return 'DailySetCompleteResponse(correctCount: $correctCount, rank: $rank, totalParticipants: $totalParticipants)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailySetCompleteResponseImpl &&
            (identical(other.correctCount, correctCount) ||
                other.correctCount == correctCount) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.totalParticipants, totalParticipants) ||
                other.totalParticipants == totalParticipants));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, correctCount, rank, totalParticipants);

  /// Create a copy of DailySetCompleteResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailySetCompleteResponseImplCopyWith<_$DailySetCompleteResponseImpl>
  get copyWith =>
      __$$DailySetCompleteResponseImplCopyWithImpl<
        _$DailySetCompleteResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailySetCompleteResponseImplToJson(this);
  }
}

abstract class _DailySetCompleteResponse implements DailySetCompleteResponse {
  const factory _DailySetCompleteResponse({
    required final int correctCount,
    required final int rank,
    required final int totalParticipants,
  }) = _$DailySetCompleteResponseImpl;

  factory _DailySetCompleteResponse.fromJson(Map<String, dynamic> json) =
      _$DailySetCompleteResponseImpl.fromJson;

  @override
  int get correctCount;
  @override
  int get rank;
  @override
  int get totalParticipants;

  /// Create a copy of DailySetCompleteResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailySetCompleteResponseImplCopyWith<_$DailySetCompleteResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

LeaderboardEntry _$LeaderboardEntryFromJson(Map<String, dynamic> json) {
  return _LeaderboardEntry.fromJson(json);
}

/// @nodoc
mixin _$LeaderboardEntry {
  int get rank => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  int get correctCount => throw _privateConstructorUsedError;

  /// Serializes this LeaderboardEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaderboardEntryCopyWith<LeaderboardEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaderboardEntryCopyWith<$Res> {
  factory $LeaderboardEntryCopyWith(
    LeaderboardEntry value,
    $Res Function(LeaderboardEntry) then,
  ) = _$LeaderboardEntryCopyWithImpl<$Res, LeaderboardEntry>;
  @useResult
  $Res call({int rank, String nickname, int correctCount});
}

/// @nodoc
class _$LeaderboardEntryCopyWithImpl<$Res, $Val extends LeaderboardEntry>
    implements $LeaderboardEntryCopyWith<$Res> {
  _$LeaderboardEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rank = null,
    Object? nickname = null,
    Object? correctCount = null,
  }) {
    return _then(
      _value.copyWith(
            rank: null == rank
                ? _value.rank
                : rank // ignore: cast_nullable_to_non_nullable
                      as int,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            correctCount: null == correctCount
                ? _value.correctCount
                : correctCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeaderboardEntryImplCopyWith<$Res>
    implements $LeaderboardEntryCopyWith<$Res> {
  factory _$$LeaderboardEntryImplCopyWith(
    _$LeaderboardEntryImpl value,
    $Res Function(_$LeaderboardEntryImpl) then,
  ) = __$$LeaderboardEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int rank, String nickname, int correctCount});
}

/// @nodoc
class __$$LeaderboardEntryImplCopyWithImpl<$Res>
    extends _$LeaderboardEntryCopyWithImpl<$Res, _$LeaderboardEntryImpl>
    implements _$$LeaderboardEntryImplCopyWith<$Res> {
  __$$LeaderboardEntryImplCopyWithImpl(
    _$LeaderboardEntryImpl _value,
    $Res Function(_$LeaderboardEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rank = null,
    Object? nickname = null,
    Object? correctCount = null,
  }) {
    return _then(
      _$LeaderboardEntryImpl(
        rank: null == rank
            ? _value.rank
            : rank // ignore: cast_nullable_to_non_nullable
                  as int,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        correctCount: null == correctCount
            ? _value.correctCount
            : correctCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaderboardEntryImpl implements _LeaderboardEntry {
  const _$LeaderboardEntryImpl({
    required this.rank,
    required this.nickname,
    required this.correctCount,
  });

  factory _$LeaderboardEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaderboardEntryImplFromJson(json);

  @override
  final int rank;
  @override
  final String nickname;
  @override
  final int correctCount;

  @override
  String toString() {
    return 'LeaderboardEntry(rank: $rank, nickname: $nickname, correctCount: $correctCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaderboardEntryImpl &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.correctCount, correctCount) ||
                other.correctCount == correctCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, rank, nickname, correctCount);

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaderboardEntryImplCopyWith<_$LeaderboardEntryImpl> get copyWith =>
      __$$LeaderboardEntryImplCopyWithImpl<_$LeaderboardEntryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaderboardEntryImplToJson(this);
  }
}

abstract class _LeaderboardEntry implements LeaderboardEntry {
  const factory _LeaderboardEntry({
    required final int rank,
    required final String nickname,
    required final int correctCount,
  }) = _$LeaderboardEntryImpl;

  factory _LeaderboardEntry.fromJson(Map<String, dynamic> json) =
      _$LeaderboardEntryImpl.fromJson;

  @override
  int get rank;
  @override
  String get nickname;
  @override
  int get correctCount;

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaderboardEntryImplCopyWith<_$LeaderboardEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeaderboardResponse _$LeaderboardResponseFromJson(Map<String, dynamic> json) {
  return _LeaderboardResponse.fromJson(json);
}

/// @nodoc
mixin _$LeaderboardResponse {
  // 서버는 날짜(yyyy-MM-dd)를 내려준다. 화면은 문자열 그대로 보여준다.
  String? get date => throw _privateConstructorUsedError;
  List<LeaderboardEntry> get entries =>
      throw _privateConstructorUsedError; // 내가 오늘 완료하지 않았으면 null.
  LeaderboardEntry? get myEntry => throw _privateConstructorUsedError;

  /// Serializes this LeaderboardResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeaderboardResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaderboardResponseCopyWith<LeaderboardResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaderboardResponseCopyWith<$Res> {
  factory $LeaderboardResponseCopyWith(
    LeaderboardResponse value,
    $Res Function(LeaderboardResponse) then,
  ) = _$LeaderboardResponseCopyWithImpl<$Res, LeaderboardResponse>;
  @useResult
  $Res call({
    String? date,
    List<LeaderboardEntry> entries,
    LeaderboardEntry? myEntry,
  });

  $LeaderboardEntryCopyWith<$Res>? get myEntry;
}

/// @nodoc
class _$LeaderboardResponseCopyWithImpl<$Res, $Val extends LeaderboardResponse>
    implements $LeaderboardResponseCopyWith<$Res> {
  _$LeaderboardResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaderboardResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = freezed,
    Object? entries = null,
    Object? myEntry = freezed,
  }) {
    return _then(
      _value.copyWith(
            date: freezed == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String?,
            entries: null == entries
                ? _value.entries
                : entries // ignore: cast_nullable_to_non_nullable
                      as List<LeaderboardEntry>,
            myEntry: freezed == myEntry
                ? _value.myEntry
                : myEntry // ignore: cast_nullable_to_non_nullable
                      as LeaderboardEntry?,
          )
          as $Val,
    );
  }

  /// Create a copy of LeaderboardResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LeaderboardEntryCopyWith<$Res>? get myEntry {
    if (_value.myEntry == null) {
      return null;
    }

    return $LeaderboardEntryCopyWith<$Res>(_value.myEntry!, (value) {
      return _then(_value.copyWith(myEntry: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LeaderboardResponseImplCopyWith<$Res>
    implements $LeaderboardResponseCopyWith<$Res> {
  factory _$$LeaderboardResponseImplCopyWith(
    _$LeaderboardResponseImpl value,
    $Res Function(_$LeaderboardResponseImpl) then,
  ) = __$$LeaderboardResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? date,
    List<LeaderboardEntry> entries,
    LeaderboardEntry? myEntry,
  });

  @override
  $LeaderboardEntryCopyWith<$Res>? get myEntry;
}

/// @nodoc
class __$$LeaderboardResponseImplCopyWithImpl<$Res>
    extends _$LeaderboardResponseCopyWithImpl<$Res, _$LeaderboardResponseImpl>
    implements _$$LeaderboardResponseImplCopyWith<$Res> {
  __$$LeaderboardResponseImplCopyWithImpl(
    _$LeaderboardResponseImpl _value,
    $Res Function(_$LeaderboardResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeaderboardResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = freezed,
    Object? entries = null,
    Object? myEntry = freezed,
  }) {
    return _then(
      _$LeaderboardResponseImpl(
        date: freezed == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String?,
        entries: null == entries
            ? _value._entries
            : entries // ignore: cast_nullable_to_non_nullable
                  as List<LeaderboardEntry>,
        myEntry: freezed == myEntry
            ? _value.myEntry
            : myEntry // ignore: cast_nullable_to_non_nullable
                  as LeaderboardEntry?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaderboardResponseImpl implements _LeaderboardResponse {
  const _$LeaderboardResponseImpl({
    this.date,
    final List<LeaderboardEntry> entries = const [],
    this.myEntry,
  }) : _entries = entries;

  factory _$LeaderboardResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaderboardResponseImplFromJson(json);

  // 서버는 날짜(yyyy-MM-dd)를 내려준다. 화면은 문자열 그대로 보여준다.
  @override
  final String? date;
  final List<LeaderboardEntry> _entries;
  @override
  @JsonKey()
  List<LeaderboardEntry> get entries {
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entries);
  }

  // 내가 오늘 완료하지 않았으면 null.
  @override
  final LeaderboardEntry? myEntry;

  @override
  String toString() {
    return 'LeaderboardResponse(date: $date, entries: $entries, myEntry: $myEntry)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaderboardResponseImpl &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(other._entries, _entries) &&
            (identical(other.myEntry, myEntry) || other.myEntry == myEntry));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    date,
    const DeepCollectionEquality().hash(_entries),
    myEntry,
  );

  /// Create a copy of LeaderboardResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaderboardResponseImplCopyWith<_$LeaderboardResponseImpl> get copyWith =>
      __$$LeaderboardResponseImplCopyWithImpl<_$LeaderboardResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaderboardResponseImplToJson(this);
  }
}

abstract class _LeaderboardResponse implements LeaderboardResponse {
  const factory _LeaderboardResponse({
    final String? date,
    final List<LeaderboardEntry> entries,
    final LeaderboardEntry? myEntry,
  }) = _$LeaderboardResponseImpl;

  factory _LeaderboardResponse.fromJson(Map<String, dynamic> json) =
      _$LeaderboardResponseImpl.fromJson;

  // 서버는 날짜(yyyy-MM-dd)를 내려준다. 화면은 문자열 그대로 보여준다.
  @override
  String? get date;
  @override
  List<LeaderboardEntry> get entries; // 내가 오늘 완료하지 않았으면 null.
  @override
  LeaderboardEntry? get myEntry;

  /// Create a copy of LeaderboardResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaderboardResponseImplCopyWith<_$LeaderboardResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
