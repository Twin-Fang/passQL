import 'package:flutter/material.dart';
import '../../../data/models/progress/progress_response.dart';
import '../../design/design.dart';

/// 상단 3개 요약 통계 카드 Row.
/// solvedCount / correctRate(%) / streakDays
class SummaryStatsSection extends StatelessWidget {
  final ProgressResponse? progress;

  const SummaryStatsSection({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final solved = progress?.solvedCount ?? 0;
    final rate = progress != null ? (progress!.correctRate * 100).round() : 0;
    final streak = progress?.streakDays ?? 0;

    return Row(
      children: [
        Expanded(
          child: _StatCard(value: '$solved문제', label: '푼 문제'),
        ),
        const SizedBox(width: PqSpace.sm),
        Expanded(
          child: _StatCard(value: '$rate%', label: '정답률'),
        ),
        const SizedBox(width: PqSpace.sm),
        Expanded(
          child: _StatCard(value: '$streak일', label: '연속 학습'),
        ),
      ],
    );
  }
}

/// 개별 통계 카드.
class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final c = context.pq;
    return PqCard(
      padding: const EdgeInsets.symmetric(
        vertical: PqSpace.lg,
        horizontal: PqSpace.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 좁은 폭(320pt)이나 큰 글자에서 숫자가 넘치지 않게 줄여 맞춘다.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: PqType.title2.copyWith(color: c.label),
            ),
          ),
          const SizedBox(height: PqSpace.xxs),
          Text(
            label,
            style: PqType.caption.copyWith(color: c.secondaryLabel),
          ),
        ],
      ),
    );
  }
}
