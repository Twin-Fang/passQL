import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 잠금화면 문제 화면 켜기 금지 (#1096)
/// 서비스가 화면 꺼짐 때 문제 화면을 미리 띄움 > 화면을 켜면 꺼짐 > 켜짐 반복 (배터리·발열)
void main() {
  // 잠금화면 네이티브 코드와 활동 선언 (app/ 기준 상대 경로)
  const lockScreenSourcePaths = [
    'android/app/src/main/AndroidManifest.xml',
    'android/app/src/main/kotlin/com/coldredrice/passql/lockscreen/',
  ];
  // 화면을 켜는 설정 4종: 매니페스트 속성, 활동 API, 구버전 창 플래그, 깨우기 잠금
  final screenWakePattern = RegExp(
    r'turnScreenOn="true"|setTurnScreenOn\(true\)|FLAG_TURN_SCREEN_ON|ACQUIRE_CAUSES_WAKEUP',
  );

  test('잠금화면 문제는 화면을 켜지 않는다 (잠금 위 표시만)', () {
    final violations = <String>[];
    for (final path in lockScreenSourcePaths) {
      final files = path.endsWith('/')
          ? Directory(path)
                .listSync(recursive: true)
                .whereType<File>()
                .where((file) => file.path.endsWith('.kt'))
          : [File(path)];
      for (final file in files) {
        final lines = file.readAsLinesSync();
        for (var index = 0; index < lines.length; index++) {
          // 주석 줄은 제외 (이유 설명에 이름이 나올 수 있음)
          final line = lines[index].trim();
          if (line.startsWith('//') || line.startsWith('<!--')) continue;
          if (screenWakePattern.hasMatch(line)) {
            violations.add('${file.path}:${index + 1}: $line');
          }
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
