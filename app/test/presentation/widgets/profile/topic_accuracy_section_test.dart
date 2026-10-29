import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/meta/topic_tree.dart';
import 'package:passql_app/data/models/progress/topic_stat.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/providers/topic_providers.dart';
import 'package:passql_app/presentation/widgets/profile/topic_accuracy_section.dart';

TopicStat _stat(String uuid, double rate) => TopicStat(
  topicUuid: uuid,
  displayName: '영역 $uuid',
  correctRate: rate,
  solvedCount: 10,
);

Future<void> _pump(WidgetTester tester, List<TopicStat> stats) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        topicsProvider.overrideWith((ref) async => const <TopicTree>[]),
      ],
      child: MaterialApp(
        theme: PassqlTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: TopicAccuracySection(topicStats: stats, isLocked: false),
          ),
        ),
      ),
    ),
  );
}

void main() {
  final stats = [_stat('a', 0.9), _stat('b', 0.4), _stat('c', 0.7)];

  testWidgets('차트 아이콘을 누르면 8각 차트로 바뀌고 정렬 버튼은 숨는다', (tester) async {
    await _pump(tester, stats);
    await tester.pumpAndSettle();
    expect(find.text('정답률 낮은 순'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('차트로 보기'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('topic-accuracy-radar')), findsOneWidget);
    expect(find.text('정답률 낮은 순'), findsNothing);

    await tester.tap(find.bySemanticsLabel('목록으로 보기'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('topic-accuracy-radar')), findsNothing);
    expect(find.text('정답률 낮은 순'), findsOneWidget);
  });

  testWidgets('영역이 3개 미만이면 차트를 고를 수 없다 (면이 안 만들어짐)', (tester) async {
    await _pump(tester, stats.take(2).toList());
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('차트로 보기'), findsNothing);
  });
}
