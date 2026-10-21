import 'package:flutter/cupertino.dart';

import '../../design/design.dart';
import '../../../router/questions_tab_view.dart';

/// 문제 탭 보기 전환 (주제별 | 최신 경향 | 개념 TOP 10): 모양·시맨틱은 PassqlSegmentedControl
class QuestionsTabSegmentedControl extends StatelessWidget {
  const QuestionsTabSegmentedControl({
    super.key,
    required this.selectedView,
    required this.onSelected,
  });

  final QuestionsTabView selectedView;
  final ValueChanged<QuestionsTabView> onSelected;

  @override
  Widget build(BuildContext context) {
    return PassqlSegmentedControl<QuestionsTabView>(
      segments: [
        for (final view in QuestionsTabView.values)
          PassqlSegment(value: view, label: view.label),
      ],
      selectedValue: selectedView,
      onSelected: onSelected,
    );
  }
}
