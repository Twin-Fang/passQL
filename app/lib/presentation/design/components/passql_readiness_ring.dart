import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../passql_theme.dart';
import '../tokens/passql_motion.dart';

/// 준비도 링 (홈 합격 준비도, #701·#971): 두꺼운 링 하나가 0에서 값까지 차오름
/// 채움은 강조색 > 이용권 보라로 번지고 아래에 옅은 빛, 가운데 글자는 [centerBuilder] 가 차오르는 값으로 그림
/// 동작 줄이기면 바로 최종 값. 스크린리더 문구는 쓰는 쪽이 지표와 함께 묶어 준다 (링 자체는 숨김)
class PassqlReadinessRing extends StatelessWidget {
  const PassqlReadinessRing({
    super.key,
    required this.value,
    this.centerBuilder,
    this.size = _defaultSize,
  });

  /// 비율 0~1 (넘치면 잘라냄)
  final double value;

  /// 가운데 글자 (차오르는 중의 비율을 받아 숫자를 올려 그림)
  final Widget Function(BuildContext context, double animatedValue)?
  centerBuilder;
  final double size;

  // 홈 합격 준비도 기준 지름, 링 두께, 빛 번짐 반경
  static const double _defaultSize = 128;
  static const double _stroke = 14;
  static const double _glowBlurSigma = 6;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final centerBuilder = this.centerBuilder;
    return ExcludeSemantics(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
        duration: PassqlMotion.durationOf(context, PassqlMotion.scoreFill),
        curve: PassqlMotion.curve,
        builder: (context, animatedValue, _) => SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _ReadinessRingPainter(
              progress: animatedValue,
              track: colors.fill,
              startColor: colors.accent,
              endColor: colors.passGradientEnd,
              glowColor: colors.passGlow,
            ),
            child: centerBuilder == null
                ? null
                : Center(child: centerBuilder(context, animatedValue)),
          ),
        ),
      ),
    );
  }
}

class _ReadinessRingPainter extends CustomPainter {
  _ReadinessRingPainter({
    required this.progress,
    required this.track,
    required this.startColor,
    required this.endColor,
    required this.glowColor,
  });

  final double progress;
  final Color track;
  final Color startColor;
  final Color endColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = PassqlReadinessRing._stroke;
    final bounds = Offset.zero & size;
    final arc = bounds.deflate(stroke / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    // 바탕 링
    canvas.drawArc(arc, 0, math.pi * 2, false, base..color = track);
    if (progress <= 0) return;
    const startAngle = -math.pi / 2;
    final sweepAngle = math.pi * 2 * progress;
    // 채움 아래 옅은 빛
    canvas.drawArc(
      arc,
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = glowColor
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          PassqlReadinessRing._glowBlurSigma,
        ),
    );
    // 채움: 12시에서 시작해 시계 방향으로 색이 번짐
    canvas.drawArc(
      arc,
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: [startColor, endColor, startColor],
          transform: const GradientRotation(startAngle),
        ).createShader(bounds),
    );
  }

  @override
  bool shouldRepaint(_ReadinessRingPainter old) =>
      old.progress != progress ||
      old.track != track ||
      old.startColor != startColor ||
      old.endColor != endColor ||
      old.glowColor != glowColor;
}
