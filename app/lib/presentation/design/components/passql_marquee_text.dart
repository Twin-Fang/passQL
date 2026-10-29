import 'package:flutter/widgets.dart';

import '../tokens/passql_tokens.dart';

/// 한 줄 흐르는 글자 (마퀴·전광판, 홈 공지 #701).
/// 폭 안에 들어가면 가만히, 넘칠 때만 멈춤 > 왼쪽으로 흐름 > 처음으로 를 되풀이한다.
/// [isAlwaysScrolling] 이면 폭 안에 들어가도 흐른다 (홈 공지처럼 흐름 자체가 눈길을 끄는 자리, #756).
/// 동작 줄이기면 흐르지 않고 말줄임. 스크린리더는 흐름과 상관없이 전체 문장을 한 번 읽는다
class PassqlMarqueeText extends StatefulWidget {
  const PassqlMarqueeText(
    this.text, {
    super.key,
    required this.style,
    this.isAlwaysScrolling = false,
  });

  final String text;
  final TextStyle style;
  final bool isAlwaysScrolling;

  @override
  State<PassqlMarqueeText> createState() => _PassqlMarqueeTextState();
}

class _PassqlMarqueeTextState extends State<PassqlMarqueeText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);

  /// 지금 애니메이션이 맞춰진 이동 거리 (글자 폭 + 간격). 폭이 바뀌면 다시 맞춘다
  double? _scrollExtent;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 한 바퀴 = 멈춤 + 이동. 이동 거리에 맞춰 시간을 정하고 되풀이한다
  void _syncAnimation(double scrollExtent) {
    if (_scrollExtent == scrollExtent) return;
    _scrollExtent = scrollExtent;
    final moveMs = scrollExtent / PassqlMotion.marqueeSpeed * 1000;
    _controller
      ..duration =
          PassqlMotion.marqueePause + Duration(milliseconds: moveMs.round())
      ..repeat();
  }

  void _stopAnimation() {
    _scrollExtent = null;
    if (_controller.isAnimating) _controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    final fallback = Text(
      widget.text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: widget.style,
    );
    if (PassqlMotion.isReduced(context)) {
      _stopAnimation();
      return fallback;
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          maxLines: 1,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout();
        final textWidth = painter.width;
        final lineHeight = painter.height;
        painter.dispose();
        final fits = textWidth <= constraints.maxWidth;
        if (fits && !widget.isAlwaysScrolling) {
          _stopAnimation();
          return fallback;
        }
        // 짧은 글자가 흐를 때 두 벌이 한 화면에 같이 보이지 않게, 간격을 칸 폭까지 늘린다
        final gap = fits
            ? constraints.maxWidth - textWidth + PassqlMotion.marqueeGap
            : PassqlMotion.marqueeGap;
        final scrollExtent = textWidth + gap;
        _syncAnimation(scrollExtent);
        final pauseRatio =
            PassqlMotion.marqueePause.inMilliseconds /
            _controller.duration!.inMilliseconds;
        final line = Text(widget.text, maxLines: 1, style: widget.style);
        return Semantics(
          label: widget.text,
          excludeSemantics: true,
          child: SizedBox(
            height: lineHeight,
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final t = _controller.value <= pauseRatio
                      ? 0.0
                      : (_controller.value - pauseRatio) / (1 - pauseRatio);
                  return OverflowBox(
                    alignment: AlignmentDirectional.centerStart,
                    maxWidth: double.infinity,
                    child: Transform.translate(
                      offset: Offset(-t * scrollExtent, 0),
                      child: child,
                    ),
                  );
                },
                // 같은 글자 두 번 + 간격: 앞 글자가 빠져나가는 동안 뒤 글자가 이어 들어와 끊김 없이 한 바퀴
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    line,
                    SizedBox(width: gap),
                    line,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
