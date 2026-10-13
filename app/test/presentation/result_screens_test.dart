import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:passql_app/data/models/daily_set/daily_set_models.dart';
import 'package:passql_app/data/models/question/submit_result.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/flows/daily_set_flow.dart';
import 'package:passql_app/presentation/pages/daily_set/daily_set_result_page.dart';
import 'package:passql_app/presentation/pages/practice/practice_result_page.dart';
import 'package:passql_app/presentation/pages/result/result_page.dart';
import 'package:passql_app/presentation/providers/chapter_providers.dart';
import 'package:passql_app/presentation/providers/daily_set_providers.dart';

import '../helpers/pump_app.dart';

/// 공통 확인: 결과 틀 하나를 쓰고, 320pt 폭에서 넘치지 않는다.
Future<void> expectResultScaffold(
  WidgetTester tester,
  Widget page, {
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await pumpApp(
    tester,
    ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        routerConfig: GoRouter(
          routes: [
            GoRoute(path: '/', builder: (_, _) => page),
            GoRoute(path: '/home', builder: (_, _) => const Text('홈 화면')),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.byType(PqResultScaffold), findsOneWidget);
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets('챕터 결과: 한 화면 스크롤에 점수 고리와 문항 행', (tester) async {
    await expectResultScaffold(
      tester,
      const PracticeResultPage(
        extra: ChapterSummary(
          topicName: 'JOIN',
          results: [
            ChapterResult(questionUuid: 'a', isCorrect: true, durationMs: 12000),
            ChapterResult(questionUuid: 'b', isCorrect: false, durationMs: 18000),
          ],
          totalDurationMs: 30000,
        ),
      ),
    );
    expect(find.text('1'), findsWidgets);
    expect(find.text(' / 2'), findsOneWidget);
    expect(find.byType(PageView), findsNothing);
    // 문항 행은 스크롤 밖에 있을 수 있어 skipOffstage 를 끈다.
    expect(find.byType(PqListRow, skipOffstage: false), findsNWidgets(2));
    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();
    expect(find.text('홈 화면'), findsOneWidget);
  });

  testWidgets('오늘의 세트 결과: 오답 행에 xmark 아이콘', (tester) async {
    await expectResultScaffold(
      tester,
      const DailySetResultPage(
        extra: DailySetOutcome(
          results: [
            ChapterResult(questionUuid: 'a', isCorrect: true, durationMs: 1),
            ChapterResult(questionUuid: 'b', isCorrect: false, durationMs: 1),
          ],
          correctCount: 1,
        ),
      ),
      overrides: [
        leaderboardProvider.overrideWith(
          (ref) async => const LeaderboardResponse(
            date: '2026-10-02',
            entries: [LeaderboardEntry(rank: 1, nickname: '민트', correctCount: 5)],
          ),
        ),
      ],
    );
    expect(
      find.byIcon(CupertinoIcons.xmark_circle_fill, skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('단건 결과: 정답이면 큰 결과 표시', (tester) async {
    await expectResultScaffold(
      tester,
      const ResultPage(
        extra: SubmitResult(isCorrect: true, correctKey: 'A', correctSql: 'SELECT 1'),
      ),
    );
    final marks = tester.widgetList<PqResultMark>(find.byType(PqResultMark));
    expect(marks.where((m) => m.large).length, 1);
    expect(find.text('정답'), findsOneWidget);
  });
}
