import 'package:flutter/widgets.dart';

import '../tokens/passql_icon_size.dart';

/// PRO 아이콘 (#1014): 3D 둥근 사각 젬 + 무한대 (투명 배경, 원본 brand/pro_icon_1024.png). 크레딧 무제한 = PRO 를 그림으로
/// PRO 에셋은 이 부품만 부름
class PassqlProIcon extends StatelessWidget {
  const PassqlProIcon({
    super.key,
    this.size = PassqlIconSize.sm,
    this.isDecorative = false,
  });

  final double size;

  /// 옆에 이미 `PRO` 글자가 있어 스크린리더가 읽을 필요 없을 때
  final bool isDecorative;

  /// PRO 에셋 (assets/pro_icon.png, 2.0x·3.0x 포함)
  static const String _assetPath = 'assets/pro_icon.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      width: size,
      height: size,
      // 기본 맞춤(scaleDown)은 에셋 원래 크기보다 키우지 않아 큰 자리에서 작게 남음
      fit: BoxFit.contain,
      excludeFromSemantics: isDecorative,
      semanticLabel: 'PRO',
    );
  }
}
