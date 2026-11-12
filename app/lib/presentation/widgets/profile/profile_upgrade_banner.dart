import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/billing/pass_discount.dart';
import '../../../core/utils/number_format.dart';
import '../../design/design.dart';
import '../../providers/pass_price_providers.dart';
import '../pro/pro_discount_badge.dart';
import '../pro/pro_offer_sheet.dart';

// 보라 바탕 위 보조 글자·버튼 바탕 투명도 (탑승권 프로 보조 글자와 같은 결)
const double _subtleOnAccentAlpha = 0.78;
// 버튼 바탕: 보라 위 반투명 흰색 (글자는 흰색, 대비 규칙 유지)
const double _buttonBackgroundAlpha = 0.24;

// 권유 한 줄 (이용권 시트 머리와 같은 문구)
const String _headline = '제한 없이, 광고 없이 풀어요';

/// 무료 업그레이드 배너 (#816 A안, 정보 줄임 #971): PRO 젬 + 이름 > 한 줄 권유 > 대표 이용권 가격 + 정가 줄긋기 + 할인율 > 이용권 보기
/// 대표 이용권 = 할인이 가장 큰 이용권(없으면 첫 칸). 스토어 가격을 못 읽으면(시뮬레이터 등) 가격 줄만 숨기고 버튼은 유지
class ProfileUpgradeBanner extends ConsumerWidget {
  const ProfileUpgradeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final pricing = ref.watch(passOptionPricingProvider);
    final featuredOption =
        pricing.bestDiscountOption ?? pricing.options.firstOrNull;
    final discount = featuredOption == null
        ? null
        : pricing.discountOf(featuredOption);
    final subtleColor = colors.onAccent.withValues(alpha: _subtleOnAccentAlpha);
    return Container(
      padding: const EdgeInsets.all(PassqlSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PassqlRadius.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.accent, colors.passGradientEnd],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // PRO 젬 + 이름: "제한 없이" 권유를 무한대 그림으로 먼저 보이게 (#1014)
          Row(
            children: [
              const PassqlProIcon(size: PassqlIconSize.xl, isDecorative: true),
              const SizedBox(width: PassqlSpacing.xxs),
              Text(
                'passQL PRO',
                style: PassqlTypography.footnoteSemibold.copyWith(
                  color: subtleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: PassqlSpacing.xxs),
          Text(
            _headline,
            style: PassqlTypography.title3.copyWith(color: colors.onAccent),
          ),
          if (featuredOption != null)
            _PriceLine(
              monthsLabel: '${toPassMonths(featuredOption.durationDays)}개월',
              displayPrice: pricing
                  .priceByProductId[featuredOption.productId]
                  ?.displayPrice,
              undiscountedPrice: pricing.undiscountedPriceOf(featuredOption),
              discountPercent: discount?.discountPercent,
              subtleColor: subtleColor,
            ),
          const SizedBox(height: PassqlSpacing.sm),
          _BannerButton(
            label: '이용권 보기',
            onTap: () => showProOfferSheet(context, ref),
          ),
        ],
      ),
    );
  }
}

/// 가격 줄: `3개월 ₩9,900` + 정가 줄긋기 + 할인율 배지 (스토어 가격 없으면 그리지 않음)
class _PriceLine extends StatelessWidget {
  const _PriceLine({
    required this.monthsLabel,
    required this.displayPrice,
    required this.undiscountedPrice,
    required this.discountPercent,
    required this.subtleColor,
  });

  final String monthsLabel;
  final String? displayPrice;
  final int? undiscountedPrice;
  final int? discountPercent;
  final Color subtleColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final displayPrice = this.displayPrice;
    final undiscountedPrice = this.undiscountedPrice;
    final discountPercent = this.discountPercent;
    if (displayPrice == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: PassqlSpacing.xs),
      child: Wrap(
        spacing: PassqlSpacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '$monthsLabel $displayPrice',
            style: PassqlTypography.headline.copyWith(color: colors.onAccent),
          ),
          if (undiscountedPrice != null)
            Text(
              '${formatThousands(undiscountedPrice)}원',
              style: PassqlTypography.footnote.copyWith(
                color: subtleColor,
                decoration: TextDecoration.lineThrough,
                decorationColor: subtleColor,
              ),
            ),
          if (discountPercent != null)
            ProDiscountBadge(
              discountPercent: discountPercent,
              isOnStrongColor: true,
            ),
        ],
      ),
    );
  }
}

/// 보라 바탕 위 버튼: 반투명 흰 바탕 + 흰 글자 (기본 버튼 색은 보라 위에서 묻힘)
class _BannerButton extends StatelessWidget {
  const _BannerButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlPressable(
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        constraints: const BoxConstraints(minHeight: PassqlSize.buttonRegular),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.onAccent.withValues(alpha: _buttonBackgroundAlpha),
          borderRadius: BorderRadius.circular(PassqlRadius.md),
        ),
        child: Text(
          label,
          style: PassqlTypography.headline.copyWith(color: colors.onAccent),
        ),
      ),
    );
  }
}
