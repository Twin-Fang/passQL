import 'package:flutter/cupertino.dart';

import '../../design/design.dart';

/// 기록 탭 빈 상태: 푼 문제가 없을 때 요약·차트 대신 보이는 카드 1개 + 다음 행동 버튼 1개
/// 오늘의 세트를 풀 수 있으면 세트 풀기, 아니면 문제 탭으로 안내
class StatsEmptyStateCard extends StatelessWidget {
  const StatsEmptyStateCard({
    super.key,
    required this.hasDailySet,
    required this.onSolveDailySet,
    required this.onBrowseQuestions,
  });

  /// 오늘의 세트를 풀 수 있는지 (없으면 문제 탭 안내로 대체)
  final bool hasDailySet;
  final VoidCallback onSolveDailySet;
  final VoidCallback onBrowseQuestions;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlCard(
      padding: const EdgeInsets.all(PassqlSpacing.xl),
      child: Column(
        children: [
          ExcludeSemantics(
            child: Icon(
              CupertinoIcons.chart_bar,
              size: PassqlIconSize.statusPlaceholder,
              color: colors.iconSecondary,
            ),
          ),
          const SizedBox(height: PassqlSpacing.sm),
          Semantics(
            header: true,
            child: Text(
              '아직 푼 문제가 없어요',
              style: PassqlTypography.headline.copyWith(color: colors.label),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: PassqlSpacing.xxs),
          Text(
            '문제를 풀면 정답률과 학습 기록이 여기에 쌓여요.',
            style: PassqlTypography.subheadline.copyWith(
              color: colors.secondaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: PassqlSpacing.lg),
          PassqlButton(
            label: hasDailySet ? '오늘의 세트 풀기' : '문제 풀러 가기',
            onPressed: hasDailySet ? onSolveDailySet : onBrowseQuestions,
          ),
        ],
      ),
    );
  }
}
