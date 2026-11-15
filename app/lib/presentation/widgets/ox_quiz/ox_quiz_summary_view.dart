import 'package:flutter/cupertino.dart';

import '../../design/design.dart';
import '../../providers/ox_quiz_session_notifier.dart';
import '../../providers/ox_quiz_session_state.dart';

/// OX 퀴즈 묶음 요약 (#1083): 맞힌 수 > 다음 복습 예정 > 오늘 목표 > 다시 풀기
class OxQuizSummaryView extends StatelessWidget {
  const OxQuizSummaryView({
    super.key,
    required this.session,
    required this.onRestartPressed,
    required this.onClosePressed,
  });

  final OxQuizSessionState session;
  final VoidCallback onRestartPressed;
  final VoidCallback onClosePressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final reviewsDueByTomorrowCount = countReviewsDueByTomorrow(
      session.nextReviewDates,
    );
    final hasReachedDailyGoal =
        session.todayAnsweredCount >= session.dailyGoalCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PassqlCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${session.cards.length}장 중 ${session.correctCount}장 맞혔어요',
                style: PassqlTypography.title2.copyWith(color: colors.label),
              ),
              const SizedBox(height: PassqlSpacing.xs),
              Text(
                '다음 복습 예정 ${session.nextReviewDates.length}장 | '
                '내일까지 $reviewsDueByTomorrowCount장',
                style: PassqlTypography.subheadline.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
              const SizedBox(height: PassqlSpacing.xs),
              Text(
                hasReachedDailyGoal
                    ? '오늘 목표 ${session.dailyGoalCount}장을 채웠어요'
                    : '오늘 ${session.todayAnsweredCount}장 풀었어요, '
                          '목표까지 ${session.dailyGoalCount - session.todayAnsweredCount}장',
                style: PassqlTypography.subheadline.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
              if (session.hasSyncFailure) ...[
                const SizedBox(height: PassqlSpacing.xs),
                Text(
                  '일부 기록을 저장하지 못했어요. 그 카드는 다음에 다시 나와요',
                  style: PassqlTypography.footnote.copyWith(
                    color: colors.warningText,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: PassqlSpacing.xl),
        PassqlButton(
          label: '한 묶음 더 풀기',
          icon: CupertinoIcons.arrow_clockwise,
          onPressed: onRestartPressed,
        ),
        const SizedBox(height: PassqlSpacing.sm),
        PassqlButton(
          label: '그만 풀기',
          variant: PassqlButtonVariant.plain,
          onPressed: onClosePressed,
        ),
      ],
    );
  }
}
