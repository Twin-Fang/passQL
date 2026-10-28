import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'source_scan.dart';

/// 광고 배치 규칙: SDK 는 광고 모듈 안에서만, 광고는 정해 둔 화면에서만
/// 풀이·채점 중, 로그인, 약관, 설정(회원 탈퇴 근처), 점검·업데이트 차단 화면에는 광고를 두지 않는다

/// 광고 SDK 2종: lib/core/ads 에서만 직접 import
const List<String> _adSdkPackages = [
  'package:google_mobile_ads/',
  'package:app_tracking_transparency/',
];
const String _adCoreDirectory = 'lib/core/ads/';

/// 광고 요청(AdRequest) 조립 공통 지점: 로더 전부가 함께 사용
const String _adRequestPreparerPath = 'lib/core/ads/ad_request_preparer.dart';
final _adRequestConstructorPattern = RegExp(r'\bAdRequest\(');

/// 광고 모듈 (SDK 래퍼·광고 위젯·허용 조건)
const List<String> _adModulePaths = [
  'lib/core/ads/',
  'lib/presentation/widgets/ads/',
  'lib/presentation/providers/ad_providers.dart',
];

/// 광고 모듈을 쓸 수 있는 파일 {파일: 이유}. 새 자리는 이유와 함께 추가
const Map<String, String> _allowedAdModuleUsers = {
  'lib/main.dart': '앱 시작 첫 프레임 뒤 iOS 추적 허용 질문 1회 (광고를 그리지 않음)',
  'lib/presentation/widgets/app_shell.dart':
      '메인 탭 4개 공통 하단 탭 바 아래 한 줄 띠 + 결과 화면 전면 광고 미리 불러오기',
  'lib/presentation/pages/home/home_page.dart':
      '학습 현황 아래 인라인 배너 구간 1개',
  'lib/presentation/pages/stats/stats_page.dart': '통계 콘텐츠 맨 아래 인라인 배너 카드 1개',
  'lib/presentation/pages/questions/topic_list_page.dart':
      '토픽 목록 사이 네이티브 1칸 + 최신 경향(유형 <-> 공부 팁)·개념 TOP 10(5위 <-> 6위) 네이티브 각 1칸',
  'lib/presentation/pages/daily_set/daily_set_result_page.dart':
      '오늘의 세트를 막 끝낸 결과 화면 진입 전면 광고',
  'lib/presentation/pages/questions/chapter_result_page.dart':
      '챕터를 끝까지 푼 결과 화면 진입 전면 광고',
};

/// 광고를 절대 두지 않는 곳 (폴더 또는 파일)
const List<String> _adFreeLocations = [
  'lib/presentation/pages/login/',
  'lib/presentation/pages/legal/',
  'lib/presentation/pages/settings/',
  'lib/presentation/pages/app_gate/',
  'lib/presentation/pages/questions/chapter_page.dart',
  'lib/presentation/pages/questions/question_detail_page.dart',
  'lib/presentation/flows/',
  'lib/presentation/widgets/question/',
  'lib/presentation/widgets/chapter/',
  'lib/presentation/widgets/settings/',
  'lib/presentation/widgets/app_gate/',
];

// 상대·패키지 경로 모두: .../ads/... 또는 ad_providers.dart
final _adModuleImportPattern = RegExp(
  r'''^\s*import\s+['"](?:[^'"]*/)?(?:ads/|ad_providers\.dart)''',
);

bool _isAdModuleFile(String path) => _adModulePaths.any(path.startsWith);

bool _importsAdModule(File file) =>
    file.readAsLinesSync().any(_adModuleImportPattern.hasMatch);

void main() {
  test('광고 SDK(google_mobile_ads·ATT)는 lib/core/ads 에서만 import 한다', () {
    final violations = <String>[];
    for (final file in handWrittenDartFiles('lib')) {
      final path = normalizedPath(file);
      if (path.startsWith(_adCoreDirectory)) continue;
      final lines = file.readAsLinesSync();
      for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
        if (_adSdkPackages.any(lines[lineIndex].contains)) {
          violations.add('$path:${lineIndex + 1}');
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('광고 모듈은 허용 목록의 파일에서만 쓴다', () {
    final users = {
      for (final file in handWrittenDartFiles('lib'))
        if (!_isAdModuleFile(normalizedPath(file)) && _importsAdModule(file))
          normalizedPath(file),
    };
    expect(users, _allowedAdModuleUsers.keys.toSet());
  });

  test('풀이·로그인·약관·설정·차단 화면은 광고를 전혀 모른다', () {
    final violations = <String>[];
    for (final file in handWrittenDartFiles('lib')) {
      final path = normalizedPath(file);
      if (!_adFreeLocations.any(path.startsWith)) continue;
      final source = file.readAsStringSync();
      final mentionsAds =
          _importsAdModule(file) ||
          source.contains('AdBannerSlot') ||
          source.contains('AdInlineCard') ||
          source.contains('AdNativeSlot') ||
          source.contains('AdNativeStripSlot') ||
          source.contains('InterstitialAd');
      if (mentionsAds) violations.add(path);
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('하단 한 줄 띠는 탭 셸에 1개뿐이고 탭별 배너는 없다 (#527)', () {
    final stripUsers = <String, int>{};
    final bannerUsers = <String>[];
    for (final file in handWrittenDartFiles('lib')) {
      final path = normalizedPath(file);
      if (_isAdModuleFile(path)) continue;
      final source = file.readAsStringSync();
      final stripCount = 'AdNativeStripSlot('.allMatches(source).length;
      if (stripCount > 0) stripUsers[path] = stripCount;
      if (source.contains('AdBannerSlot(')) bannerUsers.add(path);
    }
    expect(stripUsers, {'lib/presentation/widgets/app_shell.dart': 1});
    expect(bannerUsers, isEmpty);
  });

  test(
    '콘텐츠 광고 자리: 인라인 카드는 홈·통계에 1개씩, 네이티브 카드는 문제 탭(토픽 목록·최신 경향·개념 TOP 10)에만',
    () {
      final inlineCardUsers = <String, int>{};
      final nativeCardUsers = <String, int>{};
      for (final file in handWrittenDartFiles('lib')) {
        final path = normalizedPath(file);
        if (_isAdModuleFile(path)) continue;
        final source = file.readAsStringSync();
        final inlineCardCount = 'AdInlineCard('.allMatches(source).length;
        final nativeCardCount = 'AdNativeSlot('.allMatches(source).length;
        if (inlineCardCount > 0) inlineCardUsers[path] = inlineCardCount;
        if (nativeCardCount > 0) nativeCardUsers[path] = nativeCardCount;
      }
      expect(inlineCardUsers, {
        'lib/presentation/pages/home/home_page.dart': 1,
        'lib/presentation/pages/stats/stats_page.dart': 1,
      });
      expect(nativeCardUsers, {
        'lib/presentation/pages/questions/topic_list_page.dart': 3,
      });
    },
  );

  test('AdRequest 는 공통 준비(AdRequestPreparer) 한 곳에서만 만든다', () {
    final violations = <String>[];
    for (final file in handWrittenDartFiles('lib')) {
      final path = normalizedPath(file);
      if (path == _adRequestPreparerPath) continue;
      for (final (lineNumber, codeLine) in codeLinesOf(file)) {
        if (_adRequestConstructorPattern.hasMatch(codeLine)) {
          violations.add('$path:$lineNumber');
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('광고 요청에는 비개인화 여부만 넘기고 사용자 정보를 싣지 않는다', () {
    final source = File(_adRequestPreparerPath).readAsStringSync();
    expect(source, contains('AdRequest(nonPersonalizedAds:'));
    for (final targetingField in const [
      'keywords',
      'contentUrl',
      'customTargeting',
    ]) {
      expect(source, isNot(contains(targetingField)));
    }
  });

  test('허용 목록은 실제로 존재하는 파일만 가리킨다', () {
    final staleEntries = _allowedAdModuleUsers.keys
        .where((path) => !File(path).existsSync())
        .toList();
    expect(staleEntries, isEmpty);
  });
}
