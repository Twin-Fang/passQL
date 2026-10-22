import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../../providers/pro_ui_providers.dart';
import 'pro_offer_sheet.dart';

/// 탭 화면 상단 등급 칩 자리: 무료 FREE(누르면 시트) / 프로 PRO / 결제 꺼짐·등급 모름이면 빈 자리
class ProPlanChipSlot extends ConsumerWidget {
  const ProPlanChipSlot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(shouldShowProUiProvider)) {
      return PassqlPlanChip(
        isPro: false,
        onTap: () => showProOfferSheet(context, ref),
      );
    }
    if (ref.watch(shouldShowProBadgeProvider)) {
      return const PassqlPlanChip(isPro: true);
    }
    return const SizedBox.shrink();
  }
}
