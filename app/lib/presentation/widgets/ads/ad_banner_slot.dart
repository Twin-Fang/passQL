import 'package:flutter/widgets.dart';

import '../../../core/ads/ad_banner_loader.dart';
import '../../../core/ads/ad_placement.dart';
import '../../design/design.dart';
import 'ad_view_slot.dart';

/// 하단 탭 바 위 고정 배너 자리. 로드 전·실패 시 높이 0 (탭 바만 남음)
/// 성공하면 배너 높이 + 아래 간격만큼 탭 영역이 늘고 본문 하단 여백도 함께 늚 (겹침 없음)
class AdBannerSlot extends StatelessWidget {
  const AdBannerSlot({super.key, required this.placement});

  final AdPlacement placement;

  @override
  Widget build(BuildContext context) {
    return AdViewSlot(
      loadAd: (_, ref, widthDp) =>
          ref.read(adBannerLoaderProvider).load(placement, widthDp),
      frameBuilder: (context, adView) => ColoredBox(
        color: context.passqlColors.background,
        child: Padding(
          // 탭 버튼과 띄워 오클릭 방지
          padding: const EdgeInsets.only(bottom: PassqlSpacing.xxs),
          child: SizedBox(
            height: adView.height,
            width: double.infinity,
            child: Center(child: adView.view),
          ),
        ),
      ),
    );
  }
}
