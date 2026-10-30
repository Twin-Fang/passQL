import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design/design.dart';

/// 개념 결과 고리 (#764): 이어진 고리가 맞힌 만큼 차고, 색은 강조색에서 정답색으로 맞힐수록 옮겨 감.
/// 다 맞히면 안쪽을 같은 색으로 채운 원 + 선으로 그려지는 체크, 아니면 가운데 점수 글자.
/// 값은 연출 쪽이 프레임마다 넘긴다 (여기서는 그리기만). 크기는 머리(작게)·접힘(아주 작게)에 따라 다름
class ConceptResultRing extends StatelessWidget {
  const ConceptResultRing({
    super.key,
    required this.filledFraction,
    required this.diskProgress,
    required this.checkProgress,
    required this.centerLabel,
    this.centerScale = 1,
    this.size = PassqlSize.scoreRingCompact,
    this.stroke = PassqlSize.scoreRingCompactStroke,
    this.centerStyle,
    this.isAccentOnly = false,
    this.checkColor,
  });

  /// 0~1: 고리가 찬 정도 (맞힌 수 / 문제 수, 차오르는 중간값 포함)
  final double filledFraction;

  /// 0~1: 다 맞혔을 때 안쪽 원이 채워지는 정도 (0이면 원 없음)
  final double diskProgress;

  /// 0~1: 체크가 그려진 정도
  final double checkProgress;

  /// 원이 없을 때 가운데 글자 (예: 4/5). 비우면 글자 없음 (접힌 고리)
  final String centerLabel;

  /// 마지막 칸이 찬 순간 숫자가 톡 커지는 배율
  final double centerScale;

  final double size;
  final double stroke;

  /// 가운데 글자 스타일 (null 이면 subheadlineSemibold)
  final TextStyle? centerStyle;

  /// true 면 색이 정답색으로 옮겨 가지 않고 강조색에 머묾 (점수판: 파랑 계열 유지)
  final bool isAccentOnly;

  /// 체크 색 (null 이면 onSemantic)
  final Color? checkColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final ringColor = isAccentOnly
        ? colors.accent
        : Color.lerp(
            colors.accent,
            colors.correct,
            filledFraction.clamp(0, 1),
          )!;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(
              trackColor: colors.fill,
              ringColor: ringColor,
              filledFraction: filledFraction,
              diskProgress: diskProgress,
              checkProgress: checkProgress,
              checkColor: checkColor ?? colors.onSemantic,
              stroke: stroke,
            ),
          ),
          if (diskProgress == 0 && centerLabel.isNotEmpty)
            Transform.scale(
              scale: centerScale,
              child: Text(
                centerLabel,
                style: (centerStyle ?? PassqlTypography.subheadlineSemibold)
                    .copyWith(
                      color: colors.label,
                      fontFeatures: PassqlTypography.tabular,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.trackColor,
    required this.ringColor,
    required this.filledFraction,
    required this.diskProgress,
    required this.checkProgress,
    required this.checkColor,
    required this.stroke,
  });

  final Color trackColor;
  final Color ringColor;
  final double filledFraction;
  final double diskProgress;
  final double checkProgress;
  final Color checkColor;
  final double stroke;

  // 체크 모양 (원 지름 1 기준 좌표): 왼쪽 아래로 짧게 > 오른쪽 위로 길게
  static const Offset _checkStart = Offset(0.29, 0.52);
  static const Offset _checkCorner = Offset(0.44, 0.66);
  static const Offset _checkEnd = Offset(0.72, 0.37);
  // 체크 선 두께 (지름 대비)
  static const double _checkStrokeRatio = 0.075;
  // 원이 채워질 때 처음 크기 (작게서 튕기듯 커지며 나타남)
  static const double _diskStartScale = 0.35;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, arcPaint..color = trackColor);
    final sweep = 2 * math.pi * filledFraction.clamp(0, 1);
    if (sweep > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweep,
        false,
        arcPaint..color = ringColor,
      );
    }

    if (diskProgress <= 0) return;
    // 안쪽 원: 고리 바깥 끝까지 같은 색으로 채워 하나의 원처럼
    final diskScale =
        _diskStartScale + (1 - _diskStartScale) * diskProgress.clamp(0, 1);
    canvas.drawCircle(
      center,
      size.width / 2 * diskScale,
      Paint()..color = ringColor,
    );

    if (checkProgress <= 0) return;
    final diameter = size.width;
    Offset at(Offset unit) => Offset(unit.dx * diameter, unit.dy * diameter);
    final checkPath = Path()
      ..moveTo(at(_checkStart).dx, at(_checkStart).dy)
      ..lineTo(at(_checkCorner).dx, at(_checkCorner).dy)
      ..lineTo(at(_checkEnd).dx, at(_checkEnd).dy);
    // 선을 앞에서부터 진행률만큼만 잘라 "그려지는" 모양
    final metric = checkPath.computeMetrics().first;
    final drawn = metric.extractPath(
      0,
      metric.length * checkProgress.clamp(0, 1),
    );
    canvas.drawPath(
      drawn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = diameter * _checkStrokeRatio
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = checkColor,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.filledFraction != filledFraction ||
      oldDelegate.diskProgress != diskProgress ||
      oldDelegate.checkProgress != checkProgress ||
      oldDelegate.ringColor != ringColor ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.checkColor != checkColor ||
      oldDelegate.stroke != stroke;
}
