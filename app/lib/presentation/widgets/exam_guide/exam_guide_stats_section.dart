import 'package:flutter/cupertino.dart';

import '../../../core/utils/number_format.dart';
import '../../../data/models/meta/sqld_exam_guide.dart';
import '../../design/design.dart';
import 'exam_guide_insight_cards.dart';
import 'exam_guide_source_footnote.dart';
import 'exam_round_note_timeline.dart';
import 'exam_statistics_chart.dart';

/// 역대 통계 탭 (#1077): 최근 연도 헤드라인 > 연도별 차트 > 인사이트 > 최근 회차 이야기 > 출처
class ExamGuideStatsSection extends StatelessWidget {
  const ExamGuideStatsSection({super.key, required this.guide});

  final SqldExamGuide guide;

  @override
  Widget build(BuildContext context) {
    final statistics = guide.yearlyStatistics;
    if (statistics.isEmpty) {
      return PassqlStatusView.empty(
        icon: CupertinoIcons.chart_bar,
        title: '아직 통계가 없어요',
        message: '공식 통계가 올라오면 여기에 보여 드릴게요',
      );
    }
    final latest = statistics.last;
    final latestComparison = guide.comparisons.isEmpty
        ? null
        : (guide.comparisons.toList()..sort((a, b) => b.year.compareTo(a.year)))
              .first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LatestYearHeadline(latest: latest),
        const SizedBox(height: PassqlSpacing.md),
        PassqlCard(
          title: '연도별 응시자와 합격률',
          child: ExamStatisticsChart(statistics: statistics),
        ),
        const SizedBox(height: PassqlSpacing.md),
        ExamGuideInsightCards(
          insights: guide.insights,
          latestComparison: latestComparison,
        ),
        if (guide.roundNotes.isNotEmpty) ...[
          const SizedBox(height: PassqlSpacing.xl),
          ExamRoundNoteTimeline(roundNotes: guide.roundNotes),
        ],
        const SizedBox(height: PassqlSpacing.lg),
        ExamGuideSourceFootnote(sources: guide.sources),
      ],
    );
  }
}

/// 최근 연도 응시자 수 카운트업 + 합격자·합격률 한 줄
class _LatestYearHeadline extends StatelessWidget {
  const _LatestYearHeadline({required this.latest});

  final SqldYearlyStatistic latest;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Semantics(
      label:
          '${latest.year}년 응시자 ${latest.examineeCount}명, 합격률 ${latest.passRatePercent}퍼센트',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${latest.year}년 한 해 동안',
              style: PassqlTypography.subheadline.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
            PassqlCountUp(
              value: latest.examineeCount,
              builder: (context, value) => Text(
                '${formatThousands(value)}명이 응시했어요',
                style: PassqlTypography.title1.copyWith(color: colors.label),
              ),
            ),
            const SizedBox(height: PassqlSpacing.xxs),
            Text(
              '합격 ${formatThousands(latest.passerCount)}명, 합격률 ${latest.passRatePercent.toStringAsFixed(2)}%',
              style: PassqlTypography.headline.copyWith(
                color: colors.accentText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
