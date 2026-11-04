import 'package:flutter/widgets.dart';

import '../../../core/auth/auth_session.dart';
import '../../design/design.dart';

/// 로그인 제공자 > 표시 이름 (카카오·네이버·Google·Apple·GitHub)
String loginProviderLabelOf(SocialProvider provider) => switch (provider) {
  SocialProvider.kakao => '카카오',
  SocialProvider.naver => '네이버',
  SocialProvider.google => 'Google',
  SocialProvider.apple => 'Apple',
  SocialProvider.github => 'GitHub',
};

/// 로그인 제공자 작은 배지 (#816, 프로필 계정 줄·계정 화면 공통): 카카오·네이버·GitHub 는 브랜드 색, Google·Apple 은 회색 칸
class LoginProviderBadge extends StatelessWidget {
  const LoginProviderBadge({super.key, required this.provider});

  final SocialProvider provider;

  // 배지 글자 위아래 여백 (캡션 글자에 붙지 않을 만큼)
  static const double _verticalPadding = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final (Color background, Color foreground) = switch (provider) {
      SocialProvider.kakao => (
        PassqlSocialBrandColors.kakaoBackground,
        PassqlSocialBrandColors.kakaoForeground,
      ),
      SocialProvider.naver => (
        PassqlSocialBrandColors.naverBackground,
        PassqlSocialBrandColors.naverForeground,
      ),
      SocialProvider.github => (
        PassqlSocialBrandColors.githubBackground,
        PassqlSocialBrandColors.githubForeground,
      ),
      SocialProvider.google ||
      SocialProvider.apple => (colors.fill, colors.label),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.xs,
        vertical: _verticalPadding,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(PassqlRadius.sm),
      ),
      child: Text(
        loginProviderLabelOf(provider),
        style: PassqlTypography.captionSemibold.copyWith(color: foreground),
      ),
    );
  }
}
