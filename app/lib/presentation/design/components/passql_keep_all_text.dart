import 'package:flutter/widgets.dart';

import '../../../core/utils/word_wrap.dart';

/// 단어 중간에서 줄이 바뀌지 않는 글자 ('겨 / 뤄요' 방지). 좁은 카드·시트 문장용
/// 스크린리더는 원문을 읽음
class PassqlKeepAllText extends StatelessWidget {
  const PassqlKeepAllText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      keepWordsTogether(text),
      semanticsLabel: text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
