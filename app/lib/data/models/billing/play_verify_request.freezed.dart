// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'play_verify_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PlayVerifyRequest _$PlayVerifyRequestFromJson(Map<String, dynamic> json) {
  return _PlayVerifyRequest.fromJson(json);
}

/// @nodoc
mixin _$PlayVerifyRequest {
  String get productId => throw _privateConstructorUsedError;
  String get purchaseToken => throw _privateConstructorUsedError;

  /// Serializes this PlayVerifyRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlayVerifyRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayVerifyRequestCopyWith<PlayVerifyRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayVerifyRequestCopyWith<$Res> {
  factory $PlayVerifyRequestCopyWith(
    PlayVerifyRequest value,
    $Res Function(PlayVerifyRequest) then,
  ) = _$PlayVerifyRequestCopyWithImpl<$Res, PlayVerifyRequest>;
  @useResult
  $Res call({String productId, String purchaseToken});
}

/// @nodoc
class _$PlayVerifyRequestCopyWithImpl<$Res, $Val extends PlayVerifyRequest>
    implements $PlayVerifyRequestCopyWith<$Res> {
  _$PlayVerifyRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlayVerifyRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? productId = null, Object? purchaseToken = null}) {
    return _then(
      _value.copyWith(
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            purchaseToken: null == purchaseToken
                ? _value.purchaseToken
                : purchaseToken // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlayVerifyRequestImplCopyWith<$Res>
    implements $PlayVerifyRequestCopyWith<$Res> {
  factory _$$PlayVerifyRequestImplCopyWith(
    _$PlayVerifyRequestImpl value,
    $Res Function(_$PlayVerifyRequestImpl) then,
  ) = __$$PlayVerifyRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String productId, String purchaseToken});
}

/// @nodoc
class __$$PlayVerifyRequestImplCopyWithImpl<$Res>
    extends _$PlayVerifyRequestCopyWithImpl<$Res, _$PlayVerifyRequestImpl>
    implements _$$PlayVerifyRequestImplCopyWith<$Res> {
  __$$PlayVerifyRequestImplCopyWithImpl(
    _$PlayVerifyRequestImpl _value,
    $Res Function(_$PlayVerifyRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlayVerifyRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? productId = null, Object? purchaseToken = null}) {
    return _then(
      _$PlayVerifyRequestImpl(
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        purchaseToken: null == purchaseToken
            ? _value.purchaseToken
            : purchaseToken // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayVerifyRequestImpl implements _PlayVerifyRequest {
  const _$PlayVerifyRequestImpl({
    required this.productId,
    required this.purchaseToken,
  });

  factory _$PlayVerifyRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayVerifyRequestImplFromJson(json);

  @override
  final String productId;
  @override
  final String purchaseToken;

  @override
  String toString() {
    return 'PlayVerifyRequest(productId: $productId, purchaseToken: $purchaseToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayVerifyRequestImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.purchaseToken, purchaseToken) ||
                other.purchaseToken == purchaseToken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, productId, purchaseToken);

  /// Create a copy of PlayVerifyRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayVerifyRequestImplCopyWith<_$PlayVerifyRequestImpl> get copyWith =>
      __$$PlayVerifyRequestImplCopyWithImpl<_$PlayVerifyRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayVerifyRequestImplToJson(this);
  }
}

abstract class _PlayVerifyRequest implements PlayVerifyRequest {
  const factory _PlayVerifyRequest({
    required final String productId,
    required final String purchaseToken,
  }) = _$PlayVerifyRequestImpl;

  factory _PlayVerifyRequest.fromJson(Map<String, dynamic> json) =
      _$PlayVerifyRequestImpl.fromJson;

  @override
  String get productId;
  @override
  String get purchaseToken;

  /// Create a copy of PlayVerifyRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayVerifyRequestImplCopyWith<_$PlayVerifyRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
