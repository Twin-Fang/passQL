import 'package:flutter/cupertino.dart';

import '../../../data/models/progress/heatmap_response.dart';
import '../../../data/models/progress/study_pattern_response.dart';
import '../../design/design.dart';
import 'study_stats_summaries.dart';

// 날짜 축 글자를 적는 간격 (일, 한 주마다) > 마지막 칸은 '오늘'
const int _dateLabelEveryDays = 7;
const double _legendDotSize = 8;

/// 최근 4주 학습 (#909, 무료): 요약 두 줄 + 날짜별 쌓은 막대(맞힘 강조색, 틀림 회색) + 전체 기록 칸 두 개.
/// 4주 동안 푼 문제가 없으면 막대 대신 안내 한 줄 (전체 기록 칸은 그대로)
class StudyRecordSection extends StatelessWidget {
  const StudyRecordSection({super.key, required this.studyPattern});

  final StudyPatternResponse studyPattern;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final records = studyPattern.dailyRecords;
    final weekCount = studyPattern.dailyWindowDays ~/ DateTime.daysPerWeek;
    return PassqlSection(
      title: '최근 $weekCount주 학습',
      // 구간 제목 앞 아이콘: 프로필 구간 모두 같은 모양 (#971)
      leading: PassqlIconTile(
        icon: CupertinoIcons.calendar,
        color: context.passqlColors.accent,
        isCompact: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (studyPattern.recentAttemptCount > 0) ...[
            Text(
              '$weekCount주 동안 ${studyPattern.recentStudyDayCount}일, '
              '${studyPattern.recentAttemptCount}문제 풀었어요',
              style: PassqlTypography.headline.copyWith(color: colors.label),
            ),
            const SizedBox(height: PassqlSpacing.hairlineGap),
            Text(
              _accuracyLineOf(),
              style: PassqlTypography.subheadline.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
            const SizedBox(height: PassqlSpacing.md),
            PassqlBarChart(
              semanticLabel:
                  '날짜별 풀이 막대, $weekCount주 동안 ${studyPattern.recentAttemptCount}문제 중 '
                  '${studyPattern.recentCorrectCount}문제 맞힘',
              bars: [
                for (var index = 0; index < records.length; index++)
                  PassqlBarChartBar(
                    totalValue: records[index].solvedCount.toDouble(),
                    accentValue: records[index].correctCount.toDouble(),
                    label: _dateLabelAt(index, records),
                  ),
              ],
            ),
            const SizedBox(height: PassqlSpacing.xs),
            Row(
              children: [
                _LegendItem(color: colors.accent, label: '맞힘'),
                const SizedBox(width: PassqlSpacing.md),
                _LegendItem(color: colors.accentTint, label: '틀림'),
              ],
            ),
          ] else
            Text(
              '최근 $weekCount주 동안 푼 문제가 없어요',
              style: PassqlTypography.subheadline.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          const SizedBox(height: PassqlSpacing.md),
          Row(
            children: [
              Expanded(
                child: _RecordTile(
                  label: '지금까지 공부한 날',
                  amountText: '${studyPattern.totalStudyDayCount}일',
                ),
              ),
              const SizedBox(width: PassqlSpacing.xs),
              Expanded(
                child: _RecordTile(
                  label: '최장 연속 학습',
                  amountText: '${studyPattern.longestStreakDays}일',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 정답률 한 줄: 서버가 앞 2주와 비교해 준 변화가 있으면 함께
  String _accuracyLineOf() {
    final percent = toCorrectPercent(
      studyPattern.recentCorrectCount,
      studyPattern.recentAttemptCount,
    );
    final base = '정답률 $percent%';
    final change = studyPattern.accuracyChangePoints;
    if (change == null) return base;
    if (change == 0) return '$base, 앞 2주와 같아요';
    final direction = change > 0 ? '올랐어요' : '내려갔어요';
    return '$base, 앞 2주보다 ${change.abs()}%p $direction';
  }

  /// 축 글자: 첫 칸부터 한 주마다 날짜, 마지막 칸은 '오늘' (마지막과 겹치는 주 글자는 비움)
  String? _dateLabelAt(int index, List<HeatmapEntry> records) {
    final lastIndex = records.length - 1;
    if (index == lastIndex) return '오늘';
    final isWeekStep = index % _dateLabelEveryDays == 0;
    final isTooCloseToToday = lastIndex - index < _dateLabelEveryDays ~/ 2;
    if (!isWeekStep || isTooCloseToToday) return null;
    return toMonthDayLabel(records[index].date);
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _legendDotSize,
          height: _legendDotSize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(PassqlRadius.capsule),
          ),
        ),
        const SizedBox(width: PassqlSpacing.xxs),
        Text(
          label,
          style: PassqlTypography.caption.copyWith(
            color: context.passqlColors.secondaryLabel,
          ),
        ),
      ],
    );
  }
}

/// 전체 기록 칸: 회색 채움 위 작은 이름 + 큰 숫자
class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.label, required this.amountText});

  final String label;
  final String amountText;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return MergeSemantics(
      child: Container(
        padding: const EdgeInsets.all(PassqlSpacing.sm),
        decoration: BoxDecoration(
          color: colors.fill,
          borderRadius: BorderRadius.circular(PassqlRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: PassqlTypography.footnote.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
            const SizedBox(height: PassqlSpacing.hairlineGap),
            Text(
              amountText,
              style: PassqlTypography.title3.copyWith(
                color: colors.label,
                fontFeatures: PassqlTypography.tabular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
