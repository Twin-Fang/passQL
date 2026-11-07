import 'dart:ui';

import 'package:path_parsing/path_parsing.dart';

/// SVG `d` 문자열 > Path (직접 그리는 선 아이콘 공용: 탭 바·메모 도구)
/// 아이콘은 앱 수명 동안 바뀌지 않아 한 번 만든 Path 를 다시 쓴다
Path passqlSvgPath(String svgPathData) {
  final proxy = _PathProxy();
  writeSvgPathDataToPath(svgPathData, proxy);
  return proxy.path;
}

class _PathProxy extends PathProxy {
  final Path path = Path();

  @override
  void moveTo(double x, double y) => path.moveTo(x, y);

  @override
  void lineTo(double x, double y) => path.lineTo(x, y);

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) => path.cubicTo(x1, y1, x2, y2, x3, y3);

  @override
  void close() => path.close();
}
