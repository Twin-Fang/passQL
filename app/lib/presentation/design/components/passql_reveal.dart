import 'dart:async';

import 'package:flutter/widgets.dart';

import '../tokens/passql_tokens.dart';

/// 처음 그려질 때 한 번 등장: 투명 > 불투명, 아래 8px > 제자리, index 순차 지연
/// 동작 줄이기 켜짐 > 바로 표시
class PassqlReveal extends StatefulWidget {
  const PassqlReveal({
    super.key,
    required this.child,
    this.index = 0,
    this.delay = Duration.zero,
  });

  final Widget child;

  /// 섹션 순서 (0부터, 지연 = index × staggerStep)
  final int index;

  /// 순차 지연 앞에 더할 고정 지연
  final Duration delay;

  @override
  State<PassqlReveal> createState() => _PassqlRevealState();
}

class _PassqlRevealState extends State<PassqlReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PassqlMotion.standard,
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: PassqlMotion.curve,
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
    final delay = widget.delay + PassqlMotion.staggerDelayOf(widget.index);
    _startTimer = Timer(delay, () {
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
      animation: _progress,
      child: widget.child,
      builder: (_, child) {
        final value = _progress.value;
        // 끝난 뒤에는 변환 없이 그대로 그린다
        if (value >= 1) return child!;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * PassqlMotion.revealSlideDistance),
            child: child,
          ),
        );
      },
    );
  }
}

/// 목록 > 순서대로 등장하는 목록 (간격용 SizedBox 는 감싸지 않고 순번도 세지 않는다)
List<Widget> passqlRevealInOrder(List<Widget> children) {
  var revealIndex = 0;
  return [
    for (final child in children)
      if (child is SizedBox && child.child == null)
        child
      else
        PassqlReveal(index: revealIndex++, child: child),
  ];
}
