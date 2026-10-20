import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../design/design.dart';

/// 대상을 하단 고정 바(extendBody) 위 보이는 영역으로 스크롤 (#551)
/// 보이는 영역: 뷰포트 - 하단 바 높이(MediaQuery bottom). 이미 보이면 그대로, 대상이 영역보다 크면 위 끝 우선
void revealAboveBottomBar(BuildContext targetContext) {
  final renderObject = targetContext.findRenderObject();
  final scrollable = Scrollable.maybeOf(targetContext);
  if (renderObject == null || scrollable == null) return;
  final viewport = RenderAbstractViewport.maybeOf(renderObject);
  if (viewport == null) return;

  // 위 끝 맞춤 위치 <-> 아래 끝이 하단 바 바로 위에 오는 위치
  final position = scrollable.position;
  final bottomBarHeight = MediaQuery.paddingOf(targetContext).bottom;
  final offsetToAlignTop = viewport.getOffsetToReveal(renderObject, 0).offset;
  final offsetToAlignBottomAboveBar =
      viewport.getOffsetToReveal(renderObject, 1).offset + bottomBarHeight;

  var targetOffset = position.pixels;
  if (position.pixels > offsetToAlignTop) {
    targetOffset = offsetToAlignTop;
  } else if (position.pixels < offsetToAlignBottomAboveBar) {
    targetOffset = math.min(offsetToAlignBottomAboveBar, offsetToAlignTop);
  }
  targetOffset = targetOffset.clamp(
    position.minScrollExtent,
    position.maxScrollExtent,
  );
  if ((targetOffset - position.pixels).abs() < 1) return;

  if (PassqlMotion.isReduced(targetContext)) {
    position.jumpTo(targetOffset);
    return;
  }
  position.animateTo(
    targetOffset,
    duration: PassqlMotion.standard,
    curve: PassqlMotion.curve,
  );
}

/// [shouldReveal] 가 false > true 로 바뀌면 자식을 하단 바 위로 스크롤
/// 하단 바 높이 변화(제출 버튼 > 피드백 바)가 끝난 뒤 실행
class RevealAboveBottomBarOnTrigger extends StatefulWidget {
  const RevealAboveBottomBarOnTrigger({
    super.key,
    required this.shouldReveal,
    required this.child,
  });

  final bool shouldReveal;
  final Widget child;

  @override
  State<RevealAboveBottomBarOnTrigger> createState() =>
      _RevealAboveBottomBarOnTriggerState();
}

class _RevealAboveBottomBarOnTriggerState
    extends State<RevealAboveBottomBarOnTrigger> {
  Timer? _revealTimer;

  @override
  void didUpdateWidget(covariant RevealAboveBottomBarOnTrigger oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldReveal && !oldWidget.shouldReveal) {
      _revealTimer?.cancel();
      _revealTimer = Timer(
        PassqlMotion.isReduced(context) ? Duration.zero : PassqlMotion.standard,
        () {
          if (mounted) revealAboveBottomBar(context);
        },
      );
    }
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
