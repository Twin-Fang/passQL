import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../design/design.dart';
import 'concept_lesson_block.dart';

/// 조인 연결 그림 (#853): 왼쪽 표 행 | 오른쪽 표 행, 스크롤로 들어오면 짝마다 선이 차례로 그어짐
/// 짝 없는 행은 반대쪽 NULL 칸과 점선으로 이어짐 (OUTER JOIN 에서 NULL 로 채워지는 모습)
class ConceptJoinDiagram extends StatelessWidget {
  const ConceptJoinDiagram({super.key, required this.join});

  final ConceptJoinBlock join;

  // 행 칸 높이·간격 (선 위치를 칸 순서로 계산하려고 고정)
  static const double _rowHeight = 36;
  static const double _rowGap = PassqlSpacing.xs;
  // 두 표 사이 선이 지나가는 폭
  static const double _connectorWidth = 56;
  // 선 전체가 그어지는 시간 (짝이 많아도 한 번에 끝나게 고정)
  static const Duration _drawDuration = Duration(milliseconds: 1400);
  static const String _nullLabel = 'NULL';

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final pairs = join.pairs;
    final hasLeftNull = pairs.any((pair) => pair.isLeftMissing);
    final hasRightNull = pairs.any((pair) => pair.isRightMissing);
    final leftRows = [...join.leftRows, if (hasLeftNull) _nullLabel];
    final rightRows = [...join.rightRows, if (hasRightNull) _nullLabel];
    final rowCount = math.max(leftRows.length, rightRows.length);
    final height = rowCount * _rowHeight + (rowCount - 1) * _rowGap;
    final links = [
      for (final pair in pairs)
        _Link(
          leftIndex: pair.isLeftMissing
              ? leftRows.length - 1
              : leftRows.indexOf(pair.left),
          rightIndex: pair.isRightMissing
              ? rightRows.length - 1
              : rightRows.indexOf(pair.right),
          isPadded: pair.isLeftMissing || pair.isRightMissing,
        ),
    ];
    return Semantics(
      label: '조인 결과 ${pairs.length}행',
      child: PassqlScrollProgress(
        duration: _drawDuration,
        builder: (context, progress) => SizedBox(
          height: height,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _JoinLinkPainter(
                    links: links,
                    progress: progress,
                    rowHeight: _rowHeight,
                    rowGap: _rowGap,
                    connectorWidth: _connectorWidth,
                    lineColor: colors.accent,
                    paddedLineColor: colors.warning,
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _RowColumn(rows: leftRows)),
                  const SizedBox(width: _connectorWidth),
                  Expanded(child: _RowColumn(rows: rightRows)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 한쪽 표의 행 칸 세로 목록 (NULL 칸은 회색 점선 느낌의 흐린 칸)
class _RowColumn extends StatelessWidget {
  const _RowColumn({required this.rows});

  final List<String> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Column(
      children: [
        for (final (index, row) in rows.indexed) ...[
          if (index > 0) const SizedBox(height: ConceptJoinDiagram._rowGap),
          Container(
            height: ConceptJoinDiagram._rowHeight,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.xs),
            decoration: BoxDecoration(
              color: row == ConceptJoinDiagram._nullLabel
                  ? colors.background
                  : colors.accentTint,
              border: Border.all(color: colors.separator),
              borderRadius: BorderRadius.circular(PassqlRadius.sm),
            ),
            child: Text(
              row,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: PassqlTypography.codeCompact.copyWith(
                color: row == ConceptJoinDiagram._nullLabel
                    ? colors.secondaryLabel
                    : colors.label,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// 선 하나: 왼쪽 칸 순서 > 오른쪽 칸 순서 (NULL 로 채운 짝이면 주의색)
class _Link {
  const _Link({
    required this.leftIndex,
    required this.rightIndex,
    required this.isPadded,
  });

  final int leftIndex;
  final int rightIndex;
  final bool isPadded;
}

/// 짝마다 곡선을 순서대로 그림: 진행 구간을 짝 수로 나눠 앞 짝부터 끝까지 그어짐
class _JoinLinkPainter extends CustomPainter {
  _JoinLinkPainter({
    required this.links,
    required this.progress,
    required this.rowHeight,
    required this.rowGap,
    required this.connectorWidth,
    required this.lineColor,
    required this.paddedLineColor,
  });

  final List<_Link> links;
  final double progress;
  final double rowHeight;
  final double rowGap;
  final double connectorWidth;
  final Color lineColor;
  final Color paddedLineColor;

  // 선 두께, 양 끝 점 반지름
  static const double _strokeWidth = 2;
  static const double _endDotRadius = 3;

  @override
  void paint(Canvas canvas, Size size) {
    if (links.isEmpty) return;
    final columnWidth = (size.width - connectorWidth) / 2;
    final startX = columnWidth;
    final endX = columnWidth + connectorWidth;
    final segment = 1 / links.length;
    for (final (index, link) in links.indexed) {
      final linkProgress = ((progress - index * segment) / segment).clamp(
        0.0,
        1.0,
      );
      if (linkProgress <= 0) continue;
      final start = Offset(startX, _centerY(link.leftIndex));
      final end = Offset(endX, _centerY(link.rightIndex));
      final controlX = (startX + endX) / 2;
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(controlX, start.dy, controlX, end.dy, end.dx, end.dy);
      final color = link.isPadded ? paddedLineColor : lineColor;
      final paint = Paint()
        ..color = color
        ..strokeWidth = _strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      for (final metric in path.computeMetrics()) {
        canvas.drawPath(
          metric.extractPath(0, metric.length * linkProgress),
          paint,
        );
      }
      final dotPaint = Paint()..color = color;
      canvas.drawCircle(start, _endDotRadius, dotPaint);
      if (linkProgress >= 1) canvas.drawCircle(end, _endDotRadius, dotPaint);
    }
  }

  double _centerY(int index) => index * (rowHeight + rowGap) + rowHeight / 2;

  @override
  bool shouldRepaint(_JoinLinkPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.links != links ||
      oldDelegate.lineColor != lineColor;
}
