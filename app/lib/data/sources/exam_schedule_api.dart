import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/exam/exam_schedule_response.dart';
import '../models/exam/sqld_exam_schedule_overview_response.dart';

part 'exam_schedule_api.g.dart';

@RestApi()
abstract class ExamScheduleApiClient {
  factory ExamScheduleApiClient(Dio dio, {String baseUrl}) = _ExamScheduleApiClient;

  /// 선택된 시험 일정. 없으면 200 + null body.
  @GET('/exam-schedules/selected')
  Future<ExamScheduleResponse?> getSelectedSchedule();

  /// SQLD 한 해 일정 (#991, 시험 일정 화면). [year] null 이면 서버 올해(KST)
  @GET('/exam-schedules/sqld')
  Future<SqldExamScheduleOverviewResponse> getSqldOverview(
    @Query('year') int? year,
  );
}
