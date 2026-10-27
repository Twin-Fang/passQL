import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 작은 진행 고리 (목록 행용, 애니메이션 없음): 가운데 짧은 글자(완료 수, 순번 등)
/// 결과 화면의 큰 점수 고리는 PassqlScoreHeader
class PassqlProgressRing extends StatelessWidget {
  const PassqlProgressRing({
    super.key,
    required this.value,
    required this.centerText,
    this.semanticLabel,
  });

  /// 진행 비율 (0~1, 넘치면 잘라냄)
  final double value;

  /// 고리 가운데 글자 (2~3자)
  final String centerText;

  /// 스크린리더 문구 (없으면 고리 숨김, 행 문구로 대신 읽음)
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final ring = SizedBox.square(
      dimension: PassqlSize.progressRing,
      child: CustomPaint(
        painter: _ProgressRingPainter(
          progress: value.clamp(0.0, 1.0),
          track: colors.fill,
          color: colors.accent,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(PassqlSize.progressRingStroke),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                centerText,
                style: PassqlTypography.footnoteSemibold.copyWith(
                  color: colors.label,
                  fontFeatures: PassqlTypography.tabular,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (semanticLabel == null) return ExcludeSemantics(child: ring);
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(child: ring),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({
    required this.progress,
    required this.track,
    required this.color,
  });

  final double progress;
  final Color track;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = PassqlSize.progressRingStroke;
    final arc = (Offset.zero & size).deflate(stroke / 2);
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
  bool shouldRepaint(_ProgressRingPainter old) =>
      old.progress != progress || old.color != color || old.track != track;
}
