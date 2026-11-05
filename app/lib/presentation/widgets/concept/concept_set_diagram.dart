import 'package:flutter/widgets.dart';

import '../../design/design.dart';
import 'concept_lesson_block.dart';

/// 집합 그림 (#853): 두 원이 겹친 그림 + 연산 세그먼트, 연산을 고르면 칠해지는 영역과 결과 값이 바뀜
/// 영역 3곳: 왼쪽만, 겹침, 오른쪽만 (UNION 전체, INTERSECT 겹침, MINUS·EXCEPT 왼쪽만)
class ConceptSetDiagram extends StatefulWidget {
  const ConceptSetDiagram({super.key, required this.set});

  final ConceptSetBlock set;

  @override
  State<ConceptSetDiagram> createState() => _ConceptSetDiagramState();
}

class _ConceptSetDiagramState extends State<ConceptSetDiagram> {
  // 그림 높이 (원 지름 기준)
  static const double _diagramHeight = 168;

  int _selectedIndex = 0;

  /// 연산 이름 > 칠할 영역 (왼쪽만, 겹침, 오른쪽만)
  static (double, double, double) _regionsOf(String operationName) {
    final name = operationName.toUpperCase();
    if (name.contains('INTERSECT')) return (0, 1, 0);
    if (name.contains('MINUS') || name.contains('EXCEPT')) return (1, 0, 0);
    if (name.contains('UNION')) return (1, 1, 1);
    return (0, 0, 0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final set = widget.set;
    final operations = set.operations;
    final selected = operations[_selectedIndex.clamp(0, operations.length - 1)];
    final (left, middle, right) = _regionsOf(selected.name);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TweenAnimationBuilder<List<double>>(
          tween: _RegionTween(end: [left, middle, right]),
          duration: PassqlMotion.durationOf(context, PassqlMotion.emphasized),
          curve: PassqlMotion.curve,
          builder: (context, regions, _) => SizedBox(
            height: _diagramHeight,
            child: CustomPaint(
              painter: _VennPainter(
                regions: regions,
                fillColor: colors.accent,
                outlineColor: colors.accentText,
              ),
              child: Row(
                children: [
                  Expanded(child: _ValueColumn(values: set.leftOnlyValues)),
                  Expanded(child: _ValueColumn(values: set.sharedValues)),
                  Expanded(child: _ValueColumn(values: set.rightOnlyValues)),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: PassqlSpacing.xxs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(set.leftName, style: _labelStyle(colors)),
              Text(set.rightName, style: _labelStyle(colors)),
            ],
          ),
        ),
        const SizedBox(height: PassqlSpacing.sm),
        PassqlSegmentedControl<int>(
          segments: [
            for (final (index, operation) in operations.indexed)
              PassqlSegment(value: index, label: operation.name),
          ],
          selectedValue: _selectedIndex,
          onSelected: (index) {
            PassqlHaptics.playSelection();
            setState(() => _selectedIndex = index);
          },
        ),
        const SizedBox(height: PassqlSpacing.sm),
        // 고른 연산의 결과 (바뀔 때 페이드)
        PassqlFadeSwitcher(
          child: Container(
            key: ValueKey(_selectedIndex),
            width: double.infinity,
            padding: const EdgeInsets.all(PassqlSpacing.sm),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(PassqlRadius.md),
            ),
            child: Text.rich(
              TextSpan(
                style: PassqlTypography.code.copyWith(color: colors.label),
                children: [
                  TextSpan(
                    text: '결과  ',
                    style: PassqlTypography.footnoteSemibold.copyWith(
                      color: colors.accentText,
                    ),
                  ),
                  TextSpan(text: selected.result),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  TextStyle _labelStyle(PassqlColors colors) =>
      PassqlTypography.footnoteSemibold.copyWith(color: colors.secondaryLabel);
}

/// 영역 한 곳 값들 (세로 가운데, 고정폭 글꼴)
class _ValueColumn extends StatelessWidget {
  const _ValueColumn({required this.values});

  final List<String> values;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final value in values)
          Text(
            value,
            style: PassqlTypography.code.copyWith(color: colors.label),
          ),
      ],
    );
  }
}

/// 세 영역 칠하기 값 3개를 함께 보간
class _RegionTween extends Tween<List<double>> {
  _RegionTween({required List<double> end}) : super(begin: end, end: end);

  @override
  List<double> lerp(double t) => [
    for (var index = 0; index < end!.length; index++)
      begin![index] + (end![index] - begin![index]) * t,
  ];
}

/// 두 원 그리기: 영역마다 칠하기 비율만큼 옅은 강조색 + 두 원 윤곽선
class _VennPainter extends CustomPainter {
  _VennPainter({
    required this.regions,
    required this.fillColor,
    required this.outlineColor,
  });

  final List<double> regions;
  final Color fillColor;
  final Color outlineColor;

  // 칠한 영역의 최대 불투명도 (값 글자가 읽히게 옅게)
  static const double _maxFillAlpha = 0.35;
  static const double _outlineWidth = 2;
  // 두 원 중심 위치 (폭 비율), 반지름 (높이 비율)
  static const double _leftCenterFraction = 0.36;
  static const double _rightCenterFraction = 0.64;
  static const double _radiusFraction = 0.48;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.height * _radiusFraction;
    final leftCircle = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width * _leftCenterFraction, size.height / 2),
          radius: radius,
        ),
      );
    final rightCircle = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width * _rightCenterFraction, size.height / 2),
          radius: radius,
        ),
      );
    final areas = [
      Path.combine(PathOperation.difference, leftCircle, rightCircle),
      Path.combine(PathOperation.intersect, leftCircle, rightCircle),
      Path.combine(PathOperation.difference, rightCircle, leftCircle),
    ];
    for (final (index, area) in areas.indexed) {
      final alpha = regions[index] * _maxFillAlpha;
      if (alpha <= 0) continue;
      canvas.drawPath(
        area,
        Paint()..color = fillColor.withValues(alpha: alpha),
      );
    }
    final outline = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _outlineWidth;
    canvas
      ..drawPath(leftCircle, outline)
      ..drawPath(rightCircle, outline);
  }

  @override
  bool shouldRepaint(_VennPainter oldDelegate) =>
      oldDelegate.regions != regions || oldDelegate.fillColor != fillColor;
}
