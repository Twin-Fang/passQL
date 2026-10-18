import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/ai/ai_result.dart';
import '../models/ai/choice_explanation_response.dart';
import '../models/ai/similar_question.dart';

part 'ai_api.g.dart';

@RestApi()
abstract class AiApiClient {
  factory AiApiClient(Dio dio, {String baseUrl}) = _AiApiClient;

  /// SQL 에러 AI 해설. body: { questionUuid, sql, errorMessage }
  @POST('/ai/explain-error')
  Future<AiResult> explainError(
    @Body() Map<String, dynamic> body,
  );

  /// 오답 AI 해설. body: { questionUuid, selectedChoiceKey }
  @POST('/ai/diff-explain')
  Future<AiResult> diffExplain(
    @Body() Map<String, dynamic> body,
  );

  /// 구조화 선택지 해설 조회 (기다리지 않음, #521). GENERATING 이면 retryAfterMilliseconds 뒤 재조회
  /// choiceSetUuid·selectedChoiceKey 생략 시 서버가 이 문제 마지막 제출 기준으로 찾음
  @GET('/ai/choice-explanation')
  Future<ChoiceExplanationResponse> getChoiceExplanation(
    @Query('questionUuid') String questionUuid, {
    @Query('choiceSetUuid') String? choiceSetUuid,
    @Query('selectedChoiceKey') String? selectedChoiceKey,
  });

  /// 유사 문제 k개 조회.
  @GET('/ai/similar/{questionUuid}')
  Future<List<SimilarQuestion>> getSimilar(
    @Path('questionUuid') String questionUuid,
    @Query('k') int k,
  );
}
