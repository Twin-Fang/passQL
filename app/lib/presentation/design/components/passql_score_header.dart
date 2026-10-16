import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 결과 점수 머리. 정답률을 고리로 보여 주고 가운데에 점수를 둔다.
/// 화면 전환이 끝난 뒤 고리가 차오르고 점수·정답률 숫자가 함께 올라간다.
class PassqlScoreHeader extends StatefulWidget {
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
  State<PassqlScoreHeader> createState() => _PassqlScoreHeaderState();
}

class _PassqlScoreHeaderState extends State<PassqlScoreHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PassqlMotion.scoreFill,
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: PassqlMotion.curve,
  );
  Timer? _startTimer;
  bool _hasStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasStarted) return;
    _hasStarted = true;
    if (PassqlMotion.isReduced(context)) {
      _controller.value = 1;
      return;
    }
    _startTimer = Timer(PassqlMotion.afterRouteTransitionDelay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final ratio = widget.total == 0 ? 0.0 : widget.score / widget.total;
    return AnimatedBuilder(
      animation: _progress,
      builder: (_, _) {
        final animatedValue = _progress.value;
        final animatedScore = (widget.score * animatedValue).round();
        final animatedPercent = (ratio * 100 * animatedValue).round();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.caption != null) ...[
              Text(
                widget.caption!,
                style: PassqlTypography.subheadline.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
              const SizedBox(height: PassqlSpacing.sm),
            ],
            SizedBox.square(
              dimension: PassqlSize.scoreRing,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: ratio * animatedValue,
                  track: colors.fill,
                  color: colors.accent,
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
                          '$animatedScore',
                          style: PassqlTypography.scoreNumber.copyWith(
                            color: colors.label,
                          ),
                        ),
                        Text(
                          ' / ${widget.total}',
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
              '정답률 $animatedPercent%',
              style: PassqlTypography.subheadlineSemibold.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ],
        );
      },
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
