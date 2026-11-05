import 'package:flutter/widgets.dart';

import '../tokens/passql_tokens.dart';

/// 스크롤로 화면에 들어오면 0 > 1 로 한 번 진행하는 그림 틀 (#853): 진행 값으로 선 긋기·칠하기·빠지기 연출
/// 스크롤 영역 밖이면 바로 시작, 동작 줄이기 켜짐 > 처음부터 1 (최종 모습만)
class PassqlScrollProgress extends StatefulWidget {
  const PassqlScrollProgress({
    super.key,
    required this.duration,
    required this.builder,
  });

  /// 0 > 1 까지 걸리는 시간
  final Duration duration;

  /// 진행 값(0~1, 곡선 적용)으로 그리기
  final Widget Function(BuildContext context, double progress) builder;

  @override
  State<PassqlScrollProgress> createState() => _PassqlScrollProgressState();
}

class _PassqlScrollProgressState extends State<PassqlScrollProgress>
    with SingleTickerProviderStateMixin {
  // 화면 아래에서 이만큼 올라오면 시작 (화면 높이 비율, 그림 대부분이 보일 때)
  static const double _startViewportFraction = 0.8;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: PassqlMotion.standardCurve,
  );
  ScrollPosition? _scrollPosition;
  bool _hasStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasStarted) return;
    if (PassqlMotion.isReduced(context)) {
      _hasStarted = true;
      _controller.value = 1;
      return;
    }
    final position = Scrollable.maybeOf(context)?.position;
    if (position != _scrollPosition) {
      _scrollPosition?.removeListener(_checkVisibility);
      _scrollPosition = position?..addListener(_checkVisibility);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  /// 내 위쪽 끝이 기준선 위로 올라왔으면 시작 (스크롤 영역이 없으면 바로)
  void _checkVisibility() {
    if (!mounted || _hasStarted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final scrollableBox =
        Scrollable.maybeOf(context)?.context.findRenderObject() as RenderBox?;
    final isInView =
        scrollableBox == null ||
        !scrollableBox.hasSize ||
        box.localToGlobal(Offset.zero, ancestor: scrollableBox).dy <=
            scrollableBox.size.height * _startViewportFraction;
    if (!isInView) return;
    _hasStarted = true;
    _scrollPosition?.removeListener(_checkVisibility);
    _scrollPosition = null;
    _controller.forward();
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_checkVisibility);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _progress,
    builder: (context, _) => widget.builder(context, _progress.value),
  );
}
