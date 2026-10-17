import 'package:flutter/widgets.dart';

import '../../../core/ads/ad_native_strip_loader.dart';
import '../../../core/ads/ad_placement.dart';
import '../../design/design.dart';
import 'ad_view_slot.dart';

/// 탭 셸 하단 탭 바 아래 한 줄 네이티브 광고 띠 (#527)
/// 광고 없음(꺼짐·로드 전·실패)이면 탭 바만 (띠 자리 0). 셸 수명 동안 1회 로드, 탭 전환에는 그대로
class AdNativeStripSlot extends StatelessWidget {
  const AdNativeStripSlot({super.key, required this.tabBar});

  final Widget tabBar;

  /// 광고 표시 배지 문구 (네이티브 띠 왼쪽 캡슐)
  static const badgeLabel = 'AD';

  // 앱 복귀 때 이보다 오래 띄운 광고는 교체 (Google 권장: 네이티브 광고 1시간 넘게 보유 금지)
  static const _maximumAdAgeOnResume = Duration(hours: 1);

  @override
  Widget build(BuildContext context) {
    return AdViewSlot(
      // 라이트·다크 전환 시 새 색으로 다시 로드 (색은 로드 때 네이티브에 전달)
      key: ValueKey(context.isDark),
      maximumAdAgeOnResume: _maximumAdAgeOnResume,
      childWithoutAd: tabBar,
      loadAd: (context, ref, _) => ref
          .read(adNativeStripLoaderProvider)
          .load(
            AdPlacement.nativeStrip,
            PassqlSize.bottomStrip,
            _styleOf(context),
          ),
      frameBuilder: (context, adView) =>
          PassqlTabBarWithBottomStrip(tabBar: tabBar, strip: adView.view),
    );
  }

  /// 앱 색 토큰 > 네이티브 띠 색 (라이트·다크)
  static NativeAdStripStyle _styleOf(BuildContext context) {
    final colors = context.passqlColors;
    return NativeAdStripStyle(
      background: PassqlTabBarWithBottomStrip.backgroundOf(context),
      headlineText: colors.label,
      callToActionText: colors.accent,
      badgeBackground: colors.fill,
      badgeText: colors.secondaryLabel,
      badgeLabel: badgeLabel,
    );
  }
}
