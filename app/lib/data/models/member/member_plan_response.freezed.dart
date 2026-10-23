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
      throw _privateConstructorUsedError; // deprecated: 옛 앱(1.36·1.37) 호환용 3개월권 예상 만료일. 화면은 passOptions 사용
  DateTime? get purchasableUntil =>
      throw _privateConstructorUsedError; // 구매할 수 있는 이용권 (서버 순서: 3개월 먼저, 결제 꺼짐·상품 없음이면 빈 목록)
  List<PassOption> get passOptions =>
      throw _privateConstructorUsedError; // 가장 최근 검증 구매 시각 (KST, 구매 없음·관리자 부여만 있으면 null)
  DateTime? get lastPurchasedAt =>
      throw _privateConstructorUsedError; // 가장 최근 검증 구매의 Play 주문 번호 (구매 없음·관리자 부여만 있으면 null)
  String? get lastOrderId => throw _privateConstructorUsedError;

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
    List<PassOption> passOptions,
    DateTime? lastPurchasedAt,
    String? lastOrderId,
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
    Object? passOptions = null,
    Object? lastPurchasedAt = freezed,
    Object? lastOrderId = freezed,
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
            passOptions: null == passOptions
                ? _value.passOptions
                : passOptions // ignore: cast_nullable_to_non_nullable
                      as List<PassOption>,
            lastPurchasedAt: freezed == lastPurchasedAt
                ? _value.lastPurchasedAt
                : lastPurchasedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastOrderId: freezed == lastOrderId
                ? _value.lastOrderId
                : lastOrderId // ignore: cast_nullable_to_non_nullable
                      as String?,
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
    List<PassOption> passOptions,
    DateTime? lastPurchasedAt,
    String? lastOrderId,
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
    Object? passOptions = null,
    Object? lastPurchasedAt = freezed,
    Object? lastOrderId = freezed,
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
        passOptions: null == passOptions
            ? _value._passOptions
            : passOptions // ignore: cast_nullable_to_non_nullable
                  as List<PassOption>,
        lastPurchasedAt: freezed == lastPurchasedAt
            ? _value.lastPurchasedAt
            : lastPurchasedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastOrderId: freezed == lastOrderId
            ? _value.lastOrderId
            : lastOrderId // ignore: cast_nullable_to_non_nullable
                  as String?,
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
    final List<PassOption> passOptions = const <PassOption>[],
    this.lastPurchasedAt,
    this.lastOrderId,
  }) : _passOptions = passOptions;

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
  // deprecated: 옛 앱(1.36·1.37) 호환용 3개월권 예상 만료일. 화면은 passOptions 사용
  @override
  final DateTime? purchasableUntil;
  // 구매할 수 있는 이용권 (서버 순서: 3개월 먼저, 결제 꺼짐·상품 없음이면 빈 목록)
  final List<PassOption> _passOptions;
  // 구매할 수 있는 이용권 (서버 순서: 3개월 먼저, 결제 꺼짐·상품 없음이면 빈 목록)
  @override
  @JsonKey()
  List<PassOption> get passOptions {
    if (_passOptions is EqualUnmodifiableListView) return _passOptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_passOptions);
  }

  // 가장 최근 검증 구매 시각 (KST, 구매 없음·관리자 부여만 있으면 null)
  @override
  final DateTime? lastPurchasedAt;
  // 가장 최근 검증 구매의 Play 주문 번호 (구매 없음·관리자 부여만 있으면 null)
  @override
  final String? lastOrderId;

  @override
  String toString() {
    return 'MemberPlanResponse(isBillingEnabled: $isBillingEnabled, plan: $plan, proExpiresAt: $proExpiresAt, todayRandomSolvedCount: $todayRandomSolvedCount, dailyFreeLimit: $dailyFreeLimit, purchasableUntil: $purchasableUntil, passOptions: $passOptions, lastPurchasedAt: $lastPurchasedAt, lastOrderId: $lastOrderId)';
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
                other.purchasableUntil == purchasableUntil) &&
            const DeepCollectionEquality().equals(
              other._passOptions,
              _passOptions,
            ) &&
            (identical(other.lastPurchasedAt, lastPurchasedAt) ||
                other.lastPurchasedAt == lastPurchasedAt) &&
            (identical(other.lastOrderId, lastOrderId) ||
                other.lastOrderId == lastOrderId));
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
    const DeepCollectionEquality().hash(_passOptions),
    lastPurchasedAt,
    lastOrderId,
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
    final List<PassOption> passOptions,
    final DateTime? lastPurchasedAt,
    final String? lastOrderId,
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
  int get dailyFreeLimit; // deprecated: 옛 앱(1.36·1.37) 호환용 3개월권 예상 만료일. 화면은 passOptions 사용
  @override
  DateTime? get purchasableUntil; // 구매할 수 있는 이용권 (서버 순서: 3개월 먼저, 결제 꺼짐·상품 없음이면 빈 목록)
  @override
  List<PassOption> get passOptions; // 가장 최근 검증 구매 시각 (KST, 구매 없음·관리자 부여만 있으면 null)
  @override
  DateTime? get lastPurchasedAt; // 가장 최근 검증 구매의 Play 주문 번호 (구매 없음·관리자 부여만 있으면 null)
  @override
  String? get lastOrderId;

  /// Create a copy of MemberPlanResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemberPlanResponseImplCopyWith<_$MemberPlanResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PassOption _$PassOptionFromJson(Map<String, dynamic> json) {
  return _PassOption.fromJson(json);
}

/// @nodoc
mixin _$PassOption {
  // Play 일회성 상품 ID (예: pro_pass_3m)
  String get productId =>
      throw _privateConstructorUsedError; // 이용 일수 (30 = 1개월, 90 = 3개월)
  int get durationDays =>
      throw _privateConstructorUsedError; // 지금 구매하면 될 만료 시각 (보유 중이면 현재 만료일에 이어 붙인 값)
  DateTime get expiresAtIfPurchased => throw _privateConstructorUsedError;

  /// Serializes this PassOption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PassOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PassOptionCopyWith<PassOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PassOptionCopyWith<$Res> {
  factory $PassOptionCopyWith(
    PassOption value,
    $Res Function(PassOption) then,
  ) = _$PassOptionCopyWithImpl<$Res, PassOption>;
  @useResult
  $Res call({
    String productId,
    int durationDays,
    DateTime expiresAtIfPurchased,
  });
}

/// @nodoc
class _$PassOptionCopyWithImpl<$Res, $Val extends PassOption>
    implements $PassOptionCopyWith<$Res> {
  _$PassOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PassOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? durationDays = null,
    Object? expiresAtIfPurchased = null,
  }) {
    return _then(
      _value.copyWith(
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            durationDays: null == durationDays
                ? _value.durationDays
                : durationDays // ignore: cast_nullable_to_non_nullable
                      as int,
            expiresAtIfPurchased: null == expiresAtIfPurchased
                ? _value.expiresAtIfPurchased
                : expiresAtIfPurchased // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PassOptionImplCopyWith<$Res>
    implements $PassOptionCopyWith<$Res> {
  factory _$$PassOptionImplCopyWith(
    _$PassOptionImpl value,
    $Res Function(_$PassOptionImpl) then,
  ) = __$$PassOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String productId,
    int durationDays,
    DateTime expiresAtIfPurchased,
  });
}

/// @nodoc
class __$$PassOptionImplCopyWithImpl<$Res>
    extends _$PassOptionCopyWithImpl<$Res, _$PassOptionImpl>
    implements _$$PassOptionImplCopyWith<$Res> {
  __$$PassOptionImplCopyWithImpl(
    _$PassOptionImpl _value,
    $Res Function(_$PassOptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PassOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? durationDays = null,
    Object? expiresAtIfPurchased = null,
  }) {
    return _then(
      _$PassOptionImpl(
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        durationDays: null == durationDays
            ? _value.durationDays
            : durationDays // ignore: cast_nullable_to_non_nullable
                  as int,
        expiresAtIfPurchased: null == expiresAtIfPurchased
            ? _value.expiresAtIfPurchased
            : expiresAtIfPurchased // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PassOptionImpl implements _PassOption {
  const _$PassOptionImpl({
    required this.productId,
    required this.durationDays,
    required this.expiresAtIfPurchased,
  });

  factory _$PassOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PassOptionImplFromJson(json);

  // Play 일회성 상품 ID (예: pro_pass_3m)
  @override
  final String productId;
  // 이용 일수 (30 = 1개월, 90 = 3개월)
  @override
  final int durationDays;
  // 지금 구매하면 될 만료 시각 (보유 중이면 현재 만료일에 이어 붙인 값)
  @override
  final DateTime expiresAtIfPurchased;

  @override
  String toString() {
    return 'PassOption(productId: $productId, durationDays: $durationDays, expiresAtIfPurchased: $expiresAtIfPurchased)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PassOptionImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.durationDays, durationDays) ||
                other.durationDays == durationDays) &&
            (identical(other.expiresAtIfPurchased, expiresAtIfPurchased) ||
                other.expiresAtIfPurchased == expiresAtIfPurchased));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, productId, durationDays, expiresAtIfPurchased);

  /// Create a copy of PassOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PassOptionImplCopyWith<_$PassOptionImpl> get copyWith =>
      __$$PassOptionImplCopyWithImpl<_$PassOptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PassOptionImplToJson(this);
  }
}

abstract class _PassOption implements PassOption {
  const factory _PassOption({
    required final String productId,
    required final int durationDays,
    required final DateTime expiresAtIfPurchased,
  }) = _$PassOptionImpl;

  factory _PassOption.fromJson(Map<String, dynamic> json) =
      _$PassOptionImpl.fromJson;

  // Play 일회성 상품 ID (예: pro_pass_3m)
  @override
  String get productId; // 이용 일수 (30 = 1개월, 90 = 3개월)
  @override
  int get durationDays; // 지금 구매하면 될 만료 시각 (보유 중이면 현재 만료일에 이어 붙인 값)
  @override
  DateTime get expiresAtIfPurchased;

  /// Create a copy of PassOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PassOptionImplCopyWith<_$PassOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
