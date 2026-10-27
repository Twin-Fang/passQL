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
  const DailySetFlow({this.isOnboarding = false});

  // 같은 세트라 진행 상태(id)는 일반 진입과 공유하고, 배지·축하 화면만 다르게 보인다.
  @override
  final bool isOnboarding;

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

  // 풀다 만 세트는 이미 푼 문제 다음부터 (#566)
  @override
  Future<ChapterStart> loadStart(WidgetRef ref) =>
      ref.read(dailySetServiceProvider).fetchTodayStart();

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
    // 시작 화면을 스택에 남기려고 세트 화면 자리를 결과로 교체
    context.pushReplacement(
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
