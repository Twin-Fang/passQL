import 'package:flutter/widgets.dart';

import '../../design/design.dart';

/// 광고 카드 위 '광고' 라벨 (인라인 배너·네이티브 공통)
/// 콘텐츠 카드와 헷갈려 눌리지 않게 모든 화면 안 광고에 필수 (무효 클릭 방지)
class AdLabel extends StatelessWidget {
  const AdLabel({super.key});

  /// 라벨 문구
  static const text = '광고';

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: PassqlTypography.captionSemibold.copyWith(
        color: context.passqlColors.secondaryLabel,
      ),
    );
  }
}
