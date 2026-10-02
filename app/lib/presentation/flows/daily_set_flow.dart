import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/error/app_exception.dart';
import '../../core/error/error_code.dart';
import '../../core/network/api_providers.dart';
import '../../data/models/daily_set/daily_set_models.dart';
import '../../router/app_routes.dart';
import '../providers/chapter_providers.dart';
import '../providers/daily_set_providers.dart';
import 'question_flow.dart';

/// 데일리 세트 결과 화면에 넘기는 값.
class DailySetOutcome {
  const DailySetOutcome({
    required this.results,
    required this.correctCount,
    this.completed,
    this.saveError,
  });

  /// 문제별 정오답.
  final List<ChapterResult> results;

  /// 이번에 맞힌 개수.
  final int correctCount;

  /// 서버가 돌려준 순위 정보. 점수 등록에 실패했으면 null.
  final DailySetCompleteResponse? completed;

  /// 점수 등록에 실패한 사유. 풀이 결과는 보여주되 순위 반영이 안 됐음을 알린다.
  final String? saveError;
}

/// 오늘의 데일리 세트(전 회원 공통 5문제 안팎)를 푸는 흐름.
class DailySetFlow extends QuestionFlow {
  const DailySetFlow();

  @override
  String get id => 'daily-set';

  @override
  String get title => '오늘의 세트';

  // 한 번의 풀이를 하나의 세션으로 묶어 서버에 알린다.
  @override
  bool get tracksSession => true;

  @override
  Future<List<String>> loadQuestionUuids(WidgetRef ref) async {
    final today = await ref.read(dailySetApiProvider).getToday();
    if (today.alreadyCompleted) {
      throw const AppException(
        code: ErrorCode.dailySetAlreadyCompleted,
        message: '오늘의 세트를 이미 완료했어요.',
      );
    }
    if (today.questions.isEmpty) {
      throw const AppException(
        code: ErrorCode.dailySetNotFound,
        message: '오늘의 세트가 아직 준비되지 않았어요.',
      );
    }
    return today.questions.map((q) => q.questionUuid).toList();
  }

  @override
  Future<void> onCompleted(
    BuildContext context,
    WidgetRef ref,
    ChapterSummary summary,
    String sessionUuid,
  ) async {
    final correct = summary.results.where((r) => r.isCorrect).length;

    DailySetCompleteResponse? completed;
    String? saveError;
    try {
      completed = await ref
          .read(dailySetApiProvider)
          .complete(
            DailySetCompleteRequest(correctCount: correct, sessionUuid: sessionUuid),
          );
    } on DioException catch (e) {
      final error = e.asAppException;
      // 이미 등록된 경우는 결과를 그대로 보여주면 되고, 그 외는 순위 미반영을 알린다.
      if (error.code != ErrorCode.dailySetAlreadyCompleted) {
        saveError = error.message;
      }
    }

    // 순위를 최신으로 맞춘다. 홈 카드(완료 표시)와 학습 현황은 풀이 화면을 벗어날 때
    // ChapterPage 가 한 번에 갱신하므로 여기서 다시 하지 않는다.
    ref
      ..invalidate(dailySetTodayProvider)
      ..invalidate(leaderboardProvider);

    if (!context.mounted) return;
    context.go(
      AppRoutes.dailySetResult,
      extra: DailySetOutcome(
        results: summary.results,
        correctCount: correct,
        completed: completed,
        saveError: saveError,
      ),
    );
  }
}
