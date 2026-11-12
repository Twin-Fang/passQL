// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lock_screen_question_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LockScreenQuestionResponse _$LockScreenQuestionResponseFromJson(
  Map<String, dynamic> json,
) {
  return _LockScreenQuestionResponse.fromJson(json);
}

/// @nodoc
mixin _$LockScreenQuestionResponse {
  String get questionUuid => throw _privateConstructorUsedError;

  /// Serializes this LockScreenQuestionResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LockScreenQuestionResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LockScreenQuestionResponseCopyWith<LockScreenQuestionResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LockScreenQuestionResponseCopyWith<$Res> {
  factory $LockScreenQuestionResponseCopyWith(
    LockScreenQuestionResponse value,
    $Res Function(LockScreenQuestionResponse) then,
  ) =
      _$LockScreenQuestionResponseCopyWithImpl<
        $Res,
        LockScreenQuestionResponse
      >;
  @useResult
  $Res call({String questionUuid});
}

/// @nodoc
class _$LockScreenQuestionResponseCopyWithImpl<
  $Res,
  $Val extends LockScreenQuestionResponse
>
    implements $LockScreenQuestionResponseCopyWith<$Res> {
  _$LockScreenQuestionResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LockScreenQuestionResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? questionUuid = null}) {
    return _then(
      _value.copyWith(
            questionUuid: null == questionUuid
                ? _value.questionUuid
                : questionUuid // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LockScreenQuestionResponseImplCopyWith<$Res>
    implements $LockScreenQuestionResponseCopyWith<$Res> {
  factory _$$LockScreenQuestionResponseImplCopyWith(
    _$LockScreenQuestionResponseImpl value,
    $Res Function(_$LockScreenQuestionResponseImpl) then,
  ) = __$$LockScreenQuestionResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String questionUuid});
}

/// @nodoc
class __$$LockScreenQuestionResponseImplCopyWithImpl<$Res>
    extends
        _$LockScreenQuestionResponseCopyWithImpl<
          $Res,
          _$LockScreenQuestionResponseImpl
        >
    implements _$$LockScreenQuestionResponseImplCopyWith<$Res> {
  __$$LockScreenQuestionResponseImplCopyWithImpl(
    _$LockScreenQuestionResponseImpl _value,
    $Res Function(_$LockScreenQuestionResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LockScreenQuestionResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? questionUuid = null}) {
    return _then(
      _$LockScreenQuestionResponseImpl(
        questionUuid: null == questionUuid
            ? _value.questionUuid
            : questionUuid // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LockScreenQuestionResponseImpl implements _LockScreenQuestionResponse {
  const _$LockScreenQuestionResponseImpl({required this.questionUuid});

  factory _$LockScreenQuestionResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$LockScreenQuestionResponseImplFromJson(json);

  @override
  final String questionUuid;

  @override
  String toString() {
    return 'LockScreenQuestionResponse(questionUuid: $questionUuid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LockScreenQuestionResponseImpl &&
            (identical(other.questionUuid, questionUuid) ||
                other.questionUuid == questionUuid));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, questionUuid);

  /// Create a copy of LockScreenQuestionResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LockScreenQuestionResponseImplCopyWith<_$LockScreenQuestionResponseImpl>
  get copyWith =>
      __$$LockScreenQuestionResponseImplCopyWithImpl<
        _$LockScreenQuestionResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LockScreenQuestionResponseImplToJson(this);
  }
}

abstract class _LockScreenQuestionResponse
    implements LockScreenQuestionResponse {
  const factory _LockScreenQuestionResponse({
    required final String questionUuid,
  }) = _$LockScreenQuestionResponseImpl;

  factory _LockScreenQuestionResponse.fromJson(Map<String, dynamic> json) =
      _$LockScreenQuestionResponseImpl.fromJson;

  @override
  String get questionUuid;

  /// Create a copy of LockScreenQuestionResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LockScreenQuestionResponseImplCopyWith<_$LockScreenQuestionResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
