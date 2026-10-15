import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 결과 점수 머리. 정답률을 고리로 보여 주고 가운데에 점수를 둔다.
class PassqlScoreHeader extends StatelessWidget {
  const PassqlScoreHeader({
    super.key,
    required this.score,
    required this.total,
    this.caption,
  });
  final int score;
  final int total;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final ratio = total == 0 ? 0.0 : score / total;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (caption != null) ...[
          Text(
            caption!,
            style: PassqlTypography.subheadline.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: PassqlSpacing.sm),
        ],
        SizedBox.square(
          dimension: PassqlSize.scoreRing,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: ratio),
            duration: const Duration(milliseconds: 700),
            curve: PassqlMotion.curve,
            builder: (_, animatedProgress, child) => CustomPaint(
              painter: _RingPainter(
                progress: animatedProgress,
                track: colors.fill,
                color: colors.accent,
              ),
              child: child,
            ),
            // 좁은 폭·큰 글자에서도 고리 안에 머물도록 줄여서 맞춘다.
            child: Padding(
              // 고리 두께 + 여유(xs) 안쪽에서만 줄어들게 한다.
              padding: const EdgeInsets.all(
                PassqlSize.scoreRingStroke + PassqlSpacing.xs,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$score',
                      style: PassqlTypography.scoreNumber.copyWith(
                        color: colors.label,
                      ),
                    ),
                    Text(
                      ' / $total',
                      style: PassqlTypography.title3.copyWith(
                        color: colors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: PassqlSpacing.sm),
        Text(
          '정답률 ${(ratio * 100).round()}%',
          style: PassqlTypography.subheadlineSemibold.copyWith(
            color: colors.secondaryLabel,
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.track,
    required this.color,
  });
  final double progress;
  final Color track;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = PassqlSize.scoreRingStroke;
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arc, 0, math.pi * 2, false, base..color = track);
    if (progress > 0) {
      canvas.drawArc(
        arc,
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        base..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color || old.track != track;
}
