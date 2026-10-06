import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/daily_set/daily_set_models.dart';

part 'daily_set_api.g.dart';

@RestApi()
abstract class DailySetApiClient {
  factory DailySetApiClient(Dio dio, {String baseUrl}) = _DailySetApiClient;

  /// 오늘의 데일리 세트. 세트가 아직 없으면 서버가 DAILY_SET_NOT_FOUND 로 거절한다.
  @GET('/daily-set/today')
  Future<DailySetTodayResponse> getToday();

  /// 풀이 완료 점수 등록. 이미 완료했으면 DAILY_SET_ALREADY_COMPLETED(409).
  @POST('/daily-set/complete')
  Future<DailySetCompleteResponse> complete(
    @Body() DailySetCompleteRequest body,
  );

  /// 오늘의 순위.
  @GET('/daily-set/leaderboard')
  Future<LeaderboardResponse> getLeaderboard();
}
