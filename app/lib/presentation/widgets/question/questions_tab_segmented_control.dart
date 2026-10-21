import 'package:flutter/cupertino.dart';

import '../../design/design.dart';
import '../../pages/questions/questions_tab_view.dart';

/// 문제 탭 보기 전환 (주제별 | 최신 경향 | 개념 TOP 10): 선택한 보기는 카드색 알약
/// 모양은 NotificationSegmentedControl 과 같음 (2곳째라 디자인 시스템으로는 아직 뽑지 않음)
class QuestionsTabSegmentedControl extends StatelessWidget {
  const QuestionsTabSegmentedControl({
    super.key,
    required this.selectedView,
    required this.onSelected,
  });

  final QuestionsTabView selectedView;
  final ValueChanged<QuestionsTabView> onSelected;

  // 선택 알약 안쪽 여백 (트랙과 알약 사이)
  static const double _trackPadding = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Container(
      padding: const EdgeInsets.all(_trackPadding),
      decoration: BoxDecoration(
        color: colors.fill,
        borderRadius: BorderRadius.circular(PassqlRadius.md),
      ),
      child: Row(
        children: [
          for (final view in QuestionsTabView.values)
            Expanded(
              child: _SegmentTab(
                label: view.label,
                isSelected: view == selectedView,
                onTap: () => onSelected(view),
              ),
            ),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: PassqlSize.buttonSmall,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? colors.cardElevated : null,
            borderRadius: BorderRadius.circular(PassqlRadius.sm),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: PassqlTypography.subheadlineSemibold.copyWith(
              color: isSelected ? colors.label : colors.secondaryLabel,
            ),
          ),
        ),
      ),
    );
  }
}
