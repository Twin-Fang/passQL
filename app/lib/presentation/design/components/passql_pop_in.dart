import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../tokens/passql_tokens.dart';

/// 처음 그려질 때 톡 튀어나오는 등장 (웹 sparkle-pop)
/// 0%: 0.7배·-10°·투명 > 60%: 1.15배·+4°·불투명 > 100%: 1배·0°
class PassqlPopIn extends StatefulWidget {
  const PassqlPopIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.isRotating = true,
  });

  final Widget child;
  final Duration delay;

  /// 회전 포함 여부 (아이콘은 true, 큰 결과 마크처럼 기울면 어색한 것은 false)
  final bool isRotating;

  @override
  State<PassqlPopIn> createState() => _PassqlPopInState();
}

class _PassqlPopInState extends State<PassqlPopIn>
    with SingleTickerProviderStateMixin {
  // 키프레임 지점 (60%)
  static const double _overshootPoint = 0.6;
  static const double _startScale = 0.7;
  static const double _overshootScale = 1.15;
  static const double _startDegrees = -10;
  static const double _overshootDegrees = 4;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PassqlMotion.emphasized,
  );
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: _startScale,
        end: _overshootScale,
      ).chain(CurveTween(curve: PassqlMotion.springCurve)),
      weight: _overshootPoint,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: _overshootScale,
        end: 1.0,
      ).chain(CurveTween(curve: PassqlMotion.springCurve)),
      weight: 1 - _overshootPoint,
    ),
  ]).animate(_controller);
  late final Animation<double> _degrees = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: _startDegrees, end: _overshootDegrees),
      weight: _overshootPoint,
    ),
    TweenSequenceItem(
      tween: Tween(begin: _overshootDegrees, end: 0.0),
      weight: 1 - _overshootPoint,
    ),
  ]).animate(_controller);
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, _overshootPoint),
  );
  Timer? _startTimer;
  bool _hasStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasStarted) return;
    _hasStarted = true;
    if (PassqlMotion.isReduced(context)) {
      _controller.value = 1;
      return;
    }
    _startTimer = Timer(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (_, child) {
        if (_controller.isCompleted) return child!;
        final radians = widget.isRotating
            ? _degrees.value * math.pi / 180
            : 0.0;
        return Opacity(
          opacity: _opacity.value.clamp(0.0, 1.0),
          child: Transform.rotate(
            angle: radians,
            child: Transform.scale(scale: _scale.value, child: child),
          ),
        );
      },
    );
  }
}
