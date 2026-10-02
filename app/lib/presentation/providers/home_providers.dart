import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_providers.dart';
import '../../core/network/safe_call.dart';
import '../../data/models/home/greeting_response.dart';
import '../../data/models/home/recommendations_request.dart';
import '../../data/models/home/recommendations_response.dart';
import '../../data/models/home/today_question_response.dart';
import '../../data/models/progress/heatmap_response.dart';
import '../../data/models/progress/progress_response.dart';
import '../../data/models/exam/exam_schedule_response.dart';

/// 홈 화면에 필요한 모든 API 응답을 담는 집계 모델.
/// 각 필드는 nullable — API 실패 시 해당 섹션을 graceful하게 숨김 처리.
class HomeData {
  final GreetingResponse? greeting;
  final ProgressResponse? progress;
  final TodayQuestionResponse? todayQuestion;
  final RecommendationsResponse? recommendations;
  final ExamScheduleResponse? examSchedule;
  final HeatmapResponse? heatmap;

  const HomeData({
    this.greeting,
    this.progress,
    this.todayQuestion,
    this.recommendations,
    this.examSchedule,
    this.heatmap,
  });
}

/// 홈 화면 데이터 Provider.
///
/// 6개 API를 병렬 호출. 회원은 요청의 토큰으로 식별된다.
/// 개별 API 실패는 null로 처리 — 전체 화면 에러 방지.
final homeDataProvider = FutureProvider<HomeData>((ref) async {
  final homeClient = ref.read(homeApiProvider);
  final progressClient = ref.read(progressApiProvider);
  final questionClient = ref.read(questionApiProvider);
  final examClient = ref.read(examScheduleApiProvider);

  // 6개 API 병렬 호출.
  // getHeatmap(from, to) — from/to는 nullable String.
  final results = await Future.wait([
    safeCall(homeClient.getGreeting()),
    safeCall(progressClient.getProgress()),
    safeCall(questionClient.getTodayQuestion()),
    safeCall(questionClient.getRecommendations(
      const RecommendationsRequest(size: 3),
    )),
    safeCall(examClient.getSelectedSchedule()),
    safeCall(progressClient.getHeatmap(null, null)),
  ]);

  return HomeData(
    greeting: results[0] as GreetingResponse?,
    progress: results[1] as ProgressResponse?,
    todayQuestion: results[2] as TodayQuestionResponse?,
    recommendations: results[3] as RecommendationsResponse?,
    examSchedule: results[4] as ExamScheduleResponse?,
    heatmap: results[5] as HeatmapResponse?,
  );
});
