import 'package:flutter/widgets.dart';

import '../../../data/models/mock_exam/mock_exam_enums.dart';
import '../../design/design.dart';

/// 과목 묶음 1개: 제목 + 번호 칸들
class MockExamNumberGroup {
  const MockExamNumberGroup({required this.title, required this.cells});

  final String title;
  final List<Widget> cells;
}

/// 번호판: 과목별 제목 + 5열 칸 (풀이 번호판·결과 정오 번호판 공용)
class MockExamNumberGrid extends StatelessWidget {
  const MockExamNumberGrid({super.key, required this.groups});

  final List<MockExamNumberGroup> groups;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var groupIndex = 0; groupIndex < groups.length; groupIndex++) ...[
          if (groupIndex > 0) const SizedBox(height: PassqlSpacing.lg),
          Text(
            groups[groupIndex].title,
            style: PassqlTypography.footnoteSemibold.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: PassqlSpacing.xs),
          LayoutBuilder(
            builder: (context, constraints) {
              final cellWidth =
                  (constraints.maxWidth - _gap * (_columnCount - 1)) /
                  _columnCount;
              return Wrap(
                spacing: _gap,
                runSpacing: _gap,
                children: [
                  for (final cell in groups[groupIndex].cells)
                    SizedBox(width: cellWidth, child: cell),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}

/// 과목 > 번호판 묶음 제목 (1과목 데이터 모델링 · 2과목 SQL)
String mockExamSubjectGroupTitle(MockExamSubject subject) => switch (subject) {
  MockExamSubject.subjectOne => '1과목 데이터 모델링의 이해',
  MockExamSubject.subjectTwo => '2과목 SQL 기본 및 활용',
  MockExamSubject.unknown => '기타',
};

/// 과목 > 짧은 이름 (문항 머리 줄)
String mockExamSubjectShortName(MockExamSubject subject) => switch (subject) {
  MockExamSubject.subjectOne => '1과목',
  MockExamSubject.subjectTwo => '2과목',
  MockExamSubject.unknown => '',
};

// 한 줄 칸 수 (10문항 = 2줄, 40문항 = 8줄)
const int _columnCount = 5;
// 칸 사이 (논리 픽셀)
const double _gap = PassqlSpacing.xs;
