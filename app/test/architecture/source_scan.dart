import 'dart:io';

/// 규칙 테스트용 소스 스캔 도구: lib 아래 Dart 파일 읽기, 주석 제거, import 경로 해석
/// 생성 파일(*.g.dart, *.freezed.dart)은 사람이 고치지 않으므로 제외

/// app 폴더 기준 상대 경로로 [directory] 아래 손으로 쓴 Dart 파일 목록
List<File> handWrittenDartFiles(String directory) {
  final root = Directory(directory);
  if (!root.existsSync()) return const [];
  return root
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .where((file) => !file.path.endsWith('.g.dart'))
      .where((file) => !file.path.endsWith('.freezed.dart'))
      .toList()
    ..sort((first, second) => first.path.compareTo(second.path));
}

/// 경로 구분자를 / 로 맞춘 경로 (allow-list 키와 비교용)
String normalizedPath(File file) => file.path.replaceAll(r'\', '/');

/// 주석 줄(//, ///)과 줄 끝 주석을 지운 코드 줄 목록. 줄 번호는 1부터 유지
List<(int, String)> codeLinesOf(File file) {
  final lines = file.readAsLinesSync();
  return [
    for (var lineIndex = 0; lineIndex < lines.length; lineIndex++)
      if (!lines[lineIndex].trimLeft().startsWith('//'))
        (
          lineIndex + 1,
          lines[lineIndex].replaceFirst(RegExp(r'\s//\s.*$'), ''),
        ),
  ];
}

final _importPattern = RegExp(r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''');

/// 파일이 가져오는 lib 내부 대상들을 lib 기준 경로(lib/...)로 돌려준다. 외부 패키지는 제외
List<(int, String)> internalImportsOf(File file) {
  final fileDirectory = file.absolute.parent.uri;
  final imports = <(int, String)>[];
  final lines = file.readAsLinesSync();
  for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
    final match = _importPattern.firstMatch(lines[lineIndex]);
    if (match == null) continue;
    final target = match.group(1)!;
    if (target.startsWith('package:passql_app/')) {
      imports.add((
        lineIndex + 1,
        'lib/${target.substring('package:passql_app/'.length)}',
      ));
    } else if (!target.startsWith('package:') && !target.startsWith('dart:')) {
      final resolved = fileDirectory.resolve(target).toFilePath();
      final libIndex = resolved.replaceAll(r'\', '/').lastIndexOf('/lib/');
      if (libIndex >= 0) {
        imports.add((
          lineIndex + 1,
          resolved.replaceAll(r'\', '/').substring(libIndex + 1),
        ));
      }
    }
  }
  return imports;
}
