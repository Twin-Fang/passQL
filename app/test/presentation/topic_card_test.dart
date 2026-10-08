import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:passql_app/data/models/meta/topic_tree.dart';
import 'package:passql_app/presentation/widgets/question/topic_card.dart';

Widget _host(TopicTree topic) => ScreenUtilInit(
  designSize: const Size(390, 844),
  builder: (_, _) => MaterialApp(
    home: Scaffold(
      body: TopicCard(topic: topic, onTap: () {}),
    ),
  ),
);

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
    final icon = tester.widget<FaIcon>(find.byType(FaIcon).first);
    expect(icon.icon?.codePoint, FontAwesomeIcons.objectGroup.codePoint);
  });

  testWidgets('모르는 토픽 코드는 물음표 아이콘으로 대체한다', (tester) async {
    await tester.pumpWidget(
      _host(
        const TopicTree(topicUuid: 't', code: 'unknown', displayName: '신규'),
      ),
    );
    final icon = tester.widget<FaIcon>(find.byType(FaIcon).first);
    expect(icon.icon?.codePoint, FontAwesomeIcons.circleQuestion.codePoint);
  });
}
