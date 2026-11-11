import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/monitoring/app_analytics.dart';
import '../../router/app_routes.dart';
import '../providers/chapter_providers.dart';
import '../providers/random_practice_providers.dart';
import 'question_flow.dart';

/// 랜덤 풀기 흐름: 전 범위 문제를 끊김 없이 이어 풀기 > 나가면 이번에 푼 문제 요약 (무료·프로 공통, #576·#963)
class RandomPracticeFlow extends QuestionFlow {
  const RandomPracticeFlow();

  /// 진입 행·카드·앱바 공통 이름과 설명 한 줄
  static const String displayName = '랜덤 풀기';
  static const String summary = '전 범위에서 안 푼 문제부터 골라 풀어요';

  // 분석 이벤트의 토픽 코드 자리 값 (토픽 없이 전 범위)
  static const String _analyticsTopicCode = 'random';

  @override
  String get id => 'random-practice';

  @override
  String get title => displayName;

  @override
  bool get isContinuous => true;

  @override
  Future<List<String>> loadQuestionUuids(WidgetRef ref) =>
      ref.read(randomPracticeServiceProvider).fetchQuestionUuids();

  /// 같은 랜덤 목록 다시 받기 > 지금 목록에 있는 문제 빼기 (서버가 안 푼 문제를 앞에 둠)
  @override
  Future<List<String>> loadMoreQuestionUuids(WidgetRef ref) async {
    // 화면이 닫히면 ref 를 못 쓰므로 받기 전에 지금 목록을 잡아 둠
    final loadedQuestionUuids = ref
        .read(chapterProvider(id))
        .questionUuids
        .toSet();
    final fetchedQuestionUuids = await loadQuestionUuids(ref);
    return fetchedQuestionUuids
        .where((questionUuid) => !loadedQuestionUuids.contains(questionUuid))
        .toList();
  }

  @override
  Future<void> onCompleted(
    BuildContext context,
    WidgetRef ref,
    ChapterSummary summary,
    String sessionUuid,
  ) async {
    ref
        .read(appAnalyticsProvider)
        .logChapterCompleted(
          topicCode: _analyticsTopicCode,
          correctCount: summary.results
              .where((result) => result.isCorrect)
              .length,
          questionCount: summary.results.length,
        );
    // 풀이 화면 자리를 요약으로 교체 (뒤로 가기 > 진입 전 화면)
    context.pushReplacement(AppRoutes.randomPracticeSummary, extra: summary);
  }
}
