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

/// 홈 첫 표시에 필요한 API 응답을 담는 집계 모델.
/// 각 필드는 nullable — API 실패 시 해당 섹션을 graceful하게 숨김 처리.
/// 추천 문제는 등급 확인 > 추천 직렬이라 가장 늦어서 빼고 [homeRecommendationsProvider] 로 따로 채운다 (#676)
class HomeData {
  final GreetingResponse? greeting;
  final ProgressResponse? progress;
  final DailySetTodayResponse? dailySet;
  final ExamScheduleResponse? examSchedule;
  final HeatmapResponse? heatmap;

  const HomeData({
    this.greeting,
    this.progress,
    this.dailySet,
    this.examSchedule,
    this.heatmap,
  });
}

/// 홈 데이터 중 풀이와 무관한 묶음: 인사말·시험 일정 (추천 문제는 잠금 판정이 걸려 따로)
class HomeOverview {
  final GreetingResponse? greeting;
  final ExamScheduleResponse? examSchedule;

  const HomeOverview({this.greeting, this.examSchedule});
}

/// 홈 데이터 중 풀이마다 바뀌는 묶음: 진행 현황·오늘의 세트 상태·히트맵
class HomeLearningStatus {
  final ProgressResponse? progress;
  final DailySetTodayResponse? dailySet;
  final HeatmapResponse? heatmap;

  const HomeLearningStatus({this.progress, this.dailySet, this.heatmap});
}

/// 선택한 시험 일정 하나 (홈 상단 바·내 프로필 탑승권 공용, #749). 선택이 없거나 실패하면 null
/// 내 프로필이 인사말까지 다시 부르지 않도록 홈 묶음에서 떼어 냈다
final examScheduleProvider = FutureProvider.autoDispose<ExamScheduleResponse?>((
  ref,
) async {
  if (ref.watch(currentMemberUuidProvider) == null) return null;
  return safeCall<ExamScheduleResponse?>(
    ref.read(examScheduleApiProvider).getSelectedSchedule(),
    label: 'examSchedule',
  );
});

/// 내 프로필 빈 상태(푼 문제 0개)의 버튼 분기용 오늘의 세트 (#749). 홈 학습 묶음(진행·히트맵 포함)을 부르지 않으려고 따로 둔다
final profileDailySetProvider =
    FutureProvider.autoDispose<DailySetTodayResponse?>((ref) async {
      if (ref.watch(currentMemberUuidProvider) == null) return null;
      return safeCall(
        ref.read(dailySetApiProvider).getToday(),
        label: 'profileDailySet',
      );
    });

/// 인사말·시험 일정 2개 병렬 호출. 날짜가 바뀌거나 직접 새로고침할 때만 다시 받는다
/// 로그아웃이면 빈 묶음 (API 호출 없음)
final homeOverviewProvider = FutureProvider.autoDispose<HomeOverview>((
  ref,
) async {
  if (ref.watch(currentMemberUuidProvider) == null) return const HomeOverview();
  final greeting = SafeCallSlot(ref.read(homeApiProvider).getGreeting());
  // 시험 일정은 내 프로필과 같은 Provider 를 쓴다 (한 번 받아 두 화면 공유, #749)
  final examSchedule = SafeCallSlot(ref.watch(examScheduleProvider.future));
  await safeCallAll([greeting, examSchedule]);
  return HomeOverview(
    greeting: greeting.value,
    examSchedule: examSchedule.value,
  );
});

/// 추천 문제 3개. 실패하면 null(섹션 숨김), 무료(결제 켜짐)면 요청 없이 null (약점 추천 잠금)
/// 잠금 판정은 이 Provider 만 구독 > 판정이 바뀌어도 인사말·일정은 다시 받지 않음
final homeRecommendationsProvider =
    FutureProvider.autoDispose<RecommendationsResponse?>((ref) async {
      if (ref.watch(currentMemberUuidProvider) == null) return null;
      final questionApi = ref.read(questionApiProvider);
      if (await watchIsProFeatureLocked(ref)) return null;
      return safeCall(
        questionApi.getRecommendations(const RecommendationsRequest(size: 3)),
        label: 'homeRecommendations',
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

/// 홈 화면 데이터: [homeOverviewProvider] + [homeLearningStatusProvider] 합침 (추천 문제는 기다리지 않음, #676)
///
/// 한 묶음만 다시 받아도 다른 묶음은 캐시를 그대로 쓴다.
/// 한 묶음 실패는 그 섹션만 숨기고, 개요·학습 둘 다 실패(서버 장애·네트워크 끊김)하면 오류 화면 (#375).
/// 인증 만료는 삼키지 않고 다시 던짐 (로그인 화면 전환)
final homeDataProvider = FutureProvider.autoDispose<HomeData>((ref) async {
  // 두 묶음 동시 대기 (각 오류는 결과로 받아 미처리 예외 방지)
  final overviewOutcome = _settle(ref.watch(homeOverviewProvider.future));
  final learningOutcome = _settle(ref.watch(homeLearningStatusProvider.future));
  final (overview, overviewError) = await overviewOutcome;
  final (learning, learningError) = await learningOutcome;

  // 실패 판정 (인증 만료 우선 > 개요·학습 둘 다 실패)
  for (final error in [overviewError, learningError]) {
    if (error is AppException && error.isUnauthorized) throw error;
  }
  if (overviewError != null && learningError != null) throw overviewError;

  return HomeData(
    greeting: overview?.greeting,
    progress: learning?.progress,
    dailySet: learning?.dailySet,
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
  // 개요는 공유 시험 일정을 watch 만 해서, 일정까지 비워야 새로 받는다 (#749)
  invalidate(examScheduleProvider);
  invalidate(homeRecommendationsProvider);
  invalidate(homeLearningStatusProvider);
  // 테스트에서 합친 Provider 만 override 해도 다시 불러오도록 함께 비움
  invalidate(homeDataProvider);
}
