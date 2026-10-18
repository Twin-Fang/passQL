// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppPlatformVersionPolicyImpl _$$AppPlatformVersionPolicyImplFromJson(
  Map<String, dynamic> json,
) => _$AppPlatformVersionPolicyImpl(
  minimumVersion: json['minimumVersion'] as String? ?? '0.0.0',
  recommendedVersion: json['recommendedVersion'] as String? ?? '0.0.0',
  storeUrl: json['storeUrl'] as String?,
);

Map<String, dynamic> _$$AppPlatformVersionPolicyImplToJson(
  _$AppPlatformVersionPolicyImpl instance,
) => <String, dynamic>{
  'minimumVersion': instance.minimumVersion,
  'recommendedVersion': instance.recommendedVersion,
  'storeUrl': instance.storeUrl,
};

_$AppMaintenanceStatusImpl _$$AppMaintenanceStatusImplFromJson(
  Map<String, dynamic> json,
) => _$AppMaintenanceStatusImpl(
  isUnderMaintenance: json['isUnderMaintenance'] as bool? ?? false,
  message: json['message'] as String? ?? '',
);

Map<String, dynamic> _$$AppMaintenanceStatusImplToJson(
  _$AppMaintenanceStatusImpl instance,
) => <String, dynamic>{
  'isUnderMaintenance': instance.isUnderMaintenance,
  'message': instance.message,
};

_$AppNoticeImpl _$$AppNoticeImplFromJson(Map<String, dynamic> json) =>
    _$AppNoticeImpl(
      noticeUuid: json['noticeUuid'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      isImportant: json['isImportant'] as bool? ?? false,
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
    );

Map<String, dynamic> _$$AppNoticeImplToJson(_$AppNoticeImpl instance) =>
    <String, dynamic>{
      'noticeUuid': instance.noticeUuid,
      'title': instance.title,
      'body': instance.body,
      'isImportant': instance.isImportant,
      'publishedAt': instance.publishedAt?.toIso8601String(),
    };

_$AppConfigImpl _$$AppConfigImplFromJson(Map<String, dynamic> json) =>
    _$AppConfigImpl(
      ios: json['ios'] == null
          ? const AppPlatformVersionPolicy()
          : AppPlatformVersionPolicy.fromJson(
              json['ios'] as Map<String, dynamic>,
            ),
      android: json['android'] == null
          ? const AppPlatformVersionPolicy()
          : AppPlatformVersionPolicy.fromJson(
              json['android'] as Map<String, dynamic>,
            ),
      maintenance: json['maintenance'] == null
          ? const AppMaintenanceStatus()
          : AppMaintenanceStatus.fromJson(
              json['maintenance'] as Map<String, dynamic>,
            ),
      notices:
          (json['notices'] as List<dynamic>?)
              ?.map((e) => AppNotice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$AppConfigImplToJson(_$AppConfigImpl instance) =>
    <String, dynamic>{
      'ios': instance.ios,
      'android': instance.android,
      'maintenance': instance.maintenance,
      'notices': instance.notices,
    };
