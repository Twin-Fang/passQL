import 'package:flutter_test/flutter_test.dart';

import 'source_scan.dart';

/// 파일 크기 규칙: lib 의 손으로 쓴 Dart 파일은 500줄 이하 (300줄부터 분리 검토, 500줄 넘으면 반드시 분리)
/// 생성 파일(*.g.dart, *.freezed.dart)은 handWrittenDartFiles 가 제외

// 파일 하나의 최대 줄 수
const int _maximumLineCount = 500;

/// 명시적 예외: {파일 경로: 이유}. 비어 있는 것이 정상
const Map<String, String> _allowedOversizedFiles = {};

void main() {
  test('lib 의 손으로 쓴 Dart 파일은 $_maximumLineCount줄을 넘지 않는다', () {
    final violations = <String>[];
    for (final file in handWrittenDartFiles('lib')) {
      final path = normalizedPath(file);
      if (_allowedOversizedFiles.containsKey(path)) continue;
      final lineCount = file.readAsLinesSync().length;
      if (lineCount > _maximumLineCount) {
        violations.add('$path: $lineCount줄 > 책임별로 파일 분리');
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
