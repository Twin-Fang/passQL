import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/daily_set/daily_set_models.dart';
import 'package:passql_app/data/models/exam/exam_schedule_response.dart';
import 'package:passql_app/data/models/home/greeting_response.dart';
import 'package:passql_app/data/models/home/question_summary.dart';
import 'package:passql_app/data/models/home/recommendations_response.dart';
import 'package:passql_app/data/models/meta/topic_tree.dart';
import 'package:passql_app/data/models/progress/ai_comment_response.dart';
import 'package:passql_app/data/models/progress/heatmap_response.dart';
import 'package:passql_app/data/models/progress/progress_response.dart';
import 'package:passql_app/data/models/progress/readiness_response.dart';
import 'package:passql_app/data/models/progress/topic_analysis_response.dart';
import 'package:passql_app/data/models/progress/topic_stat.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/pages/home/home_page.dart';
import 'package:passql_app/presentation/pages/questions/topic_list_page.dart';
import 'package:passql_app/presentation/pages/stats/stats_page.dart';
import 'package:passql_app/presentation/providers/home_providers.dart';
import 'package:passql_app/presentation/providers/stats_providers.dart';
import 'package:passql_app/presentation/providers/topic_providers.dart';

import '../helpers/pump_app.dart';

final homeData = HomeData(
  greeting: const GreetingResponse(
    nickname: '찬',
    message: '{nickname}님,\nSQLD D-12! 지금이 골든타임이에요',
    messageType: 'COUNTDOWN',
  ),
  progress: const ProgressResponse(
    solvedCount: 12,
    correctRate: 0.6,
    streakDays: 3,
    readiness: ReadinessResponse(
      score: 0.4,
      accuracy: 0.6,
      coverage: 0.5,
      recency: 0.7,
      recentAttemptCount: 5,
      coveredTopicCount: 3,
      activeTopicCount: 9,
      toneKey: 'STEADY',
    ),
  ),
  dailySet: const DailySetTodayResponse(),
  recommendations: const RecommendationsResponse(
    questions: [
      QuestionSummary(
        questionUuid: 'q1',
        topicName: 'JOIN',
        stemPreview: '다음 중 옳은 것은?',
        difficulty: 2,
      ),
    ],
  ),
  examSchedule: const ExamScheduleResponse(
    examScheduleUuid: 'e',
    certType: 'SQLD',
    round: 58,
    examDate: '2099-01-01',
    isSelected: true,
  ),
  heatmap: HeatmapResponse(
    entries: [
      HeatmapEntry(
        date: DateTime.now().toIso8601String().substring(0, 10),
        solvedCount: 4,
        correctCount: 2,
      ),
    ],
  ),
);

const statsData = StatsData(
  progress: ProgressResponse(solvedCount: 12, correctRate: 0.6, streakDays: 3),
  topicAnalysis: TopicAnalysisResponse(
    topicStats: [
      TopicStat(
        topicUuid: 'a',
        displayName: 'SQL 기본 / SELECT',
        totalQuestionCount: 10,
        correctRate: 0.5,
      ),
      TopicStat(
        topicUuid: 'b',
        displayName: 'JOIN',
        totalQuestionCount: 6,
        correctRate: 0.8,
      ),
      TopicStat(
        topicUuid: 'c',
        displayName: '서브쿼리',
        totalQuestionCount: 4,
        correctRate: 0.3,
      ),
    ],
  ),
  aiComment: AiCommentResponse(comment: '`JOIN` 토픽이 강해요.'),
);

const topics = [
  TopicTree(
    topicUuid: 't1',
    code: 'sql_join',
    displayName: 'JOIN',
    subtopics: [SubtopicItem(code: 'a', displayName: 'A', isActive: true)],
  ),
  TopicTree(topicUuid: 't2', code: 'unknown', displayName: '신규'),
];

Future<void> _pump(
  WidgetTester tester,
  Widget page,
  List<Override> overrides, {
  ThemeData? theme,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await pumpApp(
    tester,
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(theme: theme ?? PqTheme.light, home: page),
    ),
  );
  await tester.pump();
}

void main() {
  final cases = <String, (Widget, List<Override>)>{
    '홈': (
      const HomePage(),
      [homeDataProvider.overrideWith((ref) async => homeData)],
    ),
    '문제': (
      const TopicListPage(),
      [topicsProvider.overrideWith((ref) async => topics)],
    ),
    '통계': (
      const StatsPage(),
      [statsDataProvider.overrideWith((ref) async => statsData)],
    ),
  };

  for (final entry in cases.entries) {
    for (final dark in [false, true]) {
      testWidgets(
        '${entry.key} 화면: large title 바 1개, ${dark ? '다크' : '라이트'} 예외 없음',
        (tester) async {
          await _pump(
            tester,
            entry.value.$1,
            entry.value.$2,
            theme: dark ? PqTheme.dark : PqTheme.light,
          );
          expect(find.byType(CupertinoSliverNavigationBar), findsOneWidget);
          // 인사 둘째 줄이 잘리지 않고 본문으로 보인다.
          if (entry.key == '홈') {
            expect(find.textContaining('D-12'), findsOneWidget);
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('통계 화면은 320pt 폭에서도 예외 없다', (tester) async {
    await _pump(tester, const StatsPage(), [
      statsDataProvider.overrideWith((ref) async => statsData),
    ], size: const Size(320, 640));
    expect(tester.takeException(), isNull);
  });
}
