import 'package:flutter_test/flutter_test.dart';

import 'source_scan.dart';

/// 화면 문구 구분자 규칙 (#947): 문자열 리터럴에 가운뎃점(·) 금지
/// 정보 사이 구분은 " | ", 낱말 나열은 ", " 사용. 주석은 검사 대상 아님

// 문자열 리터럴 (작은따옴표, 큰따옴표)
final _stringLiteralPattern = RegExp(r'''('(?:[^'\\]|\\.)*'|"(?:[^"\\]|\\.)*")''');
const _middleDot = '·';

void main() {
  test('화면 문구에는 가운뎃점(·) 대신 " | " 또는 ", " 를 쓴다', () {
    final violations = <String>[];
    for (final file in handWrittenDartFiles('lib')) {
      final path = normalizedPath(file);
      for (final (lineNumber, code) in codeLinesOf(file)) {
        final hasMiddleDotInString = _stringLiteralPattern
            .allMatches(code)
            .any((match) => match.group(0)!.contains(_middleDot));
        if (hasMiddleDotInString) violations.add('$path:$lineNumber');
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
