/// 로그 한 줄 마스킹: 이메일, Bearer 토큰, JWT 모양, token·password 쿼리 값 > ***
abstract final class AppLogMasker {
  static const String _maskedText = '***';

  // JWT 를 Bearer 보다 먼저 처리 (Bearer 뒤 JWT 도 한 번에 가림)
  static final List<RegExp> _sensitivePatterns = [
    RegExp(r'eyJ[\w-]+\.[\w-]+\.[\w-]+'),
    RegExp(r'Bearer\s+\S+', caseSensitive: false),
    // token=, access_token=, refresh_token=, password= 값만 가림 (키 유지)
    RegExp(r'(?<=(?:token|password)=)[^&\s]+', caseSensitive: false),
    RegExp(r'[\w.+-]+@[\w-]+\.[\w.]+'),
  ];

  static String mask(String line) {
    var maskedLine = line;
    for (final pattern in _sensitivePatterns) {
      maskedLine = maskedLine.replaceAll(pattern, _maskedText);
    }
    return maskedLine;
  }
}
