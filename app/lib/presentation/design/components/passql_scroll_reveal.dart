import 'dart:async';

import 'package:flutter/widgets.dart';

import '../tokens/passql_tokens.dart';

/// 스크롤로 화면에 들어올 때 한 번 등장: 투명·아래 > 불투명·제자리, index 순차 지연 (#848)
/// 처음부터 보이는 위치면 바로 등장, 스크롤 영역 밖이면 그리자마자 등장, 동작 줄이기 켜짐 > 바로 표시
class PassqlScrollReveal extends StatefulWidget {
  const PassqlScrollReveal({super.key, required this.child, this.index = 0});

  final Widget child;

  /// 같은 묶음 안 순서 (0부터, 지연 = index × staggerStep)
  final int index;

  @override
  State<PassqlScrollReveal> createState() => _PassqlScrollRevealState();
}

class _PassqlScrollRevealState extends State<PassqlScrollReveal>
    with SingleTickerProviderStateMixin {
  // 화면 아래에서 이만큼 올라오면 등장 (화면 높이 비율, 너무 늦게 나타나지 않게)
  static const double _revealViewportFraction = 0.92;
  // 아래에서 올라오는 거리 (섹션 등장보다 조금 크게, 스크롤 방향이 느껴지게)
  static const double _slideDistance = PassqlMotion.revealSlideDistance * 3;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PassqlMotion.emphasized,
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: PassqlMotion.curve,
  );
  ScrollPosition? _scrollPosition;
  Timer? _startTimer;
  bool _hasRevealed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasRevealed) return;
    if (PassqlMotion.isReduced(context)) {
      _hasRevealed = true;
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

  /// 내 위쪽 끝이 화면 안 기준선 위로 올라왔으면 등장 (스크롤 영역이 없으면 바로)
  void _checkVisibility() {
    if (!mounted || _hasRevealed) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final scrollableBox =
        Scrollable.maybeOf(context)?.context.findRenderObject() as RenderBox?;
    if (scrollableBox == null || !scrollableBox.hasSize) {
      _reveal();
      return;
    }
    final topInViewport = box
        .localToGlobal(Offset.zero, ancestor: scrollableBox)
        .dy;
    if (topInViewport <= scrollableBox.size.height * _revealViewportFraction) {
      _reveal();
    }
  }

  void _reveal() {
    _hasRevealed = true;
    _scrollPosition?.removeListener(_checkVisibility);
    _scrollPosition = null;
    _startTimer = Timer(PassqlMotion.staggerDelayOf(widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_checkVisibility);
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
        // 끝난 뒤에도 래퍼 구조 유지 (자식이 다시 만들어지지 않게)
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * _slideDistance),
            child: child,
          ),
        );
      },
    );
  }
}
