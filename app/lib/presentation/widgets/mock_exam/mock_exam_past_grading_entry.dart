import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/date_format.dart';
import '../../../data/models/mock_exam/mock_exam_round_list.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';

// 가답안 API 자격증 경로 값 (기출 복원 회차는 SQLD 만)
const String _gradingCertType = 'SQLD';

/// 지난 회차 가채점 진입 (#1151): 행 1개 > 탭하면 회차 고르는 시트 > 가답안·OMR 가채점 화면
/// 가채점이 열린 회차가 하나도 없으면 아무것도 그리지 않음
class MockExamPastGradingEntry extends StatelessWidget {
  const MockExamPastGradingEntry({super.key, required this.pastRounds});

  final List<MockExamRoundSummary> pastRounds;

  @override
  Widget build(BuildContext context) {
    final gradableRounds = findGradableRounds(pastRounds);
    if (gradableRounds.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: PassqlSpacing.lg),
      child: PassqlGroupedSection(
        children: [
          PassqlListRow(
            title: '지난 회차 가채점',
            subtitle: '내 답안을 OMR로 넣고 점수, 과락, 합격을 확인해요',
            hasChevron: true,
            onTap: () => _pickRound(context, gradableRounds),
          ),
        ],
      ),
    );
  }

  Future<void> _pickRound(
    BuildContext context,
    List<MockExamRoundSummary> gradableRounds,
  ) async {
    final pickedRoundNumber = await showPassqlSheet<int>(
      context,
      title: '가채점할 회차',
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            PassqlSpacing.md,
            0,
            PassqlSpacing.md,
            PassqlSpacing.md,
          ),
          child: SingleChildScrollView(
            child: PassqlGroupedSection(
              children: [
                for (final round in gradableRounds)
                  PassqlListRow(
                    title: '${round.examRoundNumber}회',
                    subtitle: _examDateTextOf(round),
                    hasChevron: true,
                    onTap: () =>
                        Navigator.of(sheetContext).pop(round.examRoundNumber),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    if (pickedRoundNumber == null || !context.mounted) return;
    await context.push(
      AppRoutes.examAnswer(_gradingCertType, pickedRoundNumber),
    );
  }

  static String? _examDateTextOf(MockExamRoundSummary round) {
    final examDate = DateTime.tryParse(round.examDate ?? '');
    return examDate == null ? null : formatDottedDate(examDate);
  }
}

/// 가채점이 열린 기출 회차 (실제 회차 번호 큰 순, 번호 없는 회차 제외)
List<MockExamRoundSummary> findGradableRounds(
  List<MockExamRoundSummary> pastRounds,
) =>
    pastRounds
        .where((round) => round.hasExamAnswerKey && round.examRoundNumber != null)
        .toList()
      ..sort(
        (first, second) =>
            second.examRoundNumber!.compareTo(first.examRoundNumber!),
      );
