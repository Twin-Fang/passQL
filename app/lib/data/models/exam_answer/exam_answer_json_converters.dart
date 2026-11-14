import 'package:freezed_annotation/freezed_annotation.dart';

/// 가답안 응답의 모양이 갈릴 수 있는 칸 변환 (#1075, 서버 병행 개발이라 두 모양 모두 받음)
/// 쉼표 문자열("2,3") 또는 숫자 배열 > 숫자 목록
class ExamAnswerIntListConverter implements JsonConverter<List<int>, Object> {
  const ExamAnswerIntListConverter();

  // 쉼표 문자열 구분자 (서버 alternative_answers·concept_tags 저장 형식)
  static const String delimiter = ',';

  @override
  List<int> fromJson(Object json) => switch (json) {
    final List<dynamic> values => [
      for (final value in values)
        if (int.tryParse('$value') case final int number) number,
    ],
    final String text => [
      for (final part in text.split(delimiter))
        if (int.tryParse(part.trim()) case final int number) number,
    ],
    _ => const [],
  };

  @override
  Object toJson(List<int> numbers) => numbers;
}

/// 쉼표 문자열 또는 문자열 배열 > 글자 목록 (빈 칸 제거)
class ExamAnswerStringListConverter
    implements JsonConverter<List<String>, Object> {
  const ExamAnswerStringListConverter();

  @override
  List<String> fromJson(Object json) {
    final parts = switch (json) {
      final List<dynamic> values => values.map((value) => '$value'),
      final String text => text.split(ExamAnswerIntListConverter.delimiter),
      _ => const <String>[],
    };
    return [
      for (final part in parts)
        if (part.trim().isNotEmpty) part.trim(),
    ];
  }

  @override
  Object toJson(List<String> texts) => texts;
}

/// 보기별 득표 {"1": n, ...} 또는 [n1, n2, n3, n4] > 길이 4 목록 (보기 1번이 0번 칸)
class ExamAnswerTallyConverter implements JsonConverter<List<int>, Object> {
  const ExamAnswerTallyConverter();

  // 보기 수 (SQLD 4지선다)
  static const int choiceCount = 4;

  @override
  List<int> fromJson(Object json) => switch (json) {
    final Map<String, dynamic> countByChoice => [
      for (var choice = 1; choice <= choiceCount; choice++)
        (countByChoice['$choice'] as num?)?.toInt() ?? 0,
    ],
    final List<dynamic> counts => [
      for (var index = 0; index < choiceCount; index++)
        index < counts.length ? (counts[index] as num?)?.toInt() ?? 0 : 0,
    ],
    _ => List.filled(choiceCount, 0),
  };

  @override
  Object toJson(List<int> counts) => {
    for (var index = 0; index < counts.length; index++)
      '${index + 1}': counts[index],
  };
}
