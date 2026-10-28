import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'feedback_api.g.dart';

@RestApi()
abstract class FeedbackApiClient {
  factory FeedbackApiClient(Dio dio, {String baseUrl}) = _FeedbackApiClient;

  /// 의견 보내기 (multipart: request=JSON 본문, images=WebP 0~5장, diagnostics=JSON, log=gzip)
  @POST('/feedback')
  Future<void> submit(@Body() FormData formData);
}
