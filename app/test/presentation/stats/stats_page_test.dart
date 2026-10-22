import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:passql_app/data/models/daily_set/daily_set_models.dart';
import 'package:passql_app/data/models/progress/heatmap_response.dart';
import 'package:passql_app/data/models/progress/progress_response.dart';
import 'package:passql_app/data/models/progress/readiness_response.dart';
import 'package:passql_app/data/models/home/question_summary.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/pages/stats/stats_page.dart';
import 'package:passql_app/presentation/providers/home_providers.dart';
import 'package:passql_app/presentation/providers/stats_providers.dart';
import 'package:passql_app/presentation/providers/wrong_questions_provider.dart';
import 'package:passql_app/presentation/widgets/ads/ad_inline_card.dart';
import 'package:passql_app/presentation/widgets/home/heatmap_widget.dart';
import 'package:passql_app/presentation/widgets/home/readiness_card.dart';
import 'package:passql_app/presentation/widgets/stats/bar_chart_section.dart';
import 'package:passql_app/presentation/widgets/stats/radar_chart_section.dart';
import 'package:passql_app/presentation/widgets/stats/stats_empty_state_card.dart';
import 'package:passql_app/presentation/widgets/stats/stats_shortcut_section.dart';
import 'package:passql_app/presentation/widgets/stats/summary_stats_section.dart';
import 'package:passql_app/router/app_routes.dart';

import '../../helpers/pump_app.dart';
import '../tab_pages_test.dart' show statsData;

const _readiness = ReadinessResponse(
  score: 0.4,
  accuracy: 0.6,
  coverage: 0.5,
  recency: 0.7,
  recentAttemptCount: 5,
  coveredTopicCount: 3,
  activeTopicCount: 9,
  toneKey: 'STEADY',
);

const _availableDailySet = DailySetTodayResponse(
  questions: [
    QuestionSummary(
      questionUuid: 'q1',
      topicName: 'JOIN',
      stemPreview: '다음 중 옳은 것은?',
      difficulty: 2,
    ),
  ],
);

const _emptyStatsData = StatsData(
  progress: ProgressResponse(solvedCount: 0, correctRate: 0, streakDays: 0),
);

Future<GoRouter> _pumpStatsPage(
  WidgetTester tester, {
  required StatsData stats,
  required HomeLearningStatus learningStatus,
}) async {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const StatsPage()),
      GoRoute(
        path: AppRoutes.dailySet,
        builder: (_, _) => const Text('daily-set-page'),
      ),
      GoRoute(
        path: AppRoutes.questions,
        builder: (_, _) => const Text('questions-page'),
      ),
    ],
  );
  addTearDown(router.dispose);
  tester.view.physicalSize = const Size(390, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await pumpApp(
    tester,
    ProviderScope(
      overrides: [
        statsDataProvider.overrideWith((ref) async => stats),
        statsAiCommentProvider.overrideWith((ref) async => null),
        homeLearningStatusProvider.overrideWith((ref) async => learningStatus),
        wrongQuestionTotalCountProvider.overrideWith((ref) async => 3),
      ],
      child: MaterialApp.router(theme: PassqlTheme.light, routerConfig: router),
    ),
  );
  await pumpUntilMotionDone(tester);
  return router;
}

void main() {
  testWidgets('푼 문제 0개: 빈 상태 카드 1개와 세트 풀기 버튼, 요약·차트·바로가기는 숨김', (tester) async {
    await _pumpStatsPage(
      tester,
      stats: _emptyStatsData,
      learningStatus: const HomeLearningStatus(dailySet: _availableDailySet),
    );

    expect(find.byType(StatsEmptyStateCard), findsOneWidget);
    expect(find.text('아직 푼 문제가 없어요'), findsOneWidget);
    expect(find.text('오늘의 세트 풀기'), findsOneWidget);
    expect(find.byType(SummaryStatsSection), findsNothing);
    expect(find.byType(RadarChartSection), findsNothing);
    expect(find.byType(BarChartSection), findsNothing);
    expect(find.byType(StatsShortcutSection), findsNothing);

    await tester.tap(find.text('오늘의 세트 풀기'));
    await tester.pumpAndSettle();
    expect(find.text('daily-set-page'), findsOneWidget);
  });

  testWidgets('푼 문제 0개 + 세트 없음: 문제 풀러 가기 > 문제 탭으로 이동', (tester) async {
    await _pumpStatsPage(
      tester,
      stats: _emptyStatsData,
      learningStatus: const HomeLearningStatus(),
    );

    expect(find.text('오늘의 세트 풀기'), findsNothing);
    await tester.tap(find.text('문제 풀러 가기'));
    await tester.pumpAndSettle();
    expect(find.text('questions-page'), findsOneWidget);
  });

  testWidgets('푼 문제 1개 이상: 요약·준비도·히트맵·차트·바로가기가 모두 보이고 빈 카드는 없음', (
    tester,
  ) async {
    await _pumpStatsPage(
      tester,
      stats: StatsData(
        progress: statsData.progress!.copyWith(readiness: _readiness),
        topicAnalysis: statsData.topicAnalysis,
      ),
      learningStatus: HomeLearningStatus(
        heatmap: HeatmapResponse(
          entries: [
            HeatmapEntry(
              date: DateTime.now().toIso8601String().substring(0, 10),
              solvedCount: 4,
              correctCount: 2,
            ),
          ],
        ),
      ),
    );

    expect(find.byType(StatsEmptyStateCard), findsNothing);
    expect(find.byType(SummaryStatsSection), findsOneWidget);
    expect(find.byType(ReadinessCard), findsOneWidget);
    expect(find.byType(HeatmapWidget), findsOneWidget);
    expect(find.byType(RadarChartSection), findsOneWidget);
    expect(find.byType(BarChartSection), findsOneWidget);
    expect(find.byType(StatsShortcutSection), findsOneWidget);
    expect(find.text('오답 노트'), findsOneWidget);
    expect(find.text('오늘의 세트 순위'), findsOneWidget);
    // 인라인 광고 자리는 빈 상태와 같이 1개 (광고 꺼짐이면 자리만)
    expect(find.byType(AdInlineCard), findsOneWidget);
  });
}
