import 'package:flutter_test/flutter_test.dart';

import 'source_scan.dart';

/// 로그 공통 지점 규칙: lib 의 debugPrint 직접 사용 금지 > AppLogger.info·warn·error(태그, 문구)
/// AppLogger 가 마스킹·파일 기록(의견 보내기 첨부)·디버그 콘솔 미러를 한 곳에서 처리

final _debugPrintPattern = RegExp(r'\bdebugPrint\s*\(');

/// 명시적 예외: {파일 경로: 이유}
const Map<String, String> _allowedDebugPrintUsages = {
  'lib/core/logging/app_logger.dart': 'AppLogger 내부 디버그 콘솔 미러 (공통 지점 자체)',
  'lib/core/network/debug_log_interceptor.dart':
      '디버그 전용 요청·응답 본문 콘솔 출력 (본문은 로그 파일 기록 금지라 AppLogger 미사용)',
};

void main() {
  test('lib 은 debugPrint 대신 AppLogger 로 로그를 남긴다', () {
    final violations = <String>[];
    for (final file in handWrittenDartFiles('lib')) {
      final path = normalizedPath(file);
      if (_allowedDebugPrintUsages.containsKey(path)) continue;
      for (final (lineNumber, code) in codeLinesOf(file)) {
        if (_debugPrintPattern.hasMatch(code)) {
          violations.add('$path:$lineNumber > AppLogger.info·warn·error');
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
