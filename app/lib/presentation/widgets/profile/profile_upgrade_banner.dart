import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/billing/pass_discount.dart';
import '../../../core/utils/exam_dday.dart';
import '../../../core/utils/number_format.dart';
import '../../design/design.dart';
import '../../providers/home_providers.dart';
import '../../providers/pass_price_providers.dart';
import '../pro/pro_discount_badge.dart';
import '../pro/pro_offer_sheet.dart';

// 보라 바탕 위 보조 글자·버튼 바탕 투명도 (탑승권 프로 보조 글자와 같은 결)
const double _subtleOnAccentAlpha = 0.78;
const double _buttonBackgroundAlpha = 0.2;

/// 무료 업그레이드 배너 (#816 A안): 시험 D-day · 할인 리본 > 한 줄 권유 > 정가 줄긋기 + 대표 이용권 가격 + 하루 가격 > 이용권 보기
/// 대표 이용권 = 할인이 가장 큰 이용권(없으면 첫 칸). 스토어 가격을 못 읽으면(시뮬레이터 등) 가격 줄만 숨기고 버튼은 유지
class ProfileUpgradeBanner extends ConsumerWidget {
  const ProfileUpgradeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final schedule = ref.watch(examScheduleProvider).valueOrNull;
    final pricing = ref.watch(passOptionPricingProvider);
    final featuredOption =
        pricing.bestDiscountOption ?? pricing.options.firstOrNull;
    final discount = featuredOption == null
        ? null
        : pricing.discountOf(featuredOption);
    final daysUntil = schedule == null
        ? null
        : daysUntilExam(schedule.examDate);
    final hasUpcomingExam = daysUntil != null && daysUntil > 0;
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
          Row(
            children: [
              Expanded(
                child: Text(
                  schedule != null && hasUpcomingExam
                      ? '${schedule.certType} ${schedule.round}회 · 시험까지 $daysUntil일'
                      : 'passQL PRO',
                  style: PassqlTypography.footnoteSemibold.copyWith(
                    color: subtleColor,
                  ),
                ),
              ),
              if (discount != null)
                ProDiscountBadge(discountPercent: discount.discountPercent),
            ],
          ),
          const SizedBox(height: PassqlSpacing.xs),
          Text(
            hasUpcomingExam
                ? '시험까지 제한 없이 풀고\n보기별 해설까지 보세요'
                : '제한 없이 풀고\n보기별 해설까지 보세요',
            style: PassqlTypography.title3.copyWith(color: colors.onAccent),
          ),
          if (featuredOption != null)
            _PriceLine(
              monthsLabel: '${toPassMonths(featuredOption.durationDays)}개월',
              displayPrice: pricing
                  .priceByProductId[featuredOption.productId]
                  ?.displayPrice,
              undiscountedPrice: pricing.undiscountedPriceOf(featuredOption),
              dailyPrice: pricing.dailyPriceOf(featuredOption),
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

/// 가격 줄: 정가 줄긋기 + `3개월 9,900원` + `하루 약 110원` (스토어 가격 없으면 그리지 않음)
class _PriceLine extends StatelessWidget {
  const _PriceLine({
    required this.monthsLabel,
    required this.displayPrice,
    required this.undiscountedPrice,
    required this.dailyPrice,
    required this.subtleColor,
  });

  final String monthsLabel;
  final String? displayPrice;
  final int? undiscountedPrice;
  final int? dailyPrice;
  final Color subtleColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final displayPrice = this.displayPrice;
    final undiscountedPrice = this.undiscountedPrice;
    final dailyPrice = this.dailyPrice;
    if (displayPrice == null) return const SizedBox.shrink();
    final subtleStyle = PassqlTypography.footnote.copyWith(color: subtleColor);
    return Padding(
      padding: const EdgeInsets.only(top: PassqlSpacing.xs),
      child: Wrap(
        spacing: PassqlSpacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (undiscountedPrice != null)
            Text(
              '${formatThousands(undiscountedPrice)}원',
              style: subtleStyle.copyWith(
                decoration: TextDecoration.lineThrough,
                decorationColor: subtleColor,
              ),
            ),
          Text(
            '$monthsLabel $displayPrice',
            style: PassqlTypography.headline.copyWith(color: colors.onAccent),
          ),
          if (dailyPrice != null)
            Text('하루 약 ${formatThousands(dailyPrice)}원', style: subtleStyle),
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
