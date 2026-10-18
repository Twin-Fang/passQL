import 'package:flutter/widgets.dart';

import '../../design/design.dart';

/// 가로로 나열한 선택 칩 한 줄 (피드 탭 4종·의견 정렬 2종 공통), 넘치면 가로 스크롤
/// 선택한 칩은 강조 틴트, 나머지는 회색 채움
class CommunityChoiceChips<T> extends StatelessWidget {
  const CommunityChoiceChips({
    super.key,
    required this.values,
    required this.labelOf,
    required this.selectedValue,
    required this.onSelected,
  });

  final List<T> values;
  final String Function(T value) labelOf;
  final T selectedValue;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    // 폭을 가득 채워 부모 Column 에서 가운데로 몰리지 않고 왼쪽 정렬
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.md),
        child: Row(
          children: [
            for (final value in values) ...[
              _Chip(
                label: labelOf(value),
                isSelected: value == selectedValue,
                onTap: () => onSelected(value),
              ),
              if (value != values.last) const SizedBox(width: PassqlSpacing.xs),
            ],
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
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
      selected: isSelected,
      child: PassqlPressable(
        onTap: onTap,
        semanticLabel: label,
        child: Container(
          height: PassqlSize.buttonSmall,
          padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.sm),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? colors.accentTint : colors.fill,
            borderRadius: BorderRadius.circular(PassqlRadius.capsule),
          ),
          child: Text(
            label,
            style: PassqlTypography.subheadlineSemibold.copyWith(
              color: isSelected ? colors.accent : colors.secondaryLabel,
            ),
          ),
        ),
      ),
    );
  }
}
