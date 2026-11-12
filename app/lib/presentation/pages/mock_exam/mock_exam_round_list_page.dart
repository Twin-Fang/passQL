import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../data/models/mock_exam/mock_exam_round_list.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/mock_exam_countdown.dart';
import '../../providers/mock_exam_providers.dart';
import '../../widgets/mock_exam/mock_exam_round_row.dart';
import '../../widgets/mock_exam/mock_exam_rule_rows.dart';
import '../../widgets/mock_exam/mock_exam_trend_section.dart';

/// 모의고사 회차 목록 (#866): 시험 형식 > 풀이 중 이어 풀기 > 회차(최고 점수·체험·잠금) > 점수 추이
/// 시작 가능 여부·막힌 이유는 서버 판정 그대로
class MockExamRoundListPage extends ConsumerWidget {
  const MockExamRoundListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roundsAsync = ref.watch(mockExamRoundsProvider);
    return Scaffold(
      appBar: PassqlNavBar(title: 'SQLD 모의고사', leading: PassqlNavLeading.back),
      body: SafeArea(
        child: PassqlFadeSwitcher(
          child: roundsAsync.when(
            loading: () => const SingleChildScrollView(
              key: ValueKey('loading'),
              padding: _listPadding,
              child: PassqlListSkeleton(rowCount: 6),
            ),
            error: (error, _) => KeyedSubtree(
              key: const ValueKey('error'),
              child: PassqlStatusView.error(
                message: error.asAppException.message,
                onRetry: () => ref.invalidate(mockExamRoundsProvider),
              ),
            ),
            data: (roundList) => ListView(
              key: const ValueKey('data'),
              padding: _listPadding,
              children: [
                if (roundList.inProgressAttempt
                    case final inProgressAttempt?) ...[
                  _InProgressCard(inProgressAttempt: inProgressAttempt),
                  const SizedBox(height: PassqlSpacing.xl),
                ],
                MockExamRuleRows(rule: roundList.examRule),
                const SizedBox(height: PassqlSpacing.xl),
                if (roundList.rounds.isEmpty)
                  PassqlStatusView.empty(
                    icon: CupertinoIcons.doc_text,
                    title: '곧 첫 회차가 열려요',
                  )
                else
                  PassqlGroupedSection(
                    header: '회차',
                    separatorIndent: MockExamRoundRow.separatorIndent,
                    children: [
                      for (final round in roundList.rounds)
                        MockExamRoundRow(
                          round: round,
                          rule: roundList.examRule,
                          inProgressAttempt: roundList.inProgressAttempt,
                        ),
                    ],
                  ),
                const SizedBox(height: PassqlSpacing.xl),
                const MockExamTrendSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 풀이 중 응시 카드: 남은 시간(목록 받은 시점) · 답한 수 > 이어 풀기
class _InProgressCard extends StatelessWidget {
  const _InProgressCard({required this.inProgressAttempt});

  final MockExamInProgressAttempt inProgressAttempt;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlCard(
      title: '${inProgressAttempt.title} 풀이 중',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '남은 시간 ${formatMockExamRemaining(inProgressAttempt.remainingSeconds)} · '
            '${inProgressAttempt.answeredCount}문항 답함',
            style: PassqlTypography.subheadline.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: PassqlSpacing.md),
          PassqlButton(
            label: '이어서 풀기',
            onPressed: () => context.push(
              AppRoutes.mockExamAttempt(inProgressAttempt.attemptUuid),
            ),
          ),
        ],
      ),
    );
  }
}

const EdgeInsets _listPadding = EdgeInsets.fromLTRB(
  PassqlSpacing.md,
  PassqlSpacing.xs,
  PassqlSpacing.md,
  PassqlSpacing.xl,
);
