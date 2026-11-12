import 'package:flutter/widgets.dart';

import '../tokens/passql_icon_size.dart';

/// 크레딧 아이콘 (#971): 인디고 동전 모양 (투명 배경). 옆 글자가 뜻을 읽어 주므로 스크린리더에서는 제외
/// 크레딧 에셋은 이 부품만 부름
class PassqlCreditIcon extends StatelessWidget {
  const PassqlCreditIcon({super.key, this.size = PassqlIconSize.sm});

  final double size;

  /// 크레딧 에셋 (assets/credit.png, 2.0x·3.0x 포함)
  static const String _assetPath = 'assets/credit.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      width: size,
      height: size,
      excludeFromSemantics: true,
    );
  }
}
