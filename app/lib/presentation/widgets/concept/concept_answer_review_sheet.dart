import 'package:flutter/cupertino.dart';

import '../../../data/models/concept/concept_models.dart';
import '../../design/design.dart';
import '../question/markdown_lite_text.dart';
import '../question/stem_text.dart';

/// 결과 화면의 문제 칩을 누르면 뜨는 풀이 시트 (#764): 문제 > 내 답 · 정답 > 풀이 > 이 부분 다시 읽기
/// 다시 읽기를 누르면 시트를 닫고 [onReread] (자세히 칸의 그 문단으로 이동)
Future<void> showConceptAnswerReviewSheet(
  BuildContext context, {
  required int order,
  required ConceptCheckQuestionResponse question,
  required ConceptCheckAnswerResponse result,
  required String? selectedKey,
  required String? rereadLabel,
  required VoidCallback onReread,
}) {
  return showPassqlSheet<void>(
    context,
    builder: (sheetContext) => _ConceptAnswerReviewBody(
      order: order,
      question: question,
      result: result,
      selectedKey: selectedKey,
      rereadLabel: rereadLabel,
      onReread: () {
        Navigator.of(sheetContext).pop();
        onReread();
      },
    ),
  );
}

class _ConceptAnswerReviewBody extends StatelessWidget {
  const _ConceptAnswerReviewBody({
    required this.order,
    required this.question,
    required this.result,
    required this.selectedKey,
    required this.rereadLabel,
    required this.onReread,
  });

  final int order;
  final ConceptCheckQuestionResponse question;
  final ConceptCheckAnswerResponse result;
  final String? selectedKey;
  final String? rereadLabel;
  final VoidCallback onReread;

  String? _bodyOf(String? choiceKey) => question.choices
      .where((choice) => choice.choiceKey == choiceKey)
      .firstOrNull
      ?.body;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final selectedKeyValue = selectedKey;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        0,
        PassqlSpacing.md,
        PassqlSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '문제 $order',
            style: PassqlTypography.footnoteSemibold.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: PassqlSpacing.xxs),
          StemText(question.stem),
          if (question.stemSql != null) ...[
            const SizedBox(height: PassqlSpacing.sm),
            PassqlCodeBlock(code: question.stemSql!),
          ],
          const SizedBox(height: PassqlSpacing.md),
          if (!result.isCorrect && selectedKeyValue != null) ...[
            _AnswerLine(
              label: '내 답 $selectedKeyValue',
              body: _bodyOf(selectedKeyValue) ?? '',
              isCorrect: false,
            ),
            const SizedBox(height: PassqlSpacing.xs),
          ],
          _AnswerLine(
            label: '정답 ${result.correctKey}',
            body: _bodyOf(result.correctKey) ?? '',
            isCorrect: true,
          ),
          const SizedBox(height: PassqlSpacing.md),
          MarkdownLiteText(
            result.explanation,
            style: MarkdownLiteStyle.article,
          ),
          if (result.rereadAnchor.isNotEmpty) ...[
            const SizedBox(height: PassqlSpacing.md),
            PassqlButton(
              label: rereadLabel == null
                  ? '이 부분 다시 읽기'
                  : '이 부분 다시 읽기 · $rereadLabel',
              icon: CupertinoIcons.book,
              variant: PassqlButtonVariant.tinted,
              size: PassqlButtonSize.regular,
              onPressed: onReread,
            ),
          ],
        ],
      ),
    );
  }
}

/// 내 답(빨강 바탕) · 정답(초록 바탕) 한 줄
class _AnswerLine extends StatelessWidget {
  const _AnswerLine({
    required this.label,
    required this.body,
    required this.isCorrect,
  });

  final String label;
  final String body;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.sm,
        vertical: PassqlSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isCorrect ? colors.correctTint : colors.wrongTint,
        borderRadius: BorderRadius.circular(PassqlRadius.md),
      ),
      child: Text.rich(
        TextSpan(
          style: PassqlTypography.subheadline.copyWith(color: colors.label),
          children: [
            TextSpan(
              text: '$label  ',
              style: PassqlTypography.subheadlineSemibold.copyWith(
                color: isCorrect ? colors.correctText : colors.wrongText,
              ),
            ),
            TextSpan(text: body),
          ],
        ),
      ),
    );
  }
}
