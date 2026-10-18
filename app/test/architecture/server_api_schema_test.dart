import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'source_scan.dart';

/// 서버 API 계약 검사 (#493): 앱 모델 필드 <-> api-contract/openapi.json
/// 앱 모델은 @Default·unknownEnumValue 로 구버전 앱을 보호하므로 생성하지 않고, 어긋남만 잡는다.
/// 잡는 것 3가지: 서버에 없는 필드를 읽음, 서버가 null 을 줄 수 있는데 기본값 없이 non-null, 타입 불일치

/// 서버 스펙 위치 (app 폴더 기준)
const String _specPath = '../api-contract/openapi.json';
const String _modelsDirectory = 'lib/data/models';

/// 이름이 다른 모델 {앱 클래스: 스펙 스키마}. 같은 이름이면 적지 않는다
const Map<String, String> _specSchemaByAppClass = {
  'AppConfig': 'AppConfigResponse',
  'AppMaintenanceStatus': 'AppMaintenanceResponse',
  'AppNotice': 'AppNoticeResponse',
  'AppNoticePage': 'AppNoticePageResponse',
  'AppPlatformVersionPolicy': 'AppPlatformVersionResponse',
  'QuestionListResponse': 'PageQuestionSummary',
};

/// 스펙에 대응이 없는 앱 전용 모델 {앱 클래스: 이유}
const Map<String, String> _appOnlyClasses = {
  'ExecuteRequest': '서버가 Map<String, String> 본문을 받아 스펙에 모델이 없음',
};

/// 알려진 어긋남 {'클래스.필드': 이유}. 새로 생기면 테스트가 실패하고, 고치면 여기서 지운다
const Map<String, String> _knownMismatches = {};

class _AppField {
  _AppField(this.name, this.type, this.isNullable, this.hasDefault, this.isLocalOnly);

  final String name;
  final String type; // '?' 뗀 Dart 타입
  final bool isNullable;
  final bool hasDefault;
  final bool isLocalOnly; // JSON 에 안 실리는 앱 전용 값
}

void main() {
  final spec = jsonDecode(File(_specPath).readAsStringSync()) as Map<String, dynamic>;
  final schemas = (spec['components'] as Map<String, dynamic>)['schemas'] as Map<String, dynamic>;
  final appClasses = _readAppModelClasses();

  String? specSchemaNameOf(String appClassName) {
    final specName = _specSchemaByAppClass[appClassName] ?? appClassName;
    return schemas.containsKey(specName) ? specName : null;
  }

  test('모든 앱 모델은 스펙 스키마와 대응하거나 앱 전용으로 명시돼 있다', () {
    final unmapped = [
      for (final className in appClasses.keys)
        if (specSchemaNameOf(className) == null && !_appOnlyClasses.containsKey(className)) className,
    ];
    expect(unmapped, isEmpty, reason: '스펙에 없는 앱 모델: $unmapped. 이름이 다르면 _specSchemaByAppClass, 앱 전용이면 _appOnlyClasses 에 이유와 함께 추가');
  });

  test('앱 모델 필드는 서버 스펙과 맞는다', () {
    final problems = <String>[];
    appClasses.forEach((className, fields) {
      final specName = specSchemaNameOf(className);
      if (specName == null) return;
      final properties = (schemas[specName] as Map<String, dynamic>)['properties'] as Map<String, dynamic>? ?? const {};
      final requiredNames = ((schemas[specName] as Map<String, dynamic>)['required'] as List<dynamic>? ?? const []).cast<String>();

      for (final field in fields.where((field) => !field.isLocalOnly)) {
        final key = '$className.${field.name}';
        if (_knownMismatches.containsKey(key)) continue;
        final property = properties[field.name] as Map<String, dynamic>?;
        if (property == null) {
          problems.add('$key: 서버 스펙($specName)에 없는 필드');
          continue;
        }
        // 요청 모델은 앱이 보내는 값이라 non-null 이어도 안전, 응답 모델만 null 가능성을 검사
        final isResponseSchema = !specName.endsWith('Request');
        final isServerNullable = _isNullable(property) || !requiredNames.contains(field.name);
        if (isResponseSchema && isServerNullable && !field.isNullable && !field.hasDefault) {
          problems.add('$key: 서버가 null 일 수 있는데 앱은 기본값 없는 non-null');
        }
        final typeProblem = _typeProblem(field.type, property, schemas, specSchemaNameOf);
        if (typeProblem != null) problems.add('$key: $typeProblem');
      }
    });
    expect(problems, isEmpty, reason: problems.join('\n'));
  });
}

/// lib/data/models 의 freezed 생성자 파라미터 읽기 {클래스: 필드들}
Map<String, List<_AppField>> _readAppModelClasses() {
  final classes = <String, List<_AppField>>{};
  final factoryPattern = RegExp(r'const factory (\w+)\(\{');
  for (final file in handWrittenDartFiles(_modelsDirectory)) {
    final source = codeLinesOf(file).map((line) => line.$2).join('\n');
    for (final match in factoryPattern.allMatches(source)) {
      final bodyStart = match.end;
      final bodyEnd = _matchingBraceEnd(source, bodyStart);
      final body = source.substring(bodyStart, bodyEnd);
      classes[match.group(1)!] = [
        for (final parameter in _splitTopLevel(body))
          if (parameter.trim().isNotEmpty) _parseParameter(parameter.trim()),
      ];
    }
  }
  return classes;
}

/// '{' 바로 뒤 위치에서 짝이 되는 '}' 위치
int _matchingBraceEnd(String source, int start) {
  var depth = 1;
  for (var index = start; index < source.length; index++) {
    if (source[index] == '{') depth++;
    if (source[index] == '}' && --depth == 0) return index;
  }
  throw StateError('닫는 중괄호를 찾지 못함');
}

/// 괄호·꺾쇠 안의 쉼표는 무시하고 최상위 쉼표로 나누기
List<String> _splitTopLevel(String body) {
  final parts = <String>[];
  var depth = 0;
  var current = StringBuffer();
  for (final character in body.split('')) {
    if ('(<[{'.contains(character)) depth++;
    if (')>]}'.contains(character)) depth--;
    if (character == ',' && depth == 0) {
      parts.add(current.toString());
      current = StringBuffer();
    } else {
      current.write(character);
    }
  }
  parts.add(current.toString());
  return parts;
}

_AppField _parseParameter(String parameter) {
  final hasDefault = parameter.contains('@Default(');
  final isLocalOnly = parameter.contains('includeFromJson: false');
  var declaration = parameter;
  // 어노테이션 제거: @이름 또는 @이름(...) (괄호 짝 맞춤)
  while (true) {
    final annotation = RegExp(r'@\w+').firstMatch(declaration);
    if (annotation == null) break;
    var end = annotation.end;
    if (end < declaration.length && declaration[end] == '(') {
      var depth = 0;
      for (; end < declaration.length; end++) {
        if (declaration[end] == '(') depth++;
        if (declaration[end] == ')' && --depth == 0) {
          end++;
          break;
        }
      }
    }
    declaration = declaration.replaceRange(annotation.start, end, ' ');
  }
  declaration = declaration.replaceFirst('required ', '').trim();
  final nameMatch = RegExp(r'(\w+)\s*$').firstMatch(declaration)!;
  final rawType = declaration.substring(0, nameMatch.start).trim();
  final isNullable = rawType.endsWith('?');
  return _AppField(
    nameMatch.group(1)!,
    isNullable ? rawType.substring(0, rawType.length - 1) : rawType,
    isNullable,
    hasDefault,
    isLocalOnly,
  );
}

bool _isNullable(Map<String, dynamic> property) {
  final type = property['type'];
  if (type is List && type.contains('null')) return true;
  if (type == 'null') return true;
  final oneOf = property['oneOf'];
  return oneOf is List && oneOf.any((option) => (option as Map<String, dynamic>)['type'] == 'null');
}

/// 앱 타입이 스펙 속성과 호환되지 않으면 이유, 아니면 null
String? _typeProblem(
  String appType,
  Map<String, dynamic> property,
  Map<String, dynamic> schemas,
  String? Function(String) specSchemaNameOf,
) {
  if (appType == 'dynamic' || appType == 'Object') return null;

  // oneOf [참조, null] > 참조
  final oneOf = property['oneOf'];
  if (oneOf is List) {
    final reference = oneOf.cast<Map<String, dynamic>>().firstWhere((option) => option.containsKey(r'$ref'), orElse: () => const {});
    if (reference.isNotEmpty) return _typeProblem(appType, reference, schemas, specSchemaNameOf);
  }
  final reference = property[r'$ref'] as String?;
  if (reference != null) {
    final referencedName = reference.split('/').last;
    final appSpecName = specSchemaNameOf(appType);
    return appSpecName == referencedName ? null : '참조 $referencedName 인데 앱 타입은 $appType';
  }

  final rawType = property['type'];
  final specType = rawType is List ? rawType.firstWhere((type) => type != 'null', orElse: () => null) : rawType;
  switch (specType) {
    case 'string':
      final isPlainString = appType == 'String' || appType == 'DateTime';
      final isEnumLike = !isPlainString && RegExp(r'^[A-Z]\w*$').hasMatch(appType) && !_isPrimitive(appType);
      return isPlainString || isEnumLike ? null : 'string 인데 앱 타입은 $appType';
    case 'integer':
      return appType == 'int' || appType == 'num' ? null : 'integer 인데 앱 타입은 $appType';
    case 'number':
      return appType == 'double' || appType == 'num' || appType == 'int' ? null : 'number 인데 앱 타입은 $appType';
    case 'boolean':
      return appType == 'bool' ? null : 'boolean 인데 앱 타입은 $appType';
    case 'array':
      final listMatch = RegExp(r'^List<(.+)>$').firstMatch(appType);
      if (listMatch == null) return 'array 인데 앱 타입은 $appType';
      final items = property['items'] as Map<String, dynamic>? ?? const {};
      return _typeProblem(listMatch.group(1)!.replaceAll('?', ''), items, schemas, specSchemaNameOf);
    case 'object':
      return appType.startsWith('Map<') ? null : 'object 인데 앱 타입은 $appType';
  }
  return null;
}

bool _isPrimitive(String type) => const {'String', 'int', 'double', 'num', 'bool', 'DateTime'}.contains(type);
