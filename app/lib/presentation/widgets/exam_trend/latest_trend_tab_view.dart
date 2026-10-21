import 'package:flutter/cupertino.dart';

import '../../../data/models/exam_trend/exam_trend_report_response.dart';
import '../../design/design.dart';
import 'exam_trend_sections.dart';

/// 문제 탭 '최신 경향' 보기: 머리(요약, 최신 경향 문제 총 개수) > 과목 비중 > 늘어난 유형 > 광고 자리 > 공부 팁
/// 광고 위젯은 호출한 화면이 [adSlot] 으로 꽂음 (없으면 자리 없음)
class LatestTrendTabView extends StatelessWidget {
  const LatestTrendTabView({
    super.key,
    required this.report,
    required this.onSolveTopic,
    this.adSlot,
  });

  final ExamTrendReportResponse report;
  final void Function(String topicCode, String topicName) onSolveTopic;
  final Widget? adSlot;

  @override
  Widget build(BuildContext context) {
    final sectionsBeforeAd = <Widget>[
      _LatestTrendHeader(report: report),
      if (report.subjectShares.isNotEmpty)
        ExamTrendSubjectShareSection(subjectShares: report.subjectShares),
      if (report.risingPatterns.isNotEmpty)
        ExamTrendPatternSection(
          patterns: report.risingPatterns,
          onSolveTopic: onSolveTopic,
        ),
    ];
    final sectionsAfterAd = <Widget>[
      if (report.studyTips.isNotEmpty)
        ExamTrendStudyTipSection(studyTips: report.studyTips),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 섹션이 위에서부터 차례로 떠오른다
        for (final (index, section) in sectionsBeforeAd.indexed) ...[
          if (index > 0) const SizedBox(height: PassqlSpacing.lg),
          PassqlReveal(index: index, child: section),
        ],
        // 광고 자리 (간격 없이 붙임: 광고가 안 뜨면 높이 0 > 위아래 간격이 겹치지 않음)
        ?adSlot,
        for (final (offset, section) in sectionsAfterAd.indexed) ...[
          const SizedBox(height: PassqlSpacing.lg),
          PassqlReveal(index: sectionsBeforeAd.length + offset, child: section),
        ],
      ],
    );
  }
}

/// 머리 카드: 최신 경향 배지 + 요약 + 풀 수 있는 최신 경향 문제 총 개수
class _LatestTrendHeader extends StatelessWidget {
  const _LatestTrendHeader({required this.report});

  final ExamTrendReportResponse report;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PassqlLatestTrendBadge(),
          const SizedBox(height: PassqlSpacing.xs),
          Text(
            report.summary,
            style: PassqlTypography.headline.copyWith(color: colors.label),
          ),
          const SizedBox(height: PassqlSpacing.xxs),
          Text(
            '${report.basisDescription} · ${report.updatedDate} 갱신',
            style: PassqlTypography.caption.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          if (report.latestTrendQuestionCount > 0) ...[
            const SizedBox(height: PassqlSpacing.sm),
            Text(
              '최신 경향 문제 총 ${report.latestTrendQuestionCount}개',
              style: PassqlTypography.footnoteSemibold.copyWith(
                color: colors.accent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
