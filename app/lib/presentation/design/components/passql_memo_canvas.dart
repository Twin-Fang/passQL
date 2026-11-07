import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_memo_controller.dart';
import 'passql_memo_scope.dart';

/// 펜 색 > 테마 색 (빨강 wrong, 파랑 memoInkBlue, 검정 label)
Color passqlMemoInkColor(PassqlMemoInk ink, PassqlColors colors) =>
    switch (ink) {
      PassqlMemoInk.red => colors.wrong,
      PassqlMemoInk.blue => colors.memoInkBlue,
      PassqlMemoInk.label => colors.label,
    };

/// 메모 층: 문항 내용 위에 겹쳐 내용과 함께 스크롤 (스크롤 내용 안에 둠)
/// 켬: 한 손가락 그리기·지우기(스크롤 멈춤), 두 손가락 스크롤 / 끔: 흐리게 보이기만, 터치는 전부 아래 내용으로
/// [PassqlMemoScope] 밖이면 내용만 그대로 그림
class PassqlMemoCanvas extends StatefulWidget {
  const PassqlMemoCanvas({
    super.key,
    required this.pageKey,
    required this.child,
  });

  /// 메모를 나눠 담는 문항 식별자 (문제 UUID·문항 번호)
  final Object pageKey;
  final Widget child;

  @override
  State<PassqlMemoCanvas> createState() => _PassqlMemoCanvasState();
}

class _PassqlMemoCanvasState extends State<PassqlMemoCanvas> {
  // 메모를 끈 동안 메모 불투명도 (보이되 내용을 가리지 않게, 시안 0.55)
  static const double _restingOpacity = 0.55;
  // 지우개 원 반지름 (손가락 끝 크기)
  static const double _eraserRadius = 12;
  // 이보다 가까운 다음 점은 버림 (획 점 수 줄임)
  static const double _minimumPointGap = 1.5;

  final Map<int, Offset> _globalPositionByPointer = {};
  final _PassqlMemoInProgressStroke _inProgressStroke =
      _PassqlMemoInProgressStroke();

  /// 손가락 2개 이상: 그리기 대신 내용 스크롤 (모두 뗄 때까지 유지)
  bool _isScrollingWithFingers = false;

  @override
  void dispose() {
    _inProgressStroke.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event, PassqlMemoController controller) {
    _globalPositionByPointer[event.pointer] = event.position;
    if (_globalPositionByPointer.length > 1) {
      _isScrollingWithFingers = true;
      _inProgressStroke.clear();
      return;
    }
    if (controller.selectedTool == PassqlMemoTool.eraser) {
      controller.startEraseGesture();
      controller.eraseStrokesTouchedBy(
        widget.pageKey,
        event.localPosition,
        _eraserRadius,
      );
      return;
    }
    _inProgressStroke.start(
      controller.selectedTool,
      controller.selectedInk,
      event.localPosition,
    );
  }

  void _onPointerMove(PointerMoveEvent event, PassqlMemoController controller) {
    final previousGlobalPosition = _globalPositionByPointer[event.pointer];
    if (previousGlobalPosition == null) return;
    if (_isScrollingWithFingers) {
      _scrollByFingers(event.pointer, event.position);
      return;
    }
    _globalPositionByPointer[event.pointer] = event.position;
    if (controller.selectedTool == PassqlMemoTool.eraser) {
      controller.eraseStrokesTouchedBy(
        widget.pageKey,
        event.localPosition,
        _eraserRadius,
      );
      return;
    }
    _inProgressStroke.addPoint(event.localPosition, _minimumPointGap);
  }

  void _onPointerEnd(int pointer, PassqlMemoController controller) {
    if (_globalPositionByPointer.remove(pointer) == null) return;
    if (_isScrollingWithFingers) {
      if (_globalPositionByPointer.isEmpty) _isScrollingWithFingers = false;
      return;
    }
    final stroke = _inProgressStroke.toStroke();
    _inProgressStroke.clear();
    if (stroke != null) controller.addStroke(widget.pageKey, stroke);
  }

  /// 손가락들 가운데 점의 세로 이동만큼 내용 스크롤 (끝에서 멈춤)
  void _scrollByFingers(int movedPointer, Offset movedGlobalPosition) {
    final previousCenter = _centerOfPointers();
    _globalPositionByPointer[movedPointer] = movedGlobalPosition;
    final verticalDelta = _centerOfPointers().dy - previousCenter.dy;
    final position = context
        .findAncestorStateOfType<ScrollableState>()
        ?.position;
    if (position == null || !position.hasContentDimensions) return;
    position.jumpTo(
      (position.pixels - verticalDelta).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      ),
    );
  }

  Offset _centerOfPointers() {
    final positions = _globalPositionByPointer.values;
    final sum = positions.fold(Offset.zero, (total, offset) => total + offset);
    return sum / positions.length.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final controller = PassqlMemoScope.maybeControllerOf(context);
    if (controller == null) return widget.child;
    final isMemoMode = controller.isMemoMode;
    // 순서: 내용 > 메모 층. 크기는 내용이 정하고 층은 그 위를 덮음 (끔이면 층은 터치를 받지 않음)
    return Stack(
      fit: StackFit.passthrough,
      children: [
        // 펜 버튼·도구 막대가 마지막 내용을 가리지 않게 아래 여백
        Padding(
          padding: const EdgeInsets.only(
            bottom: PassqlMemoScope.floatingControlsReservedHeight,
          ),
          child: widget.child,
        ),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !isMemoMode,
            child: AnimatedOpacity(
              opacity: isMemoMode ? 1 : _restingOpacity,
              duration: PassqlMotion.durationOf(context, PassqlMotion.fast),
              // 켬: 손가락 내리는 즉시 이 층이 차지 > 스크롤·뒤로 밀기 제스처가 끼어들지 않음
              child: RawGestureDetector(
                behavior: HitTestBehavior.opaque,
                gestures: isMemoMode ? _claimingGestures : const {},
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (event) => _onPointerDown(event, controller),
                  onPointerMove: (event) => _onPointerMove(event, controller),
                  onPointerUp: (event) =>
                      _onPointerEnd(event.pointer, controller),
                  onPointerCancel: (event) =>
                      _onPointerEnd(event.pointer, controller),
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _PassqlMemoPainter(
                        strokes: controller.strokesOf(widget.pageKey),
                        inProgressStroke: _inProgressStroke,
                        colors: context.passqlColors,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static final Map<Type, GestureRecognizerFactory> _claimingGestures = {
    EagerGestureRecognizer:
        GestureRecognizerFactoryWithHandlers<EagerGestureRecognizer>(
          EagerGestureRecognizer.new,
          (_) {},
        ),
  };
}

/// 그리는 중인 획 (손을 떼면 컨트롤러에 넘김). 점이 늘 때마다 층만 다시 그림
class _PassqlMemoInProgressStroke extends ChangeNotifier {
  PassqlMemoTool _tool = PassqlMemoTool.pen;
  PassqlMemoInk _ink = PassqlMemoInk.red;
  final List<Offset> _points = [];

  void start(PassqlMemoTool tool, PassqlMemoInk ink, Offset point) {
    _tool = tool;
    _ink = ink;
    _points
      ..clear()
      ..add(point);
    notifyListeners();
  }

  void addPoint(Offset point, double minimumGap) {
    if (_points.isEmpty || (point - _points.last).distance < minimumGap) {
      return;
    }
    _points.add(point);
    notifyListeners();
  }

  void clear() {
    if (_points.isEmpty) return;
    _points.clear();
    notifyListeners();
  }

  /// 점 1개 이상이면 획 (점 1개 = 콕 찍은 점)
  PassqlMemoStroke? toStroke() => _points.isEmpty
      ? null
      : PassqlMemoStroke(
          tool: _tool,
          ink: _ink,
          points: List.unmodifiable(_points),
        );
}

/// 획 그리기: 저장된 획 > 그리는 중인 획. 점 사이는 중점 곡선으로 부드럽게
class _PassqlMemoPainter extends CustomPainter {
  _PassqlMemoPainter({
    required this.strokes,
    required this.inProgressStroke,
    required this.colors,
  }) : super(repaint: inProgressStroke);

  // 형광펜 불투명도 (아래 글자가 비치게, 시안 0.45)
  static const double _highlighterOpacity = 0.45;

  final List<PassqlMemoStroke> strokes;
  final _PassqlMemoInProgressStroke inProgressStroke;
  final PassqlColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _paintStroke(canvas, stroke);
    }
    final inProgress = inProgressStroke.toStroke();
    if (inProgress != null) _paintStroke(canvas, inProgress);
  }

  void _paintStroke(Canvas canvas, PassqlMemoStroke stroke) {
    final color = stroke.tool == PassqlMemoTool.highlighter
        ? colors.memorize.withValues(alpha: _highlighterOpacity)
        : passqlMemoInkColor(stroke.ink, colors);
    final points = stroke.points;
    // 콕 찍은 점: 선 굵기 지름 원
    if (points.length == 1) {
      canvas.drawCircle(points.first, stroke.width / 2, Paint()..color = color);
      return;
    }
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(_smoothPathOf(points), paint);
  }

  /// 점 목록 > 이웃 점 중점을 잇는 2차 곡선 경로
  static Path _smoothPathOf(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var index = 1; index < points.length - 1; index++) {
      final midpoint = Offset.lerp(points[index], points[index + 1], 0.5)!;
      path.quadraticBezierTo(
        points[index].dx,
        points[index].dy,
        midpoint.dx,
        midpoint.dy,
      );
    }
    path.lineTo(points.last.dx, points.last.dy);
    return path;
  }

  @override
  bool shouldRepaint(_PassqlMemoPainter oldDelegate) =>
      oldDelegate.strokes != strokes ||
      oldDelegate.colors != colors ||
      oldDelegate.inProgressStroke != inProgressStroke;
}
