import 'dart:async';

import 'package:flutter/widgets.dart';

import '../tokens/passql_tokens.dart';

/// 숫자 카운트업 (#1041): 0 > 값을 점수 차오름 시간(700ms)으로 올려 builder 에 넘김
/// 첫 표시는 화면 전환이 끝난 뒤 시작, 값이 바뀌면 이전 값에서 이어 올라감, 동작 줄이기면 바로 최종값
/// 스크린리더는 부모 Semantics 가 최종값을 읽게 둠 (중간값 낭독 방지)
class PassqlCountUp extends StatefulWidget {
  const PassqlCountUp({super.key, required this.value, required this.builder});

  /// 최종 숫자
  final int value;

  /// 지금 보일 숫자 > 위젯 (Text.rich 처럼 숫자 일부만 바꾸는 자리에 맞춤)
  final Widget Function(BuildContext context, int displayedValue) builder;

  @override
  State<PassqlCountUp> createState() => _PassqlCountUpState();
}

class _PassqlCountUpState extends State<PassqlCountUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PassqlMotion.scoreFill,
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: PassqlMotion.curve,
  );
  Timer? _startTimer;
  bool _hasStarted = false;

  // 이번 애니메이션의 시작값 (첫 표시 0, 값 변경 시 직전 표시값)
  int _startValue = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasStarted) return;
    _hasStarted = true;
    if (PassqlMotion.isReduced(context)) {
      _controller.value = 1;
      return;
    }
    _startTimer = Timer(PassqlMotion.afterRouteTransitionDelay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(covariant PassqlCountUp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value) return;
    _startValue = _displayedValueOf(oldWidget.value);
    if (PassqlMotion.isReduced(context)) {
      _controller.value = 1;
      return;
    }
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// 진행률 > 지금 보일 숫자 (시작값과 목표값 사이)
  int _displayedValueOf(int targetValue) =>
      (_startValue + (targetValue - _startValue) * _progress.value).round();

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _progress,
    builder: (context, _) =>
        widget.builder(context, _displayedValueOf(widget.value)),
  );
}
