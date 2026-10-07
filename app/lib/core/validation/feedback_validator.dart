import 'package:flutter/services.dart';

/// 건의 내용 검증. 서버 규칙(공백 제외 1자 이상, 500자 이하)과 같아야 한다.
abstract final class FeedbackValidator {
  static const int maxLength = 500;

  /// 서버는 앞뒤 공백을 제거한 값으로 판단하므로 같은 기준으로 센다.
  static String normalize(String raw) => raw.trim();

  /// 입력창에서 최대 글자 수를 넘겨 입력하지 못하게 막는다. 넘친 뒤 지우게 하지 않는다.
  static List<TextInputFormatter> get inputFormatters => [
    LengthLimitingTextInputFormatter(maxLength),
  ];

  static bool isValid(String raw) {
    final text = normalize(raw);
    return text.isNotEmpty && text.length <= maxLength;
  }
}
