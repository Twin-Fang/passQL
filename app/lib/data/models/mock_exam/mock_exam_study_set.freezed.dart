// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mock_exam_study_set.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MockExamStudySetResponse _$MockExamStudySetResponseFromJson(
  Map<String, dynamic> json,
) {
  return _MockExamStudySetResponse.fromJson(json);
}

/// @nodoc
mixin _$MockExamStudySetResponse {
  String get roundUuid => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  List<String> get questionUuids => throw _privateConstructorUsedError;

  /// Serializes this MockExamStudySetResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MockExamStudySetResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MockExamStudySetResponseCopyWith<MockExamStudySetResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MockExamStudySetResponseCopyWith<$Res> {
  factory $MockExamStudySetResponseCopyWith(
    MockExamStudySetResponse value,
    $Res Function(MockExamStudySetResponse) then,
  ) = _$MockExamStudySetResponseCopyWithImpl<$Res, MockExamStudySetResponse>;
  @useResult
  $Res call({String roundUuid, String title, List<String> questionUuids});
}

/// @nodoc
class _$MockExamStudySetResponseCopyWithImpl<
  $Res,
  $Val extends MockExamStudySetResponse
>
    implements $MockExamStudySetResponseCopyWith<$Res> {
  _$MockExamStudySetResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MockExamStudySetResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roundUuid = null,
    Object? title = null,
    Object? questionUuids = null,
  }) {
    return _then(
      _value.copyWith(
            roundUuid: null == roundUuid
                ? _value.roundUuid
                : roundUuid // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            questionUuids: null == questionUuids
                ? _value.questionUuids
                : questionUuids // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MockExamStudySetResponseImplCopyWith<$Res>
    implements $MockExamStudySetResponseCopyWith<$Res> {
  factory _$$MockExamStudySetResponseImplCopyWith(
    _$MockExamStudySetResponseImpl value,
    $Res Function(_$MockExamStudySetResponseImpl) then,
  ) = __$$MockExamStudySetResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String roundUuid, String title, List<String> questionUuids});
}

/// @nodoc
class __$$MockExamStudySetResponseImplCopyWithImpl<$Res>
    extends
        _$MockExamStudySetResponseCopyWithImpl<
          $Res,
          _$MockExamStudySetResponseImpl
        >
    implements _$$MockExamStudySetResponseImplCopyWith<$Res> {
  __$$MockExamStudySetResponseImplCopyWithImpl(
    _$MockExamStudySetResponseImpl _value,
    $Res Function(_$MockExamStudySetResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MockExamStudySetResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roundUuid = null,
    Object? title = null,
    Object? questionUuids = null,
  }) {
    return _then(
      _$MockExamStudySetResponseImpl(
        roundUuid: null == roundUuid
            ? _value.roundUuid
            : roundUuid // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        questionUuids: null == questionUuids
            ? _value._questionUuids
            : questionUuids // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MockExamStudySetResponseImpl implements _MockExamStudySetResponse {
  const _$MockExamStudySetResponseImpl({
    required this.roundUuid,
    required this.title,
    required final List<String> questionUuids,
  }) : _questionUuids = questionUuids;

  factory _$MockExamStudySetResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$MockExamStudySetResponseImplFromJson(json);

  @override
  final String roundUuid;
  @override
  final String title;
  final List<String> _questionUuids;
  @override
  List<String> get questionUuids {
    if (_questionUuids is EqualUnmodifiableListView) return _questionUuids;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questionUuids);
  }

  @override
  String toString() {
    return 'MockExamStudySetResponse(roundUuid: $roundUuid, title: $title, questionUuids: $questionUuids)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamStudySetResponseImpl &&
            (identical(other.roundUuid, roundUuid) ||
                other.roundUuid == roundUuid) &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality().equals(
              other._questionUuids,
              _questionUuids,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    roundUuid,
    title,
    const DeepCollectionEquality().hash(_questionUuids),
  );

  /// Create a copy of MockExamStudySetResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MockExamStudySetResponseImplCopyWith<_$MockExamStudySetResponseImpl>
  get copyWith =>
      __$$MockExamStudySetResponseImplCopyWithImpl<
        _$MockExamStudySetResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MockExamStudySetResponseImplToJson(this);
  }
}

abstract class _MockExamStudySetResponse implements MockExamStudySetResponse {
  const factory _MockExamStudySetResponse({
    required final String roundUuid,
    required final String title,
    required final List<String> questionUuids,
  }) = _$MockExamStudySetResponseImpl;

  factory _MockExamStudySetResponse.fromJson(Map<String, dynamic> json) =
      _$MockExamStudySetResponseImpl.fromJson;

  @override
  String get roundUuid;
  @override
  String get title;
  @override
  List<String> get questionUuids;

  /// Create a copy of MockExamStudySetResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamStudySetResponseImplCopyWith<_$MockExamStudySetResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
