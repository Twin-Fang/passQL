import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/home/recommendations_request.dart';
import '../models/home/recommendations_response.dart';
import '../models/question/question_detail.dart';
import '../models/question/question_list_response.dart';
import '../models/question/execute_request.dart';
import '../models/question/execute_result.dart';
import '../models/question/submit_request.dart';
import '../models/question/submit_result.dart';

part 'question_api.g.dart';

@RestApi()
abstract class QuestionApiClient {
  factory QuestionApiClient(Dio dio, {String baseUrl}) = _QuestionApiClient;

  /// 추천 문제 N개.
  ///
  /// 제외 목록이 쿼리스트링으로 누적되면 서버 헤더 한도(8KB)를 넘어 400이 나므로
  /// 서버가 POST 본문으로 받는다.
  @POST('/questions/recommendations')
  Future<RecommendationsResponse> getRecommendations(
    @Body() RecommendationsRequest body,
  );

  /// 문제 목록 조회 (페이지네이션). topic, difficulty는 선택 필터.
  @GET('/questions')
  Future<QuestionListResponse> getQuestions(
    @Query('page') int page,
    @Query('size') int size, {
    @Query('topic') String? topic,
    @Query('difficulty') int? difficulty,
  });

  /// 문제 상세 조회.
  @GET('/questions/{questionUuid}')
  Future<QuestionDetail> getQuestion(
    @Path('questionUuid') String questionUuid,
  );

  /// SQL 실행 (EXECUTABLE 모드 전용). body: { sql: "..." }
  @POST('/questions/{questionUuid}/execute')
  Future<ExecuteResult> executeChoice(
    @Path('questionUuid') String questionUuid,
    @Body() ExecuteRequest body,
  );

  /// 답안 제출. 회원은 토큰으로 식별한다.
  @POST('/questions/{questionUuid}/submit')
  Future<SubmitResult> submitAnswer(
    @Path('questionUuid') String questionUuid,
    @Body() SubmitRequest body,
  );
}
