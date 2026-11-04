import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/billing/pass_discount.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/exam_dday.dart';
import '../../design/design.dart';
import '../../providers/pass_price_providers.dart';
import '../../providers/plan_providers.dart';
import '../pro/pro_discount_badge.dart';
import '../pro/pro_offer_sheet.dart';

/// 프로 이어서 연장 (#816 A안): 제목 + 할인 배지 > 남은 날 뒤에 이어 붙는 새 만료일 > 연장 버튼(이용권 시트)
/// 대표 이용권 = 할인이 가장 큰 이용권(없으면 첫 칸). 가격을 못 읽으면 버튼 문구에서 가격만 뺌, 판매 이용권이 없으면 카드째 없음
class ProfileProExtendCard extends ConsumerWidget {
  const ProfileProExtendCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final pricing = ref.watch(passOptionPricingProvider);
    final featuredOption =
        pricing.bestDiscountOption ?? pricing.options.firstOrNull;
    if (featuredOption == null) return const SizedBox.shrink();
    final discount = pricing.discountOf(featuredOption);
    final displayPrice =
        pricing.priceByProductId[featuredOption.productId]?.displayPrice;
    final expiresAt = ref.watch(knownPlanProvider)?.proExpiresAt;
    final daysLeft = expiresAt == null ? null : daysUntilDate(expiresAt);
    final monthsLabel = '${toPassMonths(featuredOption.durationDays)}개월';
    final newExpiryText = formatDottedDate(featuredOption.expiresAtIfPurchased);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '다음 시험까지 이어서 쓰기',
                style: PassqlTypography.headline.copyWith(color: colors.label),
              ),
            ),
            if (discount != null)
              ProDiscountBadge(discountPercent: discount.discountPercent),
          ],
        ),
        const SizedBox(height: PassqlSpacing.xxs),
        Text(
          daysLeft != null && daysLeft > 0
              ? '지금 연장하면 남은 $daysLeft일 뒤에 이어 붙어요 ($newExpiryText까지)'
              : '지금 연장하면 $newExpiryText까지 쓸 수 있어요',
          style: PassqlTypography.subheadline.copyWith(
            color: colors.secondaryLabel,
          ),
        ),
        const SizedBox(height: PassqlSpacing.sm),
        PassqlButton(
          label: displayPrice == null
              ? '$monthsLabel 연장하기'
              : '$monthsLabel 연장 $displayPrice',
          variant: PassqlButtonVariant.tinted,
          onPressed: () => showProOfferSheet(context, ref),
        ),
      ],
    );
  }
}
