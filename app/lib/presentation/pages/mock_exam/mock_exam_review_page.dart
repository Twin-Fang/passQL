import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../data/models/mock_exam/mock_exam_result.dart';
import '../../../data/models/mock_exam/mock_exam_sheet.dart';
import '../../design/design.dart';
import '../../providers/mock_exam_providers.dart';
import '../../widgets/question/choice_display_label.dart';
import '../../widgets/mock_exam/mock_exam_question_view.dart';

/// 모의고사 문항 해설 (#866, 프로): 내 답·정답 표시 보기 > 보기별 근거 > 요약 해설, 이전·다음 / 오답만 보기
/// 결과 화면과 같은 결과 응답을 씀 (저장된 해설만, AI 호출 없음)
class MockExamReviewPage extends ConsumerStatefulWidget {
  const MockExamReviewPage({
    super.key,
    required this.attemptUuid,
    required this.initialQuestionNumber,
  });

  final String attemptUuid;
  final int initialQuestionNumber;

  @override
  ConsumerState<MockExamReviewPage> createState() => _MockExamReviewPageState();
}

class _MockExamReviewPageState extends ConsumerState<MockExamReviewPage> {
  late int _questionNumber = widget.initialQuestionNumber;
  bool _isWrongOnly = false;

  @override
  Widget build(BuildContext context) {
    final resultAsync = ref.watch(mockExamResultProvider(widget.attemptUuid));
    return Scaffold(
      appBar: PassqlNavBar(
        title: '$_questionNumber번 해설',
        leading: PassqlNavLeading.back,
      ),
      body: SafeArea(
        child: resultAsync.when(
          loading: () => const PassqlStatusView.loading(),
          error: (error, _) => PassqlStatusView.error(
            message: error.asAppException.message,
            onRetry: () =>
                ref.invalidate(mockExamResultProvider(widget.attemptUuid)),
          ),
          data: _buildBody,
        ),
      ),
    );
  }

  Widget _buildBody(MockExamResultResponse result) {
    final reviews = _isWrongOnly
        ? result.reviews.where((review) => !review.isCorrect).toList()
        : result.reviews;
    if (reviews.isEmpty) {
      return PassqlStatusView.empty(
        icon: CupertinoIcons.checkmark_seal,
        title: '틀린 문항이 없어요',
      );
    }
    final currentIndex = reviews.indexWhere(
      (review) => review.questionNumber == _questionNumber,
    );
    final review = reviews[currentIndex < 0 ? 0 : currentIndex];
    final reviewIndex = reviews.indexOf(review);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            PassqlSpacing.md,
            PassqlSpacing.xs,
            PassqlSpacing.md,
            0,
          ),
          child: PassqlSegmentedControl<bool>(
            segments: const [
              PassqlSegment(value: false, label: '전체'),
              PassqlSegment(value: true, label: '틀린 문항'),
            ],
            selectedValue: _isWrongOnly,
            onSelected: (isWrongOnly) =>
                setState(() => _isWrongOnly = isWrongOnly),
          ),
        ),
        Expanded(
          child: PassqlPageSlideSwitcher(
            child: SingleChildScrollView(
              key: ValueKey(review.questionNumber),
              padding: const EdgeInsets.only(bottom: PassqlSpacing.xl),
              child: MockExamQuestionView(
                questionNumber: review.questionNumber,
                subject: review.subject,
                topicName: review.topicName,
                stem: review.stem,
                schemaTables: review.schemaTables,
                choices: review.choices,
                choiceStateOf: (choice) => _choiceStateOf(choice, review),
                footer: _ReviewExplanation(review: review),
              ),
            ),
          ),
        ),
        PassqlBottomActionBar(
          actions: [
            Row(
              children: [
                Expanded(
                  child: PassqlButton(
                    label: '이전',
                    variant: PassqlButtonVariant.tinted,
                    size: PassqlButtonSize.regular,
                    onPressed: reviewIndex == 0
                        ? null
                        : () => setState(
                            () => _questionNumber =
                                reviews[reviewIndex - 1].questionNumber,
                          ),
                  ),
                ),
                const SizedBox(width: PassqlSpacing.sm),
                Expanded(
                  child: PassqlButton(
                    label: '다음',
                    size: PassqlButtonSize.regular,
                    onPressed: reviewIndex == reviews.length - 1
                        ? null
                        : () => setState(
                            () => _questionNumber =
                                reviews[reviewIndex + 1].questionNumber,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// 정답 보기 초록, 내가 고른 오답 빨강, 나머지 흐림
  static PassqlChoiceState _choiceStateOf(
    MockExamChoice choice,
    MockExamQuestionReview review,
  ) {
    if (choice.key == review.correctChoiceKey) return PassqlChoiceState.correct;
    if (choice.key == review.selectedChoiceKey) return PassqlChoiceState.wrong;
    return PassqlChoiceState.dimmed;
  }
}

/// 보기 아래 해설: 내 답 한 줄 > 보기별 근거 > 요약 해설
class _ReviewExplanation extends StatelessWidget {
  const _ReviewExplanation({required this.review});

  final MockExamQuestionReview review;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final labelByKey = choiceDisplayLabelsOf(
      review.choices.map((choice) => choice.toChoiceItem()).toList(),
    );
    final selectedLabel = review.selectedChoiceKey == null
        ? null
        : labelByKey[review.selectedChoiceKey];
    final verdict = selectedLabel == null
        ? '안 푼 문항이에요. 정답은 ${labelByKey[review.correctChoiceKey]}'
        : review.isCorrect
        ? '$selectedLabel 정답이에요'
        : '$selectedLabel 오답, 정답은 ${labelByKey[review.correctChoiceKey]}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.md,
        PassqlSpacing.md,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            verdict,
            style: PassqlTypography.headline.copyWith(
              color: review.isCorrect ? colors.correctText : colors.wrongText,
            ),
          ),
          const SizedBox(height: PassqlSpacing.sm),
          for (final choice in review.choices)
            if (choice.rationale != null && choice.rationale!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: PassqlSpacing.xs),
                child: Text(
                  '${labelByKey[choice.key]}  ${choice.rationale}',
                  style: PassqlTypography.subheadline.copyWith(
                    color: colors.label,
                  ),
                ),
              ),
          if (review.explanationSummary != null &&
              review.explanationSummary!.isNotEmpty) ...[
            const SizedBox(height: PassqlSpacing.sm),
            PassqlCallout(
              kind: PassqlCalloutKind.accent,
              label: '핵심 정리',
              child: Text(review.explanationSummary!),
            ),
          ],
        ],
      ),
    );
  }
}
