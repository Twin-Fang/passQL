import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/meta/topic_tree.dart';
import '../../../data/models/progress/ai_stats_analysis.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/topic_providers.dart';

/// 점수 올리기 좋은 영역 (#1111): 머리 한 줄 > 영역 행 최대 3개(이름·정답률·출제 문항 수, 오른쪽 +N점 ›)
/// 행을 누르면 그 영역 챕터 풀이. 계산·순서는 서버(ScoreGainTopicCalculator), 목록이 비면 자리 없음
class AiAnalysisScoreGainBlock extends ConsumerWidget {
  const AiAnalysisScoreGainBlock({super.key, required this.topics});

  final List<AiScoreGainTopic> topics;

  /// 기대 상승 점수 표기: 3.0 > "+3점", 3.6 > "+3.6점"
  static String gainLabelOf(double expectedGainScore) {
    final isWholeNumber = expectedGainScore == expectedGainScore.roundToDouble();
    final scoreText = isWholeNumber
        ? expectedGainScore.toStringAsFixed(0)
        : expectedGainScore.toStringAsFixed(1);
    return '+$scoreText점';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (topics.isEmpty) return const SizedBox.shrink();
    final colors = context.passqlColors;
    // 서버는 topicUuid 만 실음 > 챕터 경로가 받는 토픽 코드는 토픽 목록에서 짝지음 (바로 풀기 버튼과 같은 방식)
    final topicTrees =
        ref.watch(topicsProvider).valueOrNull ?? const <TopicTree>[];
    final topicTreeByUuid = {
      for (final topicTree in topicTrees) topicTree.topicUuid: topicTree,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 머리: 묶음 이름 + 계산 기준
        Row(
          children: [
            Expanded(
              child: Text(
                '점수 올리기 좋은 영역',
                style: PassqlTypography.footnoteSemibold.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
            ),
            Text(
              '정답률 ${topics.first.targetCorrectRatePercent}%까지 올리면',
              style: PassqlTypography.caption.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ],
        ),
        for (var index = 0; index < topics.length; index++) ...[
          if (index > 0)
            Container(height: PassqlSize.hairline, color: colors.separator),
          _ScoreGainRow(
            topic: topics[index],
            topicTree: topicTreeByUuid[topics[index].topicUuid],
          ),
        ],
      ],
    );
  }
}

/// 영역 한 줄: 이름 / 정답률 | 시험 N문항, 오른쪽 +N점 (토픽 목록에 없으면 누름 없음)
class _ScoreGainRow extends StatelessWidget {
  const _ScoreGainRow({required this.topic, required this.topicTree});

  final AiScoreGainTopic topic;
  final TopicTree? topicTree;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final gainLabel = AiAnalysisScoreGainBlock.gainLabelOf(
      topic.expectedGainScore,
    );
    final matchedTopicTree = topicTree;
    return PassqlListRow(
      title: topic.topicName,
      titleMaxLines: 1,
      subtitle:
          '정답률 ${topic.correctRatePercent}% | 시험 ${topic.examQuestionCount}문항',
      trailing: Text(
        gainLabel,
        style: PassqlTypography.subheadlineSemibold.copyWith(
          color: colors.accentText,
          fontFeatures: PassqlTypography.tabular,
        ),
      ),
      hasChevron: matchedTopicTree != null,
      hasHorizontalPadding: false,
      semanticLabel:
          '${topic.topicName}, 정답률 ${topic.correctRatePercent}%, 시험 ${topic.examQuestionCount}문항, 올리면 $gainLabel',
      // 문제 탭 토픽 목록과 같은 챕터 흐름
      onTap: matchedTopicTree == null
          ? null
          : () => context.push(
              AppRoutes.questionChapterOf(
                topicCode: matchedTopicTree.code,
                topicName: matchedTopicTree.displayName,
              ),
            ),
    );
  }
}
