import 'package:flutter/widgets.dart';

import '../../../core/auth/auth_session.dart';
import '../../design/design.dart';

// Apple 이메일 가리기(나의 이메일 가리기) 중계 주소 도메인: 사용자가 알아볼 수 없어 이메일로 보이지 않음
const String _appleHiddenEmailDomain = '@privaterelay.appleid.com';

/// 로그인 제공자 > 표시 이름 (카카오·네이버·Google·Apple·GitHub)
String loginProviderLabelOf(SocialProvider provider) => switch (provider) {
  SocialProvider.kakao => '카카오',
  SocialProvider.naver => '네이버',
  SocialProvider.google => 'Google',
  SocialProvider.apple => 'Apple',
  SocialProvider.github => 'GitHub',
};

/// 로그인한 계정 표시 (#908): 이메일 > 없음·빈 값·Apple 가림 주소면 제공자 이름
String loginAccountLabelOf(SocialProvider provider, String? email) {
  final trimmedEmail = email?.trim() ?? '';
  final isHiddenEmail = trimmedEmail.toLowerCase().endsWith(
    _appleHiddenEmailDomain,
  );
  if (trimmedEmail.isEmpty || isHiddenEmail) {
    return loginProviderLabelOf(provider);
  }
  return trimmedEmail;
}

/// 로그인 제공자 바탕·로고·테두리 색 (로그인 버튼과 제공자 아이콘 공통 원본)
class LoginProviderPalette {
  const LoginProviderPalette({
    required this.background,
    required this.foreground,
    this.border,
  });

  final Color background;
  final Color foreground;

  /// null 이면 테두리 없음
  final Color? border;
}

/// 제공자 > 색 (카카오·네이버·GitHub: 브랜드 색, Google·Apple: 앱 카드 색 + 라이트 테두리)
LoginProviderPalette loginProviderPaletteOf(
  SocialProvider provider,
  BuildContext context,
) {
  final colors = context.passqlColors;
  final isDarkMode = context.isDark;
  // Google·Apple 공통 바탕: 라이트는 card+테두리, 다크는 cardElevated 로 배경과 구분
  final neutralBackground = isDarkMode ? colors.cardElevated : colors.card;
  final neutralBorder = isDarkMode ? null : colors.separator;
  return switch (provider) {
    SocialProvider.kakao => const LoginProviderPalette(
      background: PassqlSocialBrandColors.kakaoBackground,
      foreground: PassqlSocialBrandColors.kakaoForeground,
    ),
    SocialProvider.naver => const LoginProviderPalette(
      background: PassqlSocialBrandColors.naverBackground,
      foreground: PassqlSocialBrandColors.naverForeground,
    ),
    // Apple HIG 는 흰 바탕+검정 로고 변형 허용 > Google 과 같은 모양
    SocialProvider.google || SocialProvider.apple => LoginProviderPalette(
      background: neutralBackground,
      foreground: colors.label,
      border: neutralBorder,
    ),
    SocialProvider.github => LoginProviderPalette(
      background: PassqlSocialBrandColors.githubBackground,
      foreground: PassqlSocialBrandColors.githubForeground,
      // 다크 배경(검정) 위 어두운 칸 경계 구분
      border: isDarkMode ? colors.separator : null,
    ),
  };
}
