import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/legal/legal_models.dart';
import '../models/meta/app_config.dart';
import '../models/meta/app_notice_page.dart';
import '../models/meta/topic_tree.dart';

part 'meta_api.g.dart';

@RestApi()
abstract class MetaApiClient {
  factory MetaApiClient(Dio dio, {String baseUrl}) = _MetaApiClient;

  /// 토픽 트리 전체 조회. isActive=true인 항목만 화면에 표시.
  @GET('/meta/topics')
  Future<List<TopicTree>> getTopics();

  /// 약관/개인정보처리방침. 로그인 전에도 볼 수 있는 공개 API 다.
  @GET('/meta/legal/{type}')
  Future<LegalDocument> getLegal(@Path('type') String type);

  /// 앱 시작 설정(버전 정책·점검·공지). 공개 API, 점검 중에도 응답
  @GET('/meta/app-config')
  Future<AppConfig> getAppConfig();

  /// 공지 목록 한 페이지 (지난 공지 포함, 노출 중 중요 먼저 > 게시 최신 순). 공개 API (#529)
  @GET('/meta/notices')
  Future<AppNoticePage> getNotices({
    @Query('page') required int page,
    @Query('size') int? size,
  });

  /// 공지 1건. 없음·비활성·노출 전이면 404 APP_NOTICE_NOT_FOUND (#529)
  @GET('/meta/notices/{noticeUuid}')
  Future<AppNotice> getNotice(@Path('noticeUuid') String noticeUuid);
}
