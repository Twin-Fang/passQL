import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/feedback/feedback_models.dart';

part 'feedback_api.g.dart';

@RestApi()
abstract class FeedbackApiClient {
  factory FeedbackApiClient(Dio dio, {String baseUrl}) = _FeedbackApiClient;

  /// 건의 보내기. 응답은 접수 결과라 화면에서는 목록을 다시 불러 쓴다.
  @POST('/feedback')
  Future<void> submit(@Body() FeedbackSubmitRequest body);

  /// 내가 보낸 건의 목록.
  @GET('/feedback/me')
  Future<FeedbackListResponse> getMyFeedbacks();
}
