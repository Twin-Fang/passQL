import 'package:flutter/material.dart';

import '../../design/design.dart';
import 'concept_unit_progress.dart';

/// 단원 줄: "N단원 · 이름" 과 "n / 총", 아래에 개념 수만큼 칸 막대.
/// 이번에 끝냈으면 +1 이 떠오른 뒤 숫자가 굴러 바뀌고, 새로 찬 칸이 한 번 커졌다 돌아옴
class ConceptUnitRow extends StatelessWidget {
  const ConceptUnitRow({
    super.key,
    required this.unit,
    required this.isPlusVisible,
    required this.isRolled,
    required this.pulse,
  });

  // +1 이 떠오르는 거리 (자기 높이 비율)
  static const double _plusRiseFraction = 0.3;

  final ConceptUnitProgress unit;
  final bool isPlusVisible;
  final bool isRolled;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final shownCount = isRolled ? unit.solvedCount : unit.solvedCountBefore;
    final duration = PassqlMotion.durationOf(context, PassqlMotion.standard);
    return Semantics(
      label: '${unit.label}, 개념 ${unit.total}개 중 ${unit.solvedCount}개 끝냄',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: PassqlSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    unit.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PassqlTypography.subheadline.copyWith(
                      color: colors.label,
                    ),
                  ),
                ),
                const SizedBox(width: PassqlSpacing.sm),
                // 숫자 굴림: 이전 숫자는 위로 밀려나고 새 숫자가 아래에서 올라옴
                ClipRect(
                  child: AnimatedSwitcher(
                    duration: duration,
                    switchInCurve: PassqlMotion.curve,
                    switchOutCurve: PassqlMotion.curve,
                    transitionBuilder: (child, animation) {
                      final isIncoming = child.key == ValueKey<int>(shownCount);
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0, isIncoming ? 1 : -1),
                          end: Offset.zero,
                        ).animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: Text(
                      '$shownCount',
                      key: ValueKey<int>(shownCount),
                      style: PassqlTypography.headline.copyWith(
                        color: colors.accentText,
                        fontFeatures: PassqlTypography.tabular,
                      ),
                    ),
                  ),
                ),
                Text(
                  ' / ${unit.total}',
                  style: PassqlTypography.subheadline.copyWith(
                    color: colors.secondaryLabel,
                    fontFeatures: PassqlTypography.tabular,
                  ),
                ),
                const SizedBox(width: PassqlSpacing.xxs),
                AnimatedSlide(
                  offset: Offset(0, isPlusVisible ? -_plusRiseFraction : 0),
                  duration: duration,
                  curve: PassqlMotion.springCurve,
                  child: AnimatedOpacity(
                    opacity: isPlusVisible ? 1 : 0,
                    duration: duration,
                    child: Text(
                      '+${unit.solvedCount - unit.solvedCountBefore}',
                      style: PassqlTypography.footnoteSemibold.copyWith(
                        color: colors.accentText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PassqlSpacing.xs),
            _SegmentBar(
              total: unit.total,
              filledCount: shownCount,
              pulsingIndex: isRolled && unit.hasIncrease
                  ? unit.solvedCount - 1
                  : null,
              pulse: pulse,
            ),
          ],
        ),
      ),
    );
  }
}

/// 칸 막대: 개념 하나가 칸 하나. 새로 찬 칸은 세로로 한 번 커졌다 돌아옴
class _SegmentBar extends StatelessWidget {
  const _SegmentBar({
    required this.total,
    required this.filledCount,
    required this.pulsingIndex,
    required this.pulse,
  });

  // 칸 사이 간격, 튈 때 최대 세로 배율
  static const double _gap = 3;
  static const double _pulseScale = 1.9;

  final int total;
  final int filledCount;
  final int? pulsingIndex;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final duration = PassqlMotion.durationOf(context, PassqlMotion.fast);
    return Row(
      children: [
        for (var index = 0; index < total; index++) ...[
          if (index > 0) const SizedBox(width: _gap),
          Expanded(
            child: Transform.scale(
              scaleY: index == pulsingIndex
                  ? 1 + (_pulseScale - 1) * (1 - (2 * pulse - 1).abs())
                  : 1,
              child: AnimatedContainer(
                duration: duration,
                curve: PassqlMotion.curve,
                height: PassqlSize.unitSegmentHeight,
                decoration: BoxDecoration(
                  color: index < filledCount ? colors.accent : colors.fill,
                  borderRadius: BorderRadius.circular(PassqlRadius.capsule),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
