import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../../design/design.dart';
import 'topic_accuracy_rows.dart';

// 차트 높이와 꼭짓점 바깥 이름 자리 (좌우로 긴 이름 "DDL / DML / TCL" 이 들어가는 폭)
const double _chartHeight = 240;
const double _labelGap = 10;
const double _labelMaxWidth = 76;
const double _horizontalLabelRoom = 64;
const double _verticalLabelRoom = 22;
// 안쪽 눈금 비율, 점 크기, 선 두께
const List<double> _gridLevels = [0.25, 0.5, 0.75, 1];
const double _pointRadius = 3.5;
const double _outlineWidth = 2;
const double _fillOpacity = 0.22;
const double _dashLength = 3;
const double _legendDotSize = 8;

/// 영역별 정답률 8각 차트 (#749): 꼭짓점 = 토픽(토픽 순서), 면 = 내 정답률, 빨간 점선 = 약한 영역 기준.
/// 기준 미만 꼭짓점과 이름은 빨강, 안 푼 영역은 점 없이 중심. 스크린리더는 약한 영역 한 문장
class TopicAccuracyRadar extends StatelessWidget {
  const TopicAccuracyRadar({super.key, required this.rows});

  /// [buildTopicChartRows] 결과 (3개 이상일 때만 그린다)
  final List<TopicAccuracyRow> rows;

  String get _semanticLabel {
    final weak = rows.where((row) => row.isWeak).toList();
    if (weak.isEmpty) return '영역별 정답률 차트, 약한 영역 없음';
    final names = weak
        .map((row) => '${row.name} ${(row.correctRate * 100).round()}%')
        .join(', ');
    return '영역별 정답률 차트, 약한 영역: $names';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Semantics(
      label: _semanticLabel,
      container: true,
      excludeSemantics: true,
      child: Column(
        children: [
          SizedBox(
            height: _chartHeight,
            width: double.infinity,
            child: CustomPaint(
              painter: _RadarPainter(
                rows: rows,
                textScaler: MediaQuery.textScalerOf(context),
                accent: colors.accent,
                weak: colors.wrong,
                weakText: colors.wrongText,
                grid: colors.separator,
                label: colors.secondaryLabel,
              ),
            ),
          ),
          const SizedBox(height: PassqlSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: colors.accent, label: '내 정답률'),
              const SizedBox(width: PassqlSpacing.md),
              _LegendItem(
                color: colors.wrong,
                label: '${(weakAccuracyThreshold * 100).round()}% 기준선',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _legendDotSize,
          height: _legendDotSize,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: PassqlSpacing.xxs),
        Text(
          label,
          style: PassqlTypography.caption.copyWith(
            color: context.passqlColors.secondaryLabel,
          ),
        ),
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.rows,
    required this.textScaler,
    required this.accent,
    required this.weak,
    required this.weakText,
    required this.grid,
    required this.label,
  });

  final List<TopicAccuracyRow> rows;
  final TextScaler textScaler;
  final Color accent;
  final Color weak;
  final Color weakText;
  final Color grid;
  final Color label;

  @override
  void paint(Canvas canvas, Size size) {
    final count = rows.length;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.max(
      0.0,
      math.min(
        size.width / 2 - _horizontalLabelRoom,
        size.height / 2 - _verticalLabelRoom,
      ),
    );
    // 12시에서 시작해 시계 방향
    Offset pointAt(int index, double ratio) {
      final angle = -math.pi / 2 + index * 2 * math.pi / count;
      return center +
          Offset(math.cos(angle), math.sin(angle)) * (radius * ratio);
    }

    Path polygon(double Function(int index) ratioOf) {
      final path = Path()
        ..moveTo(pointAt(0, ratioOf(0)).dx, pointAt(0, ratioOf(0)).dy);
      for (var i = 1; i < count; i++) {
        final point = pointAt(i, ratioOf(i));
        path.lineTo(point.dx, point.dy);
      }
      return path..close();
    }

    final gridPaint = Paint()
      ..color = grid
      ..style = PaintingStyle.stroke
      ..strokeWidth = PassqlSize.hairline;
    for (final level in _gridLevels) {
      canvas.drawPath(polygon((_) => level), gridPaint);
    }
    for (var i = 0; i < count; i++) {
      canvas.drawLine(center, pointAt(i, 1), gridPaint);
    }

    _drawDashedPath(
      canvas,
      polygon((_) => weakAccuracyThreshold),
      Paint()
        ..color = weak
        ..style = PaintingStyle.stroke
        ..strokeWidth = PassqlSize.hairline,
    );

    final shape = polygon((i) => rows[i].correctRate.clamp(0.0, 1.0));
    canvas.drawPath(
      shape,
      Paint()..color = accent.withValues(alpha: _fillOpacity),
    );
    canvas.drawPath(
      shape,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = _outlineWidth
        ..strokeJoin = StrokeJoin.round,
    );

    for (var i = 0; i < count; i++) {
      final row = rows[i];
      if (!row.isUnsolved) {
        canvas.drawCircle(
          pointAt(i, row.correctRate.clamp(0.0, 1.0)),
          _pointRadius,
          Paint()..color = row.isWeak ? weak : accent,
        );
      }
      _drawLabel(canvas, row, pointAt(i, 1), center);
    }
  }

  /// 꼭짓점 바깥 이름: 왼쪽 꼭짓점은 오른쪽 정렬, 오른쪽은 왼쪽 정렬, 위아래는 가운데
  void _drawLabel(
    Canvas canvas,
    TopicAccuracyRow row,
    Offset vertex,
    Offset center,
  ) {
    // 안 푼 영역은 보통 이름과 같은 회색 (빨강은 풀어 본 약한 영역만)
    final color = row.isWeak ? weakText : label;
    final style =
        (row.isWeak
                ? PassqlTypography.captionSemibold
                : PassqlTypography.caption)
            .copyWith(color: color);
    final painter = TextPainter(
      text: TextSpan(text: row.name, style: style),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      maxLines: 2,
      textAlign: TextAlign.center,
    )..layout(maxWidth: _labelMaxWidth);
    final direction = vertex - center;
    final unit = direction.distance == 0
        ? Offset.zero
        : direction / direction.distance;
    final anchor = vertex + unit * _labelGap;
    final isCentered = direction.dx.abs() < 1;
    final dx = isCentered
        ? anchor.dx - painter.width / 2
        : direction.dx < 0
        ? anchor.dx - painter.width
        : anchor.dx;
    final dy = direction.dy.abs() < 1
        ? anchor.dy - painter.height / 2
        : direction.dy < 0
        ? anchor.dy - painter.height
        : anchor.dy;
    painter.paint(canvas, Offset(dx, dy));
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + _dashLength),
          paint,
        );
        distance += _dashLength * 2;
      }
    }
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) =>
      oldDelegate.rows != rows ||
      oldDelegate.accent != accent ||
      oldDelegate.label != label ||
      oldDelegate.textScaler != textScaler;
}
