import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/utils/word_wrap.dart';
import 'package:passql_app/data/models/home/greeting_response.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/widgets/home/greeting_section.dart';

/// 홈 인사: large title 은 한 줄 규격 > 긴 인사는 말줄임 대신 본문 맨 위에 여러 줄로
void main() {
  const longGreeting = GreetingResponse(
    nickname: '공부하는새찬',
    message: '늦은 시간에도 열심인 {nickname}님,\n오늘도 한 문제 더 풀어 볼까요?',
    messageType: 'DEFAULT',
  );
  const shortGreeting = GreetingResponse(
    nickname: '찬',
    message: '{nickname}님,\n지금이 골든타임',
    messageType: 'DEFAULT',
  );
  // 375pt 화면 - 좌우 여백
  const largeTitleWidth = 375 - PassqlSpacing.md * 2;

  test('짧은 인사는 large title 에 들어가고 긴 인사는 들어가지 않는다', () {
    expect(
      GreetingSection.fitsInLargeTitle(
        GreetingSection.resolveMessage(shortGreeting),
        maxWidth: largeTitleWidth,
        textScaler: TextScaler.noScaling,
      ),
      isTrue,
    );
    expect(
      GreetingSection.fitsInLargeTitle(
        GreetingSection.resolveMessage(longGreeting),
        maxWidth: largeTitleWidth,
        textScaler: TextScaler.noScaling,
      ),
      isFalse,
    );
  });

  testWidgets('본문으로 내려온 인사는 말줄임 없이 전부 보인다', (tester) async {
    expect(
      GreetingSection.hasContent(longGreeting, isHeadlineShown: true),
      isTrue,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: PassqlTheme.light,
        home: const Scaffold(
          body: SizedBox(
            width: largeTitleWidth,
            child: GreetingSection(
              greeting: longGreeting,
              isHeadlineShown: true,
            ),
          ),
        ),
      ),
    );
    final headline = keepWordsTogether(
      GreetingSection.resolveMessage(longGreeting),
    );
    final headlineText = tester.widget<Text>(find.text(headline));
    expect(headlineText.maxLines, isNull);
    expect(headlineText.overflow, isNull);
    expect(tester.takeException(), isNull);
  });
}
