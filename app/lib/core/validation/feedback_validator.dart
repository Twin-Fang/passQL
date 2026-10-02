/// 건의 내용 검증. 서버 규칙(공백 제외 1자 이상, 500자 이하)과 같아야 한다.
abstract final class FeedbackValidator {
  static const int maxLength = 500;

  /// 서버는 앞뒤 공백을 제거한 값으로 판단하므로 같은 기준으로 센다.
  static String normalize(String raw) => raw.trim();

  static bool isValid(String raw) {
    final text = normalize(raw);
    return text.isNotEmpty && text.length <= maxLength;
  }
}
