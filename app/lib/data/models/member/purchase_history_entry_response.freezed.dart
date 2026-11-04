// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase_history_entry_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PurchaseHistoryEntryResponse _$PurchaseHistoryEntryResponseFromJson(
  Map<String, dynamic> json,
) {
  return _PurchaseHistoryEntryResponse.fromJson(json);
}

/// @nodoc
mixin _$PurchaseHistoryEntryResponse {
  // 서버에 새 종류가 생겨도 깨지지 않게 모르는 값은 스토어 구매로 봄
  @JsonKey(unknownEnumValue: PurchaseHistoryKind.storePurchase)
  PurchaseHistoryKind get kind => throw _privateConstructorUsedError; // 구매·지급 시각 (KST)
  DateTime get purchasedAt =>
      throw _privateConstructorUsedError; // 스토어 상품 ID (운영 지급이면 null)
  String? get productId =>
      throw _privateConstructorUsedError; // 스토어 서버 값 PLAY·APP_STORE (운영 지급이면 null)
  String? get store =>
      throw _privateConstructorUsedError; // 구매 상태 서버 값 VERIFIED·REVOKED (운영 지급이면 null)
  String? get status =>
      throw _privateConstructorUsedError; // 이 구매·지급으로 정해진 프로 만료 시각 (KST)
  DateTime? get grantedExpiresAt =>
      throw _privateConstructorUsedError; // 더한 이용 일수 (모르면 null)
  int? get grantedDays =>
      throw _privateConstructorUsedError; // 결제 금액 x 1,000,000 (스토어가 알려 준 값만)
  int? get priceAmountMicros =>
      throw _privateConstructorUsedError; // 결제 통화 ISO 4217 (예: KRW)
  String? get currencyCode => throw _privateConstructorUsedError;

  /// Serializes this PurchaseHistoryEntryResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PurchaseHistoryEntryResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PurchaseHistoryEntryResponseCopyWith<PurchaseHistoryEntryResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchaseHistoryEntryResponseCopyWith<$Res> {
  factory $PurchaseHistoryEntryResponseCopyWith(
    PurchaseHistoryEntryResponse value,
    $Res Function(PurchaseHistoryEntryResponse) then,
  ) =
      _$PurchaseHistoryEntryResponseCopyWithImpl<
        $Res,
        PurchaseHistoryEntryResponse
      >;
  @useResult
  $Res call({
    @JsonKey(unknownEnumValue: PurchaseHistoryKind.storePurchase)
    PurchaseHistoryKind kind,
    DateTime purchasedAt,
    String? productId,
    String? store,
    String? status,
    DateTime? grantedExpiresAt,
    int? grantedDays,
    int? priceAmountMicros,
    String? currencyCode,
  });
}

/// @nodoc
class _$PurchaseHistoryEntryResponseCopyWithImpl<
  $Res,
  $Val extends PurchaseHistoryEntryResponse
>
    implements $PurchaseHistoryEntryResponseCopyWith<$Res> {
  _$PurchaseHistoryEntryResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PurchaseHistoryEntryResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kind = null,
    Object? purchasedAt = null,
    Object? productId = freezed,
    Object? store = freezed,
    Object? status = freezed,
    Object? grantedExpiresAt = freezed,
    Object? grantedDays = freezed,
    Object? priceAmountMicros = freezed,
    Object? currencyCode = freezed,
  }) {
    return _then(
      _value.copyWith(
            kind: null == kind
                ? _value.kind
                : kind // ignore: cast_nullable_to_non_nullable
                      as PurchaseHistoryKind,
            purchasedAt: null == purchasedAt
                ? _value.purchasedAt
                : purchasedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            productId: freezed == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String?,
            store: freezed == store
                ? _value.store
                : store // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            grantedExpiresAt: freezed == grantedExpiresAt
                ? _value.grantedExpiresAt
                : grantedExpiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            grantedDays: freezed == grantedDays
                ? _value.grantedDays
                : grantedDays // ignore: cast_nullable_to_non_nullable
                      as int?,
            priceAmountMicros: freezed == priceAmountMicros
                ? _value.priceAmountMicros
                : priceAmountMicros // ignore: cast_nullable_to_non_nullable
                      as int?,
            currencyCode: freezed == currencyCode
                ? _value.currencyCode
                : currencyCode // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PurchaseHistoryEntryResponseImplCopyWith<$Res>
    implements $PurchaseHistoryEntryResponseCopyWith<$Res> {
  factory _$$PurchaseHistoryEntryResponseImplCopyWith(
    _$PurchaseHistoryEntryResponseImpl value,
    $Res Function(_$PurchaseHistoryEntryResponseImpl) then,
  ) = __$$PurchaseHistoryEntryResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(unknownEnumValue: PurchaseHistoryKind.storePurchase)
    PurchaseHistoryKind kind,
    DateTime purchasedAt,
    String? productId,
    String? store,
    String? status,
    DateTime? grantedExpiresAt,
    int? grantedDays,
    int? priceAmountMicros,
    String? currencyCode,
  });
}

/// @nodoc
class __$$PurchaseHistoryEntryResponseImplCopyWithImpl<$Res>
    extends
        _$PurchaseHistoryEntryResponseCopyWithImpl<
          $Res,
          _$PurchaseHistoryEntryResponseImpl
        >
    implements _$$PurchaseHistoryEntryResponseImplCopyWith<$Res> {
  __$$PurchaseHistoryEntryResponseImplCopyWithImpl(
    _$PurchaseHistoryEntryResponseImpl _value,
    $Res Function(_$PurchaseHistoryEntryResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PurchaseHistoryEntryResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kind = null,
    Object? purchasedAt = null,
    Object? productId = freezed,
    Object? store = freezed,
    Object? status = freezed,
    Object? grantedExpiresAt = freezed,
    Object? grantedDays = freezed,
    Object? priceAmountMicros = freezed,
    Object? currencyCode = freezed,
  }) {
    return _then(
      _$PurchaseHistoryEntryResponseImpl(
        kind: null == kind
            ? _value.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as PurchaseHistoryKind,
        purchasedAt: null == purchasedAt
            ? _value.purchasedAt
            : purchasedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        productId: freezed == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String?,
        store: freezed == store
            ? _value.store
            : store // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        grantedExpiresAt: freezed == grantedExpiresAt
            ? _value.grantedExpiresAt
            : grantedExpiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        grantedDays: freezed == grantedDays
            ? _value.grantedDays
            : grantedDays // ignore: cast_nullable_to_non_nullable
                  as int?,
        priceAmountMicros: freezed == priceAmountMicros
            ? _value.priceAmountMicros
            : priceAmountMicros // ignore: cast_nullable_to_non_nullable
                  as int?,
        currencyCode: freezed == currencyCode
            ? _value.currencyCode
            : currencyCode // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PurchaseHistoryEntryResponseImpl extends _PurchaseHistoryEntryResponse {
  const _$PurchaseHistoryEntryResponseImpl({
    @JsonKey(unknownEnumValue: PurchaseHistoryKind.storePurchase)
    this.kind = PurchaseHistoryKind.storePurchase,
    required this.purchasedAt,
    this.productId,
    this.store,
    this.status,
    this.grantedExpiresAt,
    this.grantedDays,
    this.priceAmountMicros,
    this.currencyCode,
  }) : super._();

  factory _$PurchaseHistoryEntryResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$PurchaseHistoryEntryResponseImplFromJson(json);

  // 서버에 새 종류가 생겨도 깨지지 않게 모르는 값은 스토어 구매로 봄
  @override
  @JsonKey(unknownEnumValue: PurchaseHistoryKind.storePurchase)
  final PurchaseHistoryKind kind;
  // 구매·지급 시각 (KST)
  @override
  final DateTime purchasedAt;
  // 스토어 상품 ID (운영 지급이면 null)
  @override
  final String? productId;
  // 스토어 서버 값 PLAY·APP_STORE (운영 지급이면 null)
  @override
  final String? store;
  // 구매 상태 서버 값 VERIFIED·REVOKED (운영 지급이면 null)
  @override
  final String? status;
  // 이 구매·지급으로 정해진 프로 만료 시각 (KST)
  @override
  final DateTime? grantedExpiresAt;
  // 더한 이용 일수 (모르면 null)
  @override
  final int? grantedDays;
  // 결제 금액 x 1,000,000 (스토어가 알려 준 값만)
  @override
  final int? priceAmountMicros;
  // 결제 통화 ISO 4217 (예: KRW)
  @override
  final String? currencyCode;

  @override
  String toString() {
    return 'PurchaseHistoryEntryResponse(kind: $kind, purchasedAt: $purchasedAt, productId: $productId, store: $store, status: $status, grantedExpiresAt: $grantedExpiresAt, grantedDays: $grantedDays, priceAmountMicros: $priceAmountMicros, currencyCode: $currencyCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseHistoryEntryResponseImpl &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.purchasedAt, purchasedAt) ||
                other.purchasedAt == purchasedAt) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.store, store) || other.store == store) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.grantedExpiresAt, grantedExpiresAt) ||
                other.grantedExpiresAt == grantedExpiresAt) &&
            (identical(other.grantedDays, grantedDays) ||
                other.grantedDays == grantedDays) &&
            (identical(other.priceAmountMicros, priceAmountMicros) ||
                other.priceAmountMicros == priceAmountMicros) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    kind,
    purchasedAt,
    productId,
    store,
    status,
    grantedExpiresAt,
    grantedDays,
    priceAmountMicros,
    currencyCode,
  );

  /// Create a copy of PurchaseHistoryEntryResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchaseHistoryEntryResponseImplCopyWith<
    _$PurchaseHistoryEntryResponseImpl
  >
  get copyWith =>
      __$$PurchaseHistoryEntryResponseImplCopyWithImpl<
        _$PurchaseHistoryEntryResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PurchaseHistoryEntryResponseImplToJson(this);
  }
}

abstract class _PurchaseHistoryEntryResponse
    extends PurchaseHistoryEntryResponse {
  const factory _PurchaseHistoryEntryResponse({
    @JsonKey(unknownEnumValue: PurchaseHistoryKind.storePurchase)
    final PurchaseHistoryKind kind,
    required final DateTime purchasedAt,
    final String? productId,
    final String? store,
    final String? status,
    final DateTime? grantedExpiresAt,
    final int? grantedDays,
    final int? priceAmountMicros,
    final String? currencyCode,
  }) = _$PurchaseHistoryEntryResponseImpl;
  const _PurchaseHistoryEntryResponse._() : super._();

  factory _PurchaseHistoryEntryResponse.fromJson(Map<String, dynamic> json) =
      _$PurchaseHistoryEntryResponseImpl.fromJson;

  // 서버에 새 종류가 생겨도 깨지지 않게 모르는 값은 스토어 구매로 봄
  @override
  @JsonKey(unknownEnumValue: PurchaseHistoryKind.storePurchase)
  PurchaseHistoryKind get kind; // 구매·지급 시각 (KST)
  @override
  DateTime get purchasedAt; // 스토어 상품 ID (운영 지급이면 null)
  @override
  String? get productId; // 스토어 서버 값 PLAY·APP_STORE (운영 지급이면 null)
  @override
  String? get store; // 구매 상태 서버 값 VERIFIED·REVOKED (운영 지급이면 null)
  @override
  String? get status; // 이 구매·지급으로 정해진 프로 만료 시각 (KST)
  @override
  DateTime? get grantedExpiresAt; // 더한 이용 일수 (모르면 null)
  @override
  int? get grantedDays; // 결제 금액 x 1,000,000 (스토어가 알려 준 값만)
  @override
  int? get priceAmountMicros; // 결제 통화 ISO 4217 (예: KRW)
  @override
  String? get currencyCode;

  /// Create a copy of PurchaseHistoryEntryResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PurchaseHistoryEntryResponseImplCopyWith<
    _$PurchaseHistoryEntryResponseImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
