import 'package:flutter/widgets.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_semantic_button.dart';

/// 세그먼트 한 칸: 값, 보이는 이름, (선택) 읽을 문구·오른쪽 부가 요소
class PassqlSegment<T> {
  const PassqlSegment({
    required this.value,
    required this.label,
    this.semanticLabel,
    this.trailingBuilder,
  });

  final T value;
  final String label;

  /// 스크린리더 문구 (null 이면 label). 개수 배지처럼 글자 밖 정보가 있을 때 지정
  final String? semanticLabel;

  /// 이름 오른쪽 요소 (선택 여부에 따라 모양이 바뀌는 개수 배지 등)
  final Widget Function(bool isSelected)? trailingBuilder;
}

/// iOS 식 세그먼트 전환: 회색 트랙 + 선택 칸 카드색 알약 (문제 탭 보기·알림함 탭 공통)
/// 칸마다 탭 동작·선택 상태 시맨틱, 누르는 영역 높이 44, 글자 크기 커지면 높이도 늘어남
class PassqlSegmentedControl<T> extends StatelessWidget {
  const PassqlSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedValue,
    required this.onSelected,
  });

  final List<PassqlSegment<T>> segments;
  final T selectedValue;
  final ValueChanged<T> onSelected;

  // 트랙 <-> 알약 여백 (위아래는 칸이 가져가 누르는 영역에 포함)
  static const double _trackPadding = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: _trackPadding),
      decoration: BoxDecoration(
        color: colors.fill,
        borderRadius: BorderRadius.circular(PassqlRadius.md),
      ),
      child: Row(
        children: [
          for (final segment in segments)
            Expanded(
              child: _SegmentCell(
                segment: segment,
                isSelected: segment.value == selectedValue,
                onTap: () => onSelected(segment.value),
              ),
            ),
        ],
      ),
    );
  }
}

class _SegmentCell<T> extends StatelessWidget {
  const _SegmentCell({
    required this.segment,
    required this.isSelected,
    required this.onTap,
  });

  final PassqlSegment<T> segment;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final trailing = segment.trailingBuilder?.call(isSelected);
    return PassqlSemanticButton(
      label: segment.semanticLabel ?? segment.label,
      isSelected: isSelected,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: PassqlSegmentedControl._trackPadding,
          ),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: PassqlSize.segmentedControlSegment,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? colors.cardElevated : null,
              borderRadius: BorderRadius.circular(PassqlRadius.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    segment.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PassqlTypography.subheadlineSemibold.copyWith(
                      color: isSelected ? colors.label : colors.secondaryLabel,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: PassqlSpacing.xxs),
                  trailing,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
