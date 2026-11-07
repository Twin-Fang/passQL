import 'package:flutter/cupertino.dart';

import '../../../data/models/progress/study_pattern_response.dart';
import '../../design/design.dart';
import 'study_stats_summaries.dart';

// 시간대 축 글자를 적는 간격 (시, 0·6·12·18시)
const int _hourLabelEveryHours = 6;
// 요일·시간대 막대 높이 (날짜별 막대보다 낮게, 두 장이 한 구간에 들어감)
const double _patternChartHeight = 72;

/// 공부하는 시간 (#909, 무료): 최근 12주 요일별·시간대별 풀이 막대, 가장 많이 푼 칸만 강조색.
/// 서버가 가장 많은 칸을 판정하지 않으면(풀이가 최소 미만) 막대 대신 몇 문제부터 보이는지 안내
class StudyTimePatternSection extends StatelessWidget {
  const StudyTimePatternSection({super.key, required this.studyPattern});

  final StudyPatternResponse studyPattern;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final weekdayCounts = studyPattern.weekdayAttemptCounts;
    final hourCounts = studyPattern.hourAttemptCounts;
    final attemptCount = studyPattern.patternAttemptCount;
    final busiestWeekday = studyPattern.busiestWeekdayIndex;
    final busiestHour = studyPattern.busiestHour;
    final weekCount = studyPattern.patternWindowDays ~/ DateTime.daysPerWeek;
    // 가장 많은 칸은 서버가 최소 풀이 수를 넘을 때만 줌 (모양이 어긋난 응답은 안내로)
    final hasEnoughAttempts =
        busiestWeekday != null &&
        busiestHour != null &&
        weekdayCounts.length == weekdayShortNames.length &&
        busiestWeekday < weekdayCounts.length &&
        busiestHour < hourCounts.length;
    return PassqlSection(
      title: '공부하는 시간',
      trailing: Text(
        '최근 $weekCount주',
        style: PassqlTypography.footnote.copyWith(color: colors.secondaryLabel),
      ),
      child: hasEnoughAttempts
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${weekdayShortNames[busiestWeekday]}요일, '
                  '${toSpokenHourLabel(busiestHour)}대에 가장 많이 풀었어요',
                  style: PassqlTypography.headline.copyWith(
                    color: colors.label,
                  ),
                ),
                const SizedBox(height: PassqlSpacing.md),
                _ChartCaption(label: '요일'),
                const SizedBox(height: PassqlSpacing.xxs),
                PassqlBarChart(
                  height: _patternChartHeight,
                  semanticLabel:
                      '요일별 풀이 막대, ${weekdayShortNames[busiestWeekday]}요일 '
                      '${weekdayCounts[busiestWeekday]}문제로 가장 많음',
                  bars: [
                    for (var index = 0; index < weekdayCounts.length; index++)
                      PassqlBarChartBar(
                        totalValue: weekdayCounts[index].toDouble(),
                        accentValue: index == busiestWeekday ? null : 0,
                        label: weekdayShortNames[index],
                      ),
                  ],
                ),
                const SizedBox(height: PassqlSpacing.md),
                _ChartCaption(label: '시간대'),
                const SizedBox(height: PassqlSpacing.xxs),
                PassqlBarChart(
                  height: _patternChartHeight,
                  semanticLabel:
                      '시간대별 풀이 막대, ${toSpokenHourLabel(busiestHour)}대 '
                      '${hourCounts[busiestHour]}문제로 가장 많음',
                  bars: [
                    for (var hour = 0; hour < hourCounts.length; hour++)
                      PassqlBarChartBar(
                        totalValue: hourCounts[hour].toDouble(),
                        accentValue: hour == busiestHour ? null : 0,
                        label: hour % _hourLabelEveryHours == 0
                            ? '$hour시'
                            : null,
                      ),
                  ],
                ),
              ],
            )
          : Text(
              attemptCount == 0
                  ? '최근 $weekCount주 동안 푼 문제가 없어요'
                  : '${studyPattern.minimumPatternAttemptCount}문제 이상 풀면 자주 공부하는 요일과 시간이 보여요 '
                        '(지금 $attemptCount문제)',
              style: PassqlTypography.subheadline.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
    );
  }
}

/// 차트 위 작은 이름
class _ChartCaption extends StatelessWidget {
  const _ChartCaption({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: PassqlTypography.footnoteSemibold.copyWith(
        color: context.passqlColors.secondaryLabel,
      ),
    );
  }
}
