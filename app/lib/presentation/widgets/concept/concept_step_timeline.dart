import 'package:flutter/widgets.dart';

import '../../design/design.dart';
import '../question/markdown_lite_text.dart';
import 'concept_lesson_block.dart';

/// 단계 흐름 (#848·#853): 번호 원 + 세로 연결선 + 단계 이름 + 설명, 스크롤로 들어오면 단계가 차례로 켜지고 연결선이 다음 단계로 차오름
class ConceptStepTimeline extends StatelessWidget {
  const ConceptStepTimeline({super.key, required this.steps});

  final List<ConceptStep> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, step) in steps.indexed)
          PassqlScrollReveal(
            index: index,
            child: _StepRow(
              order: index + 1,
              step: step,
              isLast: index == steps.length - 1,
            ),
          ),
      ],
    );
  }
}

/// 단계 한 줄: 왼쪽 번호 원과 다음 단계까지 이어지는 선, 오른쪽 글
class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.order,
    required this.step,
    required this.isLast,
  });

  final int order;
  final ConceptStep step;
  final bool isLast;

  // 번호 원 지름 (최소 터치 영역보다 작은 장식, 누르지 않음)
  static const double _orderCircleDiameter = 28;
  // 연결선 두께
  static const double _connectorWidth = 2;
  // 연결선이 다음 단계까지 차오르는 시간
  static const Duration _connectorFillDuration = Duration(milliseconds: 700);

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return MergeSemantics(
      // 연결선은 글 높이를 따라가야 해서 Stack 뒤쪽에 깔고 위아래로 늘림 (글 안에 LayoutBuilder 가 있어 IntrinsicHeight 불가)
      child: Stack(
        children: [
          if (!isLast)
            Positioned(
              top: _orderCircleDiameter,
              bottom: 0,
              left: (_orderCircleDiameter - _connectorWidth) / 2,
              width: _connectorWidth,
              // 옅은 바탕 선 위로 강조색 선이 위에서 아래로 차오름
              child: ColoredBox(
                color: colors.accentTint,
                child: PassqlScrollProgress(
                  duration: _connectorFillDuration,
                  builder: (_, progress) => Align(
                    alignment: Alignment.topCenter,
                    child: FractionallySizedBox(
                      heightFactor: progress,
                      widthFactor: 1,
                      child: ColoredBox(color: colors.accent),
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : PassqlSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: _orderCircleDiameter,
                  height: _orderCircleDiameter,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$order',
                    style: PassqlTypography.footnoteSemibold.copyWith(
                      color: colors.onAccent,
                    ),
                  ),
                ),
                const SizedBox(width: PassqlSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 번호 원 높이 가운데에 이름 첫 줄을 맞춤
                      Padding(
                        padding: const EdgeInsets.only(top: PassqlSpacing.xxs),
                        child: Text(
                          step.title,
                          style: PassqlTypography.headline.copyWith(
                            color: colors.label,
                          ),
                        ),
                      ),
                      if (step.detail.isNotEmpty) ...[
                        const SizedBox(height: PassqlSpacing.xxs),
                        MarkdownLiteText(
                          step.detail,
                          style: MarkdownLiteStyle.article,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
