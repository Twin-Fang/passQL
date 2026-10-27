import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../data/models/concept/concept_models.dart';
import '../../design/design.dart';
import '../../providers/concept_providers.dart';
import '../common/app_toast.dart';
import '../question/markdown_lite_text.dart';
import '../question/stem_text.dart';

/// 개념 풀기 화면: 문제 n/5 > 지문·SQL > 보기 > (채점 후) 정답 표시·풀이·다시 읽기 > 하단 확인·다음
/// 마지막 문제 다음은 결과(점수 고리 + 관련 문제 더 풀기 + 다시 풀기·다음 개념)
class ConceptSolveView extends ConsumerWidget {
  const ConceptSolveView({
    super.key,
    required this.conceptUuid,
    required this.finishLabel,
    required this.onFinished,
    this.relatedQuestionCount = 0,
    this.onRelatedQuestionsPressed,
  });

  final String conceptUuid;

  /// 결과 화면 "관련 문제 더 풀기" 문제 수 (0이면 버튼 숨김)
  final int relatedQuestionCount;

  /// 결과 화면 "관련 문제 더 풀기" (기존 문제 풀이 화면으로)
  final VoidCallback? onRelatedQuestionsPressed;

  /// 결과 화면 다음 버튼 글자 (다음 개념 또는 단원으로)
  final String finishLabel;

  /// 결과 화면의 다음 버튼 (다음 개념 또는 단원으로)
  final VoidCallback onFinished;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = ref.watch(conceptCheckQuestionsProvider(conceptUuid));
    return questions.when(
      loading: () => const PassqlStatusView.loading(),
      error: (_, _) => PassqlStatusView.error(
        message: '확인 문제를 불러오지 못했어요.',
        onRetry: () =>
            ref.invalidate(conceptCheckQuestionsProvider(conceptUuid)),
      ),
      data: (loadedQuestions) {
        if (loadedQuestions.isEmpty) {
          return PassqlStatusView.empty(
            icon: CupertinoIcons.square_list,
            title: '아직 확인 문제가 없어요',
            message: '읽기로 개념을 먼저 정리해 보세요.',
          );
        }
        final study = ref.watch(conceptStudyProvider(conceptUuid));
        if (study.questionIndex >= loadedQuestions.length) {
          return _SolveResult(
            correctCount: study.correctCount,
            total: loadedQuestions.length,
            onRestart: ref
                .read(conceptStudyProvider(conceptUuid).notifier)
                .restartQuiz,
            finishLabel: finishLabel,
            onFinished: onFinished,
            relatedQuestionCount: relatedQuestionCount,
            onRelatedQuestionsPressed: onRelatedQuestionsPressed,
          );
        }
        return _QuestionStep(
          conceptUuid: conceptUuid,
          question: loadedQuestions[study.questionIndex],
          order: study.questionIndex + 1,
          total: loadedQuestions.length,
        );
      },
    );
  }
}

/// 문제 한 개: 위 진행 막대·순번 > 지문 > 보기 > 채점 결과 > 하단 버튼
class _QuestionStep extends ConsumerWidget {
  const _QuestionStep({
    required this.conceptUuid,
    required this.question,
    required this.order,
    required this.total,
  });

  final String conceptUuid;
  final ConceptCheckQuestionResponse question;
  final int order;
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final study = ref.watch(conceptStudyProvider(conceptUuid));
    final notifier = ref.read(conceptStudyProvider(conceptUuid).notifier);
    final selectedKey = study.selectedKeyByQuestion[question.questionUuid];
    final result = study.resultByQuestion[question.questionUuid];
    final isLastQuestion = order == total;

    Future<void> submit() async {
      try {
        await notifier.submit(question.questionUuid);
      } catch (error) {
        if (!context.mounted) return;
        final message = error is AppException
            ? error.message
            : '채점하지 못했어요. 다시 시도해 주세요.';
        showAppToast(context, message);
      }
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              PassqlSpacing.lg,
              PassqlSpacing.sm,
              PassqlSpacing.lg,
              PassqlSpacing.xxl,
            ),
            children: [
              PassqlProgressBar(
                value: order / total,
                semanticValue: '문제 $order / $total',
              ),
              const SizedBox(height: PassqlSpacing.sm),
              Text(
                '문제 $order / $total',
                style: PassqlTypography.footnoteSemibold.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
              const SizedBox(height: PassqlSpacing.sm),
              StemText(question.stem),
              if (question.stemSql != null) ...[
                const SizedBox(height: PassqlSpacing.sm),
                PassqlCodeBlock(code: question.stemSql!),
              ],
              const SizedBox(height: PassqlSpacing.lg),
              for (final choice in question.choices) ...[
                PassqlChoiceCard(
                  keyLabel: choice.choiceKey,
                  state: _choiceStateOf(choice.choiceKey, selectedKey, result),
                  onTap: result == null
                      ? () => notifier.selectChoice(
                          question.questionUuid,
                          choice.choiceKey,
                        )
                      : null,
                  child: Text(
                    choice.body,
                    style: PassqlTypography.body.copyWith(color: colors.label),
                  ),
                ),
                const SizedBox(height: PassqlSpacing.sm),
              ],
              if (result != null) ...[
                const SizedBox(height: PassqlSpacing.sm),
                _AnswerExplanation(
                  result: result,
                  selectedKey: selectedKey,
                  onReread: () => notifier.rereadSection(result.rereadAnchor),
                ),
              ],
            ],
          ),
        ),
        PassqlBottomActionBar(
          actions: [
            if (result == null)
              PassqlButton(
                label: '확인',
                isLoading: study.isSubmitting,
                onPressed: selectedKey == null || study.isSubmitting
                    ? null
                    : submit,
              )
            else
              PassqlButton(
                label: isLastQuestion ? '결과 보기' : '다음 문제',
                onPressed: notifier.goToNextQuestion,
              ),
          ],
        ),
      ],
    );
  }

  /// 보기 상태: 채점 전 고름 여부, 채점 후 정답(초록)·내 오답(빨강)·나머지 흐림
  static PassqlChoiceState _choiceStateOf(
    String choiceKey,
    String? selectedKey,
    ConceptCheckAnswerResponse? result,
  ) {
    if (result == null) {
      return choiceKey == selectedKey
          ? PassqlChoiceState.selected
          : PassqlChoiceState.idle;
    }
    if (choiceKey == result.correctKey) return PassqlChoiceState.correct;
    if (choiceKey == selectedKey) return PassqlChoiceState.wrong;
    return PassqlChoiceState.dimmed;
  }
}

/// 채점 뒤 풀이 카드: 정답 표시 > 풀이 > 내가 고른 보기 근거 > 다시 읽기(틀렸을 때 강조)
class _AnswerExplanation extends StatelessWidget {
  const _AnswerExplanation({
    required this.result,
    required this.selectedKey,
    required this.onReread,
  });

  final ConceptCheckAnswerResponse result;
  final String? selectedKey;
  final VoidCallback onReread;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final selectedRationale = selectedKey == null
        ? null
        : result.rationaleByChoiceKey[selectedKey];
    return PassqlCard(
      padding: const EdgeInsets.all(PassqlSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: PassqlResultMark(
              isCorrect: result.isCorrect,
              label: result.isCorrect ? '맞았어요' : '정답은 ${result.correctKey}예요',
            ),
          ),
          const SizedBox(height: PassqlSpacing.sm),
          MarkdownLiteText(
            result.explanation,
            style: MarkdownLiteStyle.article,
          ),
          if (!result.isCorrect &&
              selectedRationale != null &&
              selectedRationale.isNotEmpty) ...[
            const SizedBox(height: PassqlSpacing.sm),
            Text(
              '내가 고른 $selectedKey: $selectedRationale',
              style: PassqlTypography.subheadline.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ],
          if (result.rereadAnchor.isNotEmpty) ...[
            const SizedBox(height: PassqlSpacing.md),
            PassqlButton(
              label: '이 부분 다시 읽기',
              icon: CupertinoIcons.book,
              variant: result.isCorrect
                  ? PassqlButtonVariant.plain
                  : PassqlButtonVariant.tinted,
              size: PassqlButtonSize.regular,
              onPressed: onReread,
            ),
          ],
        ],
      ),
    );
  }
}

/// 결과: 점수 고리 > 한 줄 > 관련 문제 더 풀기(있을 때) > 다시 풀기·다음
class _SolveResult extends StatelessWidget {
  const _SolveResult({
    required this.correctCount,
    required this.total,
    required this.onRestart,
    required this.finishLabel,
    required this.onFinished,
    required this.relatedQuestionCount,
    required this.onRelatedQuestionsPressed,
  });

  final int correctCount;
  final int total;
  final VoidCallback onRestart;
  final String finishLabel;
  final VoidCallback onFinished;
  final int relatedQuestionCount;
  final VoidCallback? onRelatedQuestionsPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final isPerfect = correctCount == total;
    final hasRelatedQuestions =
        relatedQuestionCount > 0 && onRelatedQuestionsPressed != null;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(PassqlSpacing.lg),
            children: [
              const SizedBox(height: PassqlSpacing.xl),
              Center(
                child: PassqlScoreHeader(score: correctCount, total: total),
              ),
              const SizedBox(height: PassqlSpacing.lg),
              Text(
                '$total문제 중 $correctCount문제를 맞혔어요',
                textAlign: TextAlign.center,
                style: PassqlTypography.title3.copyWith(color: colors.label),
              ),
              const SizedBox(height: PassqlSpacing.xs),
              Text(
                isPerfect
                    ? '이 개념은 확실히 잡았어요. 다음 개념으로 넘어가도 좋아요.'
                    : '틀린 문제의 풀이에서 "이 부분 다시 읽기"를 눌러 헷갈린 부분만 다시 보고 오면 돼요.',
                textAlign: TextAlign.center,
                style: PassqlTypography.subheadline.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
              // 강조 버튼은 하단 하나만: 관련 문제는 보조(plain) 버튼
              if (hasRelatedQuestions) ...[
                const SizedBox(height: PassqlSpacing.lg),
                Center(
                  child: PassqlButton(
                    label: '실전 문제 $relatedQuestionCount개 더 풀기',
                    variant: PassqlButtonVariant.plain,
                    size: PassqlButtonSize.regular,
                    onPressed: onRelatedQuestionsPressed,
                  ),
                ),
              ],
            ],
          ),
        ),
        PassqlBottomActionBar(
          actions: [
            PassqlButton(
              label: '다시 풀기',
              variant: PassqlButtonVariant.tinted,
              onPressed: onRestart,
            ),
            PassqlButton(label: finishLabel, onPressed: onFinished),
          ],
        ),
      ],
    );
  }
}
