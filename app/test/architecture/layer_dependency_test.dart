import 'package:flutter_test/flutter_test.dart';

import 'source_scan.dart';

/// 계층 의존 방향 규칙: 바깥(presentation·router) > data > core 한 방향만 허용
/// 세션 만료처럼 안쪽이 바깥에 알려야 하면 core 의 신호(SessionExpirySignal)를 바깥이 구독한다.
/// core 가 data 기능이 필요하면 core 에 포트를 두고 data 가 구현한다 (TokenReissueClient <- AuthApi).

/// 계층별 import 금지 대상 3종 {검사할 폴더: [가져오면 안 되는 폴더 접두사]}
const Map<String, List<String>> _forbiddenImportsByLayer = {
  // 공통·인프라는 화면도 데이터 계층도 모른다 (core <-> data 순환 방지)
  'lib/core': ['lib/presentation/', 'lib/router/', 'lib/data/'],
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

/// 오류·분석 수집 SDK: core/monitoring 의 공통 지점만 직접 import (나머지는 공통 지점 경유)
const List<String> _monitoringSdkPackages = [
  'package:firebase_crashlytics/',
  'package:firebase_analytics/',
];
const String _monitoringDirectory = 'lib/core/monitoring/';

/// 푸시 SDK: core/push 의 공통 지점만 직접 import (나머지는 PushNotificationService 경유)
const String _pushSdkPackage = 'package:firebase_messaging/';
const String _pushDirectory = 'lib/core/push/';

/// 앱 아이콘 숫자 패키지: core/notification 의 AppIconBadgeUpdater 만 직접 import
const String _iconBadgePackage = 'package:app_badge_plus/';
const String _notificationDirectory = 'lib/core/notification/';

/// 기기 일반 저장소 SDK: core/storage 의 DevicePreferences 만 직접 import (키는 StorageKeys 한 곳)
const String _sharedPreferencesPackage = 'package:shared_preferences/';
const String _storageDirectory = 'lib/core/storage/';

/// 알림함 진입 경로: 종 아이콘(PassqlNotificationBellButton)을 둔 화면만 사용 {파일: 이유}
const Map<String, String> _allowedNotificationInboxRouteUsages = {
  'lib/presentation/pages/home/home_page.dart': '홈 상단 종 아이콘 onPressed',
};

void main() {
  test('안쪽 계층(core·data·design)은 바깥 계층을 import 하지 않는다 (core 는 data 도 금지)', () {
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

  test('오류·분석 수집 SDK 는 core/monitoring 에서만 import 한다', () {
    final violations = <String>[];
    for (final file in handWrittenDartFiles('lib')) {
      final path = normalizedPath(file);
      if (path.startsWith(_monitoringDirectory)) continue;
      final lines = file.readAsLinesSync();
      for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
        if (_monitoringSdkPackages.any(lines[lineIndex].contains)) {
          violations.add('$path:${lineIndex + 1}');
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('푸시 SDK 는 core/push 에서만 import 한다', () {
    final violations = <String>[];
    for (final file in handWrittenDartFiles('lib')) {
      final path = normalizedPath(file);
      if (path.startsWith(_pushDirectory)) continue;
      final lines = file.readAsLinesSync();
      for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
        if (lines[lineIndex].contains(_pushSdkPackage)) {
          violations.add('$path:${lineIndex + 1}');
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('앱 아이콘 숫자 패키지는 core/notification 에서만 import 한다', () {
    final violations = <String>[];
    for (final file in handWrittenDartFiles('lib')) {
      final path = normalizedPath(file);
      if (path.startsWith(_notificationDirectory)) continue;
      final lines = file.readAsLinesSync();
      for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
        if (lines[lineIndex].contains(_iconBadgePackage)) {
          violations.add('$path:${lineIndex + 1}');
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('SharedPreferences 는 core/storage 에서만 import 한다', () {
    final violations = <String>[];
    for (final file in handWrittenDartFiles('lib')) {
      final path = normalizedPath(file);
      if (path.startsWith(_storageDirectory)) continue;
      final lines = file.readAsLinesSync();
      for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
        if (lines[lineIndex].contains(_sharedPreferencesPackage)) {
          violations.add('$path:${lineIndex + 1}');
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('화면은 알림함 진입을 종 아이콘 컴포넌트로만 하고 직접 경로를 쓰지 않는다', () {
    final violations = <String>[];
    for (final directory in const [
      'lib/presentation/pages',
      'lib/presentation/widgets',
      'lib/presentation/flows',
    ]) {
      for (final file in handWrittenDartFiles(directory)) {
        final path = normalizedPath(file);
        final codeLines = codeLinesOf(file);
        final usesInboxRoute = codeLines.any(
          (line) => line.$2.contains('AppRoutes.notificationInbox'),
        );
        if (!usesInboxRoute) continue;
        final usesBellButton = codeLines.any(
          (line) => line.$2.contains('PassqlNotificationBellButton('),
        );
        if (!_allowedNotificationInboxRouteUsages.containsKey(path) ||
            !usesBellButton) {
          violations.add(path);
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
