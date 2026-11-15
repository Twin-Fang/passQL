import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/mock_exam/mock_exam_enums.dart';
import '../../../data/models/progress/wrong_note_filter.dart';
import '../../design/design.dart';
import '../../providers/wrong_questions_provider.dart';
import '../mock_exam/mock_exam_number_grid.dart';

/// 오답 노트 필터 (#1081): 과목 세그먼트(전체 | 1과목 | 2과목) > 정렬 행(시트에서 고름) > 정리된 문제도 보기 스위치
class WrongNotesFilterBar extends ConsumerWidget {
  const WrongNotesFilterBar({super.key});

  // 과목 세그먼트 칸 3개 (null = 전체)
  static final List<PassqlSegment<MockExamSubject?>> _subjectSegments = [
    const PassqlSegment(value: null, label: '전체'),
    for (final subject in [
      MockExamSubject.subjectOne,
      MockExamSubject.subjectTwo,
    ])
      PassqlSegment(value: subject, label: mockExamSubjectShortName(subject)),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final filter = ref.watch(wrongNotesFilterProvider);
    final filterNotifier = ref.read(wrongNotesFilterProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PassqlSegmentedControl<MockExamSubject?>(
          segments: _subjectSegments,
          selectedValue: filter.subject,
          onSelected: (subject) => filterNotifier.state = (
            subject: subject,
            sort: filter.sort,
            isResolvedIncluded: filter.isResolvedIncluded,
          ),
        ),
        const SizedBox(height: PassqlSpacing.md),
        PassqlGroupedSection(
          children: [
            PassqlListRow(
              title: '정렬',
              trailing: Text(filter.sort.label),
              hasChevron: true,
              onTap: () async {
                final sort = await _showSortSheet(context, filter.sort);
                if (sort == null) return;
                filterNotifier.state = (
                  subject: filter.subject,
                  sort: sort,
                  isResolvedIncluded: filter.isResolvedIncluded,
                );
              },
            ),
            PassqlListRow(
              title: '정리된 문제도 보기',
              subtitle: '다시 맞힌 문제까지 함께 보여요',
              trailing: CupertinoSwitch(
                value: filter.isResolvedIncluded,
                activeTrackColor: colors.accent,
                onChanged: (isResolvedIncluded) => filterNotifier.state = (
                  subject: filter.subject,
                  sort: filter.sort,
                  isResolvedIncluded: isResolvedIncluded,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 정렬 고르는 시트 (고른 값, 그냥 닫으면 null)
  Future<WrongQuestionSort?> _showSortSheet(
    BuildContext context,
    WrongQuestionSort selectedSort,
  ) => showPassqlSheet<WrongQuestionSort>(
    context,
    title: '정렬',
    builder: (sheetContext) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PassqlSpacing.md,
          0,
          PassqlSpacing.md,
          PassqlSpacing.md,
        ),
        child: PassqlGroupedSection(
          children: [
            for (final sort in WrongQuestionSort.values)
              PassqlCheckRow(
                title: sort.label,
                isSelected: sort == selectedSort,
                onTap: () => Navigator.of(sheetContext).pop(sort),
              ),
          ],
        ),
      ),
    ),
  );
}
