import 'package:flutter/widgets.dart';

import '../tokens/passql_size.dart';

/// 환영 일러스트 (#985): 실행 결과 표 카드 + 실행 버튼 + AI 반짝임 3D 그림 (투명 배경)
/// 장식 그림이라 스크린리더에서는 제외, 환영 에셋은 이 부품만 부름
class PassqlWelcomeIllustration extends StatelessWidget {
  const PassqlWelcomeIllustration({
    super.key,
    this.size = PassqlSize.welcomeIllustration,
  });

  final double size;

  /// 환영 일러스트 에셋 (assets/welcome_illustration.png, 2.0x·3.0x 포함)
  static const String _assetPath = 'assets/welcome_illustration.png';

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
