// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notice_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppNoticePageImpl _$$AppNoticePageImplFromJson(Map<String, dynamic> json) =>
    _$AppNoticePageImpl(
      notices:
          (json['notices'] as List<dynamic>?)
              ?.map((e) => AppNotice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      page: (json['page'] as num?)?.toInt() ?? 0,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
    );

Map<String, dynamic> _$$AppNoticePageImplToJson(_$AppNoticePageImpl instance) =>
    <String, dynamic>{
      'notices': instance.notices,
      'page': instance.page,
      'hasNextPage': instance.hasNextPage,
    };
