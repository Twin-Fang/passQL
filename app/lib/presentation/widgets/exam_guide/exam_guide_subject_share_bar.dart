import 'package:flutter/widgets.dart';

import '../../../data/models/meta/sqld_exam_guide.dart';
import '../../design/design.dart';

/// 과목 배점 비율 막대 (#1076): 과목별 배점만큼 가로 칸 + 아래 과목명·문항·배점 줄
class ExamGuideSubjectShareBar extends StatelessWidget {
  const ExamGuideSubjectShareBar({super.key, required this.subjects});

  final List<SqldExamSubject> subjects;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    // 과목 순서대로 강조색 > 진한 강조 글자색 (2과목까지, 그 이상은 반복)
    final subjectColors = [colors.accentText, colors.accent];
    return PassqlCard(
      title: '과목 구성',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(PassqlRadius.capsule),
            child: SizedBox(
              width: double.infinity,
              height: PassqlSize.examSubjectShareBarHeight,
              // 칸이 막대 높이를 채우도록 stretch
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var index = 0; index < subjects.length; index++)
                    Expanded(
                      flex: subjects[index].points,
                      child: ColoredBox(
                        color: subjectColors[index % subjectColors.length],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: PassqlSpacing.sm),
          for (var index = 0; index < subjects.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: PassqlSpacing.xxs),
              child: Row(
                children: [
                  _ColorDot(color: subjectColors[index % subjectColors.length]),
                  const SizedBox(width: PassqlSpacing.xs),
                  Expanded(
                    child: Text(
                      '${index + 1}과목 ${subjects[index].name}',
                      style: PassqlTypography.subheadline.copyWith(
                        color: colors.label,
                      ),
                    ),
                  ),
                  Text(
                    '${subjects[index].questionCount}문항 | ${subjects[index].points}점',
                    style: PassqlTypography.footnote.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: PassqlSpacing.xs,
    child: DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
  );
}
