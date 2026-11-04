import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 개발자 도구 스토어 빌드 차단 보장 (#820)
/// 규칙 3개: 빌드 프로파일 release 꺼짐, 스토어 워크플로 개발 플래그 없음 + release 적용, 개발자 도구는 서버 호출 금지
void main() {
  // 레포 루트 자산 (app/ 기준 상대 경로)
  const buildProfilePath = '../.github/config/build-profile.json';
  const storeWorkflowPaths = [
    '../.github/workflows/PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml',
    '../.github/workflows/PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml',
  ];
  // 개발자 도구 코드 위치 (폴더 또는 파일)
  const devToolsSourcePaths = [
    'lib/presentation/widgets/dev_tools/',
    'lib/presentation/widgets/ads/dev_ad_tools_section.dart',
    'lib/presentation/providers/dev_plan_overrides.dart',
  ];
  // 서버 호출·운영 데이터 변경 경로: API 클라이언트·데이터 소스·HTTP 클라이언트
  final serverAccessImportPattern = RegExp(
    r'''import\s+['"][^'"]*(data/sources/|api_providers\.dart|dio_client\.dart|package:dio/)''',
  );

  test('빌드 프로파일 release 는 개발 키를 끄고 개발 플래그를 넣지 않는다', () {
    final profiles =
        (jsonDecode(File(buildProfilePath).readAsStringSync())
                as Map<String, dynamic>)['profiles']
            as Map<String, dynamic>;
    final release = profiles['release'] as Map<String, dynamic>;
    final releaseEnv = release['env'] as Map<String, dynamic>;
    expect(releaseEnv.values.every((value) => value == 'false'), isTrue);
    expect(release['dart_define'] as Map<String, dynamic>, isEmpty);
    final testDefines =
        (profiles['test'] as Map<String, dynamic>)['dart_define']
            as Map<String, dynamic>;
    expect(testDefines['APP_FLAVOR'], 'dev');
  });

  test('스토어 워크플로는 개발 플래그 없이 release 프로파일을 적용한다', () {
    for (final workflowPath in storeWorkflowPaths) {
      final workflow = File(workflowPath).readAsStringSync();
      expect(
        workflow.contains('APP_FLAVOR'),
        isFalse,
        reason: '$workflowPath 에 개발 플래그',
      );
      expect(
        RegExp(
          r'apply_build_profile\.py"\s*\\\s*\n\s*release\b',
        ).hasMatch(workflow),
        isTrue,
        reason: '$workflowPath 에 release 프로파일 단계 없음',
      );
    }
  });

  test('개발자 도구 코드는 서버 API·데이터 소스를 import 하지 않는다 (운영 변경 금지)', () {
    final violations = <String>[];
    for (final sourcePath in devToolsSourcePaths) {
      final files = sourcePath.endsWith('/')
          ? Directory(sourcePath)
                .listSync(recursive: true)
                .whereType<File>()
                .where((file) => file.path.endsWith('.dart'))
          : [File(sourcePath)];
      for (final file in files) {
        final lines = file.readAsLinesSync();
        for (var index = 0; index < lines.length; index++) {
          if (serverAccessImportPattern.hasMatch(lines[index])) {
            violations.add('${file.path}:${index + 1} ${lines[index].trim()}');
          }
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
