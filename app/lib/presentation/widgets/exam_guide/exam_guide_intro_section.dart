import 'package:flutter/cupertino.dart';

import '../../../data/models/meta/sqld_exam_guide.dart';
import '../../design/design.dart';
import 'exam_guide_fact_tiles.dart';
import 'exam_guide_faq_list.dart';
import 'exam_guide_source_footnote.dart';
import 'exam_guide_subject_share_bar.dart';

/// 시험 소개 탭 (#1076): 한 줄 정의 > 핵심 숫자 > 과목 구성 > 이런 분께 > 자주 묻는 질문 > 출처
class ExamGuideIntroSection extends StatelessWidget {
  const ExamGuideIntroSection({super.key, required this.guide});

  final SqldExamGuide guide;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 한 줄 정의
        Text(
          guide.oneLineDefinition,
          style: PassqlTypography.title2.copyWith(color: colors.label),
        ),
        const SizedBox(height: PassqlSpacing.xs),
        Text(
          '${guide.organizerName} 주관 | ${guide.certificationNumber}',
          style: PassqlTypography.subheadline.copyWith(
            color: colors.secondaryLabel,
          ),
        ),
        const SizedBox(height: PassqlSpacing.lg),
        ExamGuideFactTiles(guide: guide),
        const SizedBox(height: PassqlSpacing.md),
        ExamGuideSubjectShareBar(subjects: guide.subjects),
        const SizedBox(height: PassqlSpacing.xl),
        // 이런 분께
        PassqlGroupedSection(
          header: '이런 분께 추천해요',
          footer: '자격 유효기간: ${guide.validityDescription}',
          children: [
            for (final target in guide.recommendedFor)
              PassqlListRow(
                title: target,
                titleMaxLines: 2,
                leading: Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  size: PassqlIconSize.lg,
                  color: colors.correct,
                ),
              ),
          ],
        ),
        const SizedBox(height: PassqlSpacing.xl),
        ExamGuideFaqList(faqs: guide.faqs),
        const SizedBox(height: PassqlSpacing.lg),
        ExamGuideSourceFootnote(sources: guide.sources),
      ],
    );
  }
}
