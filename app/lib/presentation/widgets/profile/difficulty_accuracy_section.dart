import 'package:flutter/cupertino.dart';

import '../../../data/models/progress/difficulty_stat.dart';
import '../../design/design.dart';
import 'topic_accuracy_rows.dart';

// 정답률 숫자 칸 폭 (100% 까지 오른쪽 맞춤)
const double _percentColumnWidth = 44;
// 별 칸 폭 (별 아이콘 다섯 개가 한 줄)
const double _starColumnWidth = 72;

/// 난이도별 정답률 (#909, 프로): 단계마다 별 + 막대 + 정답률 + 푼 문제 수, 약한 단계(60% 미만)는 빨강.
/// 전체 기록, 문제마다 마지막 풀이 기준. 푼 단계가 없으면 그리지 않음
class DifficultyAccuracySection extends StatelessWidget {
  const DifficultyAccuracySection({super.key, required this.difficultyStats});

  final List<DifficultyStat> difficultyStats;

  @override
  Widget build(BuildContext context) {
    if (difficultyStats.isEmpty) return const SizedBox.shrink();
    final colors = context.passqlColors;
    return PassqlSection(
      title: '난이도별 정답률',
      // 구간 제목 앞 아이콘: 프로필 구간 모두 같은 모양 (#971)
      leading: PassqlIconTile(
        icon: CupertinoIcons.chart_bar_fill,
        color: context.passqlColors.accent,
        isCompact: true,
      ),
      trailing: Text(
        '전체 기록',
        style: PassqlTypography.footnote.copyWith(color: colors.secondaryLabel),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final stat in difficultyStats) _DifficultyRow(stat: stat),
          const SizedBox(height: PassqlSpacing.xs),
          Text(
            '같은 문제는 마지막으로 푼 결과만 세요',
            style: PassqlTypography.caption.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyRow extends StatelessWidget {
  const _DifficultyRow({required this.stat});

  final DifficultyStat stat;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final percent = (stat.correctRate * 100).round();
    final isWeak = stat.correctRate < weakAccuracyThreshold;
    return Semantics(
      container: true,
      label: '난이도 ${stat.difficulty}, ${stat.solvedCount}문제, 정답률 $percent%',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: PassqlSpacing.xs),
          child: Row(
            children: [
              SizedBox(
                width: _starColumnWidth,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: PassqlDifficultyStars(difficulty: stat.difficulty),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PassqlProgressBar(
                      value: stat.correctRate,
                      fillColor: isWeak ? colors.wrong : null,
                    ),
                    const SizedBox(height: PassqlSpacing.xxs),
                    Text(
                      '${stat.solvedCount}문제',
                      style: PassqlTypography.caption.copyWith(
                        color: colors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: _percentColumnWidth,
                child: Text(
                  '$percent%',
                  textAlign: TextAlign.right,
                  style: PassqlTypography.subheadlineSemibold.copyWith(
                    color: isWeak ? colors.wrongText : colors.label,
                    fontFeatures: PassqlTypography.tabular,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
