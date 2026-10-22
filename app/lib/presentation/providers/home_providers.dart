import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/sources/api_providers.dart';
import '../../core/error/app_exception.dart';
import '../../core/network/safe_call.dart';
import '../../data/models/home/greeting_response.dart';
import '../../data/models/home/recommendations_request.dart';
import '../../data/models/home/recommendations_response.dart';
import '../../data/models/daily_set/daily_set_models.dart';
import '../../data/models/progress/heatmap_response.dart';
import '../../data/models/progress/progress_response.dart';
import '../../data/models/exam/exam_schedule_response.dart';
import 'pro_ui_providers.dart';
import 'session_reset.dart';

/// 홈 화면에 필요한 모든 API 응답을 담는 집계 모델.
/// 각 필드는 nullable — API 실패 시 해당 섹션을 graceful하게 숨김 처리.
class HomeData {
  final GreetingResponse? greeting;
  final ProgressResponse? progress;
  final DailySetTodayResponse? dailySet;
  final RecommendationsResponse? recommendations;
  final ExamScheduleResponse? examSchedule;
  final HeatmapResponse? heatmap;

  const HomeData({
    this.greeting,
    this.progress,
    this.dailySet,
    this.recommendations,
    this.examSchedule,
    this.heatmap,
  });
}

/// 홈 데이터 중 풀이와 무관한 묶음: 인사말·추천 문제·시험 일정
class HomeOverview {
  final GreetingResponse? greeting;
  final RecommendationsResponse? recommendations;
  final ExamScheduleResponse? examSchedule;

  const HomeOverview({this.greeting, this.recommendations, this.examSchedule});
}

/// 홈 데이터 중 풀이마다 바뀌는 묶음: 진행 현황·오늘의 세트 상태·히트맵
class HomeLearningStatus {
  final ProgressResponse? progress;
  final DailySetTodayResponse? dailySet;
  final HeatmapResponse? heatmap;

  const HomeLearningStatus({this.progress, this.dailySet, this.heatmap});
}

/// 인사말·추천·시험 일정 3개 병렬 호출. 날짜가 바뀌거나 직접 새로고침할 때만 다시 받는다
/// 로그아웃이면 빈 묶음 (API 호출 없음), 무료(결제 켜짐)면 추천 요청 없음 (약점 추천 잠금)
final homeOverviewProvider = FutureProvider.autoDispose<HomeOverview>((
  ref,
) async {
  if (ref.watch(currentMemberUuidProvider) == null) return const HomeOverview();
  final greeting = SafeCallSlot(ref.read(homeApiProvider).getGreeting());
  // 추천만 등급 첫 조회 뒤 판정 (다른 요청은 기다리지 않음, 슬롯은 모두 바로 묶음)
  final questionApi = ref.read(questionApiProvider);
  final recommendations = SafeCallSlot(
    resolveShouldShowProUi(ref).then<RecommendationsResponse?>(
      (isRecommendationLocked) => isRecommendationLocked
          ? null
          : questionApi.getRecommendations(
              const RecommendationsRequest(size: 3),
            ),
    ),
  );
  final examSchedule = SafeCallSlot(
    ref.read(examScheduleApiProvider).getSelectedSchedule(),
  );
  await safeCallAll([greeting, recommendations, examSchedule]);
  return HomeOverview(
    greeting: greeting.value,
    recommendations: recommendations.value,
    examSchedule: examSchedule.value,
  );
});

/// 진행 현황·오늘의 세트·히트맵 3개 병렬 호출. 풀이 후 갱신 대상(refreshLearningData)
/// 로그아웃이면 빈 묶음 (API 호출 없음)
final homeLearningStatusProvider =
    FutureProvider.autoDispose<HomeLearningStatus>((ref) async {
  if (ref.watch(currentMemberUuidProvider) == null) {
    return const HomeLearningStatus();
  }
  final progressClient = ref.read(progressApiProvider);
  final progress = SafeCallSlot(progressClient.getProgress());
  final dailySet = SafeCallSlot(ref.read(dailySetApiProvider).getToday());
  // getHeatmap(from, to): null 이면 서버 기본 기간
  final heatmap = SafeCallSlot(progressClient.getHeatmap(null, null));
  await safeCallAll([progress, dailySet, heatmap]);
  return HomeLearningStatus(
    progress: progress.value,
    dailySet: dailySet.value,
    heatmap: heatmap.value,
  );
});

/// 홈 화면 데이터: [homeOverviewProvider] + [homeLearningStatusProvider] 합침
///
/// 한 묶음만 다시 받아도 다른 묶음은 캐시를 그대로 쓴다.
/// 한쪽 실패는 그 섹션만 숨기고, 양쪽 다 실패(서버 장애·네트워크 끊김)하면 오류 화면 (#375).
/// 인증 만료는 삼키지 않고 다시 던짐 (로그인 화면 전환)
final homeDataProvider = FutureProvider.autoDispose<HomeData>((ref) async {
  // 두 묶음 동시 대기 (각 오류는 결과로 받아 미처리 예외 방지)
  final overviewOutcome = _settle(ref.watch(homeOverviewProvider.future));
  final learningOutcome = _settle(
    ref.watch(homeLearningStatusProvider.future),
  );
  final (overview, overviewError) = await overviewOutcome;
  final (learning, learningError) = await learningOutcome;

  // 실패 판정 (인증 만료 우선 > 양쪽 실패)
  for (final error in [overviewError, learningError]) {
    if (error is AppException && error.isUnauthorized) throw error;
  }
  if (overviewError != null && learningError != null) throw overviewError;

  return HomeData(
    greeting: overview?.greeting,
    progress: learning?.progress,
    dailySet: learning?.dailySet,
    recommendations: overview?.recommendations,
    examSchedule: overview?.examSchedule,
    heatmap: learning?.heatmap,
  );
});

/// 결과 또는 오류 > (값, 오류) 쌍
Future<(T?, Object?)> _settle<T>(Future<T> load) => load.then<(T?, Object?)>(
  (value) => (value, null),
  onError: (Object error) => (null, error),
);

/// 홈 전체 다시 받기 (당겨서 새로고침·재시도·날짜 변경·계정 전환 공통)
void invalidateHomeData(void Function(ProviderOrFamily provider) invalidate) {
  invalidate(homeOverviewProvider);
  invalidate(homeLearningStatusProvider);
  // 테스트에서 합친 Provider 만 override 해도 다시 불러오도록 함께 비움
  invalidate(homeDataProvider);
}
