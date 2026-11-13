// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'explanation_outline.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExplanationOutline _$ExplanationOutlineFromJson(Map<String, dynamic> json) {
  return _ExplanationOutline.fromJson(json);
}

/// @nodoc
mixin _$ExplanationOutline {
  int get choiceCount => throw _privateConstructorUsedError;
  List<ExplanationOutlineSection> get sections =>
      throw _privateConstructorUsedError;

  /// Serializes this ExplanationOutline to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExplanationOutline
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExplanationOutlineCopyWith<ExplanationOutline> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExplanationOutlineCopyWith<$Res> {
  factory $ExplanationOutlineCopyWith(
    ExplanationOutline value,
    $Res Function(ExplanationOutline) then,
  ) = _$ExplanationOutlineCopyWithImpl<$Res, ExplanationOutline>;
  @useResult
  $Res call({int choiceCount, List<ExplanationOutlineSection> sections});
}

/// @nodoc
class _$ExplanationOutlineCopyWithImpl<$Res, $Val extends ExplanationOutline>
    implements $ExplanationOutlineCopyWith<$Res> {
  _$ExplanationOutlineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExplanationOutline
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? choiceCount = null, Object? sections = null}) {
    return _then(
      _value.copyWith(
            choiceCount: null == choiceCount
                ? _value.choiceCount
                : choiceCount // ignore: cast_nullable_to_non_nullable
                      as int,
            sections: null == sections
                ? _value.sections
                : sections // ignore: cast_nullable_to_non_nullable
                      as List<ExplanationOutlineSection>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExplanationOutlineImplCopyWith<$Res>
    implements $ExplanationOutlineCopyWith<$Res> {
  factory _$$ExplanationOutlineImplCopyWith(
    _$ExplanationOutlineImpl value,
    $Res Function(_$ExplanationOutlineImpl) then,
  ) = __$$ExplanationOutlineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int choiceCount, List<ExplanationOutlineSection> sections});
}

/// @nodoc
class __$$ExplanationOutlineImplCopyWithImpl<$Res>
    extends _$ExplanationOutlineCopyWithImpl<$Res, _$ExplanationOutlineImpl>
    implements _$$ExplanationOutlineImplCopyWith<$Res> {
  __$$ExplanationOutlineImplCopyWithImpl(
    _$ExplanationOutlineImpl _value,
    $Res Function(_$ExplanationOutlineImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExplanationOutline
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? choiceCount = null, Object? sections = null}) {
    return _then(
      _$ExplanationOutlineImpl(
        choiceCount: null == choiceCount
            ? _value.choiceCount
            : choiceCount // ignore: cast_nullable_to_non_nullable
                  as int,
        sections: null == sections
            ? _value._sections
            : sections // ignore: cast_nullable_to_non_nullable
                  as List<ExplanationOutlineSection>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExplanationOutlineImpl implements _ExplanationOutline {
  const _$ExplanationOutlineImpl({
    this.choiceCount = 0,
    final List<ExplanationOutlineSection> sections = const [],
  }) : _sections = sections;

  factory _$ExplanationOutlineImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExplanationOutlineImplFromJson(json);

  @override
  @JsonKey()
  final int choiceCount;
  final List<ExplanationOutlineSection> _sections;
  @override
  @JsonKey()
  List<ExplanationOutlineSection> get sections {
    if (_sections is EqualUnmodifiableListView) return _sections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sections);
  }

  @override
  String toString() {
    return 'ExplanationOutline(choiceCount: $choiceCount, sections: $sections)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExplanationOutlineImpl &&
            (identical(other.choiceCount, choiceCount) ||
                other.choiceCount == choiceCount) &&
            const DeepCollectionEquality().equals(other._sections, _sections));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    choiceCount,
    const DeepCollectionEquality().hash(_sections),
  );

  /// Create a copy of ExplanationOutline
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExplanationOutlineImplCopyWith<_$ExplanationOutlineImpl> get copyWith =>
      __$$ExplanationOutlineImplCopyWithImpl<_$ExplanationOutlineImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExplanationOutlineImplToJson(this);
  }
}

abstract class _ExplanationOutline implements ExplanationOutline {
  const factory _ExplanationOutline({
    final int choiceCount,
    final List<ExplanationOutlineSection> sections,
  }) = _$ExplanationOutlineImpl;

  factory _ExplanationOutline.fromJson(Map<String, dynamic> json) =
      _$ExplanationOutlineImpl.fromJson;

  @override
  int get choiceCount;
  @override
  List<ExplanationOutlineSection> get sections;

  /// Create a copy of ExplanationOutline
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExplanationOutlineImplCopyWith<_$ExplanationOutlineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExplanationOutlineSection _$ExplanationOutlineSectionFromJson(
  Map<String, dynamic> json,
) {
  return _ExplanationOutlineSection.fromJson(json);
}

/// @nodoc
mixin _$ExplanationOutlineSection {
  @JsonKey(unknownEnumValue: ExplanationOutlineSectionKind.unknown)
  ExplanationOutlineSectionKind get kind => throw _privateConstructorUsedError;
  List<int> get itemCharacterCounts => throw _privateConstructorUsedError;

  /// Serializes this ExplanationOutlineSection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExplanationOutlineSection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExplanationOutlineSectionCopyWith<ExplanationOutlineSection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExplanationOutlineSectionCopyWith<$Res> {
  factory $ExplanationOutlineSectionCopyWith(
    ExplanationOutlineSection value,
    $Res Function(ExplanationOutlineSection) then,
  ) = _$ExplanationOutlineSectionCopyWithImpl<$Res, ExplanationOutlineSection>;
  @useResult
  $Res call({
    @JsonKey(unknownEnumValue: ExplanationOutlineSectionKind.unknown)
    ExplanationOutlineSectionKind kind,
    List<int> itemCharacterCounts,
  });
}

/// @nodoc
class _$ExplanationOutlineSectionCopyWithImpl<
  $Res,
  $Val extends ExplanationOutlineSection
>
    implements $ExplanationOutlineSectionCopyWith<$Res> {
  _$ExplanationOutlineSectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExplanationOutlineSection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? kind = null, Object? itemCharacterCounts = null}) {
    return _then(
      _value.copyWith(
            kind: null == kind
                ? _value.kind
                : kind // ignore: cast_nullable_to_non_nullable
                      as ExplanationOutlineSectionKind,
            itemCharacterCounts: null == itemCharacterCounts
                ? _value.itemCharacterCounts
                : itemCharacterCounts // ignore: cast_nullable_to_non_nullable
                      as List<int>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExplanationOutlineSectionImplCopyWith<$Res>
    implements $ExplanationOutlineSectionCopyWith<$Res> {
  factory _$$ExplanationOutlineSectionImplCopyWith(
    _$ExplanationOutlineSectionImpl value,
    $Res Function(_$ExplanationOutlineSectionImpl) then,
  ) = __$$ExplanationOutlineSectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(unknownEnumValue: ExplanationOutlineSectionKind.unknown)
    ExplanationOutlineSectionKind kind,
    List<int> itemCharacterCounts,
  });
}

/// @nodoc
class __$$ExplanationOutlineSectionImplCopyWithImpl<$Res>
    extends
        _$ExplanationOutlineSectionCopyWithImpl<
          $Res,
          _$ExplanationOutlineSectionImpl
        >
    implements _$$ExplanationOutlineSectionImplCopyWith<$Res> {
  __$$ExplanationOutlineSectionImplCopyWithImpl(
    _$ExplanationOutlineSectionImpl _value,
    $Res Function(_$ExplanationOutlineSectionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExplanationOutlineSection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? kind = null, Object? itemCharacterCounts = null}) {
    return _then(
      _$ExplanationOutlineSectionImpl(
        kind: null == kind
            ? _value.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as ExplanationOutlineSectionKind,
        itemCharacterCounts: null == itemCharacterCounts
            ? _value._itemCharacterCounts
            : itemCharacterCounts // ignore: cast_nullable_to_non_nullable
                  as List<int>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExplanationOutlineSectionImpl implements _ExplanationOutlineSection {
  const _$ExplanationOutlineSectionImpl({
    @JsonKey(unknownEnumValue: ExplanationOutlineSectionKind.unknown)
    this.kind = ExplanationOutlineSectionKind.unknown,
    final List<int> itemCharacterCounts = const [],
  }) : _itemCharacterCounts = itemCharacterCounts;

  factory _$ExplanationOutlineSectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExplanationOutlineSectionImplFromJson(json);

  @override
  @JsonKey(unknownEnumValue: ExplanationOutlineSectionKind.unknown)
  final ExplanationOutlineSectionKind kind;
  final List<int> _itemCharacterCounts;
  @override
  @JsonKey()
  List<int> get itemCharacterCounts {
    if (_itemCharacterCounts is EqualUnmodifiableListView)
      return _itemCharacterCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_itemCharacterCounts);
  }

  @override
  String toString() {
    return 'ExplanationOutlineSection(kind: $kind, itemCharacterCounts: $itemCharacterCounts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExplanationOutlineSectionImpl &&
            (identical(other.kind, kind) || other.kind == kind) &&
            const DeepCollectionEquality().equals(
              other._itemCharacterCounts,
              _itemCharacterCounts,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    kind,
    const DeepCollectionEquality().hash(_itemCharacterCounts),
  );

  /// Create a copy of ExplanationOutlineSection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExplanationOutlineSectionImplCopyWith<_$ExplanationOutlineSectionImpl>
  get copyWith =>
      __$$ExplanationOutlineSectionImplCopyWithImpl<
        _$ExplanationOutlineSectionImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExplanationOutlineSectionImplToJson(this);
  }
}

abstract class _ExplanationOutlineSection implements ExplanationOutlineSection {
  const factory _ExplanationOutlineSection({
    @JsonKey(unknownEnumValue: ExplanationOutlineSectionKind.unknown)
    final ExplanationOutlineSectionKind kind,
    final List<int> itemCharacterCounts,
  }) = _$ExplanationOutlineSectionImpl;

  factory _ExplanationOutlineSection.fromJson(Map<String, dynamic> json) =
      _$ExplanationOutlineSectionImpl.fromJson;

  @override
  @JsonKey(unknownEnumValue: ExplanationOutlineSectionKind.unknown)
  ExplanationOutlineSectionKind get kind;
  @override
  List<int> get itemCharacterCounts;

  /// Create a copy of ExplanationOutlineSection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExplanationOutlineSectionImplCopyWith<_$ExplanationOutlineSectionImpl>
  get copyWith => throw _privateConstructorUsedError;
}
