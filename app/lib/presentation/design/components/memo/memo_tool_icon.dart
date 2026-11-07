part of '../passql_memo_scope.dart';

/// 메모 도구 아이콘 5종 (viewBox 24 선 아이콘, 시안 SVG 그대로)
/// CupertinoIcons 에 형광펜·지우개가 없어 직접 그림
enum _PassqlMemoGlyph {
  pen(['M4 20l1-4L16 5l3 3L8 19l-4 1z']),
  // 펜 버튼: 펜 + 끝 마디 선
  penWithTip(['M4 20l1-4L16 5l3 3L8 19l-4 1z', 'M14 7l3 3']),
  highlighter(['M9 15l-3 5h6l1-2', 'M9 15l7-11 4 3-7 11z']),
  eraser(['M7 20h12', 'M4 15l9-9 6 6-8 8H8z']),
  undo(['M9 14L4 9l5-5', 'M4 9h10a6 6 0 010 12h-3']);

  const _PassqlMemoGlyph(this.svgPathData);

  final List<String> svgPathData;

  /// 경로는 한 번만 만들어 다시 씀
  List<Path> get paths => _pathsByGlyph[this] ??= [
    for (final svgPath in svgPathData) passqlSvgPath(svgPath),
  ];

  static final Map<_PassqlMemoGlyph, List<Path>> _pathsByGlyph = {};
}

class _PassqlMemoToolIcon extends StatelessWidget {
  const _PassqlMemoToolIcon({required this.glyph, required this.color});

  final _PassqlMemoGlyph glyph;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(PassqlIconSize.xl),
      painter: _PassqlMemoToolIconPainter(glyph: glyph, color: color),
    );
  }
}

class _PassqlMemoToolIconPainter extends CustomPainter {
  const _PassqlMemoToolIconPainter({required this.glyph, required this.color});

  // 원본 viewBox 한 변, 선 굵기 (시안 1.8)
  static const double _viewBoxSize = 24;
  static const double _strokeWidth = 1.8;

  final _PassqlMemoGlyph glyph;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.save();
    canvas.scale(size.width / _viewBoxSize, size.height / _viewBoxSize);
    for (final path in glyph.paths) {
      canvas.drawPath(path, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PassqlMemoToolIconPainter oldDelegate) =>
      oldDelegate.glyph != glyph || oldDelegate.color != color;
}
