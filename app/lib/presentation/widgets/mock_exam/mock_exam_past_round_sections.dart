import 'package:flutter/cupertino.dart';

import '../../../data/models/mock_exam/mock_exam_round_list.dart';
import '../../design/design.dart';
import 'mock_exam_past_grading_entry.dart';
import 'mock_exam_round_row.dart';

/// 기출 복원 탭 본문 (#1079): 안내 한 줄 > 연도별 묶음(최근 회차 먼저), 없으면 빈 상태
class MockExamPastRoundSections extends StatelessWidget {
  const MockExamPastRoundSections({
    super.key,
    required this.pastRounds,
    required this.rule,
    this.inProgressAttempt,
  });

  final List<MockExamRoundSummary> pastRounds;
  final MockExamRule rule;
  final MockExamInProgressAttempt? inProgressAttempt;

  // 시험일을 모르는 회차 묶음 머리글
  static const String _unknownYearHeader = '시험일 미정';

  @override
  Widget build(BuildContext context) {
    if (pastRounds.isEmpty) {
      return PassqlStatusView.empty(
        icon: CupertinoIcons.doc_text,
        title: '곧 기출 복원 회차가 열려요',
      );
    }
    final roundsByYear = groupPastRoundsByYear(pastRounds);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '2024년 52회 개정 이후 시험을 응시자 후기로 다시 구성했어요',
          style: PassqlTypography.subheadline.copyWith(
            color: context.passqlColors.secondaryLabel,
          ),
        ),
        MockExamPastGradingEntry(pastRounds: pastRounds),
        for (final entry in roundsByYear.entries) ...[
          const SizedBox(height: PassqlSpacing.lg),
          PassqlGroupedSection(
            header: entry.key == null ? _unknownYearHeader : '${entry.key}년',
            separatorIndent: MockExamRoundRow.separatorIndent,
            children: [
              for (final round in entry.value)
                MockExamRoundRow(
                  round: round,
                  rule: rule,
                  inProgressAttempt: inProgressAttempt,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// 기출 회차 > 시험 연도별 묶음 (연도·회차 번호 큰 순, 시험일 없으면 null 연도로 맨 뒤)
Map<int?, List<MockExamRoundSummary>> groupPastRoundsByYear(
  List<MockExamRoundSummary> pastRounds,
) {
  final sortedRounds = [...pastRounds]
    ..sort(
      (first, second) => (second.examRoundNumber ?? second.roundNumber)
          .compareTo(first.examRoundNumber ?? first.roundNumber),
    );
  final roundsByYear = <int?, List<MockExamRoundSummary>>{};
  for (final round in sortedRounds) {
    final examYear = DateTime.tryParse(round.examDate ?? '')?.year;
    roundsByYear.putIfAbsent(examYear, () => []).add(round);
  }
  final sortedYears = roundsByYear.keys.toList()
    ..sort((first, second) => (second ?? -1).compareTo(first ?? -1));
  return {for (final year in sortedYears) year: roundsByYear[year]!};
}
