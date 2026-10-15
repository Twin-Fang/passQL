import 'package:flutter/material.dart';

import '../../../data/models/progress/topic_stat.dart';
import '../../design/design.dart';

// 막대 양옆 고정 칸 폭: 토픽명(2줄까지), 문제 수(세 자리까지)
const double _topicLabelWidth = 100;
const double _countLabelWidth = 28;

/// 카테고리별 문제 수 가로 막대 차트 섹션.
/// totalQuestionCount 기준으로 막대 길이 비율 결정.
class BarChartSection extends StatelessWidget {
  final List<TopicStat>? topicStats;

  const BarChartSection({super.key, required this.topicStats});

  @override
  Widget build(BuildContext context) {
    return PassqlCard(title: '카테고리별 문제 수', child: _buildBars(context));
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

    // 가장 큰 totalQuestionCount 기준으로 막대 비율 계산
    final maxCount = stats
        .map((stat) => stat.totalQuestionCount)
        .reduce((larger, other) => larger > other ? larger : other);

    return Column(
      children: stats.map((stat) {
        final ratio = maxCount > 0 ? stat.totalQuestionCount / maxCount : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: PassqlSpacing.sm),
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
              // 문제 수 숫자
              SizedBox(
                width: _countLabelWidth,
                child: Text(
                  stat.totalQuestionCount.toString(),
                  style: PassqlTypography.caption.copyWith(
                    color: colors.secondaryLabel,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
