import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/design/design.dart';
import '../helpers/pump_app.dart';

Widget host(Widget child, {double bottomInset = 0, double textScale = 1}) =>
    MaterialApp(
      theme: PassqlTheme.light,
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(390, 844),
          padding: EdgeInsets.only(bottom: bottomInset),
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(body: child),
      ),
    );


void main() {
  group('PassqlButton', () {
    testWidgets('누르면 onPressed 가 불리고 large 높이는 50이다', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          Center(
            child: PassqlButton(label: '제출', onPressed: () => taps++),
          ),
        ),
      );
      expect(tester.getSize(find.byType(PassqlButton)).height, 50);
      await tester.tap(find.text('제출'));
      expect(taps, 1);
    });

    testWidgets('loading 이면 인디케이터를 보이고 탭을 무시한다', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          Center(
            child: PassqlButton(
              label: '제출',
              isLoading: true,
              onPressed: () => taps++,
            ),
          ),
        ),
      );
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      await tester.tap(find.byType(PassqlButton));
      expect(taps, 0);
    });

    testWidgets('글자 크기 2배에서도 넘치지 않는다', (tester) async {
      await tester.pumpWidget(
        host(
          Center(
            child: PassqlButton(label: '오늘의 세트 시작하기', onPressed: () {}),
          ),
          textScale: 2,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('PassqlListRow', () {
    testWidgets('최소 높이 44, 글자 크기 2배에서도 넘치지 않는다', (tester) async {
      await tester.pumpWidget(
        host(
          PassqlGroupedSection(
            children: [
              PassqlListRow(
                title: '닉네임',
                subtitle: '아주 긴 설명이 들어가도 줄바꿈된다',
                hasChevron: true,
                onTap: () {},
              ),
            ],
          ),
          textScale: 2,
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(PassqlListRow)).height,
        greaterThanOrEqualTo(44),
      );
    });
  });

  group('PassqlBottomActionBar', () {
    testWidgets('버튼이 기기 하단 inset 위에 놓인다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: PassqlTheme.light,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 844),
              padding: EdgeInsets.only(bottom: 34),
            ),
            child: Scaffold(
              body: const SizedBox(),
              bottomNavigationBar: PassqlBottomActionBar(
                actions: [PassqlButton(label: '다음', onPressed: () {})],
              ),
            ),
          ),
        ),
      );
      final buttonBottom = tester.getBottomLeft(find.byType(PassqlButton)).dy;
      expect(buttonBottom, lessThanOrEqualTo(844 - 34));
    });
  });

  group('PassqlChoiceCard', () {
    testWidgets('채점 상태(correct/wrong/dimmed)에서는 탭이 무시된다', (tester) async {
      for (final s in [
        PassqlChoiceState.correct,
        PassqlChoiceState.wrong,
        PassqlChoiceState.dimmed,
      ]) {
        var taps = 0;
        await tester.pumpWidget(
          host(
            PassqlChoiceCard(
              keyLabel: 'A',
              state: s,
              onTap: () => taps++,
              child: const Text('SELECT 1'),
            ),
          ),
        );
        await tester.tap(find.text('SELECT 1'));
        expect(taps, 0, reason: '$s');
      }
    });

    testWidgets('정답은 체크, 오답은 X 아이콘을 보인다', (tester) async {
      await tester.pumpWidget(
        host(
          Column(
            children: const [
              PassqlChoiceCard(
                keyLabel: 'A',
                state: PassqlChoiceState.correct,
                child: Text('a'),
              ),
              PassqlChoiceCard(
                keyLabel: 'B',
                state: PassqlChoiceState.wrong,
                child: Text('b'),
              ),
            ],
          ),
        ),
      );
      expect(find.byIcon(CupertinoIcons.checkmark_circle_fill), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.xmark_circle_fill), findsOneWidget);
    });
  });

  group('PassqlChoiceCard 접근성', () {
    testWidgets('정답/오답 상태가 시맨틱 라벨로 전달된다', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          const PassqlChoiceCard(
            keyLabel: 'A',
            state: PassqlChoiceState.correct,
            child: Text('a'),
          ),
        ),
      );
      expect(find.bySemanticsLabel(RegExp('정답')), findsOneWidget);
      await tester.pumpWidget(
        host(
          const PassqlChoiceCard(
            keyLabel: 'B',
            state: PassqlChoiceState.wrong,
            child: Text('b'),
          ),
        ),
      );
      expect(find.bySemanticsLabel(RegExp('오답')), findsOneWidget);
      handle.dispose();
    });
  });

  group('PassqlNavBar', () {
    testWidgets('다크 테마에서 제목 색은 dark label 이다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: PassqlTheme.dark,
          home: const Scaffold(appBar: PassqlNavBar(title: '제목')),
        ),
      );
      final text = tester.widget<Text>(find.text('제목'));
      expect(text.style?.color, PassqlColors.dark.label);
    });
  });

  group('PassqlTabBar', () {
    testWidgets('글자 없이 아이콘만 그리고 접근성 라벨을 남긴다', (tester) async {
      var tapped = -1;
      await tester.pumpWidget(
        host(
          Align(
            alignment: Alignment.bottomCenter,
            child: PassqlTabBar(
              currentIndex: 0,
              onTap: (i) => tapped = i,
              items: const [
                PassqlTabItem(
                  icon: CupertinoIcons.house,
                  activeIcon: CupertinoIcons.house_fill,
                  label: '홈',
                ),
                PassqlTabItem(
                  icon: CupertinoIcons.book,
                  activeIcon: CupertinoIcons.book_fill,
                  label: '문제',
                ),
              ],
            ),
          ),
          bottomInset: 34,
        ),
      );
      expect(find.text('홈'), findsNothing);
      expect(find.bySemanticsLabel('문제'), findsOneWidget);
      await tester.tap(find.byIcon(CupertinoIcons.book));
      expect(tapped, 1);
      // 높이 = 44 + 홈 인디케이터 inset 34 의 60%
      expect(
        tester.getSize(find.byType(PassqlTabBar)).height,
        closeTo(44 + 34 * 0.6, 0.01),
      );
    });

    testWidgets('3버튼 내비게이션처럼 inset 이 크면 inset 을 그대로 둔다', (tester) async {
      await tester.pumpWidget(
        host(
          Align(
            alignment: Alignment.bottomCenter,
            child: PassqlTabBar(
              currentIndex: 0,
              onTap: (_) {},
              items: const [
                PassqlTabItem(
                  icon: CupertinoIcons.house,
                  activeIcon: CupertinoIcons.house_fill,
                  label: '홈',
                ),
              ],
            ),
          ),
          bottomInset: 48,
        ),
      );
      expect(tester.getSize(find.byType(PassqlTabBar)).height, 44 + 48);
    });
  });

  group('PassqlStatusView', () {
    testWidgets('error 는 다시 시도 버튼을 준다', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        host(
          PassqlStatusView.error(
            message: '불러오지 못했어요',
            onRetry: () => retried = true,
          ),
        ),
      );
      await tester.tap(find.text('다시 시도'));
      expect(retried, isTrue);
    });
  });

  group('PassqlScoreHeader', () {
    testWidgets('320pt 폭에서도 넘치지 않는다', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: PassqlTheme.light,
          home: const Scaffold(
            body: PassqlScoreHeader(score: 10, total: 10, caption: '오늘의 세트'),
          ),
        ),
      );
      // 화면 전환 지연 뒤 숫자가 0에서 10까지 올라간다
      await pumpUntilMotionDone(tester);
      expect(tester.takeException(), isNull);
      expect(find.text('10'), findsOneWidget);
    });
  });

  testWidgets('PassqlCodeBlock은 기본 줄바꿈, wrap:false면 가로 스크롤', (tester) async {
    const sql =
        'SELECT a_very_long_column_name FROM a_very_long_table_name WHERE x = 1;';
    Future<void> pump(bool wrap) => tester.pumpWidget(
      MaterialApp(
        theme: PassqlTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 120,
            child: PassqlCodeBlock(code: sql, shouldWrap: wrap),
          ),
        ),
      ),
    );
    await pump(true);
    expect(find.byType(SingleChildScrollView), findsNothing);
    await pump(false);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('다크 테마에서 모든 컴포넌트가 예외 없이 그려진다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PassqlTheme.dark,
        home: Scaffold(
          body: ListView(
            children: [
              PassqlCard(title: '카드', child: const Text('본문')),
              const PassqlCodeBlock(code: 'SELECT * FROM emp;'),
              const PassqlResultMark(isCorrect: true, isLarge: true),
              const PassqlBadge(text: 'SQLD'),
              const PassqlProgressBar(value: 0.4),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
