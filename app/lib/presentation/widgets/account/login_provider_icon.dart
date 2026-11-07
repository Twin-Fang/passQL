import 'package:flutter/widgets.dart';

import '../../../core/auth/auth_session.dart';
import '../../design/design.dart';
import 'login_provider_appearance.dart';
import 'login_provider_logo.dart';

/// 로그인 제공자 아이콘 (#908, 프로필 머리·계정 화면 공통): 로그인 버튼과 같은 색 칸 + 로고
/// 이름은 스크린리더용으로만 (옆 글자가 이름을 말하면 [isSemanticLabelHidden])
class LoginProviderIcon extends StatelessWidget {
  const LoginProviderIcon({
    super.key,
    required this.provider,
    this.size = defaultSize,
    this.isSemanticLabelHidden = false,
  });

  final SocialProvider provider;

  /// 칸 한 변 길이
  final double size;
  final bool isSemanticLabelHidden;

  // 계정 화면 행 기본 크기 (목록 행 상태 아이콘과 같은 높이)
  static const double defaultSize = PassqlIconSize.lg;
  // 칸 대비 로고 높이 비율 (로고 둘레 여백)
  static const double _logoHeightRatio = 0.6;
  // 칸 대비 모서리 비율 (iOS 아이콘 타일 모양)
  static const double _cornerRatio = 0.25;

  @override
  Widget build(BuildContext context) {
    final palette = loginProviderPaletteOf(provider, context);
    final border = palette.border;
    final icon = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(size * _cornerRatio),
        border: border == null ? null : Border.all(color: border),
      ),
      child: LoginProviderLogo(
        provider: provider,
        height: size * _logoHeightRatio,
        color: palette.foreground,
      ),
    );
    if (isSemanticLabelHidden) return ExcludeSemantics(child: icon);
    return Semantics(
      label: loginProviderLabelOf(provider),
      image: true,
      child: ExcludeSemantics(child: icon),
    );
  }
}
