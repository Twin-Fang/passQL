import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/utils/word_wrap.dart';
import 'package:passql_app/data/models/home/greeting_response.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/widgets/home/greeting_section.dart';

/// 홈 인사: 인사·본문 모두 말줄임 없이 여러 줄 (#530)
void main() {
  const longGreeting = GreetingResponse(
    nickname: '공부하는새찬',
    message: '늦은 시간에도 열심인 {nickname}님,\n오늘도 한 문제 더 풀어 볼까요?',
    messageType: 'DEFAULT',
  );
  // 320pt 화면 - 좌우 여백
  const narrowContentWidth = 320 - PassqlSpacing.md * 2;

  test('{nickname} 치환 후 첫 줄은 인사, 나머지는 본문', () {
    expect(
      GreetingSection.resolveMessage(longGreeting),
      '늦은 시간에도 열심인 공부하는새찬님,',
    );
    expect(GreetingSection.resolveBody(longGreeting), '오늘도 한 문제 더 풀어 볼까요?');
  });

  testWidgets('좁은 폭에서도 인사·본문은 말줄임 없이 전부 보인다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PassqlTheme.light,
        home: const Scaffold(
          body: SizedBox(
            width: narrowContentWidth,
            child: GreetingSection(greeting: longGreeting),
          ),
        ),
      ),
    );
    for (final line in [
      GreetingSection.resolveMessage(longGreeting),
      GreetingSection.resolveBody(longGreeting)!,
    ]) {
      final text = tester.widget<Text>(find.text(keepWordsTogether(line)));
      expect(text.maxLines, isNull);
      expect(text.overflow, isNull);
    }
    expect(tester.takeException(), isNull);
  });
}
