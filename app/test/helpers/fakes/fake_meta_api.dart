import 'package:dio/dio.dart';
import 'package:passql_app/data/models/meta/app_config.dart';
import 'package:passql_app/data/models/meta/app_notice_page.dart';
import 'package:passql_app/data/sources/meta_api.dart';

/// 공지 API 가짜: 목록은 [notices] 를 [pageSize] 씩 자르고, 상세는 uuid 로 찾음 (없으면 404)
/// 다른 메서드는 쓰지 않는 테스트 전용이라 noSuchMethod 로 둠
class FakeMetaApi implements MetaApiClient {
  FakeMetaApi({required this.notices, this.pageSize = 20});

  final List<AppNotice> notices;
  final int pageSize;

  @override
  Future<AppNoticePage> getNotices({required int page, int? size}) async {
    final start = page * pageSize;
    final end = (start + pageSize).clamp(0, notices.length);
    return AppNoticePage(
      notices: start >= notices.length ? const [] : notices.sublist(start, end),
      page: page,
      hasNextPage: end < notices.length,
    );
  }

  @override
  Future<AppNotice> getNotice(String noticeUuid) async {
    for (final notice in notices) {
      if (notice.noticeUuid == noticeUuid) return notice;
    }
    final requestOptions = RequestOptions(path: '/meta/notices/$noticeUuid');
    throw DioException(
      requestOptions: requestOptions,
      response: Response(
        requestOptions: requestOptions,
        statusCode: 404,
        data: {
          'errorCode': 'APP_NOTICE_NOT_FOUND',
          'message': '공지를 찾을 수 없습니다.',
        },
      ),
      type: DioExceptionType.badResponse,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
