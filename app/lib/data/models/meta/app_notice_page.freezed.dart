// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_notice_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AppNoticePage _$AppNoticePageFromJson(Map<String, dynamic> json) {
  return _AppNoticePage.fromJson(json);
}

/// @nodoc
mixin _$AppNoticePage {
  List<AppNotice> get notices => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  bool get hasNextPage => throw _privateConstructorUsedError;

  /// Serializes this AppNoticePage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppNoticePage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppNoticePageCopyWith<AppNoticePage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppNoticePageCopyWith<$Res> {
  factory $AppNoticePageCopyWith(
    AppNoticePage value,
    $Res Function(AppNoticePage) then,
  ) = _$AppNoticePageCopyWithImpl<$Res, AppNoticePage>;
  @useResult
  $Res call({List<AppNotice> notices, int page, bool hasNextPage});
}

/// @nodoc
class _$AppNoticePageCopyWithImpl<$Res, $Val extends AppNoticePage>
    implements $AppNoticePageCopyWith<$Res> {
  _$AppNoticePageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppNoticePage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notices = null,
    Object? page = null,
    Object? hasNextPage = null,
  }) {
    return _then(
      _value.copyWith(
            notices: null == notices
                ? _value.notices
                : notices // ignore: cast_nullable_to_non_nullable
                      as List<AppNotice>,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            hasNextPage: null == hasNextPage
                ? _value.hasNextPage
                : hasNextPage // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppNoticePageImplCopyWith<$Res>
    implements $AppNoticePageCopyWith<$Res> {
  factory _$$AppNoticePageImplCopyWith(
    _$AppNoticePageImpl value,
    $Res Function(_$AppNoticePageImpl) then,
  ) = __$$AppNoticePageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<AppNotice> notices, int page, bool hasNextPage});
}

/// @nodoc
class __$$AppNoticePageImplCopyWithImpl<$Res>
    extends _$AppNoticePageCopyWithImpl<$Res, _$AppNoticePageImpl>
    implements _$$AppNoticePageImplCopyWith<$Res> {
  __$$AppNoticePageImplCopyWithImpl(
    _$AppNoticePageImpl _value,
    $Res Function(_$AppNoticePageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppNoticePage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notices = null,
    Object? page = null,
    Object? hasNextPage = null,
  }) {
    return _then(
      _$AppNoticePageImpl(
        notices: null == notices
            ? _value._notices
            : notices // ignore: cast_nullable_to_non_nullable
                  as List<AppNotice>,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        hasNextPage: null == hasNextPage
            ? _value.hasNextPage
            : hasNextPage // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppNoticePageImpl implements _AppNoticePage {
  const _$AppNoticePageImpl({
    final List<AppNotice> notices = const [],
    this.page = 0,
    this.hasNextPage = false,
  }) : _notices = notices;

  factory _$AppNoticePageImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppNoticePageImplFromJson(json);

  final List<AppNotice> _notices;
  @override
  @JsonKey()
  List<AppNotice> get notices {
    if (_notices is EqualUnmodifiableListView) return _notices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notices);
  }

  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final bool hasNextPage;

  @override
  String toString() {
    return 'AppNoticePage(notices: $notices, page: $page, hasNextPage: $hasNextPage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppNoticePageImpl &&
            const DeepCollectionEquality().equals(other._notices, _notices) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.hasNextPage, hasNextPage) ||
                other.hasNextPage == hasNextPage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_notices),
    page,
    hasNextPage,
  );

  /// Create a copy of AppNoticePage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppNoticePageImplCopyWith<_$AppNoticePageImpl> get copyWith =>
      __$$AppNoticePageImplCopyWithImpl<_$AppNoticePageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppNoticePageImplToJson(this);
  }
}

abstract class _AppNoticePage implements AppNoticePage {
  const factory _AppNoticePage({
    final List<AppNotice> notices,
    final int page,
    final bool hasNextPage,
  }) = _$AppNoticePageImpl;

  factory _AppNoticePage.fromJson(Map<String, dynamic> json) =
      _$AppNoticePageImpl.fromJson;

  @override
  List<AppNotice> get notices;
  @override
  int get page;
  @override
  bool get hasNextPage;

  /// Create a copy of AppNoticePage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppNoticePageImplCopyWith<_$AppNoticePageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
