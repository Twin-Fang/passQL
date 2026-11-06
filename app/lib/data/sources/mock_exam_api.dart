import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/mock_exam/mock_exam_result.dart';
import '../models/mock_exam/mock_exam_round_list.dart';
import '../models/mock_exam/mock_exam_sheet.dart';

part 'mock_exam_api.g.dart';

/// SQLD 모의고사 API (#866): 시간·회차·채점·등급 판정은 모두 서버
@RestApi()
abstract class MockExamApiClient {
  factory MockExamApiClient(Dio dio, {String baseUrl}) = _MockExamApiClient;

  /// 회차 목록 (시험 형식·풀이 중 응시·회차별 시작 가능 여부)
  @GET('/mock-exams/rounds')
  Future<MockExamRoundListResponse> getRounds();

  /// 시작 또는 같은 회차 이어 풀기 > 시험지
  @POST('/mock-exams/rounds/{roundUuid}/attempts')
  Future<MockExamSheetResponse> startOrResume(
    @Path('roundUuid') String roundUuid,
  );

  /// 시험지 (마감 지났으면 status submitted)
  @GET('/mock-exams/attempts/{attemptUuid}')
  Future<MockExamSheetResponse> getSheet(
    @Path('attemptUuid') String attemptUuid,
  );

  /// 문항 답 저장 (보기 탭마다)
  @PUT('/mock-exams/attempts/{attemptUuid}/answers/{questionNumber}')
  Future<MockExamAnswerSaveResponse> saveAnswer(
    @Path('attemptUuid') String attemptUuid,
    @Path('questionNumber') int questionNumber,
    @Body() MockExamAnswerSaveRequest request,
  );

  /// 제출 (멱등) > 결과
  @POST('/mock-exams/attempts/{attemptUuid}/submit')
  Future<MockExamResultResponse> submit(
    @Path('attemptUuid') String attemptUuid,
    @Body() MockExamSubmitRequest request,
  );

  /// 결과 (무료는 프로 묶음 제거본)
  @GET('/mock-exams/attempts/{attemptUuid}/result')
  Future<MockExamResultResponse> getResult(
    @Path('attemptUuid') String attemptUuid,
  );

  /// 점수 추이 (프로 전용, 무료 403)
  @GET('/mock-exams/history')
  Future<MockExamHistoryResponse> getHistory();
}
