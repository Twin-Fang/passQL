import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/billing/promo_code_redemption_port.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../../providers/purchase_history_providers.dart';
import '../account/purchase_history_labels.dart';
import '../common/app_toast.dart';
import '../pro/pro_restore_action.dart';

// 코드 입력 화면을 열지 못했을 때 안내
const String _promoCodeOpenFailedMessage = '코드 입력 화면을 열지 못했어요';

/// 프로필 이용권 행 (#816 A안): (프로) 구매 내역 > 구매 복원 > 프로모션 코드 입력
/// 구매 내역은 계정 화면으로, 프로모션 코드는 iOS 면 바로 App Store 코드 시트, Android 는 코드 입력이 있는 계정 화면으로
class ProfilePlanActionRows extends ConsumerWidget {
  const ProfilePlanActionRows({super.key, required this.isPro});

  /// 프로면 맨 위에 구매 내역 행
  final bool isPro;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final rows = <Widget>[
      if (isPro) _PurchaseHistoryRow(),
      PassqlListRow(
        title: '구매 복원',
        hasChevron: true,
        hasHorizontalPadding: false,
        onTap: () => restoreProPurchasesWithFeedback(context, ref),
      ),
      PassqlListRow(
        title: '프로모션 코드 입력',
        hasChevron: true,
        hasHorizontalPadding: false,
        onTap: () => _openPromoCode(context, ref),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < rows.length; index++) ...[
          if (index > 0)
            Container(height: PassqlSize.hairline, color: colors.separator),
          rows[index],
        ],
      ],
    );
  }

  /// 시스템 코드 시트면 바로 열기, 앱 안 입력이 필요하면 계정 화면
  Future<void> _openPromoCode(BuildContext context, WidgetRef ref) async {
    final port = ref.read(promoCodeRedemptionPortProvider);
    if (port.isCodeEntryInApp) {
      await context.push(AppRoutes.account);
      return;
    }
    final outcome = await port.startRedemption();
    if (outcome != PromoCodeRedemptionOutcome.opened && context.mounted) {
      showAppToast(context, _promoCodeOpenFailedMessage);
    }
  }
}

/// 구매 내역 행: 가장 최근 내역 한 줄 요약(예: 2026.10.28 · 3개월권) > 계정 화면
class _PurchaseHistoryRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestEntry = ref
        .watch(purchaseHistoryProvider)
        .valueOrNull
        ?.firstOrNull;
    final plan = ref.watch(knownPlanProvider);
    return PassqlListRow(
      title: '구매 내역',
      hasChevron: true,
      hasHorizontalPadding: false,
      trailing: latestEntry == null
          ? null
          : Text(
              purchaseHistoryTitleOf(
                latestEntry,
                durationDaysByProductId: durationDaysByProductIdOf(plan),
                hasStoreLabel: false,
              ),
            ),
      onTap: () => context.push(AppRoutes.account),
    );
  }
}
