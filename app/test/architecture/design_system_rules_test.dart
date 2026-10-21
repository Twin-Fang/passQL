import 'package:flutter_test/flutter_test.dart';

import 'source_scan.dart';

/// 디자인 시스템 우회 금지 규칙: 화면 코드(pages·widgets·flows)는 토큰과 공통 컴포넌트만 쓴다.
/// 원본: lib/presentation/design (tokens, components). 새 예외는 [_allowedUsages] 에 이유와 함께 추가

/// 금지 패턴 9종 > 대신 쓸 공통 지점
final _bannedPatterns = <String, (RegExp, String)>{
  'Color(0x': (RegExp(r'Color\(0x'), 'PassqlColors 토큰 (context.passqlColors)'),
  'Colors.white/black': (
    RegExp(r'Colors\.(white|black)\b'),
    'PassqlColors 토큰 (onAccent, label 등)',
  ),
  'Image.asset(': (RegExp(r'Image\.asset\('), 'PassqlLogo 등 자산 컴포넌트'),
  'showModalBottomSheet(': (
    RegExp(r'showModalBottomSheet\s*(<[^>]*>)?\('),
    'showPassqlSheet',
  ),
  'showCupertinoDialog(': (
    RegExp(r'showCupertinoDialog\s*(<[^>]*>)?\('),
    'showPassqlConfirmDialog / showPassqlBlockingProgress',
  ),
  'CupertinoActivityIndicator(': (
    RegExp(r'CupertinoActivityIndicator\('),
    'PassqlLoadingIndicator',
  ),
  'Curves.': (RegExp(r'\bCurves\.'), 'PassqlMotion 곡선 토큰'),
  'duration: Duration(': (
    RegExp(r'duration:\s*(const\s+)?Duration\('),
    'PassqlMotion 시간 토큰',
  ),
  '라우트 문자열 리터럴': (
    RegExp(r'''\.(go|push|pushReplacement|replace)\s*(<[^>]*>)?\(\s*['"]/'''),
    'AppRoutes 상수·함수',
  ),
};

/// 여러 줄에 걸친 금지 패턴 3종(접근성 감사 C1·C2·C4) > 대신 쓸 공통 지점
final _bannedMultilinePatterns = <String, (RegExp, String)>{
  '글자 tertiaryLabel': (
    RegExp(r'copyWith\(\s*color:\s*\w+\.tertiaryLabel\b'),
    '글자는 secondaryLabel, 기능 아이콘은 iconSecondary (tertiaryLabel 대비 1.7)',
  ),
  '글자 accent': (
    RegExp(r'copyWith\(\s*color:\s*\w+\.accent\s*[,)]'),
    'accentText (다크 accent 글자 대비 3.4)',
  ),
  '탭 동작 없는 버튼 시맨틱': (
    RegExp(
      r'Semantics\((?:(?!\bchild:)[\s\S])*?\bbutton:\s*true(?:(?!\bchild:)[\s\S])*?\bexcludeSemantics:\s*true|Semantics\((?:(?!\bchild:)[\s\S])*?\bexcludeSemantics:\s*true(?:(?!\bchild:)[\s\S])*?\bbutton:\s*true',
    ),
    'PassqlSemanticButton (excludeSemantics 는 자식 탭 동작까지 지움)',
  ),
};

/// 명시적 예외: {파일 경로: {패턴 이름: 이유}}. 비어 있는 것이 정상
const Map<String, Map<String, String>> _allowedUsages = {
  'lib/presentation/widgets/common/app_toast.dart': {
    'duration: Duration(': '스낵바 표시 시간(애니메이션 아님)',
  },
};

/// 규칙을 적용하는 화면 코드 폴더 3곳
const _screenCodeDirectories = [
  'lib/presentation/pages',
  'lib/presentation/widgets',
  'lib/presentation/flows',
];

void main() {
  test('화면 코드는 색·자산·시트·대화상자·로딩·모션·라우트를 공통 지점으로만 쓴다', () {
    final violations = <String>[];
    for (final directory in _screenCodeDirectories) {
      for (final file in handWrittenDartFiles(directory)) {
        final path = normalizedPath(file);
        final allowedForFile = _allowedUsages[path] ?? const {};
        for (final (lineNumber, code) in codeLinesOf(file)) {
          _bannedPatterns.forEach((patternName, rule) {
            final (pattern, replacement) = rule;
            if (allowedForFile.containsKey(patternName)) return;
            if (pattern.hasMatch(code)) {
              violations.add('$path:$lineNumber $patternName > $replacement');
            }
          });
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('화면 코드는 읽는 글자색·버튼 시맨틱을 대비·탭 동작이 보장된 공통 지점으로만 쓴다', () {
    final violations = <String>[];
    for (final directory in _screenCodeDirectories) {
      for (final file in handWrittenDartFiles(directory)) {
        final path = normalizedPath(file);
        final code = codeLinesOf(file).map((line) => line.$2).join('\n');
        _bannedMultilinePatterns.forEach((patternName, rule) {
          final (pattern, replacement) = rule;
          for (final match in pattern.allMatches(code)) {
            final lineNumber =
                '\n'.allMatches(code.substring(0, match.start)).length + 1;
            violations.add('$path:~$lineNumber $patternName > $replacement');
          }
        });
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('예외 목록은 실제로 존재하는 파일만 가리킨다(지운 파일의 예외가 남지 않게)', () {
    final screenFiles = {
      for (final directory in _screenCodeDirectories)
        for (final file in handWrittenDartFiles(directory))
          normalizedPath(file),
    };
    final staleEntries = _allowedUsages.keys
        .where((path) => !screenFiles.contains(path))
        .toList();
    expect(staleEntries, isEmpty);
  });
}
