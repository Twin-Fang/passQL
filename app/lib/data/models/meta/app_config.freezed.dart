// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AppPlatformVersionPolicy _$AppPlatformVersionPolicyFromJson(
  Map<String, dynamic> json,
) {
  return _AppPlatformVersionPolicy.fromJson(json);
}

/// @nodoc
mixin _$AppPlatformVersionPolicy {
  String get minimumVersion => throw _privateConstructorUsedError;
  String get recommendedVersion => throw _privateConstructorUsedError;
  String? get storeUrl => throw _privateConstructorUsedError;

  /// Serializes this AppPlatformVersionPolicy to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppPlatformVersionPolicy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppPlatformVersionPolicyCopyWith<AppPlatformVersionPolicy> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppPlatformVersionPolicyCopyWith<$Res> {
  factory $AppPlatformVersionPolicyCopyWith(
    AppPlatformVersionPolicy value,
    $Res Function(AppPlatformVersionPolicy) then,
  ) = _$AppPlatformVersionPolicyCopyWithImpl<$Res, AppPlatformVersionPolicy>;
  @useResult
  $Res call({
    String minimumVersion,
    String recommendedVersion,
    String? storeUrl,
  });
}

/// @nodoc
class _$AppPlatformVersionPolicyCopyWithImpl<
  $Res,
  $Val extends AppPlatformVersionPolicy
>
    implements $AppPlatformVersionPolicyCopyWith<$Res> {
  _$AppPlatformVersionPolicyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppPlatformVersionPolicy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minimumVersion = null,
    Object? recommendedVersion = null,
    Object? storeUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            minimumVersion: null == minimumVersion
                ? _value.minimumVersion
                : minimumVersion // ignore: cast_nullable_to_non_nullable
                      as String,
            recommendedVersion: null == recommendedVersion
                ? _value.recommendedVersion
                : recommendedVersion // ignore: cast_nullable_to_non_nullable
                      as String,
            storeUrl: freezed == storeUrl
                ? _value.storeUrl
                : storeUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppPlatformVersionPolicyImplCopyWith<$Res>
    implements $AppPlatformVersionPolicyCopyWith<$Res> {
  factory _$$AppPlatformVersionPolicyImplCopyWith(
    _$AppPlatformVersionPolicyImpl value,
    $Res Function(_$AppPlatformVersionPolicyImpl) then,
  ) = __$$AppPlatformVersionPolicyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String minimumVersion,
    String recommendedVersion,
    String? storeUrl,
  });
}

/// @nodoc
class __$$AppPlatformVersionPolicyImplCopyWithImpl<$Res>
    extends
        _$AppPlatformVersionPolicyCopyWithImpl<
          $Res,
          _$AppPlatformVersionPolicyImpl
        >
    implements _$$AppPlatformVersionPolicyImplCopyWith<$Res> {
  __$$AppPlatformVersionPolicyImplCopyWithImpl(
    _$AppPlatformVersionPolicyImpl _value,
    $Res Function(_$AppPlatformVersionPolicyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppPlatformVersionPolicy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minimumVersion = null,
    Object? recommendedVersion = null,
    Object? storeUrl = freezed,
  }) {
    return _then(
      _$AppPlatformVersionPolicyImpl(
        minimumVersion: null == minimumVersion
            ? _value.minimumVersion
            : minimumVersion // ignore: cast_nullable_to_non_nullable
                  as String,
        recommendedVersion: null == recommendedVersion
            ? _value.recommendedVersion
            : recommendedVersion // ignore: cast_nullable_to_non_nullable
                  as String,
        storeUrl: freezed == storeUrl
            ? _value.storeUrl
            : storeUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppPlatformVersionPolicyImpl implements _AppPlatformVersionPolicy {
  const _$AppPlatformVersionPolicyImpl({
    this.minimumVersion = '0.0.0',
    this.recommendedVersion = '0.0.0',
    this.storeUrl,
  });

  factory _$AppPlatformVersionPolicyImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppPlatformVersionPolicyImplFromJson(json);

  @override
  @JsonKey()
  final String minimumVersion;
  @override
  @JsonKey()
  final String recommendedVersion;
  @override
  final String? storeUrl;

  @override
  String toString() {
    return 'AppPlatformVersionPolicy(minimumVersion: $minimumVersion, recommendedVersion: $recommendedVersion, storeUrl: $storeUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppPlatformVersionPolicyImpl &&
            (identical(other.minimumVersion, minimumVersion) ||
                other.minimumVersion == minimumVersion) &&
            (identical(other.recommendedVersion, recommendedVersion) ||
                other.recommendedVersion == recommendedVersion) &&
            (identical(other.storeUrl, storeUrl) ||
                other.storeUrl == storeUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, minimumVersion, recommendedVersion, storeUrl);

  /// Create a copy of AppPlatformVersionPolicy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppPlatformVersionPolicyImplCopyWith<_$AppPlatformVersionPolicyImpl>
  get copyWith =>
      __$$AppPlatformVersionPolicyImplCopyWithImpl<
        _$AppPlatformVersionPolicyImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppPlatformVersionPolicyImplToJson(this);
  }
}

abstract class _AppPlatformVersionPolicy implements AppPlatformVersionPolicy {
  const factory _AppPlatformVersionPolicy({
    final String minimumVersion,
    final String recommendedVersion,
    final String? storeUrl,
  }) = _$AppPlatformVersionPolicyImpl;

  factory _AppPlatformVersionPolicy.fromJson(Map<String, dynamic> json) =
      _$AppPlatformVersionPolicyImpl.fromJson;

  @override
  String get minimumVersion;
  @override
  String get recommendedVersion;
  @override
  String? get storeUrl;

  /// Create a copy of AppPlatformVersionPolicy
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppPlatformVersionPolicyImplCopyWith<_$AppPlatformVersionPolicyImpl>
  get copyWith => throw _privateConstructorUsedError;
}

AppMaintenanceStatus _$AppMaintenanceStatusFromJson(Map<String, dynamic> json) {
  return _AppMaintenanceStatus.fromJson(json);
}

/// @nodoc
mixin _$AppMaintenanceStatus {
  bool get isUnderMaintenance => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;

  /// Serializes this AppMaintenanceStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppMaintenanceStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppMaintenanceStatusCopyWith<AppMaintenanceStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppMaintenanceStatusCopyWith<$Res> {
  factory $AppMaintenanceStatusCopyWith(
    AppMaintenanceStatus value,
    $Res Function(AppMaintenanceStatus) then,
  ) = _$AppMaintenanceStatusCopyWithImpl<$Res, AppMaintenanceStatus>;
  @useResult
  $Res call({bool isUnderMaintenance, String message});
}

/// @nodoc
class _$AppMaintenanceStatusCopyWithImpl<
  $Res,
  $Val extends AppMaintenanceStatus
>
    implements $AppMaintenanceStatusCopyWith<$Res> {
  _$AppMaintenanceStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppMaintenanceStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? isUnderMaintenance = null, Object? message = null}) {
    return _then(
      _value.copyWith(
            isUnderMaintenance: null == isUnderMaintenance
                ? _value.isUnderMaintenance
                : isUnderMaintenance // ignore: cast_nullable_to_non_nullable
                      as bool,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppMaintenanceStatusImplCopyWith<$Res>
    implements $AppMaintenanceStatusCopyWith<$Res> {
  factory _$$AppMaintenanceStatusImplCopyWith(
    _$AppMaintenanceStatusImpl value,
    $Res Function(_$AppMaintenanceStatusImpl) then,
  ) = __$$AppMaintenanceStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isUnderMaintenance, String message});
}

/// @nodoc
class __$$AppMaintenanceStatusImplCopyWithImpl<$Res>
    extends _$AppMaintenanceStatusCopyWithImpl<$Res, _$AppMaintenanceStatusImpl>
    implements _$$AppMaintenanceStatusImplCopyWith<$Res> {
  __$$AppMaintenanceStatusImplCopyWithImpl(
    _$AppMaintenanceStatusImpl _value,
    $Res Function(_$AppMaintenanceStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppMaintenanceStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? isUnderMaintenance = null, Object? message = null}) {
    return _then(
      _$AppMaintenanceStatusImpl(
        isUnderMaintenance: null == isUnderMaintenance
            ? _value.isUnderMaintenance
            : isUnderMaintenance // ignore: cast_nullable_to_non_nullable
                  as bool,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppMaintenanceStatusImpl implements _AppMaintenanceStatus {
  const _$AppMaintenanceStatusImpl({
    this.isUnderMaintenance = false,
    this.message = '',
  });

  factory _$AppMaintenanceStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppMaintenanceStatusImplFromJson(json);

  @override
  @JsonKey()
  final bool isUnderMaintenance;
  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'AppMaintenanceStatus(isUnderMaintenance: $isUnderMaintenance, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppMaintenanceStatusImpl &&
            (identical(other.isUnderMaintenance, isUnderMaintenance) ||
                other.isUnderMaintenance == isUnderMaintenance) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, isUnderMaintenance, message);

  /// Create a copy of AppMaintenanceStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppMaintenanceStatusImplCopyWith<_$AppMaintenanceStatusImpl>
  get copyWith =>
      __$$AppMaintenanceStatusImplCopyWithImpl<_$AppMaintenanceStatusImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AppMaintenanceStatusImplToJson(this);
  }
}

abstract class _AppMaintenanceStatus implements AppMaintenanceStatus {
  const factory _AppMaintenanceStatus({
    final bool isUnderMaintenance,
    final String message,
  }) = _$AppMaintenanceStatusImpl;

  factory _AppMaintenanceStatus.fromJson(Map<String, dynamic> json) =
      _$AppMaintenanceStatusImpl.fromJson;

  @override
  bool get isUnderMaintenance;
  @override
  String get message;

  /// Create a copy of AppMaintenanceStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppMaintenanceStatusImplCopyWith<_$AppMaintenanceStatusImpl>
  get copyWith => throw _privateConstructorUsedError;
}

AppNotice _$AppNoticeFromJson(Map<String, dynamic> json) {
  return _AppNotice.fromJson(json);
}

/// @nodoc
mixin _$AppNotice {
  String get noticeUuid => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  bool get isImportant => throw _privateConstructorUsedError;

  /// Serializes this AppNotice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppNotice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppNoticeCopyWith<AppNotice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppNoticeCopyWith<$Res> {
  factory $AppNoticeCopyWith(AppNotice value, $Res Function(AppNotice) then) =
      _$AppNoticeCopyWithImpl<$Res, AppNotice>;
  @useResult
  $Res call({String noticeUuid, String title, String body, bool isImportant});
}

/// @nodoc
class _$AppNoticeCopyWithImpl<$Res, $Val extends AppNotice>
    implements $AppNoticeCopyWith<$Res> {
  _$AppNoticeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppNotice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? noticeUuid = null,
    Object? title = null,
    Object? body = null,
    Object? isImportant = null,
  }) {
    return _then(
      _value.copyWith(
            noticeUuid: null == noticeUuid
                ? _value.noticeUuid
                : noticeUuid // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
            isImportant: null == isImportant
                ? _value.isImportant
                : isImportant // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppNoticeImplCopyWith<$Res>
    implements $AppNoticeCopyWith<$Res> {
  factory _$$AppNoticeImplCopyWith(
    _$AppNoticeImpl value,
    $Res Function(_$AppNoticeImpl) then,
  ) = __$$AppNoticeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String noticeUuid, String title, String body, bool isImportant});
}

/// @nodoc
class __$$AppNoticeImplCopyWithImpl<$Res>
    extends _$AppNoticeCopyWithImpl<$Res, _$AppNoticeImpl>
    implements _$$AppNoticeImplCopyWith<$Res> {
  __$$AppNoticeImplCopyWithImpl(
    _$AppNoticeImpl _value,
    $Res Function(_$AppNoticeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppNotice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? noticeUuid = null,
    Object? title = null,
    Object? body = null,
    Object? isImportant = null,
  }) {
    return _then(
      _$AppNoticeImpl(
        noticeUuid: null == noticeUuid
            ? _value.noticeUuid
            : noticeUuid // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        isImportant: null == isImportant
            ? _value.isImportant
            : isImportant // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppNoticeImpl implements _AppNotice {
  const _$AppNoticeImpl({
    required this.noticeUuid,
    required this.title,
    required this.body,
    this.isImportant = false,
  });

  factory _$AppNoticeImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppNoticeImplFromJson(json);

  @override
  final String noticeUuid;
  @override
  final String title;
  @override
  final String body;
  @override
  @JsonKey()
  final bool isImportant;

  @override
  String toString() {
    return 'AppNotice(noticeUuid: $noticeUuid, title: $title, body: $body, isImportant: $isImportant)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppNoticeImpl &&
            (identical(other.noticeUuid, noticeUuid) ||
                other.noticeUuid == noticeUuid) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.isImportant, isImportant) ||
                other.isImportant == isImportant));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, noticeUuid, title, body, isImportant);

  /// Create a copy of AppNotice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppNoticeImplCopyWith<_$AppNoticeImpl> get copyWith =>
      __$$AppNoticeImplCopyWithImpl<_$AppNoticeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppNoticeImplToJson(this);
  }
}

abstract class _AppNotice implements AppNotice {
  const factory _AppNotice({
    required final String noticeUuid,
    required final String title,
    required final String body,
    final bool isImportant,
  }) = _$AppNoticeImpl;

  factory _AppNotice.fromJson(Map<String, dynamic> json) =
      _$AppNoticeImpl.fromJson;

  @override
  String get noticeUuid;
  @override
  String get title;
  @override
  String get body;
  @override
  bool get isImportant;

  /// Create a copy of AppNotice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppNoticeImplCopyWith<_$AppNoticeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) {
  return _AppConfig.fromJson(json);
}

/// @nodoc
mixin _$AppConfig {
  AppPlatformVersionPolicy get ios => throw _privateConstructorUsedError;
  AppPlatformVersionPolicy get android => throw _privateConstructorUsedError;
  AppMaintenanceStatus get maintenance => throw _privateConstructorUsedError;
  List<AppNotice> get notices => throw _privateConstructorUsedError;

  /// Serializes this AppConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppConfigCopyWith<AppConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppConfigCopyWith<$Res> {
  factory $AppConfigCopyWith(AppConfig value, $Res Function(AppConfig) then) =
      _$AppConfigCopyWithImpl<$Res, AppConfig>;
  @useResult
  $Res call({
    AppPlatformVersionPolicy ios,
    AppPlatformVersionPolicy android,
    AppMaintenanceStatus maintenance,
    List<AppNotice> notices,
  });

  $AppPlatformVersionPolicyCopyWith<$Res> get ios;
  $AppPlatformVersionPolicyCopyWith<$Res> get android;
  $AppMaintenanceStatusCopyWith<$Res> get maintenance;
}

/// @nodoc
class _$AppConfigCopyWithImpl<$Res, $Val extends AppConfig>
    implements $AppConfigCopyWith<$Res> {
  _$AppConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ios = null,
    Object? android = null,
    Object? maintenance = null,
    Object? notices = null,
  }) {
    return _then(
      _value.copyWith(
            ios: null == ios
                ? _value.ios
                : ios // ignore: cast_nullable_to_non_nullable
                      as AppPlatformVersionPolicy,
            android: null == android
                ? _value.android
                : android // ignore: cast_nullable_to_non_nullable
                      as AppPlatformVersionPolicy,
            maintenance: null == maintenance
                ? _value.maintenance
                : maintenance // ignore: cast_nullable_to_non_nullable
                      as AppMaintenanceStatus,
            notices: null == notices
                ? _value.notices
                : notices // ignore: cast_nullable_to_non_nullable
                      as List<AppNotice>,
          )
          as $Val,
    );
  }

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppPlatformVersionPolicyCopyWith<$Res> get ios {
    return $AppPlatformVersionPolicyCopyWith<$Res>(_value.ios, (value) {
      return _then(_value.copyWith(ios: value) as $Val);
    });
  }

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppPlatformVersionPolicyCopyWith<$Res> get android {
    return $AppPlatformVersionPolicyCopyWith<$Res>(_value.android, (value) {
      return _then(_value.copyWith(android: value) as $Val);
    });
  }

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppMaintenanceStatusCopyWith<$Res> get maintenance {
    return $AppMaintenanceStatusCopyWith<$Res>(_value.maintenance, (value) {
      return _then(_value.copyWith(maintenance: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AppConfigImplCopyWith<$Res>
    implements $AppConfigCopyWith<$Res> {
  factory _$$AppConfigImplCopyWith(
    _$AppConfigImpl value,
    $Res Function(_$AppConfigImpl) then,
  ) = __$$AppConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    AppPlatformVersionPolicy ios,
    AppPlatformVersionPolicy android,
    AppMaintenanceStatus maintenance,
    List<AppNotice> notices,
  });

  @override
  $AppPlatformVersionPolicyCopyWith<$Res> get ios;
  @override
  $AppPlatformVersionPolicyCopyWith<$Res> get android;
  @override
  $AppMaintenanceStatusCopyWith<$Res> get maintenance;
}

/// @nodoc
class __$$AppConfigImplCopyWithImpl<$Res>
    extends _$AppConfigCopyWithImpl<$Res, _$AppConfigImpl>
    implements _$$AppConfigImplCopyWith<$Res> {
  __$$AppConfigImplCopyWithImpl(
    _$AppConfigImpl _value,
    $Res Function(_$AppConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ios = null,
    Object? android = null,
    Object? maintenance = null,
    Object? notices = null,
  }) {
    return _then(
      _$AppConfigImpl(
        ios: null == ios
            ? _value.ios
            : ios // ignore: cast_nullable_to_non_nullable
                  as AppPlatformVersionPolicy,
        android: null == android
            ? _value.android
            : android // ignore: cast_nullable_to_non_nullable
                  as AppPlatformVersionPolicy,
        maintenance: null == maintenance
            ? _value.maintenance
            : maintenance // ignore: cast_nullable_to_non_nullable
                  as AppMaintenanceStatus,
        notices: null == notices
            ? _value._notices
            : notices // ignore: cast_nullable_to_non_nullable
                  as List<AppNotice>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppConfigImpl implements _AppConfig {
  const _$AppConfigImpl({
    this.ios = const AppPlatformVersionPolicy(),
    this.android = const AppPlatformVersionPolicy(),
    this.maintenance = const AppMaintenanceStatus(),
    final List<AppNotice> notices = const [],
  }) : _notices = notices;

  factory _$AppConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppConfigImplFromJson(json);

  @override
  @JsonKey()
  final AppPlatformVersionPolicy ios;
  @override
  @JsonKey()
  final AppPlatformVersionPolicy android;
  @override
  @JsonKey()
  final AppMaintenanceStatus maintenance;
  final List<AppNotice> _notices;
  @override
  @JsonKey()
  List<AppNotice> get notices {
    if (_notices is EqualUnmodifiableListView) return _notices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notices);
  }

  @override
  String toString() {
    return 'AppConfig(ios: $ios, android: $android, maintenance: $maintenance, notices: $notices)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppConfigImpl &&
            (identical(other.ios, ios) || other.ios == ios) &&
            (identical(other.android, android) || other.android == android) &&
            (identical(other.maintenance, maintenance) ||
                other.maintenance == maintenance) &&
            const DeepCollectionEquality().equals(other._notices, _notices));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    ios,
    android,
    maintenance,
    const DeepCollectionEquality().hash(_notices),
  );

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppConfigImplCopyWith<_$AppConfigImpl> get copyWith =>
      __$$AppConfigImplCopyWithImpl<_$AppConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppConfigImplToJson(this);
  }
}

abstract class _AppConfig implements AppConfig {
  const factory _AppConfig({
    final AppPlatformVersionPolicy ios,
    final AppPlatformVersionPolicy android,
    final AppMaintenanceStatus maintenance,
    final List<AppNotice> notices,
  }) = _$AppConfigImpl;

  factory _AppConfig.fromJson(Map<String, dynamic> json) =
      _$AppConfigImpl.fromJson;

  @override
  AppPlatformVersionPolicy get ios;
  @override
  AppPlatformVersionPolicy get android;
  @override
  AppMaintenanceStatus get maintenance;
  @override
  List<AppNotice> get notices;

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppConfigImplCopyWith<_$AppConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
