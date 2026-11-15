import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../core/utils/number_format.dart';
import '../../../data/models/meta/sqld_exam_guide.dart';
import '../../design/design.dart';

/// 연도별 응시자 막대 + 합격률 선 (#1077)
/// 진입 시 막대가 아래에서 자라고 선이 그려짐, 막대를 누르면 그 연도 상세 줄 (처음엔 최신 연도)
class ExamStatisticsChart extends StatefulWidget {
  const ExamStatisticsChart({super.key, required this.statistics});

  // 연도 오름차순
  final List<SqldYearlyStatistic> statistics;

  @override
  State<ExamStatisticsChart> createState() => _ExamStatisticsChartState();
}

class _ExamStatisticsChartState extends State<ExamStatisticsChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController growController = AnimationController(
    vsync: this,
  );
  late int selectedIndex = widget.statistics.length - 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 동작 줄이기면 바로 최종 모양
    growController.duration = PassqlMotion.durationOf(
      context,
      PassqlMotion.passReveal,
    );
    if (!growController.isAnimating && growController.value == 0) {
      growController.forward();
    }
  }

  @override
  void dispose() {
    growController.dispose();
    super.dispose();
  }

  // 누른 x 좌표 > 막대 번호
  void selectBarAt(double tapX, double chartWidth) {
    final barSlotWidth = chartWidth / widget.statistics.length;
    final index = (tapX / barSlotWidth).floor().clamp(
      0,
      widget.statistics.length - 1,
    );
    setState(() => selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final selected = widget.statistics[selectedIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 범례
        Row(
          children: [
            _LegendMark(color: colors.accent, isLine: false),
            const SizedBox(width: PassqlSpacing.xxs),
            Text('응시자 수', style: _legendStyle(colors)),
            const SizedBox(width: PassqlSpacing.md),
            _LegendMark(color: colors.warning, isLine: true),
            const SizedBox(width: PassqlSpacing.xxs),
            Text('합격률', style: _legendStyle(colors)),
          ],
        ),
        const SizedBox(height: PassqlSpacing.sm),
        // 차트 (스크린리더는 아래 상세 줄을 읽음)
        ExcludeSemantics(
          child: LayoutBuilder(
            builder: (context, constraints) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) =>
                  selectBarAt(details.localPosition.dx, constraints.maxWidth),
              onHorizontalDragUpdate: (details) =>
                  selectBarAt(details.localPosition.dx, constraints.maxWidth),
              child: SizedBox(
                height: PassqlSize.examStatisticsChartHeight,
                child: AnimatedBuilder(
                  animation: growController,
                  builder: (context, _) => CustomPaint(
                    size: Size.infinite,
                    painter: _ExamStatisticsPainter(
                      statistics: widget.statistics,
                      selectedIndex: selectedIndex,
                      growProgress: PassqlMotion.curve.transform(
                        growController.value,
                      ),
                      barColor: colors.accent,
                      lineColor: colors.warning,
                      selectedPointFillColor: colors.card,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: PassqlSpacing.xxs),
        // 축: 첫 연도 ~ 마지막 연도
        PassqlTextScaleLimit(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.statistics.first.year}',
                style: _legendStyle(colors),
              ),
              Text(
                '${widget.statistics.last.year}',
                style: _legendStyle(colors),
              ),
            ],
          ),
        ),
        const SizedBox(height: PassqlSpacing.sm),
        // 선택 연도 상세
        Text(
          '${selected.year}년  응시 ${formatThousands(selected.examineeCount)}명 | '
          '합격 ${formatThousands(selected.passerCount)}명 | '
          '합격률 ${selected.passRatePercent.toStringAsFixed(2)}%',
          style: PassqlTypography.subheadlineSemibold.copyWith(
            color: colors.label,
          ),
        ),
        Text(
          '막대를 누르면 연도별 숫자를 볼 수 있어요',
          style: PassqlTypography.caption.copyWith(
            color: colors.secondaryLabel,
          ),
        ),
      ],
    );
  }

  TextStyle _legendStyle(PassqlColors colors) =>
      PassqlTypography.caption.copyWith(color: colors.secondaryLabel);
}

class _LegendMark extends StatelessWidget {
  const _LegendMark({required this.color, required this.isLine});

  final Color color;
  final bool isLine;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: PassqlSpacing.sm,
    height: isLine ? PassqlSize.examStatisticsLineStroke : PassqlSpacing.sm,
    child: ColoredBox(color: color),
  );
}

/// 막대: 응시자 수 (최댓값 기준 높이), 선: 합격률 (0~100% 고정 축)
class _ExamStatisticsPainter extends CustomPainter {
  _ExamStatisticsPainter({
    required this.statistics,
    required this.selectedIndex,
    required this.growProgress,
    required this.barColor,
    required this.lineColor,
    required this.selectedPointFillColor,
  });

  final List<SqldYearlyStatistic> statistics;
  final int selectedIndex;
  // 0 > 1: 막대 높이·선 길이 비율
  final double growProgress;
  final Color barColor;
  final Color lineColor;
  final Color selectedPointFillColor;

  // 막대 칸 안 막대 너비 비율 (나머지는 막대 사이 간격)
  static const double _barWidthRatio = 0.62;

  @override
  void paint(Canvas canvas, Size size) {
    if (statistics.isEmpty) return;
    final maxExamineeCount = statistics
        .map((s) => s.examineeCount)
        .reduce(math.max);
    final slotWidth = size.width / statistics.length;
    final barWidth = slotWidth * _barWidthRatio;

    // 막대
    for (var index = 0; index < statistics.length; index++) {
      final barHeight =
          size.height *
          statistics[index].examineeCount /
          maxExamineeCount *
          growProgress;
      final left = slotWidth * index + (slotWidth - barWidth) / 2;
      final barRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(left, size.height - barHeight, barWidth, barHeight),
        topLeft: const Radius.circular(PassqlSpacing.xxs),
        topRight: const Radius.circular(PassqlSpacing.xxs),
      );
      final isSelected = index == selectedIndex;
      canvas.drawRRect(
        barRect,
        Paint()
          ..color = isSelected
              ? barColor
              : barColor.withValues(alpha: PassqlOpacity.chartBarResting),
      );
    }

    // 합격률 선 (막대 중심 연결, 진행 비율만큼만 그림)
    final points = [
      for (var index = 0; index < statistics.length; index++)
        Offset(
          slotWidth * index + slotWidth / 2,
          size.height * (1 - statistics[index].passRatePercent / 100),
        ),
    ];
    final visiblePointCount = math.max(
      1,
      (points.length * growProgress).ceil(),
    );
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var index = 1; index < visiblePointCount; index++) {
      linePath.lineTo(points[index].dx, points[index].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = PassqlSize.examStatisticsLineStroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // 선택 연도 점
    if (selectedIndex < visiblePointCount) {
      final selectedPoint = points[selectedIndex];
      canvas.drawCircle(
        selectedPoint,
        PassqlSize.examStatisticsPointRadius,
        Paint()..color = selectedPointFillColor,
      );
      canvas.drawCircle(
        selectedPoint,
        PassqlSize.examStatisticsPointRadius,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = PassqlSize.examStatisticsLineStroke,
      );
    }
  }

  @override
  bool shouldRepaint(_ExamStatisticsPainter oldDelegate) =>
      oldDelegate.growProgress != growProgress ||
      oldDelegate.selectedIndex != selectedIndex ||
      oldDelegate.barColor != barColor ||
      oldDelegate.statistics != statistics;
}
