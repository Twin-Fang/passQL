import 'package:flutter/cupertino.dart';

import '../../../data/models/exam_trend/exam_trend_report_response.dart';
import '../../design/design.dart';
import 'exam_trend_sections.dart';

/// 광고 자리를 끼우는 위치: 개념 5개 뒤 (그 뒤에 개념이 하나라도 남을 때만)
const int _adSlotAfterConceptCount = 5;

/// 문제 탭 '개념 TOP 10' 보기: 순위 구간, [adSlot] 이 있으면 5위 뒤에 광고 구간 (#726)
/// 두 구간으로 나뉘어도 제목(전체 개수)·분석 근거는 첫 구간에 한 번
class ConceptRankingTabView extends StatelessWidget {
  const ConceptRankingTabView({
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
    final concepts = report.frequentConcepts;
    // 예전 고정 문구('최근 4회 합산')는 데이터와 어긋나 서버 근거·갱신일로 대체
    final basisCaption =
        '${report.basisDescription} · ${report.updatedDate} 갱신';
    final hasAdSlot =
        adSlot != null && concepts.length > _adSlotAfterConceptCount;
    if (!hasAdSlot) {
      return ExamTrendConceptSection(
        concepts: concepts,
        basisCaption: basisCaption,
        onSolveTopic: onSolveTopic,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExamTrendConceptSection(
          concepts: concepts.take(_adSlotAfterConceptCount).toList(),
          totalConceptCount: concepts.length,
          basisCaption: basisCaption,
          onSolveTopic: onSolveTopic,
        ),
        // 광고 자리: 앞 띠는 광고가 직접 그림 (광고가 안 뜨면 띠 하나로만 나뉨)
        ?adSlot,
        const PassqlSectionGap(),
        ExamTrendConceptSection(
          concepts: concepts.skip(_adSlotAfterConceptCount).toList(),
          shouldShowHeader: false,
          onSolveTopic: onSolveTopic,
        ),
      ],
    );
  }
}
