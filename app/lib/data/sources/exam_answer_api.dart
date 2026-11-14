import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/exam_answer/exam_answer_round_response.dart';
import '../models/exam_answer/exam_answer_sheet_models.dart';

part 'exam_answer_api.g.dart';

/// 회차별 가답안·OMR 가채점 공개 API (#1075, 로그인 불필요 > 인증 헤더가 붙어도 무관)
@RestApi()
abstract class ExamAnswerApiClient {
  factory ExamAnswerApiClient(Dio dio, {String baseUrl}) = _ExamAnswerApiClient;

  /// 회차 가답안 (문항 50개·득표·참여자 수)
  @GET('/exam-answers/{certType}/{roundNumber}')
  Future<ExamAnswerRoundResponse> getRound(
    @Path('certType') String certType,
    @Path('roundNumber') int roundNumber,
  );

  /// 답안 제출·갱신 (기기 토큰당 1장) > 채점 결과
  @POST('/exam-answers/{certType}/{roundNumber}/sheets')
  Future<ExamAnswerSheetResponse> submitSheet(
    @Path('certType') String certType,
    @Path('roundNumber') int roundNumber,
    @Body() ExamAnswerSheetSubmitRequest request,
  );

  /// 내 답안지 + 채점 결과 (제출 전이면 404 EXAM_ANSWER_SHEET_NOT_FOUND)
  @GET('/exam-answers/{certType}/{roundNumber}/sheets/{clientToken}')
  Future<ExamAnswerSheetResponse> getSheet(
    @Path('certType') String certType,
    @Path('roundNumber') int roundNumber,
    @Path('clientToken') String clientToken,
  );
}
