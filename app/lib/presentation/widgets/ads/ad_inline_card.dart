import 'package:flutter/widgets.dart';

import '../../../core/ads/ad_banner_loader.dart';
import '../../../core/ads/ad_placement.dart';
import '../../design/design.dart';
import 'ad_label.dart';
import 'ad_view_slot.dart';

/// 스크롤 콘텐츠 사이 인라인 배너 카드 (홈·통계 공통)
/// 로드 전·실패·광고 꺼짐 > 자리·여백 0. 로드되면 크기 펼침 + 페이드로 등장 (AdViewSlot 공통)
class AdInlineCard extends StatelessWidget {
  const AdInlineCard({
    super.key,
    required this.placement,
    this.padding = EdgeInsets.zero,
  });

  final AdPlacement placement;

  /// 광고가 뜬 뒤에만 두는 바깥 여백 (광고 없으면 여백도 없음)
  final EdgeInsets padding;

  /// 테스트가 카드 틀을 찾는 키
  static const frameKey = Key('ad-inline-card-frame');

  // 카드 안쪽 여백 (PassqlCard 기본값과 같게)
  static const _cardPadding = EdgeInsets.all(PassqlSpacing.md);

  /// 자리 폭 > 광고 폭 (바깥 여백·카드 안쪽 여백 제외, 넘치지 않게 내림)
  static int adWidthDpOf(int slotWidthDp, EdgeInsets padding) =>
      (slotWidthDp - padding.horizontal - _cardPadding.horizontal).floor();

  @override
  Widget build(BuildContext context) {
    return AdViewSlot(
      loadAd: (_, ref, slotWidthDp) => ref
          .read(adBannerLoaderProvider)
          .load(placement, adWidthDpOf(slotWidthDp, padding)),
      frameBuilder: (context, adView) => Padding(
        padding: padding,
        // 홈·통계 카드와 같은 틀 (배경·모서리·안쪽 여백)
        child: PassqlCard(
          key: frameKey,
          padding: _cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const AdLabel(),
              const SizedBox(height: PassqlSpacing.xs),
              SizedBox(
                height: adView.height,
                width: double.infinity,
                child: Center(child: adView.view),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
