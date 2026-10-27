import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/monitoring/app_analytics.dart';
import '../../router/app_routes.dart';
import '../providers/chapter_providers.dart';
import '../providers/concept_providers.dart';
import 'question_flow.dart';

/// 개념 관련 문제 흐름 (#577): 개념 상세의 관련 문제 최대 10개 > 같은 풀이 화면 > 챕터 결과
class ConceptRelatedFlow extends QuestionFlow {
  const ConceptRelatedFlow({
    required this.conceptUuid,
    required this.conceptTitle,
  });

  // 한 번에 푸는 관련 문제 수 (챕터 10문제와 같은 길이)
  static const int maximumQuestionCount = 10;

  // 분석 이벤트의 토픽 코드 자리 값 (개념 관련 문제)
  static const String _analyticsTopicCode = 'concept_related';

  final String conceptUuid;
  final String conceptTitle;

  @override
  String get id => 'concept-related:$conceptUuid';

  @override
  String get title => '$conceptTitle 관련 문제';

  @override
  Future<List<String>> loadQuestionUuids(WidgetRef ref) async {
    final detail = await ref.read(conceptDetailProvider(conceptUuid).future);
    return detail.relatedQuestionUuids.take(maximumQuestionCount).toList();
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
    // 풀이 화면 자리를 결과로 교체 (뒤로 가기 > 개념 화면)
    context.pushReplacement(AppRoutes.chapterResult, extra: summary);
  }
}
