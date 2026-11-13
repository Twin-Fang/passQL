import 'package:flutter/widgets.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 칸 하나의 상태: 아직 안 품, 지금 푸는 칸, 맞힘, 틀림
enum PassqlProgressSegmentState { pending, current, correct, wrong }

/// 칸 N개 진행 바 (풀이 상단, #999): 맞힌 칸 correct·틀린 칸 wrong·지금 칸 accent 숨쉬기, 채점된 칸은 한 번 튐
/// 동작 줄이기면 숨쉬기·튐 없이 색만
class PassqlSegmentedProgress extends StatefulWidget {
  const PassqlSegmentedProgress({
    super.key,
    required this.segmentStates,
    this.semanticValue,
  });

  final List<PassqlProgressSegmentState> segmentStates;

  /// 스크린리더가 읽을 값 (예: '3 / 5'). null 이면 읽지 않음
  final String? semanticValue;

  @override
  State<PassqlSegmentedProgress> createState() =>
      _PassqlSegmentedProgressState();
}

class _PassqlSegmentedProgressState extends State<PassqlSegmentedProgress>
    with TickerProviderStateMixin {
  // 지금 칸 강조색 불투명도 범위 (숨쉬기 옅음 <-> 진함)
  static const double _breatheMinOpacity = 0.15;
  static const double _breatheMaxOpacity = 0.55;
  // 채점 순간 칸 세로 배율 최댓값
  static const double _popPeakScaleY = 1.8;

  late final AnimationController _breatheController = AnimationController(
    vsync: this,
    duration: PassqlMotion.segmentBreathePeriod,
  );
  late final AnimationController _popController = AnimationController(
    vsync: this,
    duration: PassqlMotion.emphasized,
  );
  late final Animation<double> _popScaleY = TweenSequence<double>(
    [
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: _popPeakScaleY),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: _popPeakScaleY, end: 1.0),
        weight: 1,
      ),
    ],
  ).animate(CurvedAnimation(parent: _popController, curve: PassqlMotion.curve));

  /// 방금 채점돼 튀는 칸 (없으면 null)
  int? _poppingIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 동작 줄이기면 숨쉬기 정지 (가운데 불투명도로 고정)
    if (PassqlMotion.isReduced(context)) {
      _breatheController.stop();
      _breatheController.value = 0.5;
    } else if (!_breatheController.isAnimating) {
      _breatheController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PassqlSegmentedProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 안 품·지금 > 맞힘·틀림으로 바뀐 칸 찾기 (이어 풀기로 처음부터 채워진 칸은 튀지 않음)
    final gradedIndex = _findNewlyGradedIndex(
      oldWidget.segmentStates,
      widget.segmentStates,
    );
    if (gradedIndex == null || PassqlMotion.isReduced(context)) return;
    _poppingIndex = gradedIndex;
    _popController.forward(from: 0);
  }

  static bool _isGraded(PassqlProgressSegmentState state) =>
      state == PassqlProgressSegmentState.correct ||
      state == PassqlProgressSegmentState.wrong;

  static int? _findNewlyGradedIndex(
    List<PassqlProgressSegmentState> before,
    List<PassqlProgressSegmentState> after,
  ) {
    for (var index = 0; index < after.length; index++) {
      final wasGraded = index < before.length && _isGraded(before[index]);
      if (!wasGraded && _isGraded(after[index])) return index;
    }
    return null;
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final segments = <Widget>[];
    for (var index = 0; index < widget.segmentStates.length; index++) {
      if (index > 0) segments.add(const SizedBox(width: PassqlSpacing.xxs));
      segments.add(
        Expanded(
          child: _buildSegment(colors, index, widget.segmentStates[index]),
        ),
      );
    }
    final bar = SizedBox(
      height: PassqlSize.segmentedProgressHeight,
      child: Row(children: segments),
    );
    final semanticValueText = widget.semanticValue;
    if (semanticValueText == null) return ExcludeSemantics(child: bar);
    return Semantics(
      value: semanticValueText,
      child: ExcludeSemantics(child: bar),
    );
  }

  /// 칸 한 개: 상태 색 바탕 > 지금 칸이면 숨쉬는 강조색 층 > 방금 채점이면 세로로 튐
  Widget _buildSegment(
    PassqlColors colors,
    int index,
    PassqlProgressSegmentState state,
  ) {
    final baseColor = switch (state) {
      PassqlProgressSegmentState.correct => colors.correct,
      PassqlProgressSegmentState.wrong => colors.wrong,
      _ => colors.fill,
    };
    Widget segment = AnimatedContainer(
      duration: PassqlMotion.durationOf(context, PassqlMotion.fast),
      curve: PassqlMotion.curve,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(PassqlRadius.capsule),
      ),
    );
    if (state == PassqlProgressSegmentState.current) {
      segment = Stack(
        fit: StackFit.expand,
        children: [
          segment,
          FadeTransition(
            opacity: Tween(
              begin: _breatheMaxOpacity,
              end: _breatheMinOpacity,
            ).animate(_breatheController),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: BorderRadius.circular(PassqlRadius.capsule),
              ),
            ),
          ),
        ],
      );
    }
    if (index != _poppingIndex) return segment;
    return AnimatedBuilder(
      animation: _popScaleY,
      child: segment,
      builder: (_, child) => Transform(
        alignment: Alignment.center,
        transform: Matrix4.diagonal3Values(1, _popScaleY.value, 1),
        child: child,
      ),
    );
  }
}
