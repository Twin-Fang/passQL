import 'package:flutter/cupertino.dart';

import '../../../data/models/progress/accuracy_detail_response.dart';
import '../../design/design.dart';
import 'study_stats_summaries.dart';

/// 오답 정리 (#909, 프로): 틀린 문제 중 다시 맞힌 비율 막대 + 최근 8주 주별 남은 오답 막대(이번 주만 강조).
/// 틀린 문제가 없으면 안내 한 줄
class WrongNoteProgressSection extends StatelessWidget {
  const WrongNoteProgressSection({super.key, required this.accuracyDetail});

  final AccuracyDetailResponse accuracyDetail;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final everWrongCount = accuracyDetail.everWrongQuestionCount;
    final clearedCount = accuracyDetail.clearedWrongQuestionCount;
    final trend = accuracyDetail.remainingWrongTrend;
    final remainingCount = everWrongCount - clearedCount;
    final change = weeklyRemainingWrongChange(trend);
    return PassqlSection(
      title: '오답 정리',
      // 구간 제목 앞 아이콘: 프로필 구간 모두 같은 모양 (#971)
      leading: PassqlIconTile(
        icon: CupertinoIcons.xmark_square_fill,
        color: context.passqlColors.accent,
        isCompact: true,
      ),
      child: everWrongCount == 0
          ? Text(
              '아직 틀린 문제가 없어요',
              style: PassqlTypography.subheadline.copyWith(
                color: colors.secondaryLabel,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  clearedCount == 0
                      ? '틀린 문제 $everWrongCount개, 아직 다시 맞힌 문제는 없어요'
                      : '틀린 문제 $everWrongCount개 중 $clearedCount개를 다시 맞혔어요',
                  style: PassqlTypography.headline.copyWith(
                    color: colors.label,
                  ),
                ),
                const SizedBox(height: PassqlSpacing.xs),
                PassqlProgressBar(
                  value: clearedCount / everWrongCount,
                  fillColor: colors.correct,
                ),
                const SizedBox(height: PassqlSpacing.xs),
                Text(
                  _remainingLineOf(remainingCount, change),
                  style: PassqlTypography.subheadline.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
                if (trend.isNotEmpty) ...[
                  const SizedBox(height: PassqlSpacing.md),
                  Text(
                    '주마다 남은 오답',
                    style: PassqlTypography.footnoteSemibold.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(height: PassqlSpacing.xxs),
                  PassqlBarChart(
                    semanticLabel:
                        '최근 ${trend.length}주 남은 오답 막대, 이번 주 $remainingCount개',
                    restColor: colors.separator,
                    accentColor: colors.wrong,
                    bars: [
                      for (var index = 0; index < trend.length; index++)
                        PassqlBarChartBar(
                          totalValue: trend[index].remainingWrongCount
                              .toDouble(),
                          accentValue: index == trend.length - 1 ? null : 0,
                          label: index == trend.length - 1
                              ? '이번 주'
                              : toMonthDayLabel(trend[index].weekStartDate),
                        ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }

  /// 남은 오답 한 줄: 지난주와 비교 (같으면 그대로)
  String _remainingLineOf(int remainingCount, int? change) {
    final base = '아직 못 맞힌 문제 $remainingCount개';
    if (change == null) return base;
    if (change == 0) return '$base, 지난주와 같아요';
    return change < 0
        ? '$base, 지난주보다 ${change.abs()}개 줄었어요'
        : '$base, 지난주보다 $change개 늘었어요';
  }
}
