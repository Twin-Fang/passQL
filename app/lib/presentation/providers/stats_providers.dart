import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/sources/api_providers.dart';
import '../../core/network/safe_call.dart';
import '../../data/models/progress/progress_response.dart';
import '../../data/models/progress/topic_analysis_response.dart';
import '../../data/models/progress/ai_comment_response.dart';
import 'pro_ui_providers.dart';
import 'session_reset.dart';

/// 통계 화면 집계 모델.
/// 각 필드 nullable — API 실패 시 해당 섹션 graceful 숨김.
class StatsData {
  final ProgressResponse? progress;
  final TopicAnalysisResponse? topicAnalysis;

  const StatsData({this.progress, this.topicAnalysis});
}

/// 통계 화면 데이터 Provider: progress + topicAnalysis 2개 병렬 호출.
/// AI 코멘트는 느려도 화면을 막지 않게 [statsAiCommentProvider] 로 따로 받는다 (#495).
/// 로그아웃이면 빈 통계 (API 호출 없음), 무료(결제 켜짐)면 토픽 분석 요청 없음 (잠금)
final statsDataProvider = FutureProvider.autoDispose<StatsData>((ref) async {
  if (ref.watch(currentMemberUuidProvider) == null) return const StatsData();
  final progressClient = ref.read(progressApiProvider);

  // 진행 현황(progress)이 실패하면 "0문제·0%"로 그려져 기록이 사라진 것처럼 보이므로 오류로 처리한다 (#375).
  final progress = SafeCallSlot(progressClient.getProgress(), isRequired: true);
  // 토픽 분석만 등급 첫 조회 뒤 판정 (진행 현황은 기다리지 않음)
  final topicAnalysis = SafeCallSlot(
    resolveShouldShowProUi(ref).then<TopicAnalysisResponse?>(
      (isTopicAnalysisLocked) =>
          isTopicAnalysisLocked ? null : progressClient.getTopicAnalysis(),
    ),
  );
  await safeCallAll([progress, topicAnalysis]);

  return StatsData(
    progress: progress.value,
    topicAnalysis: topicAnalysis.value,
  );
});

/// 통계 화면 AI 코멘트. 실패하면 null(카드 숨김), 무료(결제 켜짐)면 요청 없이 null (잠금)
/// 서버가 2시간 캐시하므로 풀이마다 다시 받지 않는다(로그아웃 때만 비움)
final statsAiCommentProvider = FutureProvider.autoDispose<AiCommentResponse?>((
  ref,
) async {
  if (ref.watch(currentMemberUuidProvider) == null) return null;
  final progressClient = ref.read(progressApiProvider);
  if (await resolveShouldShowProUi(ref)) return null;
  return safeCall(progressClient.getAiComment(), label: 'statsAiComment');
});
