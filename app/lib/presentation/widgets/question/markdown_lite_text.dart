import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../design/design.dart';

/// AI 해설이 쓰는 마크다운 일부(굵게 `**`, 인라인 코드 `` ` ``, 목록 `* `/`- `)만 그리는 가벼운 위젯.
/// 전체 마크다운 패키지를 들이지 않고, 해설에 실제로 나오는 표기만 처리한다.
/// isAnimated: 단어가 순서대로 흐림 > 선명, 아래 2px > 제자리로 나타남 (웹 ai-word-in)
/// 애니메이션 모드는 끝난 뒤에도 단어 단위 배치를 유지한다(전환 시 줄바꿈이 튀지 않게, 단어 단위 줄바꿈)
class MarkdownLiteText extends StatefulWidget {
  const MarkdownLiteText(this.text, {super.key, this.isAnimated = false});

  final String text;
  final bool isAnimated;

  @override
  State<MarkdownLiteText> createState() => _MarkdownLiteTextState();
}

class _MarkdownLiteTextState extends State<MarkdownLiteText>
    with SingleTickerProviderStateMixin {
  static final RegExp _bulletRe = RegExp(r'^\s*[*-]\s+(.*)$');
  static final RegExp _inlineRe = RegExp(r'\*\*(.+?)\*\*|`([^`\n]+)`');
  static final RegExp _whitespaceRe = RegExp(r'(\s+)');
  static final RegExp _inlineMarkerRe = RegExp(r'\*\*|`');

  /// 이보다 긴 토큰은 줄바꿈이 안 돼 넘칠 수 있어 애니메이션 없이 글자로 둔다
  static const int _maxAnimatedTokenLength = 24;

  AnimationController? _controller;

  /// 단어 단위로 그릴지 (애니메이션 모드이고 동작 줄이기가 꺼져 있을 때)
  bool get _isWordLayout => _controller != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.isAnimated || _controller != null) return;
    if (PassqlMotion.isReduced(context)) return;
    final wordCount = _countWords(widget.text);
    _controller = AnimationController(
      vsync: this,
      duration: _totalDurationOf(wordCount),
    )..forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// 전체 시간 = 첫 지연 + (단어 수 - 1) × 간격 + 단어 하나 시간
  Duration _totalDurationOf(int wordCount) =>
      PassqlMotion.wordInitialDelay +
      PassqlMotion.wordStep * (wordCount > 0 ? wordCount - 1 : 0) +
      PassqlMotion.fast;

  int _countWords(String text) =>
      text.split(_whitespaceRe).where((token) => token.isNotEmpty).length;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final base = PassqlTypography.explanationBody.copyWith(color: colors.label);
    final wordCounter = _WordCounter();
    final lines = widget.text.replaceAll('\r\n', '\n').split('\n');
    final children = <Widget>[];
    for (final line in lines) {
      if (line.trim().isEmpty) {
        // 연속 빈 줄이 여러 번 간격을 만들지 않게 한 번만 둔다.
        if (children.isNotEmpty && children.last is! SizedBox) {
          children.add(const SizedBox(height: PassqlSpacing.sm));
        }
        continue;
      }
      final bullet = _bulletRe.firstMatch(line);
      if (bullet != null) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: PassqlSpacing.xxs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: PassqlSpacing.md,
                  child: Text.rich(
                    TextSpan(
                      style: base,
                      children: [_wordSpan('•', base, wordCounter)],
                    ),
                  ),
                ),
                Expanded(child: _rich(bullet.group(1)!, base, colors, wordCounter)),
              ],
            ),
          ),
        );
      } else {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: PassqlSpacing.xxs),
            child: _rich(line, base, colors, wordCounter),
          ),
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  /// 한 줄 > 굵게·코드 구간 나눔 > (애니메이션이면) 단어 단위 조각
  Widget _rich(
    String line,
    TextStyle base,
    PassqlColors colors,
    _WordCounter wordCounter,
  ) {
    final spans = <InlineSpan>[];
    var cursor = 0;
    void addSegment(String text, TextStyle? style) {
      spans.addAll(_segmentSpans(text, style, base, wordCounter));
    }

    for (final match in _inlineRe.allMatches(line)) {
      if (match.start > cursor) {
        addSegment(line.substring(cursor, match.start), null);
      }
      if (match.group(1) != null) {
        addSegment(
          match.group(1)!,
          PassqlTypography.explanationEmphasis.copyWith(color: colors.label),
        );
      } else {
        addSegment(
          match.group(2)!,
          PassqlTypography.code.copyWith(
            fontSize: (base.fontSize ?? 14) * 0.92,
            backgroundColor: colors.fill,
          ),
        );
      }
      cursor = match.end;
    }
    if (cursor < line.length) addSegment(line.substring(cursor), null);
    final richText = Text.rich(TextSpan(style: base, children: spans));
    if (!_isWordLayout) return richText;
    // 단어 조각마다 따로 읽히지 않게 한 줄을 한 번에 읽는다
    return Semantics(
      label: line.replaceAll(_inlineMarkerRe, ''),
      child: ExcludeSemantics(child: richText),
    );
  }

  /// 구간 글자 > 조각 목록 (정적이면 TextSpan 하나, 애니메이션이면 단어마다 WidgetSpan)
  List<InlineSpan> _segmentSpans(
    String text,
    TextStyle? style,
    TextStyle base,
    _WordCounter wordCounter,
  ) {
    if (!_isWordLayout) return [TextSpan(text: text, style: style)];
    final effectiveStyle = style == null ? base : base.merge(style);
    return [
      for (final token in _tokensKeepingSpaces(text))
        if (token.trim().isEmpty || token.length > _maxAnimatedTokenLength)
          TextSpan(text: token, style: style)
        else
          _wordSpan(token, effectiveStyle, wordCounter),
    ];
  }

  /// 글자 > 단어와 공백을 원래 순서대로 나눈 목록
  List<String> _tokensKeepingSpaces(String source) {
    final tokens = <String>[];
    var cursor = 0;
    for (final match in _whitespaceRe.allMatches(source)) {
      if (match.start > cursor) tokens.add(source.substring(cursor, match.start));
      tokens.add(match.group(0)!);
      cursor = match.end;
    }
    if (cursor < source.length) tokens.add(source.substring(cursor));
    return tokens;
  }

  InlineSpan _wordSpan(String word, TextStyle style, _WordCounter wordCounter) {
    final controller = _controller;
    if (controller == null) return TextSpan(text: word, style: style);
    final wordIndex = wordCounter.next();
    final totalMilliseconds = controller.duration!.inMilliseconds;
    final startMilliseconds = (PassqlMotion.wordInitialDelay +
            PassqlMotion.wordStep * wordIndex)
        .inMilliseconds;
    final endMilliseconds = startMilliseconds + PassqlMotion.fast.inMilliseconds;
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(
        (startMilliseconds / totalMilliseconds).clamp(0.0, 1.0),
        (endMilliseconds / totalMilliseconds).clamp(0.0, 1.0),
        curve: PassqlMotion.curve,
      ),
    );
    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: _AnimatedWord(animation: animation, child: Text(word, style: style)),
    );
  }
}

/// 한 화면 안에서 단어 순번을 이어서 센다 (줄·목록을 넘어 순서대로)
class _WordCounter {
  int _nextIndex = 0;
  int next() => _nextIndex++;
}

class _AnimatedWord extends AnimatedWidget {
  const _AnimatedWord({required Animation<double> animation, required this.child})
    : super(listenable: animation);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final value = (listenable as Animation<double>).value;
    if (value <= 0) return Opacity(opacity: 0, child: child);
    if (value >= 1) return child;
    final blurSigma = (1 - value) * PassqlMotion.wordBlurSigma;
    return Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, (1 - value) * PassqlMotion.wordSlideDistance),
        child: ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: child,
        ),
      ),
    );
  }
}
