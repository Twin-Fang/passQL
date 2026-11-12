import 'package:flutter/widgets.dart';

import '../../../core/utils/profile_pass_values.dart';
import '../../../data/models/member/member_plan_response.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import 'credit_today_history.dart';

/// 오늘 크레딧 내역 시트 (#971): 받은 줄·쓴 줄 > 남은 크레딧 > 다시 채워지는 때
Future<void> showCreditTodayHistorySheet(
  BuildContext context,
  MemberPlanResponse plan,
) {
  return showPassqlSheet<void>(
    context,
    title: '오늘 크레딧 내역',
    builder: (_) => _CreditTodayHistoryBody(plan: plan),
  );
}

class _CreditTodayHistoryBody extends StatelessWidget {
  const _CreditTodayHistoryBody({required this.plan});

  final MemberPlanResponse plan;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final entries = buildTodayCreditHistory(plan);
    final remaining = remainingFreeSolves(
      used: plan.todayRandomSolvedCount,
      limit: plan.effectiveTodayFreeLimit,
    );
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PassqlSpacing.md,
          0,
          PassqlSpacing.md,
          PassqlSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final entry in entries)
              _HistoryRow(
                label: entry.label,
                amountText: entry.isSpent
                    ? '${entry.amount}'
                    : '+${entry.amount}',
                amountColor: entry.isSpent
                    ? colors.secondaryLabel
                    : colors.accentText,
              ),
            const SizedBox(height: PassqlSpacing.xs),
            // 남은 크레딧 (합계 줄)
            _HistoryRow(
              label: '남은 크레딧',
              amountText: '$remaining',
              amountColor: colors.label,
              isTotal: true,
            ),
            const SizedBox(height: PassqlSpacing.sm),
            Text(
              '내일 0시에 ${plan.dailyFreeLimit}개가 새로 채워져요.',
              style: PassqlTypography.footnote.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 내역 한 줄: 이름 · 오른쪽 수량 (합계 줄은 굵게, 위 구분선)
class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.label,
    required this.amountText,
    required this.amountColor,
    this.isTotal = false,
  });

  final String label;
  final String amountText;
  final Color amountColor;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final labelStyle = isTotal
        ? PassqlTypography.headline
        : PassqlTypography.subheadline;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: PassqlSpacing.sm),
      decoration: isTotal
          ? BoxDecoration(
              border: Border(top: BorderSide(color: colors.separator)),
            )
          : null,
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: labelStyle.copyWith(color: colors.label)),
          ),
          if (isTotal) ...[
            const PassqlCreditIcon(),
            const SizedBox(width: PassqlSpacing.xxs),
          ],
          Text(
            amountText,
            style: PassqlTypography.headline.copyWith(color: amountColor),
          ),
        ],
      ),
    );
  }
}
