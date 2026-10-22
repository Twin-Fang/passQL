import 'package:flutter/cupertino.dart';

import '../../../data/models/exam_trend/exam_trend_report_response.dart';
import '../../design/design.dart';
import 'exam_trend_sections.dart';

/// 광고 자리를 끼우는 위치: 개념 5개 뒤 (그 뒤에 개념이 하나라도 남을 때만)
const int _adSlotAfterConceptCount = 5;

/// 문제 탭 '개념 TOP 10' 보기: 순위 목록, [adSlot] 이 있으면 5위 뒤에 한 칸
/// 두 묶음이어도 머리글(전체 개수)은 첫 묶음, 안내 문구는 마지막 묶음에 한 번씩
class ConceptRankingTabView extends StatelessWidget {
  const ConceptRankingTabView({
    super.key,
    required this.concepts,
    required this.onSolveTopic,
    this.adSlot,
  });

  final List<ExamTrendConcept> concepts;
  final void Function(String topicCode, String topicName) onSolveTopic;
  final Widget? adSlot;

  @override
  Widget build(BuildContext context) {
    final hasAdSlot =
        adSlot != null && concepts.length > _adSlotAfterConceptCount;
    if (!hasAdSlot) {
      return ExamTrendConceptSection(
        concepts: concepts,
        onSolveTopic: onSolveTopic,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExamTrendConceptSection(
          concepts: concepts.take(_adSlotAfterConceptCount).toList(),
          totalConceptCount: concepts.length,
          shouldShowFooter: false,
          onSolveTopic: onSolveTopic,
        ),
        // 광고 자리 (광고가 안 뜨면 높이 0, 아래 간격은 묶음 사이 기본 간격)
        ?adSlot,
        const SizedBox(height: PassqlSpacing.md),
        ExamTrendConceptSection(
          concepts: concepts.skip(_adSlotAfterConceptCount).toList(),
          shouldShowHeader: false,
          onSolveTopic: onSolveTopic,
        ),
      ],
    );
  }
}
