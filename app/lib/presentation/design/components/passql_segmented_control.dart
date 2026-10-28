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

/// iOS 식 세그먼트 전환: 회색 트랙 + 선택 칸 카드색 알약 (문제 탭 보기·알림함 탭 등 공통)
/// 칸마다 탭 동작·선택 상태 시맨틱, 누르는 영역 높이 44, 글자 크기 커지면 높이도 늘어남
/// 선택이 바뀌면 알약이 물방울처럼 이동: 가려는 쪽 가장자리가 먼저 뻗고 뒤 가장자리가 늦게 따라붙음 (#726)
class PassqlSegmentedControl<T> extends StatefulWidget {
  const PassqlSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedValue,
    required this.onSelected,
  });

  final List<PassqlSegment<T>> segments;
  final T selectedValue;
  final ValueChanged<T> onSelected;

  // 트랙 <-> 알약 여백. 알약 둥글기(sm) = 트랙 둥글기(md) - 이 여백 > 두 모서리 곡선이 같은 중심 (#726)
  static const double _trackPadding = PassqlSpacing.xxs;

  // 앞 가장자리: 처음부터 빠르게 출발해 전체의 앞 0.63(220ms) 안에 도착
  static const _leadingInterval = Interval(
    0,
    0.63,
    curve: Cubic(0.3, 0.9, 0.3, 1),
  );

  // 뒤 가장자리: 50ms 늦게 출발해 천천히 따라붙음 > 그 사이 알약이 길게 늘어났다 모임
  static const _trailingInterval = Interval(
    0.14,
    1,
    curve: Cubic(0.5, 0, 0.2, 1),
  );

  @override
  State<PassqlSegmentedControl<T>> createState() =>
      _PassqlSegmentedControlState<T>();
}

class _PassqlSegmentedControlState<T> extends State<PassqlSegmentedControl<T>>
    with SingleTickerProviderStateMixin {
  // 처음 그릴 때는 이동 없이 선택 칸에 놓인 상태(1)
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PassqlMotion.segmentMorph,
    value: 1,
  );

  // 알약이 출발한 칸 (이동이 끝나면 선택 칸과 같음)
  late int _fromIndex = _selectedIndex;

  int get _selectedIndex => widget.segments.indexWhere(
    (segment) => segment.value == widget.selectedValue,
  );

  @override
  void didUpdateWidget(PassqlSegmentedControl<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previousIndex = oldWidget.segments.indexWhere(
      (segment) => segment.value == oldWidget.selectedValue,
    );
    if (previousIndex == _selectedIndex) return;
    _fromIndex = previousIndex;
    if (PassqlMotion.isReduced(context) || previousIndex < 0) {
      // 동작 줄이기·이전 선택 없음 > 바로 새 칸에
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final selectedIndex = _selectedIndex;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSegmentedControl._trackPadding,
      ),
      decoration: BoxDecoration(
        color: colors.fill,
        borderRadius: BorderRadius.circular(PassqlRadius.md),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellWidth = constraints.maxWidth / widget.segments.length;
          return Stack(
            children: [
              if (selectedIndex >= 0)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final (left, right) = _pillEdges(cellWidth, selectedIndex);
                    return Positioned(
                      left: left,
                      width: right - left,
                      top: PassqlSegmentedControl._trackPadding,
                      bottom: PassqlSegmentedControl._trackPadding,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.cardElevated,
                          borderRadius: BorderRadius.circular(PassqlRadius.sm),
                        ),
                      ),
                    );
                  },
                ),
              Row(
                children: [
                  for (final (index, segment) in widget.segments.indexed)
                    Expanded(
                      child: _SegmentCell(
                        segment: segment,
                        isSelected: index == selectedIndex,
                        onTap: () => widget.onSelected(segment.value),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  /// 지금 진행도에서 알약의 왼쪽·오른쪽 가장자리 (가는 방향 쪽이 앞 가장자리)
  (double, double) _pillEdges(double cellWidth, int toIndex) {
    final fromLeft = cellWidth * _fromIndex;
    final toLeft = cellWidth * toIndex;
    final t = _controller.value;
    final leading = PassqlSegmentedControl._leadingInterval.transform(t);
    final trailing = PassqlSegmentedControl._trailingInterval.transform(t);
    final isMovingRight = toIndex >= _fromIndex;
    final leftProgress = isMovingRight ? trailing : leading;
    final rightProgress = isMovingRight ? leading : trailing;
    final left = fromLeft + (toLeft - fromLeft) * leftProgress;
    final right = fromLeft + cellWidth + (toLeft - fromLeft) * rightProgress;
    return (left, right);
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  // 글자색도 알약 이동과 함께 서서히 바뀜 (알약은 뒤 Stack 이 그림)
                  child: AnimatedDefaultTextStyle(
                    duration: PassqlMotion.durationOf(
                      context,
                      PassqlMotion.fast,
                    ),
                    curve: PassqlMotion.curve,
                    style: PassqlTypography.subheadlineSemibold.copyWith(
                      color: isSelected ? colors.label : colors.secondaryLabel,
                    ),
                    child: Text(
                      segment.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
