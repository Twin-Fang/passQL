import 'package:flutter/widgets.dart';

import '../tokens/passql_tokens.dart';
import 'passql_tab_icon_paths.dart';

/// 하단 탭 아이콘 종류
enum PassqlTabIconKind { home, concept, questions, community, profile }

/// 하단 탭 아이콘: 선 아이콘을 직접 그려, 선택될 때 아이콘 안의 일부만 짧게 움직인다 (#755).
/// 폰트 아이콘은 통째로만 움직일 수 있어 직접 그린다. 선택이 새로 켜질 때만 재생하고(앱 시작·같은 탭 다시 누름은 제외),
/// 동작 줄이기면 움직임 없이 색·채움만 바뀐다.
class PassqlTabIcon extends StatefulWidget {
  const PassqlTabIcon({
    super.key,
    required this.kind,
    required this.isSelected,
    required this.color,
    this.size = PassqlIconSize.xxl,
  });
  final PassqlTabIconKind kind;
  final bool isSelected;

  /// 선·채움 색
  final Color color;
  final double size;

  @override
  State<PassqlTabIcon> createState() => _PassqlTabIconState();
}

class _PassqlTabIconState extends State<PassqlTabIcon>
    with SingleTickerProviderStateMixin {
  // 끝 상태(1)에서 시작해 첫 화면에서는 움직이지 않는다
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PassqlMotion.tabIconSelect,
    value: 1,
  );

  @override
  void didUpdateWidget(PassqlTabIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isNewlySelected = !oldWidget.isSelected && widget.isSelected;
    if (isNewlySelected && !PassqlMotion.isReduced(context)) {
      _controller.forward(from: 0);
    } else if (!widget.isSelected) {
      // 재생 중에 다른 탭으로 옮기면 바로 끝 모양으로
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 탭 바의 다른 부분이 프레임마다 다시 그려지지 않게 따로 떼어 둔다
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _TabIconPainter(
          kind: widget.kind,
          isSelected: widget.isSelected,
          color: widget.color,
          animation: _controller,
        ),
      ),
    );
  }
}

/// viewBox 24 좌표로 그린다. 부품별 움직임 구간(ms)은 #755 확정 시안 값
class _TabIconPainter extends CustomPainter {
  _TabIconPainter({
    required this.kind,
    required this.isSelected,
    required this.color,
    required this.animation,
  }) : super(repaint: animation);

  final PassqlTabIconKind kind;
  final bool isSelected;
  final Color color;
  final Animation<double> animation;

  static const double _viewBox = 24;
  static const double _strokeWidth = 2;

  /// 작게 시작해 커지는 부품의 시작 배율
  static const double _popFrom = 0.88;

  late final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = _strokeWidth
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = color;

  // 선택이면 선 아이콘과 같은 윤곽을 꽉 채우고, 뜻을 담은 곳(체크·말풍선 사이 틈·집게 둘레)만 뚫어 바탕이 보이게 한다
  late final Paint _fill = Paint()..color = color;
  late final Paint _cutStroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = _strokeWidth
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..blendMode = BlendMode.clear;
  final Paint _cutFill = Paint()..blendMode = BlendMode.clear;

  /// 집게 둘레 틈
  static const double _clipGap = 1;

  /// 앞·뒤 말풍선 사이 틈 (선 아이콘 경로에서 잰 값: 뒤 말풍선은 앞 말풍선 바깥 3에서 시작)
  static const double _bubbleGap = 3;

  double get _t => animation.value;

  /// 전체 진행 중 [startMs]부터 [lengthMs] 동안의 진행도 (구간 밖은 0 또는 1)
  double _phase(int startMs, int lengthMs, Curve curve) {
    final total = PassqlMotion.tabIconSelect.inMilliseconds;
    return Interval(
      startMs / total,
      (startMs + lengthMs) / total,
      curve: curve,
    ).transform(_t);
  }

  double _popScale(double from, int startMs, int lengthMs) =>
      from + (1 - from) * _phase(startMs, lengthMs, PassqlMotion.springCurve);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _viewBox);
    // 뚫는 그리기(BlendMode.clear)가 탭 바 바탕까지 지우지 않게 아이콘만의 층에서 그린다 (빛줄기가 위로 나가 넉넉히)
    if (isSelected) canvas.saveLayer(const Rect.fromLTWH(-2, -6, 28, 32), Paint());
    _paintKind(canvas);
    if (isSelected) canvas.restore();
  }

  void _paintKind(Canvas canvas) {
    switch (kind) {
      case PassqlTabIconKind.home:
        _paintHome(canvas);
      case PassqlTabIconKind.concept:
        _paintConcept(canvas);
      case PassqlTabIconKind.questions:
        _paintQuestions(canvas);
      case PassqlTabIconKind.community:
        _paintCommunity(canvas);
      case PassqlTabIconKind.profile:
        _paintProfile(canvas);
    }
  }

  // 집이 바닥을 기준으로 톡 커짐 (문은 윤곽의 일부라 따로 움직이지 않음)
  void _paintHome(Canvas canvas) {
    _scaled(canvas, const Offset(12, 21), _popScale(_popFrom, 0, 450), () {
      _drawBody(canvas, houseOutline);
    });
  }

  // 전구가 톡 커지고 위쪽 빛줄기가 번졌다 사라짐
  void _paintConcept(Canvas canvas) {
    _scaled(canvas, const Offset(12, 22), _popScale(_popFrom, 0, 450), () {
      _drawBody(canvas, bulbBody);
    });
    canvas.drawPath(bulbBase, _stroke);

    final rays = _phase(50, 550, PassqlMotion.curve);
    if (!isSelected || rays <= 0 || rays >= 1) return;
    // 40% 지점까지 밝아지고 이후 사라짐
    final opacity = rays < 0.4 ? rays / 0.4 : 1 - (rays - 0.4) / 0.6;
    _scaled(canvas, const Offset(12, 7), 0.7 + 0.4 * rays, () {
      final rayPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke.strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: color.a * opacity);
      canvas.drawPath(bulbRays, rayPaint);
    });
  }

  // 클립보드가 톡 커지고 체크가 쓱 그려짐
  void _paintQuestions(Canvas canvas) {
    _scaled(canvas, const Offset(12, 21), _popScale(_popFrom, 0, 450), () {
      _drawBody(canvas, clipboardBoard);
      if (isSelected) {
        // 집게 둘레를 틈만큼 뚫어 판과 떨어져 보이게
        canvas.drawRRect(
          _clipboardClip.inflate(_stroke.strokeWidth / 2 + _clipGap),
          _cutFill,
        );
        canvas.drawRRect(_clipboardClip, _fill);
      }
      canvas.drawRRect(_clipboardClip, _stroke);
    });
    final drawn = _phase(150, 350, PassqlMotion.curve);
    if (drawn <= 0) return;
    for (final metric in clipboardCheck.computeMetrics()) {
      canvas.drawPath(
        metric.extractPath(0, metric.length * drawn),
        isSelected ? _cutStroke : _stroke,
      );
    }
  }

  static final _clipboardClip = RRect.fromRectAndRadius(
    const Rect.fromLTWH(8, 2, 8, 4),
    const Radius.circular(1),
  );

  // 두 말풍선이 차례로 살짝 떠올랐다 내려옴
  void _paintCommunity(Canvas canvas) {
    final backLift = _bobOffset(100);
    final frontLift = _bobOffset(0);
    _lifted(canvas, backLift, () {
      if (isSelected) {
        _drawBody(canvas, bubbleBackFilled);
      } else {
        canvas.drawPath(bubbleBack, _stroke);
      }
    });
    _lifted(canvas, frontLift, () {
      if (isSelected) {
        // 앞 말풍선 둘레를 뚫어 두 말풍선이 떨어져 보이게
        final gapPaint = Paint.from(_cutStroke)
          ..strokeWidth = _stroke.strokeWidth + _bubbleGap * 2;
        canvas.drawPath(bubbleFront, gapPaint);
      }
      _drawBody(canvas, bubbleFront);
    });
  }

  /// 말풍선이 뜨는 높이
  static const double _bobHeight = 1.5;

  double _bobOffset(int startMs) {
    final p = _phase(startMs, 400, PassqlMotion.curve);
    // 45% 지점이 꼭대기인 삼각형
    final lift = p < 0.45 ? p / 0.45 : (1 - p) / 0.55;
    return -_bobHeight * lift;
  }

  // 어깨가 톡 커지고, 머리가 살짝 내려갔다 올라옴 (끄덕임)
  void _paintProfile(Canvas canvas) {
    _scaled(canvas, const Offset(12, 21), _popScale(_popFrom, 0, 450), () {
      _drawBody(canvas, isSelected ? userBodyClosed : userBody);
    });
    final nod = _nodDepth * (1 - _phase(60, 450, PassqlMotion.springCurve));
    _lifted(canvas, nod, () => _drawBody(canvas, _userHead));
  }

  /// 끄덕일 때 머리가 내려가는 깊이. 머리와 어깨 사이 틈(2)보다 작아 닿지 않는다
  static const double _nodDepth = 1.5;

  static final _userHead = Path()
    ..addOval(Rect.fromCircle(center: const Offset(12, 7), radius: 4));

  /// 몸체: 선은 언제나 그리고, 선택이면 안쪽을 꽉 채운다
  void _drawBody(Canvas canvas, Path path) {
    if (isSelected) canvas.drawPath(path, _fill);
    canvas.drawPath(path, _stroke);
  }

  /// [origin] 기준 균등 확대. 선 굵기는 배율과 반대로 맞춰 움직이는 동안에도 2로 유지한다
  /// (가로·세로를 다르게 늘리거나 굵기가 출렁이면 아이콘이 깨져 보인다)
  void _scaled(Canvas canvas, Offset origin, double scale, VoidCallback draw) {
    if (scale == 1) {
      draw();
      return;
    }
    // 확대가 끝나면 원래 굵기로 되돌리기 위해 기억
    final previousWidth = _stroke.strokeWidth;
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(scale);
    canvas.translate(-origin.dx, -origin.dy);
    _stroke.strokeWidth = previousWidth / scale;
    _cutStroke.strokeWidth = previousWidth / scale;
    draw();
    _stroke.strokeWidth = previousWidth;
    _cutStroke.strokeWidth = previousWidth;
    canvas.restore();
  }

  void _lifted(Canvas canvas, double dy, VoidCallback draw) {
    canvas.save();
    canvas.translate(0, dy);
    draw();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TabIconPainter old) =>
      old.kind != kind ||
      old.isSelected != isSelected ||
      old.color != color ||
      old.animation != animation;
}
