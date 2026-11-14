import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import 'pro_offer_sheet.dart';

/// 화면의 잠금 자리 공통: 흐린 가짜 미리보기 + 가운데 한 줄, 누르면 프로 안내 시트([onUnlock] 주면 그쪽)
/// 그릴지 말지는 호출부가 shouldShowProUiProvider 로 정함 (여기서는 판정하지 않음)
class ProLockedSection extends ConsumerWidget {
  const ProLockedSection({
    super.key,
    required this.preview,
    required this.caption,
    this.isCaptionAtTop = false,
    this.onUnlock,
    this.previewMaxHeight,
  });

  /// 가짜 미리보기 (locked_preview_samples.dart)
  final Widget preview;

  /// 가운데 한 줄 (LockedPreviewCaptions)
  final String caption;

  /// 한 줄·버튼 위쪽 배치 (긴 미리보기용, PassqlLockedPreview 참고)
  final bool isCaptionAtTop;

  /// 누를 때 동작 (null 이면 프로 안내 시트, 잠금화면 엔진은 앱을 열어 구매)
  final VoidCallback? onUnlock;

  /// 미리보기 최대 높이 (PassqlLockedPreview 참고)
  final double? previewMaxHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PassqlLockedPreview(
      preview: preview,
      caption: caption,
      isCaptionAtTop: isCaptionAtTop,
      previewMaxHeight: previewMaxHeight,
      onUnlock: onUnlock ?? () => showProOfferSheet(context, ref),
    );
  }
}
