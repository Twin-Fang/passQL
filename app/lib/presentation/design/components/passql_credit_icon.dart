import 'package:flutter/widgets.dart';

import '../tokens/passql_icon_size.dart';

/// 크레딧 아이콘 (#971, #999): 3D 둥근 사각 젬 + 번개 (투명 배경, 원본 brand/credit_icon_1024.png). 옆 글자가 뜻을 읽어 주므로 스크린리더에서는 제외
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
      // 기본 맞춤(scaleDown)은 에셋 원래 크기(24pt)보다 키우지 않아 큰 자리(보상 창)에서 작게 남음
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
  }
}
