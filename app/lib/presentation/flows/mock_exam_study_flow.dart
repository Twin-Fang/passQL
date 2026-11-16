import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/mock_exam/mock_exam_study_progress_store.dart';
import '../../core/monitoring/app_analytics.dart';
import '../../router/app_routes.dart';
import '../providers/chapter_providers.dart';
import '../providers/mock_exam_providers.dart';
import 'question_flow.dart';

/// 모의고사 학습 모드 흐름 (#1084): 회차 50문항 시험 번호 순서 > 같은 풀이 화면(바로 채점·해설·실행 결과 비교) > 챕터 결과
/// 진도는 기기 저장 (문항마다), 50문항 끝내면 완료 표시 후 다음엔 처음부터. 크레딧은 문제 상세 기존 규칙
class MockExamStudyFlow extends QuestionFlow {
  const MockExamStudyFlow({required this.roundUuid, required this.roundTitle});

  final String roundUuid;
  final String roundTitle;

  // 분석 이벤트의 토픽 코드 자리 값 (모의고사 학습 모드)
  static const String _analyticsTopicCode = 'mockExamStudy';

  @override
  String get id => 'mockExamStudy:$roundUuid';

  @override
  String get title => '$roundTitle 학습';

  @override
  Future<List<String>> loadQuestionUuids(WidgetRef ref) =>
      fetchMockExamStudyQuestionUuids(ref, roundUuid);

  /// 이어 풀기: 기기 진도만큼 앞 문항을 푼 것으로 시작 (마지막 문항은 다시 풀 수 있게 제외)
  @override
  Future<ChapterStart> loadStart(WidgetRef ref) async {
    final questionUuids = await loadQuestionUuids(ref);
    final savedCorrectness = await MockExamStudyProgressStore.readCorrectness(
      roundUuid,
    );
    final resumableCount = savedCorrectness.length.clamp(
      0,
      questionUuids.isEmpty ? 0 : questionUuids.length - 1,
    );
    return ChapterStart(
      questionUuids: questionUuids,
      resumedCorrectness: savedCorrectness.take(resumableCount).toList(),
    );
  }

  @override
  Future<void> onQuestionAnswered(WidgetRef ref, List<bool> correctness) =>
      MockExamStudyProgressStore.saveCorrectness(roundUuid, correctness);

  @override
  Future<void> onCompleted(
    BuildContext context,
    WidgetRef ref,
    ChapterSummary summary,
    String sessionUuid,
  ) async {
    await MockExamStudyProgressStore.markCompleted(roundUuid);
    ref
        .read(appAnalyticsProvider)
        .logChapterCompleted(
          topicCode: _analyticsTopicCode,
          correctCount: summary.results
              .where((result) => result.isCorrect)
              .length,
          questionCount: summary.results.length,
        );
    if (!context.mounted) return;
    // 풀이 화면 자리를 결과로 교체 (뒤로 가기 > 시험 안내)
    context.pushReplacement(AppRoutes.chapterResult, extra: summary);
  }
}
