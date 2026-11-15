import 'package:flutter/widgets.dart';

import '../../../data/models/meta/sqld_exam_guide.dart';
import '../../design/design.dart';

/// 출처 줄 (#1076, #1077): "출처: 이름 (확인일)" 목록, 화면 맨 아래 작은 글씨
class ExamGuideSourceFootnote extends StatelessWidget {
  const ExamGuideSourceFootnote({super.key, required this.sources});

  final List<SqldExamSource> sources;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final style = PassqlTypography.caption.copyWith(
      color: colors.secondaryLabel,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('출처', style: style),
        for (final source in sources)
          Text('${source.name} (${source.checkedDate} 확인)', style: style),
      ],
    );
  }
}
