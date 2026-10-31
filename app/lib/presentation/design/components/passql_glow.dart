import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 원에서 바깥으로 번지는 보라 빛 (#764 개념 점수판, #772 당겨서 새로고침).
/// 앞머리가 가장 밝고 안쪽은 옅게 깔리며, 퍼지는 동안 서서히 옅어진다.
/// 깔린 영역 크기 층으로 두고 [center] 는 그 층 기준 출발점 (null 이면 층 가운데).
/// [endRadius] 가 null 이면 가장 먼 귀퉁이까지 (화면 끝까지), 값을 주면 그 반지름까지.
/// 그리기만 하고 누름·스크린리더에는 끼지 않는다
class PassqlGlow extends StatelessWidget {
  const PassqlGlow({
    super.key,
    required this.progress,
    required this.startRadius,
    this.center,
    this.endRadius,
  });

  /// 0~1 번짐 진행 (0이거나 1이면 아무것도 안 그림)
  final double progress;

  /// 빛이 출발하는 반지름
  final double startRadius;

  /// 빛이 출발하는 점 (층 왼쪽 위 기준). null 이면 층 가운데
  final Offset? center;

  /// 빛 앞머리가 닿는 반지름. null 이면 가장 먼 귀퉁이까지
  final double? endRadius;

  @override
  Widget build(BuildContext context) {
    if (progress <= 0 || progress >= 1) return const SizedBox.shrink();
    final colors = context.passqlColors;
    return IgnorePointer(
      child: ExcludeSemantics(
        child: CustomPaint(
          size: Size.infinite,
          painter: _GlowPainter(
            progress: progress,
            center: center,
            startRadius: startRadius,
            endRadius: endRadius,
            innerColor: colors.accent,
            edgeColor: colors.passGradientEnd,
          ),
        ),
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  _GlowPainter({
    required this.progress,
    required this.center,
    required this.startRadius,
    required this.endRadius,
    required this.innerColor,
    required this.edgeColor,
  });

  final double progress;
  final Offset? center;
  final double startRadius;
  final double? endRadius;
  final Color innerColor;
  final Color edgeColor;

  // 빛이 가장 진해지는 시점(진행률), 가장 진할 때 앞머리·안쪽 투명도
  static const double _peakAt = 0.12;
  static const double _edgeAlpha = 0.32;
  static const double _innerAlpha = 0.12;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = center ?? size.center(Offset.zero);
    // 끝 반지름이 없으면 출발점에서 가장 먼 귀퉁이까지 (거기까지 닿아야 "화면 끝까지")
    final reach =
        endRadius ??
        [
          Offset.zero,
          Offset(size.width, 0),
          Offset(0, size.height),
          Offset(size.width, size.height),
        ].map((corner) => (corner - origin).distance).reduce(math.max);
    // 앞머리는 처음 빠르게 나가고 점점 느려짐
    final eased = PassqlMotion.curve.transform(progress);
    final radius = startRadius + (reach - startRadius) * eased;
    // 금방 진해졌다가 퍼지는 동안 서서히 옅어짐
    final strength = progress < _peakAt
        ? progress / _peakAt
        : 1 - (progress - _peakAt) / (1 - _peakAt);
    final rect = Rect.fromCircle(center: origin, radius: radius);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: [
            innerColor.withValues(alpha: _innerAlpha * strength),
            innerColor.withValues(alpha: _innerAlpha * strength),
            edgeColor.withValues(alpha: _edgeAlpha * strength),
            edgeColor.withValues(alpha: 0),
          ],
          // 안쪽은 옅게 깔고, 바깥 테두리 쪽이 가장 밝은 앞머리
          stops: const [0, 0.55, 0.88, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GlowPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.center != center ||
      oldDelegate.startRadius != startRadius ||
      oldDelegate.endRadius != endRadius ||
      oldDelegate.innerColor != innerColor ||
      oldDelegate.edgeColor != edgeColor;
}
