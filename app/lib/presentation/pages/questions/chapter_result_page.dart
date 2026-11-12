import 'package:flutter/cupertino.dart';
import '../../../presentation/providers/chapter_providers.dart';
import '../../../router/solving_flow_exit.dart';
import '../../design/design.dart';
import '../../widgets/ads/rewarded_interstitial_on_result.dart';
import '../../widgets/notification/study_result_seen_recorder.dart';
import '../../widgets/result/solved_question_list_section.dart';

/// 챕터 완료 결과 화면: 점수 고리 > 분석(피드백·시간) > 푼 문제(틀린 문제 먼저)
///
/// 이동 인자 [summary] 로 렌더링 (없으면 결과 없음 화면).
class ChapterResultPage extends StatelessWidget {
  final ChapterSummary? summary;

  const ChapterResultPage({super.key, this.summary});

  @override
  Widget build(BuildContext context) {
    final summary = this.summary;
    if (summary == null) {
      return PassqlStatusScaffold(
        title: '챕터 결과',
        leading: PassqlNavLeading.close,
        onLeadingTap: () => leaveSolvingFlow(context),
        body: PassqlStatusView.empty(
          icon: CupertinoIcons.exclamationmark_circle,
          title: '결과를 불러올 수 없어요',
        ),
      );
    }

    final correctCount = summary.results
        .where((result) => result.isCorrect)
        .length;
    final total = summary.results.length;

    // 챕터를 끝까지 푼 진입에만 보상형 전면 광고 제안 (결과 없음 화면은 제외, #963)
    // 결과를 본 기록 > 탭 화면 복귀 때 알림 권한 사전 안내 시점
    return StudyResultSeenRecorder(
      child: RewardedInterstitialOnEnter(
        child: PassqlResultScaffold(
          title: '챕터 결과',
          onClose: () => leaveSolvingFlow(context),
          header: PassqlScoreHeader(
            score: correctCount,
            total: total,
            caption: summary.topicName,
          ),
          sections: [
            // 정답 수·정답률은 점수 고리가 보여 줌 > 분석은 피드백과 시간만
            PassqlCard(
              title: '분석',
              child: _Analysis(
                total: total,
                correctCount: correctCount,
                totalDurationMs: summary.totalDurationMs,
              ),
            ),
            SolvedQuestionListSection(
              solvedQuestions: [
                for (final result in summary.results)
                  (
                    questionUuid: result.questionUuid,
                    isCorrect: result.isCorrect,
                  ),
              ],
              isTopicShown: false,
            ),
          ],
          actions: [
            PassqlButton(
              label: '완료',
              onPressed: () => leaveSolvingFlow(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// 정확도에 따른 한 줄 피드백과 풀이 시간(전체·문제당 평균).
class _Analysis extends StatelessWidget {
  const _Analysis({
    required this.total,
    required this.correctCount,
    required this.totalDurationMs,
  });
  final int total;
  final int correctCount;
  final int totalDurationMs;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final accuracy = total > 0 ? (correctCount / total * 100).round() : 0;
    final totalSec = (totalDurationMs / 1000).round();
    final avgSec = total > 0
        ? (totalDurationMs / total / 1000).toStringAsFixed(1)
        : '0';

    final String feedback;
    if (accuracy >= 90) {
      feedback = '훌륭해요! 이 토픽을 완벽히 이해하고 있어요.';
    } else if (accuracy >= 70) {
      feedback = '잘 하고 있어요! 틀린 문제를 다시 복습해보세요.';
    } else if (accuracy >= 50) {
      feedback = '조금 더 연습이 필요해요. 오답 문제를 꼭 확인하세요.';
    } else {
      feedback = '다시 한 번 도전해보세요. 꾸준히 풀다 보면 실력이 쌓여요!';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          feedback,
          style: PassqlTypography.callout.copyWith(color: colors.label),
        ),
        const SizedBox(height: PassqlSpacing.xs),
        Text(
          '모두 $totalSec초 · 문제당 평균 $avgSec초',
          style: PassqlTypography.footnote.copyWith(
            color: colors.secondaryLabel,
          ),
        ),
      ],
    );
  }
}
