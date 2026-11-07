import 'package:flutter/material.dart';

import '../../../core/auth/auth_session.dart';
import '../../widgets/account/login_provider_appearance.dart';
import '../../widgets/account/login_provider_logo.dart';

// 로그인 버튼 로고 높이 (문구 크기와 시각 균형)
const double _buttonLogoHeight = 20;

/// 소셜 로그인 버튼 한 개의 모양: 문구, 로고, 바탕·글자·테두리 색
class SocialLoginAppearance {
  const SocialLoginAppearance({
    required this.label,
    required this.logo,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
  });

  final String label;
  final Widget logo;
  final Color backgroundColor;
  final Color foregroundColor;

  /// null 이면 테두리 없음
  final Color? borderColor;
}

/// 제공자 > 버튼 모양 (색·로고 원본은 login_provider_appearance·login_provider_logo)
SocialLoginAppearance socialLoginAppearanceFor(
  SocialProvider provider,
  BuildContext context,
) {
  final palette = loginProviderPaletteOf(provider, context);
  return SocialLoginAppearance(
    label: '${loginProviderLabelOf(provider)}로 계속하기',
    logo: LoginProviderLogo(
      provider: provider,
      height: _buttonLogoHeight,
      color: palette.foreground,
    ),
    backgroundColor: palette.background,
    foregroundColor: palette.foreground,
    borderColor: palette.border,
  );
}
