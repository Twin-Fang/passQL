import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/monitoring/app_analytics.dart';
import '../../router/app_routes.dart';
import '../providers/chapter_providers.dart';
import '../providers/hardest_question_providers.dart';
import 'question_flow.dart';

/// 오답률 TOP 한 번에 풀기 흐름 (#1080): 순위 순서 최대 30문제 > 같은 풀이 화면 > 챕터 결과
/// 크레딧은 문제 상세 열기의 기존 규칙 그대로
class HardestFlow extends QuestionFlow {
  const HardestFlow();

  // 분석 이벤트의 토픽 코드 자리 값 (오답률 TOP)
  static const String _analyticsTopicCode = 'hardest';

  @override
  String get id => 'hardest';

  @override
  String get title => '오답률 TOP $hardestQuestionLimit';

  @override
  Future<List<String>> loadQuestionUuids(WidgetRef ref) =>
      fetchHardestQuestionUuids(ref);

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
    // 풀이 화면 자리를 결과로 교체 (뒤로 가기 > 오답률 TOP 목록)
    context.pushReplacement(AppRoutes.chapterResult, extra: summary);
  }
}
