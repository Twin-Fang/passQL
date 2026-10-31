import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design/design.dart';

/// 폭죽 층 (#764, 개념 결과 다 맞힘). 새 패키지 없이 직접 그린다.
/// 움직임은 웹의 canvas-confetti 물리(틱마다 속도가 decay 배로 줄고 중력은 일정, 좌우 흔들림(wobble)과
/// 기울기(tilt)로 종이가 팔랑이는 모양)를 그대로 옮겼다. 아래 왼쪽(7시)·오른쪽(5시) 구석의 대포 두 대가
/// 각각 1시·11시 방향으로 쏴 가운데서 엇갈린다. 누름·스크린리더에는 끼지 않는다
class ConceptConfetti extends StatelessWidget {
  const ConceptConfetti({super.key, required this.progress});

  /// 0~1 연출 진행
  final double progress;

  // 같은 모양이 매번 나오게 고정 시드 (연출을 다시 볼 때 흔들림 없이)
  static const int _seed = 764;
  // 연출 전체 틱 수 (canvas-confetti 기본 200틱 ≈ 60fps 3.3초, 여기선 토큰 시간에 맞춰 진행률로 나눔)
  static const int _ticks = 170;

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

  // 대포 한 대의 발사 묶음 (canvas-confetti "realistic" 예제처럼 좁고 빠른 것 + 넓고 느린 것을 겹침)
  static const List<_Burst> _bursts = [
    _Burst(
      count: 22,
      spreadDeg: 26,
      startVelocity: 72,
      decay: 0.9,
      scalar: 1.3,
    ),
    _Burst(
      count: 18,
      spreadDeg: 60,
      startVelocity: 62,
      decay: 0.9,
      scalar: 1.3,
    ),
    _Burst(
      count: 30,
      spreadDeg: 100,
      startVelocity: 50,
      decay: 0.91,
      scalar: 0.8,
    ),
    _Burst(
      count: 10,
      spreadDeg: 120,
      startVelocity: 36,
      decay: 0.92,
      scalar: 1.2,
    ),
  ];
  // 조준 각도: 왼쪽 대포 60도(1시), 오른쪽 대포 120도(11시). 0도가 오른쪽, 90도가 위
  static const double _leftAngleDeg = 60;
  static const double _rightAngleDeg = 120;

  static final List<_Piece> _pieces = () {
    final random = math.Random(_seed);
    final pieces = <_Piece>[];
    var colorIndex = 0;
    for (final isLeft in [true, false]) {
      for (final burst in _bursts) {
        final radAngle =
            (isLeft ? _leftAngleDeg : _rightAngleDeg) * math.pi / 180;
        final radSpread = burst.spreadDeg * math.pi / 180;
        for (var i = 0; i < burst.count; i++) {
          pieces.add(
            _Piece(
              originX: isLeft ? 0 : 1,
              // 화면 아래 구석에서 조금 안쪽 (조각이 처음부터 보이게)
              originY: 0.98,
              angle2D:
                  -radAngle +
                  (0.5 * radSpread - random.nextDouble() * radSpread),
              velocity:
                  burst.startVelocity * 0.5 +
                  random.nextDouble() * burst.startVelocity,
              decay: burst.decay,
              scalar: burst.scalar,
              wobble: random.nextDouble() * 10,
              wobbleSpeed: math.min(0.11, random.nextDouble() * 0.1 + 0.05),
              tiltAngle: random.nextDouble() * math.pi,
              ovalScalar: 0.6 + random.nextDouble() * 0.4,
              randomOffset: random.nextDouble() + 2,
              isCircle: random.nextDouble() < 0.3,
              // 쏘는 틱이 조금씩 달라 대포에서 뿜어져 나오듯
              delayTicks: (random.nextDouble() * 18).round(),
              colorIndex: colorIndex++,
            ),
          );
        }
      }
    }
    return pieces;
  }();
}

/// 대포 한 번의 발사 설정 (canvas-confetti 옵션 이름 그대로)
class _Burst {
  const _Burst({
    required this.count,
    required this.spreadDeg,
    required this.startVelocity,
    required this.decay,
    required this.scalar,
  });

  final int count;
  final double spreadDeg;
  final double startVelocity;
  final double decay;
  final double scalar;
}

/// 조각 하나의 초기값 (위치는 화면 비율, 속도는 논리 픽셀/틱)
class _Piece {
  const _Piece({
    required this.originX,
    required this.originY,
    required this.angle2D,
    required this.velocity,
    required this.decay,
    required this.scalar,
    required this.wobble,
    required this.wobbleSpeed,
    required this.tiltAngle,
    required this.ovalScalar,
    required this.randomOffset,
    required this.isCircle,
    required this.delayTicks,
    required this.colorIndex,
  });

  final double originX;
  final double originY;
  final double angle2D;
  final double velocity;
  final double decay;
  final double scalar;
  final double wobble;
  final double wobbleSpeed;
  final double tiltAngle;
  final double ovalScalar;
  final double randomOffset;
  final bool isCircle;
  final int delayTicks;
  final int colorIndex;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.palette});

  final double progress;
  final List<Color> palette;

  // 틱당 중력(논리 픽셀), 흔들림 반지름(scalar 1 기준), 기울기 회전 속도, 중간(50%)부터 서서히 사라짐
  static const double _gravityPerTick = 1.4;
  static const double _wobbleRadius = 10;
  static const double _tiltSpeed = 0.1;
  static const double _fadeStart = 0.5;

  @override
  void paint(Canvas canvas, Size size) {
    final totalTick = progress * ConceptConfetti._ticks;
    final opacity = progress < _fadeStart
        ? 1.0
        : 1 - (progress - _fadeStart) / (1 - _fadeStart);
    for (final piece in ConceptConfetti._pieces) {
      final tick = totalTick - piece.delayTicks;
      if (tick <= 0) continue;
      // 틱마다 velocity *= decay 를 닫힌 식으로: 누적 이동 = v0 (1 - decay^t) / (1 - decay)
      final travel =
          piece.velocity *
          (1 - math.pow(piece.decay, tick)) /
          (1 - piece.decay);
      final x = piece.originX * size.width + math.cos(piece.angle2D) * travel;
      final y =
          piece.originY * size.height +
          math.sin(piece.angle2D) * travel +
          _gravityPerTick * tick;
      final wobble = piece.wobble + piece.wobbleSpeed * tick;
      final wobbleX = x + _wobbleRadius * piece.scalar * math.cos(wobble);
      final wobbleY = y + _wobbleRadius * piece.scalar * math.sin(wobble);
      final tilt = piece.tiltAngle + _tiltSpeed * tick;
      final tiltSin = math.sin(tilt);
      final tiltCos = math.cos(tilt);
      // 화면 아래로 떨어진 조각은 그리지 않음 (바닥에 쌓이지 않고 사라짐)
      if (y > size.height + _wobbleRadius * piece.scalar) continue;
      final paint = Paint()
        ..color = palette[piece.colorIndex % palette.length].withValues(
          alpha: opacity,
        );
      // canvas-confetti 와 같은 네 점: 기울기·흔들림으로 비틀린 사각형 (종이가 뒤집히는 느낌)
      final x1 = x + piece.randomOffset * tiltCos;
      final y1 = y + piece.randomOffset * tiltSin;
      final x2 = wobbleX + piece.randomOffset * tiltCos;
      final y2 = wobbleY + piece.randomOffset * tiltSin;
      if (piece.isCircle) {
        final radiusX = (x2 - x1).abs() * piece.ovalScalar;
        final radiusY = (y2 - y1).abs() * piece.ovalScalar;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x, y),
            width: radiusX * 2,
            height: radiusY * 2,
          ),
          paint,
        );
      } else {
        final path = Path()
          ..moveTo(x, y)
          ..lineTo(wobbleX, y1)
          ..lineTo(x2, y2)
          ..lineTo(x1, wobbleY)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.palette != palette;
}
