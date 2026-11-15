import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/monitoring/app_analytics.dart';
import '../../router/app_routes.dart';
import '../providers/bookmark_providers.dart';
import '../providers/chapter_providers.dart';
import 'question_flow.dart';

/// 즐겨찾기 풀기 흐름 (#1082): 즐겨찾기 문제 무작위 최대 10개 > 같은 풀이 화면 > 챕터 결과
class BookmarkFlow extends QuestionFlow {
  const BookmarkFlow();

  // 분석 이벤트의 토픽 코드 자리 값 (즐겨찾기 풀기)
  static const String _analyticsTopicCode = 'bookmark';

  @override
  String get id => 'bookmark';

  @override
  String get title => '즐겨찾기 풀기';

  @override
  Future<List<String>> loadQuestionUuids(WidgetRef ref) =>
      fetchBookmarkPracticeQuestionUuids(ref);

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
    // 풀이 화면 자리를 결과로 교체 (뒤로 가기 > 즐겨찾기 목록)
    context.pushReplacement(AppRoutes.chapterResult, extra: summary);
  }
}
