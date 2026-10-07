import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
