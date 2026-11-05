import 'package:freezed_annotation/freezed_annotation.dart';

part 'choice_item.freezed.dart';
part 'choice_item.g.dart';

/// 개별 선택지. kind="SQL"이면 body가 SQL 코드, kind="TEXT"면 일반 텍스트.
@freezed
class ChoiceItem with _$ChoiceItem {
  const factory ChoiceItem({
    required String key,
    required String kind,
    required String body,
    bool? isCorrect,
    String? rationale,
    int? sortOrder,
  }) = _ChoiceItem;

  factory ChoiceItem.fromJson(Map<String, dynamic> json) =>
      _$ChoiceItemFromJson(json);
}

/// 선택지 종류 판정 (kind 문자열 비교는 이곳만, #828)
extension ChoiceItemKind on ChoiceItem {
  // 서버 ChoiceKind: SQL 보기 kind 값
  static const String sqlKind = 'SQL';

  /// SQL 보기 (body 가 실행 가능한 SQL). 아니면 개념 글 또는 결과 표 JSON
  bool get isSql => kind == sqlKind;
}
