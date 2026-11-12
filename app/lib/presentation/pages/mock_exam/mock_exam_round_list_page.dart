import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../data/models/mock_exam/mock_exam_enums.dart';
import '../../../data/models/mock_exam/mock_exam_round_list.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/mock_exam_countdown.dart';
import '../../providers/mock_exam_providers.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/mock_exam/mock_exam_rule_rows.dart';
import '../../widgets/mock_exam/mock_exam_trend_section.dart';
import '../../widgets/pro/pro_offer_sheet.dart';

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
                    children: [
                      for (final round in roundList.rounds)
                        _RoundRow(round: round),
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
            label: '이어 풀기',
            onPressed: () => context.push(
              AppRoutes.mockExamAttempt(inProgressAttempt.attemptUuid),
            ),
          ),
        ],
      ),
    );
  }
}

/// 회차 행: 제목 + 최고 점수·마지막 결과, 무료 체험 배지·잠금 아이콘
/// 탭: 시작 가능 > 안내, 체험 소진·이용권 필요 > (지난 결과 있으면 결과) 아니면 이용권 안내, 다른 회차 풀이 중 > 안내 문구
class _RoundRow extends ConsumerWidget {
  const _RoundRow({required this.round});

  final MockExamRoundSummary round;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final isLocked =
        !round.canStart &&
        (round.startBlockReason == MockExamStartBlockReason.proRequired ||
            round.startBlockReason == MockExamStartBlockReason.freeTrialUsed);
    return PassqlListRow(
      title: round.title,
      subtitle: _subtitleOf(round),
      leading: PassqlIconTile(
        icon: isLocked ? CupertinoIcons.lock_fill : CupertinoIcons.doc_text,
        color: isLocked ? colors.iconSecondary : colors.accent,
      ),
      trailing:
          round.isFreeTrialRound && round.canStart && round.lastAttempt == null
          ? const PassqlBadge(text: '무료 1회', kind: PassqlBadgeKind.success)
          : null,
      hasChevron: true,
      onTap: () => _onTap(context, ref),
    );
  }

  void _onTap(BuildContext context, WidgetRef ref) {
    final lastAttempt = round.lastAttempt;
    // 풀이 중 회차: 안내·시작 확인 없이 이어 풀기 (남은 시간은 서버 기준, #902)
    if (lastAttempt != null &&
        lastAttempt.status == MockExamAttemptStatus.inProgress) {
      context.push(AppRoutes.mockExamAttempt(lastAttempt.attemptUuid));
      return;
    }
    if (round.canStart) {
      context.push(AppRoutes.mockExamGuide(round.roundUuid));
      return;
    }
    switch (round.startBlockReason) {
      case MockExamStartBlockReason.otherAttemptInProgress:
        showAppToast(context, '풀고 있는 모의고사를 먼저 마쳐 주세요');
      case _
          when lastAttempt != null &&
              lastAttempt.status == MockExamAttemptStatus.submitted:
        context.push(AppRoutes.mockExamResult(lastAttempt.attemptUuid));
      default:
        showProOfferSheet(context, ref);
    }
  }

  static String _subtitleOf(MockExamRoundSummary round) {
    final lastAttempt = round.lastAttempt;
    if (lastAttempt != null &&
        lastAttempt.status == MockExamAttemptStatus.inProgress) {
      return '풀이 중';
    }
    if (round.bestScore != null) {
      final passText = lastAttempt?.isPassed == true ? '합격' : '불합격';
      return '최고 ${round.bestScore}점 · 마지막 $passText · ${round.submittedAttemptCount}회 응시';
    }
    return switch (round.startBlockReason) {
      MockExamStartBlockReason.proRequired => 'PRO로 풀 수 있어요',
      MockExamStartBlockReason.freeTrialUsed => '무료 체험을 사용했어요',
      _ => '아직 안 풀었어요',
    };
  }
}

const EdgeInsets _listPadding = EdgeInsets.fromLTRB(
  PassqlSpacing.md,
  PassqlSpacing.xs,
  PassqlSpacing.md,
  PassqlSpacing.xl,
);
