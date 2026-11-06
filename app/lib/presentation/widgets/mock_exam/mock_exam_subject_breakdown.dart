import 'package:flutter/cupertino.dart';

import '../../../data/models/mock_exam/mock_exam_result.dart';
import '../../design/design.dart';

/// 과목 2칸(점수·정답 수·과락) + 토픽별 이번 시험 정답 수 (정답률 낮은 순)
class MockExamSubjectBreakdown extends StatelessWidget {
  const MockExamSubjectBreakdown({super.key, required this.examResult});

  final MockExamResultResponse examResult;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < examResult.subjects.length; index++) ...[
                if (index > 0) const SizedBox(width: PassqlSpacing.sm),
                Expanded(child: _SubjectCard(subject: examResult.subjects[index])),
              ],
            ],
          ),
        ),
        if (examResult.topics.isNotEmpty) ...[
          const SizedBox(height: PassqlSpacing.lg),
          PassqlGroupedSection(
            header: '토픽별 정답 (약한 순)',
            children: [
              for (final topic in examResult.topics) _TopicRow(topic: topic),
            ],
          ),
        ],
      ],
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject});

  final MockExamSubjectResult subject;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlCard(
      shouldChildFillHeight: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject.name,
            maxLines: 2,
            style: PassqlTypography.footnoteSemibold.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: PassqlSpacing.xs),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${subject.score}',
                  style: PassqlTypography.title2.copyWith(
                    fontFeatures: PassqlTypography.tabular,
                    color: subject.isFailed ? colors.wrongText : colors.label,
                  ),
                ),
                TextSpan(
                  text: ' / ${subject.maxScore}점',
                  style: PassqlTypography.footnote.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PassqlSpacing.xxs),
          Text(
            '${subject.correctCount} / ${subject.questionCount} 정답',
            style: PassqlTypography.footnote.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          if (subject.isFailed) ...[
            const SizedBox(height: PassqlSpacing.xs),
            const PassqlBadge(
              text: '과락',
              kind: PassqlBadgeKind.important,
              icon: CupertinoIcons.exclamationmark_triangle_fill,
            ),
            const SizedBox(height: PassqlSpacing.xxs),
            Text(
              '${subject.failBelowScore}점 이상이어야 해요',
              style: PassqlTypography.caption.copyWith(color: colors.wrongText),
            ),
          ],
        ],
      ),
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.topic});

  final MockExamTopicResult topic;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final correctRate = topic.questionCount == 0
        ? 0.0
        : topic.correctCount / topic.questionCount;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.md,
        vertical: PassqlSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  topic.topicName ?? '',
                  style: PassqlTypography.subheadline.copyWith(
                    color: colors.label,
                  ),
                ),
              ),
              Text(
                '${topic.correctCount} / ${topic.questionCount}',
                style: PassqlTypography.subheadlineSemibold.copyWith(
                  fontFeatures: PassqlTypography.tabular,
                  color: colors.secondaryLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: PassqlSpacing.xs),
          PassqlProgressBar(
            value: correctRate,
            semanticValue: '${(correctRate * 100).round()}%',
          ),
        ],
      ),
    );
  }
}
