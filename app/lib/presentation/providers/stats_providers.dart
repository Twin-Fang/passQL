import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_providers.dart';
import '../../core/network/safe_call.dart';
import '../../data/models/progress/progress_response.dart';
import '../../data/models/progress/topic_analysis_response.dart';
import '../../data/models/progress/ai_comment_response.dart';

/// 통계 화면 집계 모델.
/// 각 필드 nullable — API 실패 시 해당 섹션 graceful 숨김.
class StatsData {
  final ProgressResponse? progress;
  final TopicAnalysisResponse? topicAnalysis;
  final AiCommentResponse? aiComment;

  const StatsData({this.progress, this.topicAnalysis, this.aiComment});
}

/// 통계 화면 데이터 Provider.
/// progress + topicAnalysis + aiComment 3개 병렬 호출.
final statsDataProvider = FutureProvider<StatsData>((ref) async {
  final progressClient = ref.read(progressApiProvider);

  final results = await Future.wait([
    safeCall(progressClient.getProgress()),
    safeCall(progressClient.getTopicAnalysis()),
    safeCall(progressClient.getAiComment()),
  ]);

  return StatsData(
    progress: results[0] as ProgressResponse?,
    topicAnalysis: results[1] as TopicAnalysisResponse?,
    aiComment: results[2] as AiCommentResponse?,
  );
});
