// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credit_history_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CreditHistoryResponse _$CreditHistoryResponseFromJson(
  Map<String, dynamic> json,
) {
  return _CreditHistoryResponse.fromJson(json);
}

/// @nodoc
mixin _$CreditHistoryResponse {
  List<CreditHistoryDayResponse> get days => throw _privateConstructorUsedError;

  /// Serializes this CreditHistoryResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreditHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreditHistoryResponseCopyWith<CreditHistoryResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreditHistoryResponseCopyWith<$Res> {
  factory $CreditHistoryResponseCopyWith(
    CreditHistoryResponse value,
    $Res Function(CreditHistoryResponse) then,
  ) = _$CreditHistoryResponseCopyWithImpl<$Res, CreditHistoryResponse>;
  @useResult
  $Res call({List<CreditHistoryDayResponse> days});
}

/// @nodoc
class _$CreditHistoryResponseCopyWithImpl<
  $Res,
  $Val extends CreditHistoryResponse
>
    implements $CreditHistoryResponseCopyWith<$Res> {
  _$CreditHistoryResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreditHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? days = null}) {
    return _then(
      _value.copyWith(
            days: null == days
                ? _value.days
                : days // ignore: cast_nullable_to_non_nullable
                      as List<CreditHistoryDayResponse>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreditHistoryResponseImplCopyWith<$Res>
    implements $CreditHistoryResponseCopyWith<$Res> {
  factory _$$CreditHistoryResponseImplCopyWith(
    _$CreditHistoryResponseImpl value,
    $Res Function(_$CreditHistoryResponseImpl) then,
  ) = __$$CreditHistoryResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<CreditHistoryDayResponse> days});
}

/// @nodoc
class __$$CreditHistoryResponseImplCopyWithImpl<$Res>
    extends
        _$CreditHistoryResponseCopyWithImpl<$Res, _$CreditHistoryResponseImpl>
    implements _$$CreditHistoryResponseImplCopyWith<$Res> {
  __$$CreditHistoryResponseImplCopyWithImpl(
    _$CreditHistoryResponseImpl _value,
    $Res Function(_$CreditHistoryResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreditHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? days = null}) {
    return _then(
      _$CreditHistoryResponseImpl(
        days: null == days
            ? _value._days
            : days // ignore: cast_nullable_to_non_nullable
                  as List<CreditHistoryDayResponse>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreditHistoryResponseImpl implements _CreditHistoryResponse {
  const _$CreditHistoryResponseImpl({
    final List<CreditHistoryDayResponse> days =
        const <CreditHistoryDayResponse>[],
  }) : _days = days;

  factory _$CreditHistoryResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreditHistoryResponseImplFromJson(json);

  final List<CreditHistoryDayResponse> _days;
  @override
  @JsonKey()
  List<CreditHistoryDayResponse> get days {
    if (_days is EqualUnmodifiableListView) return _days;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_days);
  }

  @override
  String toString() {
    return 'CreditHistoryResponse(days: $days)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreditHistoryResponseImpl &&
            const DeepCollectionEquality().equals(other._days, _days));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_days));

  /// Create a copy of CreditHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreditHistoryResponseImplCopyWith<_$CreditHistoryResponseImpl>
  get copyWith =>
      __$$CreditHistoryResponseImplCopyWithImpl<_$CreditHistoryResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreditHistoryResponseImplToJson(this);
  }
}

abstract class _CreditHistoryResponse implements CreditHistoryResponse {
  const factory _CreditHistoryResponse({
    final List<CreditHistoryDayResponse> days,
  }) = _$CreditHistoryResponseImpl;

  factory _CreditHistoryResponse.fromJson(Map<String, dynamic> json) =
      _$CreditHistoryResponseImpl.fromJson;

  @override
  List<CreditHistoryDayResponse> get days;

  /// Create a copy of CreditHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreditHistoryResponseImplCopyWith<_$CreditHistoryResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CreditHistoryDayResponse _$CreditHistoryDayResponseFromJson(
  Map<String, dynamic> json,
) {
  return _CreditHistoryDayResponse.fromJson(json);
}

/// @nodoc
mixin _$CreditHistoryDayResponse {
  // 날짜 (KST, yyyy-MM-dd)
  DateTime get date => throw _privateConstructorUsedError; // 하루 기본 크레딧
  int get baseCredits =>
      throw _privateConstructorUsedError; // 오늘의 세트 완료 보너스로 받은 크레딧 (안 받았으면 0)
  int get dailySetCompletionCredits =>
      throw _privateConstructorUsedError; // 오늘의 세트 정답 80% 보너스로 받은 크레딧 (안 받았으면 0)
  int get dailySetAccuracyCredits =>
      throw _privateConstructorUsedError; // 광고 보너스 받은 횟수
  int get adBonusCount =>
      throw _privateConstructorUsedError; // 광고 보너스로 받은 크레딧 (횟수 x 1회 보너스)
  int get adBonusCredits =>
      throw _privateConstructorUsedError; // 그날 쓴 크레딧 (랜덤 풀기로 제출한 서로 다른 문제 수)
  int get usedCredits =>
      throw _privateConstructorUsedError; // 남은 크레딧 (받은 합 - 쓴 수, 0 미만은 0, 지난 날짜는 그날이 끝난 시점 값)
  int get remainingCredits => throw _privateConstructorUsedError;

  /// Serializes this CreditHistoryDayResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreditHistoryDayResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreditHistoryDayResponseCopyWith<CreditHistoryDayResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreditHistoryDayResponseCopyWith<$Res> {
  factory $CreditHistoryDayResponseCopyWith(
    CreditHistoryDayResponse value,
    $Res Function(CreditHistoryDayResponse) then,
  ) = _$CreditHistoryDayResponseCopyWithImpl<$Res, CreditHistoryDayResponse>;
  @useResult
  $Res call({
    DateTime date,
    int baseCredits,
    int dailySetCompletionCredits,
    int dailySetAccuracyCredits,
    int adBonusCount,
    int adBonusCredits,
    int usedCredits,
    int remainingCredits,
  });
}

/// @nodoc
class _$CreditHistoryDayResponseCopyWithImpl<
  $Res,
  $Val extends CreditHistoryDayResponse
>
    implements $CreditHistoryDayResponseCopyWith<$Res> {
  _$CreditHistoryDayResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreditHistoryDayResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? baseCredits = null,
    Object? dailySetCompletionCredits = null,
    Object? dailySetAccuracyCredits = null,
    Object? adBonusCount = null,
    Object? adBonusCredits = null,
    Object? usedCredits = null,
    Object? remainingCredits = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            baseCredits: null == baseCredits
                ? _value.baseCredits
                : baseCredits // ignore: cast_nullable_to_non_nullable
                      as int,
            dailySetCompletionCredits: null == dailySetCompletionCredits
                ? _value.dailySetCompletionCredits
                : dailySetCompletionCredits // ignore: cast_nullable_to_non_nullable
                      as int,
            dailySetAccuracyCredits: null == dailySetAccuracyCredits
                ? _value.dailySetAccuracyCredits
                : dailySetAccuracyCredits // ignore: cast_nullable_to_non_nullable
                      as int,
            adBonusCount: null == adBonusCount
                ? _value.adBonusCount
                : adBonusCount // ignore: cast_nullable_to_non_nullable
                      as int,
            adBonusCredits: null == adBonusCredits
                ? _value.adBonusCredits
                : adBonusCredits // ignore: cast_nullable_to_non_nullable
                      as int,
            usedCredits: null == usedCredits
                ? _value.usedCredits
                : usedCredits // ignore: cast_nullable_to_non_nullable
                      as int,
            remainingCredits: null == remainingCredits
                ? _value.remainingCredits
                : remainingCredits // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreditHistoryDayResponseImplCopyWith<$Res>
    implements $CreditHistoryDayResponseCopyWith<$Res> {
  factory _$$CreditHistoryDayResponseImplCopyWith(
    _$CreditHistoryDayResponseImpl value,
    $Res Function(_$CreditHistoryDayResponseImpl) then,
  ) = __$$CreditHistoryDayResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime date,
    int baseCredits,
    int dailySetCompletionCredits,
    int dailySetAccuracyCredits,
    int adBonusCount,
    int adBonusCredits,
    int usedCredits,
    int remainingCredits,
  });
}

/// @nodoc
class __$$CreditHistoryDayResponseImplCopyWithImpl<$Res>
    extends
        _$CreditHistoryDayResponseCopyWithImpl<
          $Res,
          _$CreditHistoryDayResponseImpl
        >
    implements _$$CreditHistoryDayResponseImplCopyWith<$Res> {
  __$$CreditHistoryDayResponseImplCopyWithImpl(
    _$CreditHistoryDayResponseImpl _value,
    $Res Function(_$CreditHistoryDayResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreditHistoryDayResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? baseCredits = null,
    Object? dailySetCompletionCredits = null,
    Object? dailySetAccuracyCredits = null,
    Object? adBonusCount = null,
    Object? adBonusCredits = null,
    Object? usedCredits = null,
    Object? remainingCredits = null,
  }) {
    return _then(
      _$CreditHistoryDayResponseImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        baseCredits: null == baseCredits
            ? _value.baseCredits
            : baseCredits // ignore: cast_nullable_to_non_nullable
                  as int,
        dailySetCompletionCredits: null == dailySetCompletionCredits
            ? _value.dailySetCompletionCredits
            : dailySetCompletionCredits // ignore: cast_nullable_to_non_nullable
                  as int,
        dailySetAccuracyCredits: null == dailySetAccuracyCredits
            ? _value.dailySetAccuracyCredits
            : dailySetAccuracyCredits // ignore: cast_nullable_to_non_nullable
                  as int,
        adBonusCount: null == adBonusCount
            ? _value.adBonusCount
            : adBonusCount // ignore: cast_nullable_to_non_nullable
                  as int,
        adBonusCredits: null == adBonusCredits
            ? _value.adBonusCredits
            : adBonusCredits // ignore: cast_nullable_to_non_nullable
                  as int,
        usedCredits: null == usedCredits
            ? _value.usedCredits
            : usedCredits // ignore: cast_nullable_to_non_nullable
                  as int,
        remainingCredits: null == remainingCredits
            ? _value.remainingCredits
            : remainingCredits // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreditHistoryDayResponseImpl implements _CreditHistoryDayResponse {
  const _$CreditHistoryDayResponseImpl({
    required this.date,
    this.baseCredits = 0,
    this.dailySetCompletionCredits = 0,
    this.dailySetAccuracyCredits = 0,
    this.adBonusCount = 0,
    this.adBonusCredits = 0,
    this.usedCredits = 0,
    this.remainingCredits = 0,
  });

  factory _$CreditHistoryDayResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreditHistoryDayResponseImplFromJson(json);

  // 날짜 (KST, yyyy-MM-dd)
  @override
  final DateTime date;
  // 하루 기본 크레딧
  @override
  @JsonKey()
  final int baseCredits;
  // 오늘의 세트 완료 보너스로 받은 크레딧 (안 받았으면 0)
  @override
  @JsonKey()
  final int dailySetCompletionCredits;
  // 오늘의 세트 정답 80% 보너스로 받은 크레딧 (안 받았으면 0)
  @override
  @JsonKey()
  final int dailySetAccuracyCredits;
  // 광고 보너스 받은 횟수
  @override
  @JsonKey()
  final int adBonusCount;
  // 광고 보너스로 받은 크레딧 (횟수 x 1회 보너스)
  @override
  @JsonKey()
  final int adBonusCredits;
  // 그날 쓴 크레딧 (랜덤 풀기로 제출한 서로 다른 문제 수)
  @override
  @JsonKey()
  final int usedCredits;
  // 남은 크레딧 (받은 합 - 쓴 수, 0 미만은 0, 지난 날짜는 그날이 끝난 시점 값)
  @override
  @JsonKey()
  final int remainingCredits;

  @override
  String toString() {
    return 'CreditHistoryDayResponse(date: $date, baseCredits: $baseCredits, dailySetCompletionCredits: $dailySetCompletionCredits, dailySetAccuracyCredits: $dailySetAccuracyCredits, adBonusCount: $adBonusCount, adBonusCredits: $adBonusCredits, usedCredits: $usedCredits, remainingCredits: $remainingCredits)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreditHistoryDayResponseImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.baseCredits, baseCredits) ||
                other.baseCredits == baseCredits) &&
            (identical(
                  other.dailySetCompletionCredits,
                  dailySetCompletionCredits,
                ) ||
                other.dailySetCompletionCredits == dailySetCompletionCredits) &&
            (identical(
                  other.dailySetAccuracyCredits,
                  dailySetAccuracyCredits,
                ) ||
                other.dailySetAccuracyCredits == dailySetAccuracyCredits) &&
            (identical(other.adBonusCount, adBonusCount) ||
                other.adBonusCount == adBonusCount) &&
            (identical(other.adBonusCredits, adBonusCredits) ||
                other.adBonusCredits == adBonusCredits) &&
            (identical(other.usedCredits, usedCredits) ||
                other.usedCredits == usedCredits) &&
            (identical(other.remainingCredits, remainingCredits) ||
                other.remainingCredits == remainingCredits));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    date,
    baseCredits,
    dailySetCompletionCredits,
    dailySetAccuracyCredits,
    adBonusCount,
    adBonusCredits,
    usedCredits,
    remainingCredits,
  );

  /// Create a copy of CreditHistoryDayResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreditHistoryDayResponseImplCopyWith<_$CreditHistoryDayResponseImpl>
  get copyWith =>
      __$$CreditHistoryDayResponseImplCopyWithImpl<
        _$CreditHistoryDayResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreditHistoryDayResponseImplToJson(this);
  }
}

abstract class _CreditHistoryDayResponse implements CreditHistoryDayResponse {
  const factory _CreditHistoryDayResponse({
    required final DateTime date,
    final int baseCredits,
    final int dailySetCompletionCredits,
    final int dailySetAccuracyCredits,
    final int adBonusCount,
    final int adBonusCredits,
    final int usedCredits,
    final int remainingCredits,
  }) = _$CreditHistoryDayResponseImpl;

  factory _CreditHistoryDayResponse.fromJson(Map<String, dynamic> json) =
      _$CreditHistoryDayResponseImpl.fromJson;

  // 날짜 (KST, yyyy-MM-dd)
  @override
  DateTime get date; // 하루 기본 크레딧
  @override
  int get baseCredits; // 오늘의 세트 완료 보너스로 받은 크레딧 (안 받았으면 0)
  @override
  int get dailySetCompletionCredits; // 오늘의 세트 정답 80% 보너스로 받은 크레딧 (안 받았으면 0)
  @override
  int get dailySetAccuracyCredits; // 광고 보너스 받은 횟수
  @override
  int get adBonusCount; // 광고 보너스로 받은 크레딧 (횟수 x 1회 보너스)
  @override
  int get adBonusCredits; // 그날 쓴 크레딧 (랜덤 풀기로 제출한 서로 다른 문제 수)
  @override
  int get usedCredits; // 남은 크레딧 (받은 합 - 쓴 수, 0 미만은 0, 지난 날짜는 그날이 끝난 시점 값)
  @override
  int get remainingCredits;

  /// Create a copy of CreditHistoryDayResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreditHistoryDayResponseImplCopyWith<_$CreditHistoryDayResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
