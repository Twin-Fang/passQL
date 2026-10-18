import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/utils/word_wrap.dart';
import 'package:passql_app/presentation/design/design.dart';

void main() {
  test('공백이 없으면 그대로, 있으면 단어 안 글자만 잇는다 (공백·줄바꿈 유지)', () {
    expect(keepWordsTogether('정답률'), '정답률');
    expect(keepWordsTogether('겨뤄요 같은\n문제'), '겨⁠뤄⁠요 같⁠은\n문⁠제');
    // 잇기 문자를 빼면 원문과 같음 (보이는 글자 변화 없음)
    expect(
      keepWordsTogether('모두 같은 문제로 겨뤄요').replaceAll('⁠', ''),
      '모두 같은 문제로 겨뤄요',
    );
  });

  test('좁은 폭에서 단어 중간이 아니라 공백에서 줄이 바뀐다', () {
    const sentence = '모두 같은 문제로 겨뤄요';
    final text = keepWordsTogether(sentence);
    final painter = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(fontSize: 15)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 70);
    expect(painter.computeLineMetrics().length, greaterThan(1));
    // 각 줄 끝이 공백 바로 뒤이거나 문장 끝
    var offset = 0;
    while (offset < text.length) {
      final line = painter.getLineBoundary(TextPosition(offset: offset));
      expect(
        line.end == text.length || text[line.end - 1] == ' ',
        isTrue,
        reason: '줄 끝 ${line.end}',
      );
      offset = line.end;
    }
    painter.dispose();

    // 대조: 원문 그대로면 단어 중간에서 끊기는 줄이 생김 (이 테스트가 버그를 잡는지 확인)
    final plainPainter = TextPainter(
      text: const TextSpan(text: sentence, style: TextStyle(fontSize: 15)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 70);
    final firstLineEnd = plainPainter
        .getLineBoundary(const TextPosition(offset: 0))
        .end;
    expect(sentence[firstLineEnd - 1], isNot(' '));
    plainPainter.dispose();
  });

  testWidgets('스크린리더에는 원문을 준다', (tester) async {
    const sentence = '모두 같은 문제로 겨뤄요';
    await tester.pumpWidget(
      MaterialApp(
        theme: PassqlTheme.light,
        home: const Center(child: PassqlKeepAllText(sentence)),
      ),
    );
    expect(find.bySemanticsLabel(sentence), findsOneWidget);
  });
}
