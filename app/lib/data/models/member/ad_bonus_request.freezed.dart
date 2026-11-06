// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ad_bonus_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AdBonusRequest _$AdBonusRequestFromJson(Map<String, dynamic> json) {
  return _AdBonusRequest.fromJson(json);
}

/// @nodoc
mixin _$AdBonusRequest {
  String? get rewardNonce => throw _privateConstructorUsedError;

  /// Serializes this AdBonusRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AdBonusRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdBonusRequestCopyWith<AdBonusRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdBonusRequestCopyWith<$Res> {
  factory $AdBonusRequestCopyWith(
    AdBonusRequest value,
    $Res Function(AdBonusRequest) then,
  ) = _$AdBonusRequestCopyWithImpl<$Res, AdBonusRequest>;
  @useResult
  $Res call({String? rewardNonce});
}

/// @nodoc
class _$AdBonusRequestCopyWithImpl<$Res, $Val extends AdBonusRequest>
    implements $AdBonusRequestCopyWith<$Res> {
  _$AdBonusRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdBonusRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rewardNonce = freezed}) {
    return _then(
      _value.copyWith(
            rewardNonce: freezed == rewardNonce
                ? _value.rewardNonce
                : rewardNonce // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdBonusRequestImplCopyWith<$Res>
    implements $AdBonusRequestCopyWith<$Res> {
  factory _$$AdBonusRequestImplCopyWith(
    _$AdBonusRequestImpl value,
    $Res Function(_$AdBonusRequestImpl) then,
  ) = __$$AdBonusRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? rewardNonce});
}

/// @nodoc
class __$$AdBonusRequestImplCopyWithImpl<$Res>
    extends _$AdBonusRequestCopyWithImpl<$Res, _$AdBonusRequestImpl>
    implements _$$AdBonusRequestImplCopyWith<$Res> {
  __$$AdBonusRequestImplCopyWithImpl(
    _$AdBonusRequestImpl _value,
    $Res Function(_$AdBonusRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdBonusRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rewardNonce = freezed}) {
    return _then(
      _$AdBonusRequestImpl(
        rewardNonce: freezed == rewardNonce
            ? _value.rewardNonce
            : rewardNonce // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AdBonusRequestImpl implements _AdBonusRequest {
  const _$AdBonusRequestImpl({this.rewardNonce});

  factory _$AdBonusRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdBonusRequestImplFromJson(json);

  @override
  final String? rewardNonce;

  @override
  String toString() {
    return 'AdBonusRequest(rewardNonce: $rewardNonce)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdBonusRequestImpl &&
            (identical(other.rewardNonce, rewardNonce) ||
                other.rewardNonce == rewardNonce));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, rewardNonce);

  /// Create a copy of AdBonusRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdBonusRequestImplCopyWith<_$AdBonusRequestImpl> get copyWith =>
      __$$AdBonusRequestImplCopyWithImpl<_$AdBonusRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AdBonusRequestImplToJson(this);
  }
}

abstract class _AdBonusRequest implements AdBonusRequest {
  const factory _AdBonusRequest({final String? rewardNonce}) =
      _$AdBonusRequestImpl;

  factory _AdBonusRequest.fromJson(Map<String, dynamic> json) =
      _$AdBonusRequestImpl.fromJson;

  @override
  String? get rewardNonce;

  /// Create a copy of AdBonusRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdBonusRequestImplCopyWith<_$AdBonusRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
