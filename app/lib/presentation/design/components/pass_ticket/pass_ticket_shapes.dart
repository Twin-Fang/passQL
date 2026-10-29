part of '../passql_pass_ticket.dart';

/// 탑승권 외곽: 둥근 사각형에서 절취선 위아래 반원 홈을 뺀다
class _TicketClipper extends CustomClipper<Path> {
  const _TicketClipper();

  @override
  Path getClip(Size size) {
    final notchX = size.width - _stubWidth;
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(PassqlRadius.lg + PassqlSpacing.xxs),
        ),
      );
    final notches = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(notchX, 0), radius: _notchRadius),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(notchX, size.height),
          radius: _notchRadius,
        ),
      );
    return Path.combine(PathOperation.difference, outline, notches);
  }

  @override
  bool shouldReclip(_TicketClipper oldClipper) => false;
}

/// 세로 점선 (절취선)
class _PerforationPainter extends CustomPainter {
  const _PerforationPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width;
    final x = size.width / 2;
    for (
      var y = _notchRadius;
      y < size.height - _notchRadius;
      y += _dashLength + _dashGap
    ) {
      canvas.drawLine(Offset(x, y), Offset(x, y + _dashLength), paint);
    }
  }

  @override
  bool shouldRepaint(_PerforationPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// 가로 점선 (경로 선)
class _DashLinePainter extends CustomPainter {
  const _DashLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height;
    final y = size.height / 2;
    for (var x = 0.0; x < size.width; x += _dashLength + _dashGap) {
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + _dashLength, size.width), y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// 바코드 무늬 (굵기가 번갈아 바뀌는 세로줄, 장식)
class _BarcodePainter extends CustomPainter {
  const _BarcodePainter({required this.color});

  final Color color;

  // 줄 굵기 반복 패턴 (굵게·가늘게 번갈아)
  static const List<double> _barWidths = [2, 1, 1, 2, 1, 3, 1, 1, 2, 1];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    var x = 0.0;
    var index = 0;
    while (x < size.width) {
      final barWidth = math.min(
        _barWidths[index % _barWidths.length],
        size.width - x,
      );
      canvas.drawRect(Rect.fromLTWH(x, 0, barWidth, size.height), paint);
      x += barWidth + 2;
      index++;
    }
    // 오른쪽 끝이 틈으로 끝나면 글자 끝과 어긋나 보여 마지막 줄을 끝에 붙인다
    canvas.drawRect(Rect.fromLTWH(size.width - 1, 0, 1, size.height), paint);
  }

  @override
  bool shouldRepaint(_BarcodePainter oldDelegate) => oldDelegate.color != color;
}
