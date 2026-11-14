import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'source_scan.dart';

/// 화면 문구 구분자 규칙 (#947): 문자열 리터럴에 가운뎃점(·) 금지
/// 정보 사이 구분은 " | ", 낱말 나열은 ", " 사용. 주석은 검사 대상 아님
/// 검사 대상 2곳: Dart 문자열 리터럴, Android 문자열 리소스 string 태그 값(알림 문구, #1066)

// 문자열 리터럴 (작은따옴표, 큰따옴표)
final _stringLiteralPattern = RegExp(r'''('(?:[^'\\]|\\.)*'|"(?:[^"\\]|\\.)*")''');
const _middleDot = '·';

// Android 문자열 리소스 폴더 (values, values-night 등)
const _androidResourceDirectory = 'android/app/src/main/res';

// <string name="...">값</string> (XML 주석은 검사 대상 아님)
final _androidStringValuePattern = RegExp(r'<string\b[^>]*>([^<]*)</string>');
final _xmlCommentPattern = RegExp(r'<!--.*?-->', dotAll: true);

/// Android values*/strings.xml 파일 목록 (app 폴더 기준)
List<File> _androidStringResourceFiles() {
  final resourceDirectory = Directory(_androidResourceDirectory);
  if (!resourceDirectory.existsSync()) return const [];
  return resourceDirectory
      .listSync()
      .whereType<Directory>()
      .where(
        (directory) => directory.uri.pathSegments
            .where((segment) => segment.isNotEmpty)
            .last
            .startsWith('values'),
      )
      .map((directory) => File('${directory.path}/strings.xml'))
      .where((file) => file.existsSync())
      .toList()
    ..sort((first, second) => first.path.compareTo(second.path));
}

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

  test('Android 문자열 리소스에도 가운뎃점(·) 대신 " | " 또는 ", " 를 쓴다', () {
    final violations = <String>[];
    final resourceFiles = _androidStringResourceFiles();
    // 폴더를 못 찾으면 검사가 조용히 통과하므로 실패로 둠
    expect(resourceFiles, isNotEmpty, reason: '$_androidResourceDirectory 없음');
    for (final file in resourceFiles) {
      final content = file.readAsStringSync().replaceAll(
        _xmlCommentPattern,
        '',
      );
      for (final match in _androidStringValuePattern.allMatches(content)) {
        final stringValue = match.group(1)!;
        if (stringValue.contains(_middleDot)) {
          violations.add('${normalizedPath(file)}: $stringValue');
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
