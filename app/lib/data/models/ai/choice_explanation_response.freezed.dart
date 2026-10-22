// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'choice_explanation_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChoiceExplanationResponse _$ChoiceExplanationResponseFromJson(
  Map<String, dynamic> json,
) {
  return _ChoiceExplanationResponse.fromJson(json);
}

/// @nodoc
mixin _$ChoiceExplanationResponse {
  String get choiceSetUuid => throw _privateConstructorUsedError;
  String get selectedChoiceKey =>
      throw _privateConstructorUsedError; // 서버에 상태가 추가돼도 깨지지 않게 모르는 값은 실패로 봄
  @JsonKey(unknownEnumValue: ChoiceExplanationStatus.failed)
  ChoiceExplanationStatus get status => throw _privateConstructorUsedError; // READY 의 구조화 해설 (고정 세트·옛 해설이면 null)
  ChoiceExplanation? get explanation =>
      throw _privateConstructorUsedError; // 마크다운 해설: READY 는 항상, GENERATING·FAILED 는 옛 해설 있으면 임시 표시용
  String? get text =>
      throw _privateConstructorUsedError; // GENERATING 일 때 다시 조회할 간격
  int? get retryAfterMilliseconds => throw _privateConstructorUsedError;
  int? get promptVersion =>
      throw _privateConstructorUsedError; // 무료 응답에서 뺀 묶음 이름 (FULL_EXPLANATION), 없으면 빈 목록
  List<String> get lockedSections => throw _privateConstructorUsedError;

  /// Serializes this ChoiceExplanationResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChoiceExplanationResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChoiceExplanationResponseCopyWith<ChoiceExplanationResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChoiceExplanationResponseCopyWith<$Res> {
  factory $ChoiceExplanationResponseCopyWith(
    ChoiceExplanationResponse value,
    $Res Function(ChoiceExplanationResponse) then,
  ) = _$ChoiceExplanationResponseCopyWithImpl<$Res, ChoiceExplanationResponse>;
  @useResult
  $Res call({
    String choiceSetUuid,
    String selectedChoiceKey,
    @JsonKey(unknownEnumValue: ChoiceExplanationStatus.failed)
    ChoiceExplanationStatus status,
    ChoiceExplanation? explanation,
    String? text,
    int? retryAfterMilliseconds,
    int? promptVersion,
    List<String> lockedSections,
  });

  $ChoiceExplanationCopyWith<$Res>? get explanation;
}

/// @nodoc
class _$ChoiceExplanationResponseCopyWithImpl<
  $Res,
  $Val extends ChoiceExplanationResponse
>
    implements $ChoiceExplanationResponseCopyWith<$Res> {
  _$ChoiceExplanationResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChoiceExplanationResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? choiceSetUuid = null,
    Object? selectedChoiceKey = null,
    Object? status = null,
    Object? explanation = freezed,
    Object? text = freezed,
    Object? retryAfterMilliseconds = freezed,
    Object? promptVersion = freezed,
    Object? lockedSections = null,
  }) {
    return _then(
      _value.copyWith(
            choiceSetUuid: null == choiceSetUuid
                ? _value.choiceSetUuid
                : choiceSetUuid // ignore: cast_nullable_to_non_nullable
                      as String,
            selectedChoiceKey: null == selectedChoiceKey
                ? _value.selectedChoiceKey
                : selectedChoiceKey // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ChoiceExplanationStatus,
            explanation: freezed == explanation
                ? _value.explanation
                : explanation // ignore: cast_nullable_to_non_nullable
                      as ChoiceExplanation?,
            text: freezed == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String?,
            retryAfterMilliseconds: freezed == retryAfterMilliseconds
                ? _value.retryAfterMilliseconds
                : retryAfterMilliseconds // ignore: cast_nullable_to_non_nullable
                      as int?,
            promptVersion: freezed == promptVersion
                ? _value.promptVersion
                : promptVersion // ignore: cast_nullable_to_non_nullable
                      as int?,
            lockedSections: null == lockedSections
                ? _value.lockedSections
                : lockedSections // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }

  /// Create a copy of ChoiceExplanationResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChoiceExplanationCopyWith<$Res>? get explanation {
    if (_value.explanation == null) {
      return null;
    }

    return $ChoiceExplanationCopyWith<$Res>(_value.explanation!, (value) {
      return _then(_value.copyWith(explanation: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChoiceExplanationResponseImplCopyWith<$Res>
    implements $ChoiceExplanationResponseCopyWith<$Res> {
  factory _$$ChoiceExplanationResponseImplCopyWith(
    _$ChoiceExplanationResponseImpl value,
    $Res Function(_$ChoiceExplanationResponseImpl) then,
  ) = __$$ChoiceExplanationResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String choiceSetUuid,
    String selectedChoiceKey,
    @JsonKey(unknownEnumValue: ChoiceExplanationStatus.failed)
    ChoiceExplanationStatus status,
    ChoiceExplanation? explanation,
    String? text,
    int? retryAfterMilliseconds,
    int? promptVersion,
    List<String> lockedSections,
  });

  @override
  $ChoiceExplanationCopyWith<$Res>? get explanation;
}

/// @nodoc
class __$$ChoiceExplanationResponseImplCopyWithImpl<$Res>
    extends
        _$ChoiceExplanationResponseCopyWithImpl<
          $Res,
          _$ChoiceExplanationResponseImpl
        >
    implements _$$ChoiceExplanationResponseImplCopyWith<$Res> {
  __$$ChoiceExplanationResponseImplCopyWithImpl(
    _$ChoiceExplanationResponseImpl _value,
    $Res Function(_$ChoiceExplanationResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChoiceExplanationResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? choiceSetUuid = null,
    Object? selectedChoiceKey = null,
    Object? status = null,
    Object? explanation = freezed,
    Object? text = freezed,
    Object? retryAfterMilliseconds = freezed,
    Object? promptVersion = freezed,
    Object? lockedSections = null,
  }) {
    return _then(
      _$ChoiceExplanationResponseImpl(
        choiceSetUuid: null == choiceSetUuid
            ? _value.choiceSetUuid
            : choiceSetUuid // ignore: cast_nullable_to_non_nullable
                  as String,
        selectedChoiceKey: null == selectedChoiceKey
            ? _value.selectedChoiceKey
            : selectedChoiceKey // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ChoiceExplanationStatus,
        explanation: freezed == explanation
            ? _value.explanation
            : explanation // ignore: cast_nullable_to_non_nullable
                  as ChoiceExplanation?,
        text: freezed == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String?,
        retryAfterMilliseconds: freezed == retryAfterMilliseconds
            ? _value.retryAfterMilliseconds
            : retryAfterMilliseconds // ignore: cast_nullable_to_non_nullable
                  as int?,
        promptVersion: freezed == promptVersion
            ? _value.promptVersion
            : promptVersion // ignore: cast_nullable_to_non_nullable
                  as int?,
        lockedSections: null == lockedSections
            ? _value._lockedSections
            : lockedSections // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChoiceExplanationResponseImpl implements _ChoiceExplanationResponse {
  const _$ChoiceExplanationResponseImpl({
    this.choiceSetUuid = '',
    this.selectedChoiceKey = '',
    @JsonKey(unknownEnumValue: ChoiceExplanationStatus.failed)
    this.status = ChoiceExplanationStatus.failed,
    this.explanation,
    this.text,
    this.retryAfterMilliseconds,
    this.promptVersion,
    final List<String> lockedSections = const [],
  }) : _lockedSections = lockedSections;

  factory _$ChoiceExplanationResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChoiceExplanationResponseImplFromJson(json);

  @override
  @JsonKey()
  final String choiceSetUuid;
  @override
  @JsonKey()
  final String selectedChoiceKey;
  // 서버에 상태가 추가돼도 깨지지 않게 모르는 값은 실패로 봄
  @override
  @JsonKey(unknownEnumValue: ChoiceExplanationStatus.failed)
  final ChoiceExplanationStatus status;
  // READY 의 구조화 해설 (고정 세트·옛 해설이면 null)
  @override
  final ChoiceExplanation? explanation;
  // 마크다운 해설: READY 는 항상, GENERATING·FAILED 는 옛 해설 있으면 임시 표시용
  @override
  final String? text;
  // GENERATING 일 때 다시 조회할 간격
  @override
  final int? retryAfterMilliseconds;
  @override
  final int? promptVersion;
  // 무료 응답에서 뺀 묶음 이름 (FULL_EXPLANATION), 없으면 빈 목록
  final List<String> _lockedSections;
  // 무료 응답에서 뺀 묶음 이름 (FULL_EXPLANATION), 없으면 빈 목록
  @override
  @JsonKey()
  List<String> get lockedSections {
    if (_lockedSections is EqualUnmodifiableListView) return _lockedSections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lockedSections);
  }

  @override
  String toString() {
    return 'ChoiceExplanationResponse(choiceSetUuid: $choiceSetUuid, selectedChoiceKey: $selectedChoiceKey, status: $status, explanation: $explanation, text: $text, retryAfterMilliseconds: $retryAfterMilliseconds, promptVersion: $promptVersion, lockedSections: $lockedSections)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChoiceExplanationResponseImpl &&
            (identical(other.choiceSetUuid, choiceSetUuid) ||
                other.choiceSetUuid == choiceSetUuid) &&
            (identical(other.selectedChoiceKey, selectedChoiceKey) ||
                other.selectedChoiceKey == selectedChoiceKey) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.retryAfterMilliseconds, retryAfterMilliseconds) ||
                other.retryAfterMilliseconds == retryAfterMilliseconds) &&
            (identical(other.promptVersion, promptVersion) ||
                other.promptVersion == promptVersion) &&
            const DeepCollectionEquality().equals(
              other._lockedSections,
              _lockedSections,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    choiceSetUuid,
    selectedChoiceKey,
    status,
    explanation,
    text,
    retryAfterMilliseconds,
    promptVersion,
    const DeepCollectionEquality().hash(_lockedSections),
  );

  /// Create a copy of ChoiceExplanationResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChoiceExplanationResponseImplCopyWith<_$ChoiceExplanationResponseImpl>
  get copyWith =>
      __$$ChoiceExplanationResponseImplCopyWithImpl<
        _$ChoiceExplanationResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChoiceExplanationResponseImplToJson(this);
  }
}

abstract class _ChoiceExplanationResponse implements ChoiceExplanationResponse {
  const factory _ChoiceExplanationResponse({
    final String choiceSetUuid,
    final String selectedChoiceKey,
    @JsonKey(unknownEnumValue: ChoiceExplanationStatus.failed)
    final ChoiceExplanationStatus status,
    final ChoiceExplanation? explanation,
    final String? text,
    final int? retryAfterMilliseconds,
    final int? promptVersion,
    final List<String> lockedSections,
  }) = _$ChoiceExplanationResponseImpl;

  factory _ChoiceExplanationResponse.fromJson(Map<String, dynamic> json) =
      _$ChoiceExplanationResponseImpl.fromJson;

  @override
  String get choiceSetUuid;
  @override
  String get selectedChoiceKey; // 서버에 상태가 추가돼도 깨지지 않게 모르는 값은 실패로 봄
  @override
  @JsonKey(unknownEnumValue: ChoiceExplanationStatus.failed)
  ChoiceExplanationStatus get status; // READY 의 구조화 해설 (고정 세트·옛 해설이면 null)
  @override
  ChoiceExplanation? get explanation; // 마크다운 해설: READY 는 항상, GENERATING·FAILED 는 옛 해설 있으면 임시 표시용
  @override
  String? get text; // GENERATING 일 때 다시 조회할 간격
  @override
  int? get retryAfterMilliseconds;
  @override
  int? get promptVersion; // 무료 응답에서 뺀 묶음 이름 (FULL_EXPLANATION), 없으면 빈 목록
  @override
  List<String> get lockedSections;

  /// Create a copy of ChoiceExplanationResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChoiceExplanationResponseImplCopyWith<_$ChoiceExplanationResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
