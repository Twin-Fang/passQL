// characters 확장(글자 묶음 단위)은 flutter/widgets 가 다시 내보냄
import 'package:flutter/widgets.dart' show StringCharacters;

// 단어 잇기 문자 (U+2060 WORD JOINER): 폭 0, 양옆 줄바꿈 금지
const String _wordJoiner = '⁠';

/// 단어 단위 줄바꿈 (CSS word-break: keep-all 대응)
/// 한글은 글자마다 줄바꿈 가능 > 단어 안 글자 사이에 잇기 문자 > 공백·줄바꿈에서만 넘어감
/// 공백 없는 한 단어는 그대로 (어차피 넘치면 글자 단위로 끊어야 함)
String keepWordsTogether(String text) {
  if (!text.contains(' ')) return text;
  return text
      .split('\n')
      .map(
        (line) => line
            .split(' ')
            .map((word) => word.characters.join(_wordJoiner))
            .join(' '),
      )
      .join('\n');
}
