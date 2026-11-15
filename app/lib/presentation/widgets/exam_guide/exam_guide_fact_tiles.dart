import 'package:flutter/widgets.dart';

import '../../../core/utils/number_format.dart';
import '../../../data/models/meta/sqld_exam_guide.dart';
import '../../design/design.dart';

/// 핵심 숫자 타일 4개 (#1076): 문항·시간, 합격 점수, 과락 기준, 응시료 (2열 2행)
class ExamGuideFactTiles extends StatelessWidget {
  const ExamGuideFactTiles({super.key, required this.guide});

  final SqldExamGuide guide;

  @override
  Widget build(BuildContext context) {
    final totalQuestionCount = guide.subjects.fold<int>(
      0,
      (sum, subject) => sum + subject.questionCount,
    );
    return Column(
      children: [
        _tileRow(
          _FactTile(
            value: '$totalQuestionCount문항',
            caption: '${guide.examDurationMinutes}분 객관식',
          ),
          _FactTile(
            value: '${guide.passingTotalScore}점',
            caption: '100점 만점 중 합격선',
          ),
        ),
        const SizedBox(height: PassqlSpacing.xs),
        _tileRow(
          _FactTile(
            value: '${guide.failingSubjectPercent}% 미만',
            caption: '한 과목이라도 과락',
          ),
          _FactTile(
            value: '${formatThousands(guide.examFeeWon)}원',
            caption: '응시료',
          ),
        ),
      ],
    );
  }

  Widget _tileRow(Widget left, Widget right) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: left),
        const SizedBox(width: PassqlSpacing.xs),
        Expanded(child: right),
      ],
    ),
  );
}

class _FactTile extends StatelessWidget {
  const _FactTile({required this.value, required this.caption});

  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlCard(
      shouldChildFillHeight: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: PassqlTypography.title3.copyWith(color: colors.label),
          ),
          const SizedBox(height: PassqlSpacing.xxs),
          Text(
            caption,
            style: PassqlTypography.footnote.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}
