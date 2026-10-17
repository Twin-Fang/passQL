import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/monitoring/app_analytics.dart';
import '../../router/app_routes.dart';
import '../../router/result_route_arguments.dart';
import '../providers/chapter_providers.dart';
import '../providers/daily_set_providers.dart';
import 'question_flow.dart';

/// 오늘의 데일리 세트(전 회원 공통 5문제 안팎)를 푸는 흐름.
class DailySetFlow extends QuestionFlow {
  const DailySetFlow();

  @override
  String get id => 'daily-set';

  @override
  String get title => '오늘의 세트';

  // 한 번의 풀이를 하나의 세션으로 묶어 서버에 알린다.
  @override
  bool get shouldTrackSession => true;

  @override
  Future<List<String>> loadQuestionUuids(WidgetRef ref) =>
      ref.read(dailySetServiceProvider).fetchTodayQuestionUuids();

  @override
  Future<void> onCompleted(
    BuildContext context,
    WidgetRef ref,
    ChapterSummary summary,
    String sessionUuid,
  ) async {
    final correctCount = summary.results
        .where((result) => result.isCorrect)
        .length;
    final completion = await ref
        .read(dailySetServiceProvider)
        .submitCompletion(correctCount: correctCount, sessionUuid: sessionUuid);
    ref
        .read(appAnalyticsProvider)
        .logDailySetCompleted(
          correctCount: correctCount,
          questionCount: summary.results.length,
        );

    if (!context.mounted) return;
    context.go(
      AppRoutes.dailySetResult,
      extra: DailySetOutcome(
        results: summary.results,
        correctCount: correctCount,
        completed: completion.completed,
        saveError: completion.saveErrorMessage,
      ),
    );
  }
}
