// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_plan_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MemberPlanResponse _$MemberPlanResponseFromJson(Map<String, dynamic> json) {
  return _MemberPlanResponse.fromJson(json);
}

/// @nodoc
mixin _$MemberPlanResponse {
  // 서버 결제 스위치 (false 면 서버가 모든 회원을 프로처럼 취급)
  bool get isBillingEnabled =>
      throw _privateConstructorUsedError; // 서버에 새 등급이 생겨도 깨지지 않게 모르는 값은 무료로 봄
  @JsonKey(unknownEnumValue: MemberPlanType.free)
  MemberPlanType get plan => throw _privateConstructorUsedError; // 프로 만료 시각 (KST, 무료면 null)
  DateTime? get proExpiresAt =>
      throw _privateConstructorUsedError; // 오늘 제출한 서로 다른 랜덤 문제 수 (오늘의 문제 제외)
  int get todayRandomSolvedCount =>
      throw _privateConstructorUsedError; // 무료 하루 랜덤 문제 한도
  int get dailyFreeLimit =>
      throw _privateConstructorUsedError; // 지금 구매하면 이용할 수 있는 마지막 날 (다음 시험일, 없으면 null)
  DateTime? get purchasableUntil => throw _privateConstructorUsedError;

  /// Serializes this MemberPlanResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MemberPlanResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemberPlanResponseCopyWith<MemberPlanResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemberPlanResponseCopyWith<$Res> {
  factory $MemberPlanResponseCopyWith(
    MemberPlanResponse value,
    $Res Function(MemberPlanResponse) then,
  ) = _$MemberPlanResponseCopyWithImpl<$Res, MemberPlanResponse>;
  @useResult
  $Res call({
    bool isBillingEnabled,
    @JsonKey(unknownEnumValue: MemberPlanType.free) MemberPlanType plan,
    DateTime? proExpiresAt,
    int todayRandomSolvedCount,
    int dailyFreeLimit,
    DateTime? purchasableUntil,
  });
}

/// @nodoc
class _$MemberPlanResponseCopyWithImpl<$Res, $Val extends MemberPlanResponse>
    implements $MemberPlanResponseCopyWith<$Res> {
  _$MemberPlanResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MemberPlanResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isBillingEnabled = null,
    Object? plan = null,
    Object? proExpiresAt = freezed,
    Object? todayRandomSolvedCount = null,
    Object? dailyFreeLimit = null,
    Object? purchasableUntil = freezed,
  }) {
    return _then(
      _value.copyWith(
            isBillingEnabled: null == isBillingEnabled
                ? _value.isBillingEnabled
                : isBillingEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            plan: null == plan
                ? _value.plan
                : plan // ignore: cast_nullable_to_non_nullable
                      as MemberPlanType,
            proExpiresAt: freezed == proExpiresAt
                ? _value.proExpiresAt
                : proExpiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            todayRandomSolvedCount: null == todayRandomSolvedCount
                ? _value.todayRandomSolvedCount
                : todayRandomSolvedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            dailyFreeLimit: null == dailyFreeLimit
                ? _value.dailyFreeLimit
                : dailyFreeLimit // ignore: cast_nullable_to_non_nullable
                      as int,
            purchasableUntil: freezed == purchasableUntil
                ? _value.purchasableUntil
                : purchasableUntil // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MemberPlanResponseImplCopyWith<$Res>
    implements $MemberPlanResponseCopyWith<$Res> {
  factory _$$MemberPlanResponseImplCopyWith(
    _$MemberPlanResponseImpl value,
    $Res Function(_$MemberPlanResponseImpl) then,
  ) = __$$MemberPlanResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isBillingEnabled,
    @JsonKey(unknownEnumValue: MemberPlanType.free) MemberPlanType plan,
    DateTime? proExpiresAt,
    int todayRandomSolvedCount,
    int dailyFreeLimit,
    DateTime? purchasableUntil,
  });
}

/// @nodoc
class __$$MemberPlanResponseImplCopyWithImpl<$Res>
    extends _$MemberPlanResponseCopyWithImpl<$Res, _$MemberPlanResponseImpl>
    implements _$$MemberPlanResponseImplCopyWith<$Res> {
  __$$MemberPlanResponseImplCopyWithImpl(
    _$MemberPlanResponseImpl _value,
    $Res Function(_$MemberPlanResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MemberPlanResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isBillingEnabled = null,
    Object? plan = null,
    Object? proExpiresAt = freezed,
    Object? todayRandomSolvedCount = null,
    Object? dailyFreeLimit = null,
    Object? purchasableUntil = freezed,
  }) {
    return _then(
      _$MemberPlanResponseImpl(
        isBillingEnabled: null == isBillingEnabled
            ? _value.isBillingEnabled
            : isBillingEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        plan: null == plan
            ? _value.plan
            : plan // ignore: cast_nullable_to_non_nullable
                  as MemberPlanType,
        proExpiresAt: freezed == proExpiresAt
            ? _value.proExpiresAt
            : proExpiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        todayRandomSolvedCount: null == todayRandomSolvedCount
            ? _value.todayRandomSolvedCount
            : todayRandomSolvedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        dailyFreeLimit: null == dailyFreeLimit
            ? _value.dailyFreeLimit
            : dailyFreeLimit // ignore: cast_nullable_to_non_nullable
                  as int,
        purchasableUntil: freezed == purchasableUntil
            ? _value.purchasableUntil
            : purchasableUntil // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MemberPlanResponseImpl implements _MemberPlanResponse {
  const _$MemberPlanResponseImpl({
    this.isBillingEnabled = false,
    @JsonKey(unknownEnumValue: MemberPlanType.free)
    this.plan = MemberPlanType.free,
    this.proExpiresAt,
    this.todayRandomSolvedCount = 0,
    this.dailyFreeLimit = 0,
    this.purchasableUntil,
  });

  factory _$MemberPlanResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$MemberPlanResponseImplFromJson(json);

  // 서버 결제 스위치 (false 면 서버가 모든 회원을 프로처럼 취급)
  @override
  @JsonKey()
  final bool isBillingEnabled;
  // 서버에 새 등급이 생겨도 깨지지 않게 모르는 값은 무료로 봄
  @override
  @JsonKey(unknownEnumValue: MemberPlanType.free)
  final MemberPlanType plan;
  // 프로 만료 시각 (KST, 무료면 null)
  @override
  final DateTime? proExpiresAt;
  // 오늘 제출한 서로 다른 랜덤 문제 수 (오늘의 문제 제외)
  @override
  @JsonKey()
  final int todayRandomSolvedCount;
  // 무료 하루 랜덤 문제 한도
  @override
  @JsonKey()
  final int dailyFreeLimit;
  // 지금 구매하면 이용할 수 있는 마지막 날 (다음 시험일, 없으면 null)
  @override
  final DateTime? purchasableUntil;

  @override
  String toString() {
    return 'MemberPlanResponse(isBillingEnabled: $isBillingEnabled, plan: $plan, proExpiresAt: $proExpiresAt, todayRandomSolvedCount: $todayRandomSolvedCount, dailyFreeLimit: $dailyFreeLimit, purchasableUntil: $purchasableUntil)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemberPlanResponseImpl &&
            (identical(other.isBillingEnabled, isBillingEnabled) ||
                other.isBillingEnabled == isBillingEnabled) &&
            (identical(other.plan, plan) || other.plan == plan) &&
            (identical(other.proExpiresAt, proExpiresAt) ||
                other.proExpiresAt == proExpiresAt) &&
            (identical(other.todayRandomSolvedCount, todayRandomSolvedCount) ||
                other.todayRandomSolvedCount == todayRandomSolvedCount) &&
            (identical(other.dailyFreeLimit, dailyFreeLimit) ||
                other.dailyFreeLimit == dailyFreeLimit) &&
            (identical(other.purchasableUntil, purchasableUntil) ||
                other.purchasableUntil == purchasableUntil));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    isBillingEnabled,
    plan,
    proExpiresAt,
    todayRandomSolvedCount,
    dailyFreeLimit,
    purchasableUntil,
  );

  /// Create a copy of MemberPlanResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemberPlanResponseImplCopyWith<_$MemberPlanResponseImpl> get copyWith =>
      __$$MemberPlanResponseImplCopyWithImpl<_$MemberPlanResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MemberPlanResponseImplToJson(this);
  }
}

abstract class _MemberPlanResponse implements MemberPlanResponse {
  const factory _MemberPlanResponse({
    final bool isBillingEnabled,
    @JsonKey(unknownEnumValue: MemberPlanType.free) final MemberPlanType plan,
    final DateTime? proExpiresAt,
    final int todayRandomSolvedCount,
    final int dailyFreeLimit,
    final DateTime? purchasableUntil,
  }) = _$MemberPlanResponseImpl;

  factory _MemberPlanResponse.fromJson(Map<String, dynamic> json) =
      _$MemberPlanResponseImpl.fromJson;

  // 서버 결제 스위치 (false 면 서버가 모든 회원을 프로처럼 취급)
  @override
  bool get isBillingEnabled; // 서버에 새 등급이 생겨도 깨지지 않게 모르는 값은 무료로 봄
  @override
  @JsonKey(unknownEnumValue: MemberPlanType.free)
  MemberPlanType get plan; // 프로 만료 시각 (KST, 무료면 null)
  @override
  DateTime? get proExpiresAt; // 오늘 제출한 서로 다른 랜덤 문제 수 (오늘의 문제 제외)
  @override
  int get todayRandomSolvedCount; // 무료 하루 랜덤 문제 한도
  @override
  int get dailyFreeLimit; // 지금 구매하면 이용할 수 있는 마지막 날 (다음 시험일, 없으면 null)
  @override
  DateTime? get purchasableUntil;

  /// Create a copy of MemberPlanResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemberPlanResponseImplCopyWith<_$MemberPlanResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
