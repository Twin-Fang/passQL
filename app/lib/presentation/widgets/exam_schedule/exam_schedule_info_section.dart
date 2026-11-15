import 'package:flutter/widgets.dart';

import '../../../core/utils/number_format.dart';
import '../../design/design.dart';
import 'sqld_exam_facts.dart';

/// 시험 정보 묶음 (#991): 시험 시간·응시료·응시 자격 + 입실 시간·준비물은 공식 안내로
/// + SQLD 알아보기 (시험 소개·역대 합격률, #1076)
class ExamScheduleInfoSection extends StatelessWidget {
  const ExamScheduleInfoSection({
    super.key,
    required this.onOfficialGuidePressed,
    required this.onExamGuidePressed,
  });

  final VoidCallback onOfficialGuidePressed;
  final VoidCallback onExamGuidePressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlGroupedSection(
      header: '시험 정보',
      children: [
        const PassqlListRow(
          title: '시험 시간',
          trailing: Text(
            '${SqldExamFacts.examDurationMinutes}분 | ${SqldExamFacts.questionCount}문항',
          ),
        ),
        PassqlListRow(
          title: '응시료',
          trailing: Text('${formatThousands(SqldExamFacts.examFeeWon)}원'),
        ),
        const PassqlListRow(
          title: '응시 자격',
          trailing: Text(SqldExamFacts.eligibility),
        ),
        PassqlListRow(
          title: '입실 시간, 준비물',
          trailing: Text(
            '공식 안내 ›',
            style: PassqlTypography.bodyMedium.copyWith(
              color: colors.accentText,
            ),
          ),
          onTap: onOfficialGuidePressed,
        ),
        PassqlListRow(
          title: 'SQLD 알아보기',
          subtitle: '시험 소개, 역대 응시자와 합격률',
          hasChevron: true,
          onTap: onExamGuidePressed,
        ),
      ],
    );
  }
}
