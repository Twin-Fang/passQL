import 'package:flutter_test/flutter_test.dart';

import 'source_scan.dart';

/// 계층 의존 방향 규칙: 바깥(presentation·router) > 안쪽(data·core) 한 방향만 허용
/// 세션 만료처럼 안쪽이 바깥에 알려야 하면 core 의 신호(SessionExpirySignal)를 바깥이 구독한다.

/// 계층별 import 금지 대상 3종 {검사할 폴더: [가져오면 안 되는 폴더 접두사]}
const Map<String, List<String>> _forbiddenImportsByLayer = {
  // 공통·인프라는 화면을 모른다
  'lib/core': ['lib/presentation/', 'lib/router/'],
  // 데이터 계층도 화면을 모른다
  'lib/data': ['lib/presentation/', 'lib/router/'],
  // 디자인 시스템은 가장 아래 UI 계층: 상태·화면·라우터를 모른다
  'lib/presentation/design': [
    'lib/presentation/providers/',
    'lib/presentation/pages/',
    'lib/presentation/widgets/',
    'lib/presentation/flows/',
    'lib/router/',
  ],
};

/// 명시적 예외: {파일 경로: 이유}. 비어 있는 것이 정상
const Map<String, String> _allowedReverseImports = {};

void main() {
  test('안쪽 계층(core·data·design)은 바깥 계층을 import 하지 않는다', () {
    final violations = <String>[];
    _forbiddenImportsByLayer.forEach((layerDirectory, forbiddenPrefixes) {
      for (final file in handWrittenDartFiles(layerDirectory)) {
        final path = normalizedPath(file);
        if (_allowedReverseImports.containsKey(path)) continue;
        for (final (lineNumber, importedPath) in internalImportsOf(file)) {
          if (forbiddenPrefixes.any(importedPath.startsWith)) {
            violations.add('$path:$lineNumber > $importedPath');
          }
        }
      }
    });
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('화면(pages·widgets)은 API 클라이언트를 직접 부르지 않고 provider 를 거친다', () {
    final violations = <String>[];
    for (final directory in const [
      'lib/presentation/pages',
      'lib/presentation/widgets',
      'lib/presentation/flows',
    ]) {
      for (final file in handWrittenDartFiles(directory)) {
        for (final (lineNumber, importedPath) in internalImportsOf(file)) {
          if (importedPath.startsWith('lib/data/sources/')) {
            violations.add(
              '${normalizedPath(file)}:$lineNumber > $importedPath',
            );
          }
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
