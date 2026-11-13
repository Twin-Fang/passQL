import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/meta/topic_tree.dart';
import 'package:passql_app/data/models/progress/topic_stat.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/providers/topic_providers.dart';
import 'package:passql_app/presentation/widgets/profile/topic_accuracy_section.dart';

import '../../../helpers/text_finders.dart';

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
            child: TopicAccuracySection(topicStats: stats),
          ),
        ),
      ),
    ),
  );
}

void main() {
  final stats = [_stat('a', 0.9), _stat('b', 0.4), _stat('c', 0.7)];

  testWidgets('8각 차트와 목록이 함께 보이고 정렬 버튼은 목록 위에 있다 (#909)', (tester) async {
    await _pump(tester, stats);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('topic-accuracy-radar')), findsOneWidget);
    expect(findTextContainingIgnoringWordJoiners('영역 b'), findsOneWidget);
    expect(find.text('정답률 낮은 순'), findsOneWidget);
  });

  testWidgets('영역이 3개 미만이면 차트 없이 목록만 (면이 안 만들어짐)', (tester) async {
    await _pump(tester, stats.take(2).toList());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('topic-accuracy-radar')), findsNothing);
    expect(findTextContainingIgnoringWordJoiners('영역 a'), findsOneWidget);
  });
}
