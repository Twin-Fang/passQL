import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/report/report_models.dart';

part 'report_api.g.dart';

@RestApi()
abstract class ReportApiClient {
  factory ReportApiClient(Dio dio, {String baseUrl}) = _ReportApiClient;

  /// 문제 신고. 같은 제출을 다시 신고하면 서버가 409(REPORT_ALREADY_EXISTS)로 거절한다.
  @POST('/questions/{questionUuid}/report')
  Future<void> submitReport(
    @Path('questionUuid') String questionUuid,
    @Body() ReportRequest body,
  );

  /// 이 제출을 이미 신고했는지.
  @GET('/questions/{questionUuid}/report/status')
  Future<ReportStatusResponse> getReportStatus(
    @Path('questionUuid') String questionUuid,
    @Query('submissionUuid') String submissionUuid,
  );
}
