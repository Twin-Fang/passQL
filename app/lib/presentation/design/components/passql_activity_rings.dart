import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../passql_theme.dart';

/// 링 한 겹: 비율(0~1, 넘치면 잘라냄)과 색
typedef PassqlRing = ({double value, Color color});

/// 바깥에서 안쪽으로 겹친 진행 링 (피트니스 링 모양, #701). 가운데에 짧은 글자를 둘 수 있다.
/// 스크린리더 문구는 쓰는 쪽이 범례와 함께 묶어 준다 (링 자체는 숨김)
class PassqlActivityRings extends StatelessWidget {
  const PassqlActivityRings({
    super.key,
    required this.rings,
    this.center,
    this.size = _defaultSize,
  });

  /// 바깥 링부터 순서대로
  final List<PassqlRing> rings;
  final Widget? center;
  final double size;

  // 홈 합격 준비도 기준 크기: 링 세 겹 + 가운데 점수 글자가 들어가는 최소 지름
  static const double _defaultSize = 120;

  // 링 두께와 링 사이 간격 (지름 120 기준 세 겹이 가운데 글자 자리를 남기는 값)
  static const double _stroke = 10;
  static const double _gap = 4;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingsPainter(
            rings: rings,
            track: context.passqlColors.fill,
          ),
          child: center == null ? null : Center(child: center),
        ),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  _RingsPainter({required this.rings, required this.track});

  final List<PassqlRing> rings;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = PassqlActivityRings._stroke;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < rings.length; i++) {
      final inset = stroke / 2 + i * (stroke + PassqlActivityRings._gap);
      final arc = (Offset.zero & size).deflate(inset);
      canvas.drawArc(arc, 0, math.pi * 2, false, paint..color = track);
      final progress = rings[i].value.clamp(0.0, 1.0);
      if (progress > 0) {
        canvas.drawArc(
          arc,
          -math.pi / 2,
          math.pi * 2 * progress,
          false,
          paint..color = rings[i].color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) =>
      old.track != track || old.rings != rings;
}
