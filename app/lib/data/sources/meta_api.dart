import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/legal/legal_models.dart';
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
}
