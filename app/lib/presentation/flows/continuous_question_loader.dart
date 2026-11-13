import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/monitoring/crash_reporter.dart';
import '../providers/chapter_providers.dart';
import 'question_flow.dart';

/// 연속 흐름 이어 받기: 남은 문제 2개 이하면 백그라운드 1회 > 진행 중 요청 공유 > 목록 끝에 덧붙임 (#963)
/// 풀이 화면 State 가 들고, 화면이 닫히면([isMounted] false) 덧붙이지 않음
class ContinuousQuestionLoader {
  ContinuousQuestionLoader({
    required this.flow,
    required this.ref,
    required this.isMounted,
  });

  final QuestionFlow flow;
  final WidgetRef ref;
  final bool Function() isMounted;

  // 남은 문제(현재 문제 뒤)가 이 수 이하면 백그라운드로 이어 받기
  static const int _loadMoreRemainingThreshold = 2;

  // 진행 중인 이어 받기 (미리 받기·마지막 문제 [다음] 공용, 중복 요청 방지)
  Future<void>? _pendingMoreQuestionsLoad;

  // 백그라운드 이어 받기를 요청했던 목록 길이 (같은 길이에서 한 번만, 빈 응답 반복 방지)
  int? _backgroundLoadRequestedQuestionCount;

  /// 이어 받기 1회 (진행 중이면 같은 요청을 기다림). 실패는 예외 그대로 전달
  Future<void> loadMoreQuestions() =>
      _pendingMoreQuestionsLoad ??= _fetchAndAppendMoreQuestions().whenComplete(
        () => _pendingMoreQuestionsLoad = null,
      );

  Future<void> _fetchAndAppendMoreQuestions() async {
    final moreQuestionUuids = await flow.loadMoreQuestionUuids(ref);
    if (!isMounted()) return;
    ref
        .read(chapterProvider(flow.id).notifier)
        .appendQuestionUuids(moreQuestionUuids);
  }

  /// 풀이 진행 구독: 남은 문제가 기준 이하가 되면 백그라운드 이어 받기 (실패는 기록만, 마지막 [다음]에서 다시)
  void listenToLoadMoreWhenRunningLow() {
    ref.listenManual(chapterProvider(flow.id), (_, chapter) {
      if (chapter.isLoadingList ||
          chapter.listError != null ||
          chapter.questionUuids.isEmpty) {
        return;
      }
      final questionCount = chapter.questionUuids.length;
      final remainingCount = questionCount - 1 - chapter.currentIndex;
      if (remainingCount > _loadMoreRemainingThreshold) return;
      if (_backgroundLoadRequestedQuestionCount == questionCount) return;
      _backgroundLoadRequestedQuestionCount = questionCount;
      unawaited(
        loadMoreQuestions().catchError((
          Object exception,
          StackTrace stackTrace,
        ) {
          reportIfUnexpectedFailure(
            exception,
            stackTrace,
            reason: 'chapterPrefetchMore:${flow.id}',
          );
        }),
      );
    });
  }
}
