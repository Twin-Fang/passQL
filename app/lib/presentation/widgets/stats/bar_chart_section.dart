import 'package:flutter/material.dart';

import '../../../data/models/progress/topic_stat.dart';
import '../../design/design.dart';

// 막대 양옆 고정 칸 폭: 토픽명(2줄까지), 푼 문제 수(세 자리까지)
const double _topicLabelWidth = 100;
const double _countLabelWidth = 28;

/// 카테고리별 푼 문제 가로 막대 차트 섹션.
/// solvedCount 기준, 가장 많이 푼 카테고리 대비 비율로 막대 길이 결정 (전체 문제 수는 노출하지 않음).
class BarChartSection extends StatelessWidget {
  final List<TopicStat>? topicStats;

  const BarChartSection({super.key, required this.topicStats});

  @override
  Widget build(BuildContext context) {
    return PassqlCard(title: '카테고리별 푼 문제', child: _buildBars(context));
  }

  Widget _buildBars(BuildContext context) {
    final colors = context.passqlColors;
    final stats = topicStats;

    if (stats == null || stats.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: PassqlSpacing.xl),
        child: Center(
          child: Text(
            '아직 학습 데이터가 없습니다',
            style: PassqlTypography.subheadline.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
        ),
      );
    }

    // 가장 많이 푼 카테고리 기준으로 막대 비율 계산 (모두 0이면 빈 막대)
    final maxSolvedCount = stats
        .map((stat) => stat.solvedCount)
        .reduce((larger, other) => larger > other ? larger : other);

    return Column(
      children: stats.map((stat) {
        final ratio = maxSolvedCount > 0 ? stat.solvedCount / maxSolvedCount : 0.0;

        // 행마다 '토픽명, N문제 풀었어요' 한 문장 (막대는 읽지 않음)
        return Padding(
          padding: const EdgeInsets.only(bottom: PassqlSpacing.sm),
          child: Semantics(
            label: '${stat.displayName}, ${stat.solvedCount}문제 풀었어요',
            excludeSemantics: true,
            child: Row(
              children: [
                // 토픽명 — 고정폭, 2줄까지 허용
                SizedBox(
                  width: _topicLabelWidth,
                  child: Text(
                    stat.displayName,
                    style: PassqlTypography.caption.copyWith(
                      color: colors.secondaryLabel,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: PassqlSpacing.xs),
                // 진행 막대 (accent / fill)
                Expanded(child: PassqlProgressBar(value: ratio)),
                const SizedBox(width: PassqlSpacing.xs),
                // 푼 문제 수 숫자
                SizedBox(
                  width: _countLabelWidth,
                  child: Text(
                    stat.solvedCount.toString(),
                    style: PassqlTypography.caption.copyWith(
                      color: colors.secondaryLabel,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
