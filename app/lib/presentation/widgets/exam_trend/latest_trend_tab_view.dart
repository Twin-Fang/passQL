import 'package:flutter/cupertino.dart';

import '../../../data/models/exam_trend/exam_trend_report_response.dart';
import '../../design/design.dart';
import 'exam_trend_sections.dart';

/// 문제 탭 '최신 경향' 보기: 요약 > 과목 비중 > 늘어난 유형 > 광고 자리 > 공부 팁
/// 홈처럼 좌우 끝까지 닿는 구간 사이에 띠 (#726). 광고 위젯은 호출한 화면이 [adSlot] 으로 꽂음 (없으면 자리 없음)
class LatestTrendTabView extends StatelessWidget {
  const LatestTrendTabView({
    super.key,
    required this.report,
    required this.onSolveTopic,
    this.adSlot,
  });

  final ExamTrendReportResponse report;
  final void Function(String topicCode, String topicName) onSolveTopic;

  /// 광고가 뜬 뒤에만 앞 띠 + 구간을 그리는 구간형 광고 (안 뜨면 높이 0)
  final Widget? adSlot;

  @override
  Widget build(BuildContext context) {
    final sectionsBeforeAd = <Widget>[
      ExamTrendSummarySection(report: report),
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
        // 구간이 위에서부터 차례로 떠오른다
        for (final (index, section) in sectionsBeforeAd.indexed) ...[
          if (index > 0) const PassqlSectionGap(),
          PassqlReveal(index: index, child: section),
        ],
        // 광고 자리: 앞 띠는 광고가 직접 그림 (광고가 안 뜨면 띠도 없어 띠가 겹치지 않음)
        ?adSlot,
        for (final (offset, section) in sectionsAfterAd.indexed) ...[
          const PassqlSectionGap(),
          PassqlReveal(index: sectionsBeforeAd.length + offset, child: section),
        ],
      ],
    );
  }
}
