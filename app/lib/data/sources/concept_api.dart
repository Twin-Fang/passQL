import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/concept/concept_models.dart';

part 'concept_api.g.dart';

/// 단원별 개념 학습 API (#577)
@RestApi()
abstract class ConceptApiClient {
  factory ConceptApiClient(Dio dio, {String baseUrl}) = _ConceptApiClient;

  /// 단원 목록 (isAvailable=false 면 개념 기능 숨김).
  @GET('/concepts/topics')
  Future<ConceptTopicListResponse> getTopics();

  /// 단원의 개념 목록.
  @GET('/concepts/topics/{topicUuid}')
  Future<ConceptListResponse> getConcepts(@Path('topicUuid') String topicUuid);

  /// 개념 상세 (잠긴 단원 403 PRO_REQUIRED).
  @GET('/concepts/{conceptUuid}')
  Future<ConceptDetailResponse> getConceptDetail(
    @Path('conceptUuid') String conceptUuid,
  );

  /// 확인 문제 5개.
  @GET('/concepts/{conceptUuid}/check-questions')
  Future<List<ConceptCheckQuestionResponse>> getCheckQuestions(
    @Path('conceptUuid') String conceptUuid,
  );

  /// 진행 저장 (읽음·마지막 모드·깊이).
  @PUT('/concepts/{conceptUuid}/progress')
  Future<void> saveProgress(
    @Path('conceptUuid') String conceptUuid,
    @Body() ConceptProgressRequest request,
  );

  /// 확인 문제 채점.
  @POST('/concepts/{conceptUuid}/check-questions/{questionUuid}/answer')
  Future<ConceptCheckAnswerResponse> answerCheckQuestion(
    @Path('conceptUuid') String conceptUuid,
    @Path('questionUuid') String questionUuid,
    @Body() ConceptCheckAnswerRequest request,
  );
}
