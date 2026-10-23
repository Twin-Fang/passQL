// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_store_verify_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AppStoreVerifyRequest _$AppStoreVerifyRequestFromJson(
  Map<String, dynamic> json,
) {
  return _AppStoreVerifyRequest.fromJson(json);
}

/// @nodoc
mixin _$AppStoreVerifyRequest {
  String get productId => throw _privateConstructorUsedError;
  String get signedTransaction => throw _privateConstructorUsedError;

  /// Serializes this AppStoreVerifyRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppStoreVerifyRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppStoreVerifyRequestCopyWith<AppStoreVerifyRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppStoreVerifyRequestCopyWith<$Res> {
  factory $AppStoreVerifyRequestCopyWith(
    AppStoreVerifyRequest value,
    $Res Function(AppStoreVerifyRequest) then,
  ) = _$AppStoreVerifyRequestCopyWithImpl<$Res, AppStoreVerifyRequest>;
  @useResult
  $Res call({String productId, String signedTransaction});
}

/// @nodoc
class _$AppStoreVerifyRequestCopyWithImpl<
  $Res,
  $Val extends AppStoreVerifyRequest
>
    implements $AppStoreVerifyRequestCopyWith<$Res> {
  _$AppStoreVerifyRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppStoreVerifyRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? productId = null, Object? signedTransaction = null}) {
    return _then(
      _value.copyWith(
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            signedTransaction: null == signedTransaction
                ? _value.signedTransaction
                : signedTransaction // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppStoreVerifyRequestImplCopyWith<$Res>
    implements $AppStoreVerifyRequestCopyWith<$Res> {
  factory _$$AppStoreVerifyRequestImplCopyWith(
    _$AppStoreVerifyRequestImpl value,
    $Res Function(_$AppStoreVerifyRequestImpl) then,
  ) = __$$AppStoreVerifyRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String productId, String signedTransaction});
}

/// @nodoc
class __$$AppStoreVerifyRequestImplCopyWithImpl<$Res>
    extends
        _$AppStoreVerifyRequestCopyWithImpl<$Res, _$AppStoreVerifyRequestImpl>
    implements _$$AppStoreVerifyRequestImplCopyWith<$Res> {
  __$$AppStoreVerifyRequestImplCopyWithImpl(
    _$AppStoreVerifyRequestImpl _value,
    $Res Function(_$AppStoreVerifyRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppStoreVerifyRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? productId = null, Object? signedTransaction = null}) {
    return _then(
      _$AppStoreVerifyRequestImpl(
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        signedTransaction: null == signedTransaction
            ? _value.signedTransaction
            : signedTransaction // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppStoreVerifyRequestImpl implements _AppStoreVerifyRequest {
  const _$AppStoreVerifyRequestImpl({
    required this.productId,
    required this.signedTransaction,
  });

  factory _$AppStoreVerifyRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppStoreVerifyRequestImplFromJson(json);

  @override
  final String productId;
  @override
  final String signedTransaction;

  @override
  String toString() {
    return 'AppStoreVerifyRequest(productId: $productId, signedTransaction: $signedTransaction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppStoreVerifyRequestImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.signedTransaction, signedTransaction) ||
                other.signedTransaction == signedTransaction));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, productId, signedTransaction);

  /// Create a copy of AppStoreVerifyRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppStoreVerifyRequestImplCopyWith<_$AppStoreVerifyRequestImpl>
  get copyWith =>
      __$$AppStoreVerifyRequestImplCopyWithImpl<_$AppStoreVerifyRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AppStoreVerifyRequestImplToJson(this);
  }
}

abstract class _AppStoreVerifyRequest implements AppStoreVerifyRequest {
  const factory _AppStoreVerifyRequest({
    required final String productId,
    required final String signedTransaction,
  }) = _$AppStoreVerifyRequestImpl;

  factory _AppStoreVerifyRequest.fromJson(Map<String, dynamic> json) =
      _$AppStoreVerifyRequestImpl.fromJson;

  @override
  String get productId;
  @override
  String get signedTransaction;

  /// Create a copy of AppStoreVerifyRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppStoreVerifyRequestImplCopyWith<_$AppStoreVerifyRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
