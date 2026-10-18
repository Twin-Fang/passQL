import 'package:flutter/widgets.dart';

import '../../../core/ads/ad_native_loader.dart';
import '../../../core/ads/ad_placement.dart';
import '../../design/design.dart';
import 'ad_label.dart';
import 'ad_view_slot.dart';

/// 목록 사이 네이티브 광고 1칸. 로드 전·실패 시 항목 자체가 없음 (높이·여백 0)
/// 목록 행과 헷갈려 눌리지 않게 '광고' 라벨 필수 + 토픽 묶음과 같은 카드 틀로 구분 (무효 클릭 방지)
class AdNativeSlot extends StatelessWidget {
  const AdNativeSlot({
    super.key,
    required this.placement,
    this.padding = EdgeInsets.zero,
  });

  final AdPlacement placement;

  /// 광고가 뜬 뒤에만 두는 바깥 여백 (광고 없으면 여백도 없음)
  final EdgeInsets padding;

  /// 광고 라벨 문구
  static const adLabel = AdLabel.text;

  /// 테스트가 틀을 찾는 키
  static const frameKey = Key('ad-native-frame');

  @override
  Widget build(BuildContext context) {
    return AdViewSlot(
      loadAd: (context, ref, widthDp) => ref
          .read(adNativeLoaderProvider)
          .load(placement, widthDp, cardStyleOf(context)),
      frameBuilder: (context, adView) {
        final colors = context.passqlColors;
        return Padding(
          padding: padding,
          child: ClipRRect(
            key: frameKey,
            borderRadius: BorderRadius.circular(PassqlRadius.lg),
            child: ColoredBox(
              color: colors.card,
              child: Padding(
                // 좌우는 토픽 행(PassqlListRow)과 같은 md > 라벨·광고 왼쪽 선이 행 글자와 맞음
                padding: const EdgeInsets.symmetric(
                  horizontal: PassqlSpacing.md,
                  vertical: PassqlSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AdLabel(),
                    const SizedBox(height: PassqlSpacing.xs),
                    adView.view,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 디자인 토큰 > 네이티브 카드 모양 (라이트·다크). 버튼은 PassqlButton small·tinted 와 같은 모양
  static NativeAdCardStyle cardStyleOf(BuildContext context) {
    final colors = context.passqlColors;
    return NativeAdCardStyle(
      backgroundColor: colors.card,
      headlineColor: colors.label,
      bodyColor: colors.secondaryLabel,
      mediaBackgroundColor: colors.fill,
      callToActionBackgroundColor: colors.accentTint,
      callToActionTextColor: colors.accent,
      mediaCornerRadius: PassqlRadius.md,
      callToActionCornerRadius: PassqlRadius.capsule,
      callToActionHeight: PassqlSize.buttonSmall,
      callToActionHorizontalPadding: PassqlSpacing.md,
      contentGap: PassqlSpacing.sm,
      headlineFontSize: PassqlTypography.subheadlineSemibold.fontSize!,
      bodyFontSize: PassqlTypography.footnote.fontSize!,
      callToActionFontSize: PassqlTypography.footnoteSemibold.fontSize!,
    );
  }
}
