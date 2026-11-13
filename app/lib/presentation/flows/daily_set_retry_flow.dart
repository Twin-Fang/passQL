import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/chapter_providers.dart';
import '../providers/daily_set_retry_providers.dart';
import 'question_flow.dart';

/// 오늘의 세트 틀린 문제 다시 풀기 흐름 (#1035): 세트 결과의 오답 N문제 > 같은 풀이 화면 > 세트 결과로 복귀
/// 세트 점수·순위·보너스는 그대로, 맞힌 문제만 결과 화면에 표시
class DailySetRetryFlow extends QuestionFlow {
  const DailySetRetryFlow({required this.questionUuids});

  /// 다시 풀 문제 uuid (세트 결과의 오답 순서)
  final List<String> questionUuids;

  // 세트 풀이(daily-set)와 진행 상태를 섞지 않음
  @override
  String get id => 'daily-set-retry';

  @override
  String get title => '틀린 문제 다시 풀기';

  @override
  Future<List<String>> loadQuestionUuids(WidgetRef ref) async => questionUuids;

  @override
  Future<void> onCompleted(
    BuildContext context,
    WidgetRef ref,
    ChapterSummary summary,
    String sessionUuid,
  ) async {
    ref.read(dailySetRetryProvider.notifier).recordResults({
      for (final result in summary.results)
        result.questionUuid: result.isCorrect,
    });
    // 세트 결과 위에 쌓인 풀이 화면만 닫음 (결과 화면이 맞힘 표시로 갱신)
    // 완료 잠금 창이 닫힌 뒤(이벤트 큐 다음 차례)에 닫아야 잠금 창 대신 풀이 화면이 닫힘
    if (!context.mounted) return;
    final router = GoRouter.of(context);
    Future(router.pop);
  }
}
