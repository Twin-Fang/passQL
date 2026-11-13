import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 준비도 링 (홈 합격 준비도, #972): 두꺼운 링 하나 + 가운데 글자
/// 채움은 강조색 > 이용권 보라로 번지고 아래에 옅은 빛. 차오름은 쓰는 쪽이 [value] 를 올려 그림 (지표 막대와 함께 맞춤)
/// 링은 스크린리더에서 숨기고 쓰는 쪽이 지표와 묶어 읽힘
class PassqlReadinessRing extends StatelessWidget {
  const PassqlReadinessRing({
    super.key,
    required this.value,
    this.center,
    this.size = PassqlSize.readinessRing,
  });

  /// 비율 0~1 (넘치면 잘라냄)
  final double value;
  final Widget? center;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _ReadinessRingPainter(
            progress: value.clamp(0.0, 1.0),
            trackColor: colors.fill,
            startColor: colors.accent,
            endColor: colors.passGradientEnd,
            glowColor: colors.passGlow,
          ),
          child: center == null ? null : Center(child: center),
        ),
      ),
    );
  }
}

class _ReadinessRingPainter extends CustomPainter {
  _ReadinessRingPainter({
    required this.progress,
    required this.trackColor,
    required this.startColor,
    required this.endColor,
    required this.glowColor,
  });

  final double progress;
  final Color trackColor;
  final Color startColor;
  final Color endColor;
  final Color glowColor;

  // 채움 아래 빛 번짐 반경
  static const double _glowBlurSigma = 6;

  // 12시 시작
  static const double _startAngle = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = PassqlSize.readinessRingStroke;
    final bounds = Offset.zero & size;
    final arc = bounds.deflate(stroke / 2);
    Paint strokePaint() => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    // 바탕 링
    canvas.drawArc(
      arc,
      0,
      math.pi * 2,
      false,
      strokePaint()..color = trackColor,
    );
    if (progress <= 0) return;
    final sweepAngle = math.pi * 2 * progress;

    // 채움 아래 옅은 빛
    canvas.drawArc(
      arc,
      _startAngle,
      sweepAngle,
      false,
      strokePaint()
        ..color = glowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _glowBlurSigma),
    );

    // 채움: 그린 구간 안에서 강조색 > 보라 (시작 둥근 끝이 끝 색으로 물들지 않게 끝 반지름만큼 앞에서 시작)
    final capAngle = (stroke / 2) / (arc.width / 2);
    canvas.drawArc(
      arc,
      _startAngle,
      sweepAngle,
      false,
      strokePaint()
        ..shader = SweepGradient(
          endAngle: math.min(math.pi * 2, sweepAngle + capAngle * 2),
          colors: [startColor, endColor],
          transform: GradientRotation(_startAngle - capAngle),
        ).createShader(bounds),
    );
  }

  @override
  bool shouldRepaint(_ReadinessRingPainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.startColor != startColor ||
      old.endColor != endColor ||
      old.glowColor != glowColor;
}
