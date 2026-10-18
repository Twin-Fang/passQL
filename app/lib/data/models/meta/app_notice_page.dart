import 'package:freezed_annotation/freezed_annotation.dart';

import 'app_config.dart';

part 'app_notice_page.freezed.dart';
part 'app_notice_page.g.dart';

/// 공지 목록 한 페이지 (GET /meta/notices): 공지, 현재 페이지(0부터), 다음 페이지 유무
@freezed
class AppNoticePage with _$AppNoticePage {
  const factory AppNoticePage({
    @Default([]) List<AppNotice> notices,
    @Default(0) int page,
    @Default(false) bool hasNextPage,
  }) = _AppNoticePage;

  factory AppNoticePage.fromJson(Map<String, dynamic> json) =>
      _$AppNoticePageFromJson(json);
}
