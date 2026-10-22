import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/exam_trend/exam_trend_report_response.dart';

part 'exam_trend_api.g.dart';

/// 출제 경향 API (#523)
@RestApi()
abstract class ExamTrendApiClient {
  factory ExamTrendApiClient(Dio dio, {String baseUrl}) = _ExamTrendApiClient;

  /// 출제 경향 내용 (요약·과목 비중·늘어난 유형·자주 나오는 개념·공부 팁).
  @GET('/exam-trends/latest')
  Future<ExamTrendReportResponse> getLatestReport();

  /// 토픽별 최신 경향 문제 수 (1개 이상인 활성 토픽만).
  @GET('/exam-trends/latest/topics')
  Future<List<LatestTrendTopicCount>> getLatestTrendTopics();
}
