import 'package:flutter/cupertino.dart';

import '../../../data/models/exam_answer/exam_answer_round_response.dart';
import '../../design/design.dart';
import 'exam_answer_concept_links.dart';

/// 틀린 문항 복습 시트: 문항 번호·내 답·정답 > 출제 개념·태그 > 메모 > 개념 학습·문제 풀기
Future<void> showExamAnswerConceptSheet(
  BuildContext context, {
  required ExamAnswerItem item,
  required int myAnswer,
}) => showPassqlSheet<void>(
  context,
  title: '${item.questionNo}번 복습',
  builder: (_) => _ConceptSheetBody(item: item, myAnswer: myAnswer),
);

class _ConceptSheetBody extends StatelessWidget {
  const _ConceptSheetBody({required this.item, required this.myAnswer});

  final ExamAnswerItem item;
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
          Wrap(
            spacing: PassqlSpacing.xs,
            alignment: WrapAlignment.center,
            children: [
              PassqlBadge(
                text: myAnswer == 0 ? '내 답 모름' : '내 답 $myAnswer번',
                kind: PassqlBadgeKind.important,
              ),
              if (item.answer != null)
                PassqlBadge(
                  text: '가답안 ${item.answer}번',
                  kind: PassqlBadgeKind.success,
                ),
            ],
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
            item.conceptTitle.isEmpty ? '개념 정리 중이에요' : item.conceptTitle,
            style: PassqlTypography.headline.copyWith(color: colors.label),
          ),
          if (item.conceptTags.isNotEmpty) ...[
            const SizedBox(height: PassqlSpacing.xs),
            Wrap(
              spacing: PassqlSpacing.xxs,
              runSpacing: PassqlSpacing.xxs,
              children: [
                for (final tag in item.conceptTags)
                  PassqlBadge(text: tag, kind: PassqlBadgeKind.neutral),
              ],
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
          const SizedBox(height: PassqlSpacing.lg),
          ExamAnswerConceptLinks(topicCode: item.topicCode, isInSheet: true),
        ],
      ),
    );
  }
}
