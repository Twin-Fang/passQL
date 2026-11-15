import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/ox_quiz/ox_quiz_models.dart';

part 'ox_quiz_api.g.dart';

/// OX 퀴즈 API (#1083, 무료는 개념 무료 단원 카드만)
@RestApi()
abstract class OxQuizApiClient {
  factory OxQuizApiClient(Dio dio, {String baseUrl}) = _OxQuizApiClient;

  /// 카드 묶음 (기본 10장, 최대 20장)
  @GET('/ox/cards')
  Future<OxCardSetResponse> getCardSet({@Query('size') int? size});

  /// 답 기록 > 갱신된 칸·다음 출제일
  @POST('/ox/answers')
  Future<OxAnswerResponse> answer(@Body() OxAnswerRequest request);
}
