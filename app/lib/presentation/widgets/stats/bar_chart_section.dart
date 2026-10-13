import 'package:flutter/material.dart';

import '../../../data/models/progress/topic_stat.dart';
import '../../design/design.dart';

/// 카테고리별 문제 수 가로 막대 차트 섹션.
/// totalQuestionCount 기준으로 막대 길이 비율 결정.
class BarChartSection extends StatelessWidget {
  final List<TopicStat>? topicStats;

  const BarChartSection({super.key, required this.topicStats});

  @override
  Widget build(BuildContext context) {
    return PqCard(title: '카테고리별 문제 수', child: _buildBars(context));
  }

  Widget _buildBars(BuildContext context) {
    final c = context.pq;
    final stats = topicStats;

    if (stats == null || stats.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: PqSpace.xl),
        child: Center(
          child: Text(
            '아직 학습 데이터가 없습니다',
            style: PqType.subheadline.copyWith(color: c.secondaryLabel),
          ),
        ),
      );
    }

    // 가장 큰 totalQuestionCount 기준으로 막대 비율 계산
    final maxCount = stats
        .map((s) => s.totalQuestionCount)
        .reduce((a, b) => a > b ? a : b);

    return Column(
      children: stats.map((stat) {
        final ratio = maxCount > 0 ? stat.totalQuestionCount / maxCount : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: PqSpace.sm),
          child: Row(
            children: [
              // 토픽명 — 고정폭, 2줄까지 허용
              SizedBox(
                width: 100,
                child: Text(
                  stat.displayName,
                  style: PqType.caption.copyWith(color: c.secondaryLabel),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: PqSpace.xs),
              // 진행 막대 (accent / fill)
              Expanded(child: PqProgressBar(value: ratio)),
              const SizedBox(width: PqSpace.xs),
              // 문제 수 숫자
              SizedBox(
                width: 28,
                child: Text(
                  stat.totalQuestionCount.toString(),
                  style: PqType.caption.copyWith(color: c.secondaryLabel),
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
