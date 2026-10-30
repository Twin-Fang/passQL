import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design/design.dart';

/// 폭죽 조각이 흩날리는 층 (#764, 개념 결과 다 맞힘). 새 패키지 없이 직접 그린다.
/// [progress] 0~1 동안 위에서 퍼져 떨어지고 끝에서 사라진다. 누름·스크린리더에는 끼지 않는다
class ConceptConfetti extends StatelessWidget {
  const ConceptConfetti({super.key, required this.progress});

  final double progress;

  // 조각 수 (화면을 덮되 글자를 가리지 않을 정도)
  static const int _pieceCount = 60;
  // 같은 모양이 매번 나오게 고정 시드 (연출을 다시 볼 때 흔들림 없이)
  static const int _seed = 764;

  @override
  Widget build(BuildContext context) {
    if (progress <= 0 || progress >= 1) return const SizedBox.shrink();
    final colors = context.passqlColors;
    final palette = [
      colors.accent,
      colors.correct,
      colors.warning,
      colors.wrong,
      colors.accentText,
      colors.passGradientEnd,
    ];
    return IgnorePointer(
      child: ExcludeSemantics(
        child: CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(progress: progress, palette: palette),
        ),
      ),
    );
  }

  static final List<_Piece> _pieces = () {
    final random = math.Random(_seed);
    return List.generate(_pieceCount, (index) {
      return _Piece(
        startX: random.nextDouble(),
        startY: -0.05 - random.nextDouble() * 0.15,
        driftX: (random.nextDouble() - 0.5) * 0.35,
        fallY: 0.55 + random.nextDouble() * 0.45,
        spin: (random.nextDouble() - 0.5) * 12,
        width: 5 + random.nextDouble() * 5,
        isRound: random.nextDouble() < 0.35,
        colorIndex: index,
      );
    });
  }();
}

/// 조각 하나의 출발점·흐름 (화면 폭·높이 비율)
class _Piece {
  const _Piece({
    required this.startX,
    required this.startY,
    required this.driftX,
    required this.fallY,
    required this.spin,
    required this.width,
    required this.isRound,
    required this.colorIndex,
  });

  final double startX;
  final double startY;
  final double driftX;
  final double fallY;
  final double spin;
  final double width;
  final bool isRound;
  final int colorIndex;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.palette});

  final double progress;
  final List<Color> palette;

  // 끝 30% 동안 서서히 사라짐
  static const double _fadeStart = 0.7;

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = progress < _fadeStart
        ? 1.0
        : 1 - (progress - _fadeStart) / (1 - _fadeStart);
    // 처음엔 빠르게 퍼지고 점점 느려지는 낙하
    final eased = 1 - math.pow(1 - progress, 2).toDouble();
    for (final piece in ConceptConfetti._pieces) {
      final x = (piece.startX + piece.driftX * eased) * size.width;
      final y = (piece.startY + piece.fallY * eased) * size.height;
      final paint = Paint()
        ..color = palette[piece.colorIndex % palette.length].withValues(
          alpha: opacity,
        );
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(piece.spin * progress);
      if (piece.isRound) {
        canvas.drawCircle(Offset.zero, piece.width / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.width,
            height: piece.width * 2,
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.palette != palette;
}
