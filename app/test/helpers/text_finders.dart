import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// keepWordsTogether 가 넣는 단어 잇기 문자 (U+2060)
const String _wordJoiner = '⁠';

/// 화면에 보이는 글자 기준 textContaining (단어 단위 줄바꿈 문자를 빼고 비교)
/// PassqlKeepAllText 로 그린 문장도 원문 조각으로 찾음 > findsNothing 검사가 헛돌지 않게
Finder findTextContainingIgnoringWordJoiners(
  String pattern, {
  bool skipOffstage = true,
}) => find.byWidgetPredicate((widget) {
  final String? visibleText = switch (widget) {
    Text(:final data, :final textSpan) => data ?? textSpan?.toPlainText(),
    EditableText(:final controller) => controller.text,
    _ => null,
  };
  return visibleText != null &&
      visibleText.replaceAll(_wordJoiner, '').contains(pattern);
}, skipOffstage: skipOffstage);
