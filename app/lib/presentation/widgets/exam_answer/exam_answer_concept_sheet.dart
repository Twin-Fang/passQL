import 'package:flutter/cupertino.dart';

import '../../../data/models/exam_answer/exam_answer_round_response.dart';
import '../../design/design.dart';
import 'exam_answer_concept_links.dart';

/// 틀린 문항 복습 시트: 문항 번호·내 답·정답 > 출제 개념·태그 > 메모 > 개념 학습·문제 풀기
Future<void> showExamAnswerConceptSheet(
  BuildContext context, {
  required ExamAnswerItemResponse item,
  required int myAnswer,
}) => showPassqlSheet<void>(
  context,
  title: '${item.questionNo}번 복습',
  builder: (_) => _ConceptSheetBody(item: item, myAnswer: myAnswer),
);

class _ConceptSheetBody extends StatelessWidget {
  const _ConceptSheetBody({required this.item, required this.myAnswer});

  final ExamAnswerItemResponse item;
  final int myAnswer;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final note = item.note;
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
          // 내 답(오답 빨강) | 가답안
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: myAnswer == 0 ? '내 답 모름' : '내 답 $myAnswer번',
                  style: PassqlTypography.subheadlineSemibold.copyWith(
                    color: colors.wrongText,
                  ),
                ),
                if (item.answer != null)
                  TextSpan(
                    text: ' | 가답안 ${item.answer}번',
                    style: PassqlTypography.subheadline.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: PassqlSpacing.lg),
          Text(
            '출제 개념',
            style: PassqlTypography.footnoteSemibold.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: PassqlSpacing.xxs),
          Text(
            (item.conceptTitle?.isNotEmpty ?? false)
                ? item.conceptTitle!
                : '개념 정리 중이에요',
            style: PassqlTypography.headline.copyWith(color: colors.label),
          ),
          if (item.conceptTags.isNotEmpty) ...[
            const SizedBox(height: PassqlSpacing.xxs),
            Text(
              item.conceptTags.join(', '),
              style: PassqlTypography.footnote.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ],
          if (note != null && note.trim().isNotEmpty) ...[
            const SizedBox(height: PassqlSpacing.md),
            PassqlCallout(
              kind: PassqlCalloutKind.warning,
              icon: CupertinoIcons.exclamationmark_bubble_fill,
              label: '메모',
              child: Text(
                note.trim(),
                style: PassqlTypography.subheadline.copyWith(
                  color: colors.label,
                ),
              ),
            ),
          ],
          const SizedBox(height: PassqlSpacing.sm),
          ExamAnswerConceptLinks(topicCode: item.topicCode, isInSheet: true),
        ],
      ),
    );
  }
}
