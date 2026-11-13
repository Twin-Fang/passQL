import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../data/models/question/question_detail.dart';
import '../../design/design.dart';
import '../../providers/chapter_providers.dart';
import '../../providers/question_providers.dart';
import '../ai_explanation/ai_explanation_dock.dart';
import '../question/question_load_error_view.dart';
import '../question/question_solving_body.dart';
import '../question/question_solving_skeleton.dart';

/// 문제 풀이 화면 본문: 해설 시트 자리 > 메모 > 문제 교체 슬라이드 > 상세 상태(로딩·오류·한도·풀이)
/// 상태 판단·안내(프로 접근·선택지 준비)는 화면이 넘긴 콜백이 맡음
class ChapterQuestionBody extends StatelessWidget {
  const ChapterQuestionBody({
    super.key,
    required this.questionUuid,
    required this.detailAsync,
    required this.interaction,
    required this.interactionNotifier,
    required this.chapter,
    required this.memoController,
    required this.choiceLimitFailure,
    required this.shouldShowFirstQuestionBadge,
    required this.onDetailError,
    required this.onDetailLoaded,
    required this.onRetryDetail,
  });

  final String questionUuid;
  final AsyncValue<QuestionDetail> detailAsync;
  final QuestionInteractionState interaction;
  final QuestionInteractionNotifier interactionNotifier;
  final ChapterState chapter;

  /// 문제별 메모 (#904)
  final PassqlMemoController memoController;

  /// 선택지 받기가 하루 한도로 막힘 > 본문은 한도 화면
  final AppException? choiceLimitFailure;

  /// 온보딩 첫 문제 배지 표시 여부
  final bool shouldShowFirstQuestionBadge;

  /// 상세 받기 오류 (프로 접근 1회 안내)
  final ValueChanged<Object> onDetailError;

  /// 상세 받음 (선택지 준비 1회 요청)
  final ValueChanged<QuestionDetail> onDetailLoaded;
  final VoidCallback onRetryDetail;

  @override
  Widget build(BuildContext context) {
    final limitFailure = choiceLimitFailure;
    // 문제 교체: 옆으로 미끄러지며 바뀜 (문제마다 key), 같은 문제 안 로딩 > 내용은 페이드
    // 해설 시트는 본문 위에 떠서 하단 바를 가리지 않음 (다음 문제로 넘어가면 닫히고 해설함에서 다시 열 수 있음)
    return AiExplanationDock(
      // 메모: 펜 버튼으로 켜고 끔, 끄면 터치는 전부 문제로 (#904). 해설 시트는 메모 위에 뜸
      child: PassqlMemoScope(
        controller: memoController,
        activePageKey: questionUuid,
        child: PassqlPageSlideSwitcher(
          child: KeyedSubtree(
            key: ValueKey(questionUuid),
            child: PassqlFadeSwitcher(
              child: detailAsync.when(
                loading: () =>
                    const QuestionSolvingSkeleton(key: ValueKey('loading')),
                error: (error, _) {
                  onDetailError(error);
                  return KeyedSubtree(
                    key: const ValueKey('error'),
                    child: QuestionLoadErrorView(
                      error: error,
                      onRetry: onRetryDetail,
                    ),
                  );
                },
                data: (question) {
                  onDetailLoaded(question);
                  if (limitFailure != null) {
                    return QuestionLoadErrorView(
                      key: const ValueKey('limit'),
                      error: limitFailure,
                      onRetry: interactionNotifier.startSseGeneration,
                    );
                  }
                  // Scaffold 안쪽 context 여야 extendBody 가 더한 하단 바 높이를 읽는다.
                  return Builder(
                    key: const ValueKey('data'),
                    builder: (context) => QuestionSolvingBody(
                      questionUuid: questionUuid,
                      question: question,
                      interaction: interaction,
                      notifier: interactionNotifier,
                      // 제출 후에는 정답/오답을 선택지에 표시한다.
                      submitResult: chapter.isAnswered
                          ? chapter.lastSubmitResult
                          : null,
                      gradedSelectedKey: chapter.lastSelectedKey,
                      // 재시도가 소용없는 오류여도 다시 눌러 볼 수 있게 두어 막다른 길을 만들지 않는다.
                      shouldAlwaysAllowRetry: true,
                      topBadge: shouldShowFirstQuestionBadge
                          ? const PassqlBadge(text: '첫 문제')
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
