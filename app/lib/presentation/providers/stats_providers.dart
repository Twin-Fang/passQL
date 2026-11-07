import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/sources/api_providers.dart';
import '../../core/network/safe_call.dart';
import '../../data/models/progress/progress_response.dart';
import '../../data/models/progress/topic_analysis_response.dart';
import '../../data/models/progress/ai_comment_response.dart';
import '../../data/models/progress/accuracy_detail_response.dart';
import '../../data/models/progress/study_pattern_response.dart';
import 'pro_ui_providers.dart';
import 'session_reset.dart';

/// 통계 화면 집계 모델.
/// 각 필드 nullable — API 실패 시 해당 섹션 graceful 숨김.
/// [studyPattern] 학습 패턴(무료), [accuracyDetail] 정답률 상세(프로, 잠금이면 null) (#909)
class StatsData {
  final ProgressResponse? progress;
  final TopicAnalysisResponse? topicAnalysis;
  final StudyPatternResponse? studyPattern;
  final AccuracyDetailResponse? accuracyDetail;

  const StatsData({
    this.progress,
    this.topicAnalysis,
    this.studyPattern,
    this.accuracyDetail,
  });
}

/// 통계 화면 데이터 Provider: progress + topicAnalysis + 학습 패턴 + 정답률 상세 병렬 호출 (구간이 따로 튀어나오지 않게 한 번에).
/// AI 코멘트는 느려도 화면을 막지 않게 [statsAiCommentProvider] 로 따로 받는다 (#495).
/// 로그아웃이면 빈 통계 (API 호출 없음), 무료(결제 켜짐)면 토픽 분석 요청 없음 (잠금)
final statsDataProvider = FutureProvider.autoDispose<StatsData>((ref) async {
  if (ref.watch(currentMemberUuidProvider) == null) return const StatsData();
  final progressClient = ref.read(progressApiProvider);

  // 진행 현황(progress)이 실패하면 "0문제·0%"로 그려져 기록이 사라진 것처럼 보이므로 오류로 처리한다 (#375).
  final progress = SafeCallSlot(progressClient.getProgress(), isRequired: true);
  final studyPattern = SafeCallSlot(progressClient.getStudyPattern());
  // 프로 묶음(토픽 분석·정답률 상세)만 잠금 판정 뒤 요청 (진행 현황은 기다리지 않음, 판정 값이 바뀔 때만 다시 실행)
  final isProStatsLocked = watchIsProFeatureLocked(ref);
  final topicAnalysis = SafeCallSlot(
    isProStatsLocked.then<TopicAnalysisResponse?>(
      (isLocked) => isLocked ? null : progressClient.getTopicAnalysis(),
    ),
  );
  final accuracyDetail = SafeCallSlot(
    isProStatsLocked.then<AccuracyDetailResponse?>(
      (isLocked) => isLocked ? null : progressClient.getAccuracyDetail(),
    ),
  );
  await safeCallAll([progress, topicAnalysis, studyPattern, accuracyDetail]);

  return StatsData(
    progress: progress.value,
    topicAnalysis: topicAnalysis.value,
    studyPattern: studyPattern.value,
    accuracyDetail: accuracyDetail.value,
  );
});

/// 통계 화면 AI 코멘트. 실패하면 오류 상태(화면은 다시 시도 자리, #862). 프로 전용 > 무료(결제 켜짐)면 요청 없이 null (화면은 잠금 자리, #860)
/// 서버 캐시: 최근 풀이 10문제마다 새 코멘트 > 풀이마다 다시 받아도 LLM 호출 없음
final statsAiCommentProvider = FutureProvider.autoDispose<AiCommentResponse?>((
  ref,
) async {
  if (ref.watch(currentMemberUuidProvider) == null) return null;
  if (await watchIsProFeatureLocked(ref)) return null;
  final progressClient = ref.read(progressApiProvider);
  // 한 칸짜리 묶음: 실패 기록·보고는 공통 지점에서, 실패면 오류로 던짐 (인증 만료는 그대로)
  final aiComment = SafeCallSlot(progressClient.getAiComment());
  await safeCallAll([aiComment]);
  return aiComment.value;
});
