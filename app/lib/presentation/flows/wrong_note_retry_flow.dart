import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/mock_exam/mock_exam_enums.dart';
import '../providers/chapter_providers.dart';
import '../providers/wrong_questions_provider.dart';
import '../widgets/common/app_toast.dart';
import 'question_flow.dart';

/// 오답 다시 풀기 흐름 (#1081): 정리 안 된 오답 많이 틀린 순 최대 10문제 > 같은 풀이 화면 > 오답 노트로 복귀
/// 다시 맞힌 문제는 최신 제출이 정답이라 오답 노트 기본 목록에서 빠짐
class WrongNoteRetryFlow extends QuestionFlow {
  const WrongNoteRetryFlow({this.subject});

  /// 과목 필터 (null 이면 전체, 오답 노트 화면 세그먼트 값)
  final MockExamSubject? subject;

  @override
  String get id => 'wrong-note-retry';

  @override
  String get title => '오답 다시 풀기';

  @override
  Future<List<String>> loadQuestionUuids(WidgetRef ref) =>
      fetchWrongNoteRetryQuestionUuids(ref, subject);

  @override
  Future<void> onCompleted(
    BuildContext context,
    WidgetRef ref,
    ChapterSummary summary,
    String sessionUuid,
  ) async {
    // 오답 노트 목록·개수 다시 받기 (다시 맞힌 문제 빠짐)
    ref.invalidate(wrongQuestionsProvider);
    ref.invalidate(wrongQuestionTotalCountProvider);
    if (!context.mounted) return;
    final correctCount = summary.results
        .where((result) => result.isCorrect)
        .length;
    showAppToast(
      context,
      '${summary.results.length}문제 중 $correctCount문제를 다시 맞혔어요',
    );
    // 오답 노트 위에 쌓인 풀이 화면만 닫음 (완료 잠금 창이 닫힌 뒤 이벤트 큐 다음 차례에)
    final router = GoRouter.of(context);
    Future(router.pop);
  }
}
