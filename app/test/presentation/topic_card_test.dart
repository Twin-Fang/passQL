import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/topic_icons.dart';
import 'package:passql_app/data/models/meta/topic_tree.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/widgets/question/topic_card.dart';

Widget _host(TopicTree topic) => MaterialApp(
  theme: PqTheme.light,
  home: Scaffold(
    body: TopicCard(topic: topic, onTap: () {}),
  ),
);

/// 행 안의 아이콘 타일(색 배경) 데코레이션 색.
Color _tileColor(WidgetTester tester) {
  final tile = tester.widget<PqIconTile>(find.byType(PqIconTile));
  return tile.color;
}

void main() {
  testWidgets('서브토픽이 없으면 "0개 서브토픽"을 표시하지 않는다', (tester) async {
    await tester.pumpWidget(
      _host(const TopicTree(topicUuid: 't', code: 'c', displayName: 'JOIN')),
    );
    expect(find.text('JOIN'), findsOneWidget);
    expect(find.textContaining('서브토픽'), findsNothing);
  });

  testWidgets('활성 서브토픽이 있으면 개수를 표시한다', (tester) async {
    await tester.pumpWidget(
      _host(
        const TopicTree(
          topicUuid: 't',
          code: 'c',
          displayName: 'JOIN',
          subtopics: [
            SubtopicItem(code: 'a', displayName: 'A', isActive: true),
            SubtopicItem(code: 'b', displayName: 'B', isActive: false),
          ],
        ),
      ),
    );
    expect(find.text('1개 서브토픽'), findsOneWidget);
  });

  testWidgets('토픽 코드에 맞는 아이콘을 표시한다', (tester) async {
    await tester.pumpWidget(
      _host(
        const TopicTree(topicUuid: 't', code: 'sql_join', displayName: 'JOIN'),
      ),
    );
    final tile = tester.widget<PqIconTile>(find.byType(PqIconTile));
    expect(tile.icon, topicIconFor('sql_join'));
    expect(tile.icon, CupertinoIcons.rectangle_on_rectangle);
  });

  testWidgets('모르는 토픽 코드는 물음표 아이콘으로 대체한다', (tester) async {
    await tester.pumpWidget(
      _host(
        const TopicTree(topicUuid: 't', code: 'unknown', displayName: '신규'),
      ),
    );
    final tile = tester.widget<PqIconTile>(find.byType(PqIconTile));
    expect(tile.icon, CupertinoIcons.question_circle);
  });

  testWidgets('토픽 코드별로 다른 색의 아이콘 타일을 쓴다', (tester) async {
    await tester.pumpWidget(
      _host(
        const TopicTree(topicUuid: 't', code: 'sql_join', displayName: 'JOIN'),
      ),
    );
    expect(_tileColor(tester), topicColor('sql_join', Brightness.light));
    expect(
      topicColor('sql_join', Brightness.light),
      isNot(topicColor('sql_window', Brightness.light)),
    );
  });

  testWidgets('글자 200%에서도 레이아웃 예외 없이 이름과 개수를 표시한다', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: PqTheme.light,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(
            ctx,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 170,
              child: TopicCard(
                topic: const TopicTree(
                  topicUuid: 't',
                  code: 'sql_join',
                  displayName: 'JOIN',
                  subtopics: [
                    SubtopicItem(code: 'a', displayName: 'A', isActive: true),
                  ],
                ),
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('JOIN'), findsOneWidget);
    expect(find.text('1개 서브토픽'), findsOneWidget);
  });
}
