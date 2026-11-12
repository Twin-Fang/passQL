import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_format.dart';
import '../../../core/utils/exam_dday.dart';
import '../../../data/models/member/member_plan_response.dart';
import '../../../data/models/member/purchase_history_entry_response.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../../providers/pro_ui_providers.dart';
import '../../providers/purchase_history_providers.dart';
import '../pro/pro_offer_sheet.dart';
import '../pro/pro_restore_action.dart';
import 'purchase_history_labels.dart';

/// 계정 화면 `이용권` 묶음 (#816): 지금 등급(프로면 남은 날), 만료일, 구매 내역(스토어 구매·운영 지급), 구매 복원
/// 결제 UI 대상(무료 잠금 UI 또는 프로 표시)일 때만, 결제 꺼짐이면 묶음째 없음
class AccountPassSection extends ConsumerWidget {
  const AccountPassSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(isBillingUiTargetProvider)) return const SizedBox.shrink();
    final isFreeBillingTarget = ref.watch(shouldShowProUiProvider);
    final isProBillingTarget = ref.watch(shouldShowProBadgeProvider);
    final plan = ref.watch(knownPlanProvider);
    final expiresAt = isProBillingTarget ? plan?.proExpiresAt : null;
    return PassqlGroupedSection(
      header: '이용권',
      children: [
        PassqlListRow(
          title: '지금 등급',
          trailing: _PlanBadge(expiresAt: expiresAt, isPro: isProBillingTarget),
        ),
        if (expiresAt != null)
          PassqlListRow(
            title: '만료일',
            trailing: Text(formatDottedDateTime(expiresAt)),
          ),
        if (isFreeBillingTarget)
          PassqlListRow(
            title: '이용권 보기',
            hasChevron: true,
            onTap: () => showProOfferSheet(context, ref),
          ),
        _PurchaseHistoryRows(plan: plan),
        PassqlListRow(
          title: '구매 복원',
          onTap: () => restoreProPurchasesWithFeedback(context, ref),
        ),
      ],
    );
  }
}

/// 지금 등급 칩: 프로 = 강조색 `PRO · 83일 남음`, 무료 = 회색 FREE
class _PlanBadge extends StatelessWidget {
  const _PlanBadge({required this.expiresAt, required this.isPro});

  final DateTime? expiresAt;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final expiresAt = this.expiresAt;
    if (!isPro) return const PassqlPlanChip(isPro: false);
    final daysLeft = expiresAt == null ? null : daysUntilDate(expiresAt);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.xs,
        vertical: PassqlSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: BorderRadius.circular(PassqlRadius.capsule),
      ),
      child: Text(
        daysLeft == null
            ? PassqlPlanChip.proLabel
            : '${PassqlPlanChip.proLabel} · $daysLeft일 남음',
        style: PassqlTypography.captionSemibold.copyWith(
          color: colors.onAccent,
        ),
      ),
    );
  }
}

/// 구매 내역: 제목 줄 + 최신순 한 줄씩 (불러오는 중·실패·없음은 한 줄 안내)
class _PurchaseHistoryRows extends ConsumerWidget {
  const _PurchaseHistoryRows({required this.plan});

  final MemberPlanResponse? plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final historyAsync = ref.watch(purchaseHistoryProvider);
    final entries = historyAsync.valueOrNull;
    final durationDaysByProductId = durationDaysByProductIdOf(plan);
    final caption = PassqlTypography.footnote.copyWith(
      color: colors.secondaryLabel,
    );
    final Widget body;
    if (entries == null) {
      body = historyAsync.hasError
          ? PassqlPressable(
              onTap: () => ref.invalidate(purchaseHistoryProvider),
              semanticLabel: '구매 내역을 불러오지 못했어요, 다시 시도',
              child: Text('불러오지 못했어요 · 다시 시도', style: caption),
            )
          : const Align(
              alignment: Alignment.centerLeft,
              child: PassqlLoadingIndicator(),
            );
    } else if (entries.isEmpty) {
      body = Text('구매 내역이 없어요', style: caption);
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final entry in entries)
            _PurchaseHistoryLine(
              entry: entry,
              durationDaysByProductId: durationDaysByProductId,
            ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.md,
        vertical: PassqlSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '구매 내역',
            style: PassqlTypography.body.copyWith(color: colors.label),
          ),
          const SizedBox(height: PassqlSpacing.xxs),
          body,
        ],
      ),
    );
  }
}

/// 구매 내역 한 줄: 날짜 · 이용권 · 스토어 | 금액(운영 지급 무료, 환불됨)
class _PurchaseHistoryLine extends StatelessWidget {
  const _PurchaseHistoryLine({
    required this.entry,
    required this.durationDaysByProductId,
  });

  final PurchaseHistoryEntryResponse entry;
  final Map<String, int> durationDaysByProductId;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final amount = purchaseHistoryAmountOf(entry);
    final style = PassqlTypography.footnote.copyWith(
      color: colors.secondaryLabel,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PassqlSpacing.hairlineGap),
      child: Row(
        children: [
          Expanded(
            child: Text(
              purchaseHistoryTitleOf(
                entry,
                durationDaysByProductId: durationDaysByProductId,
              ),
              style: style,
            ),
          ),
          if (amount != null) ...[
            const SizedBox(width: PassqlSpacing.xs),
            Text(amount, style: style),
          ],
        ],
      ),
    );
  }
}
