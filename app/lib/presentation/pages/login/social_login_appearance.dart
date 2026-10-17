import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/auth/auth_session.dart';
import '../../design/design.dart';

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

/// 제공자 > 버튼 모양 (Google·Apple: 앱 카드 색, 카카오·네이버·GitHub: 브랜드 색)
SocialLoginAppearance socialLoginAppearanceFor(
  SocialProvider provider,
  BuildContext context,
) {
  final colors = context.passqlColors;
  final isDarkMode = context.isDark;
  // Google·Apple 공통 바탕: 라이트는 card+테두리, 다크는 cardElevated 로 배경과 구분
  final neutralBackground = isDarkMode ? colors.cardElevated : colors.card;
  final neutralBorder = isDarkMode ? null : colors.separator;
  return switch (provider) {
    SocialProvider.kakao => SocialLoginAppearance(
      label: '카카오로 계속하기',
      logo: _brandLogo(
        _kakaoSymbolSvg,
        size: _kakaoLogoSize,
        color: PassqlSocialBrandColors.kakaoForeground,
      ),
      backgroundColor: PassqlSocialBrandColors.kakaoBackground,
      foregroundColor: PassqlSocialBrandColors.kakaoForeground,
    ),
    SocialProvider.naver => SocialLoginAppearance(
      label: '네이버로 계속하기',
      logo: _brandLogo(
        _naverSymbolSvg,
        size: _naverLogoSize,
        color: PassqlSocialBrandColors.naverForeground,
      ),
      backgroundColor: PassqlSocialBrandColors.naverBackground,
      foregroundColor: PassqlSocialBrandColors.naverForeground,
    ),
    SocialProvider.google => SocialLoginAppearance(
      label: 'Google로 계속하기',
      // Google 'G' 는 브랜드 가이드상 4색 그대로 (색 입히지 않음)
      logo: SvgPicture.string(
        _googleLogoSvg,
        width: _googleLogoSize,
        height: _googleLogoSize,
      ),
      backgroundColor: neutralBackground,
      foregroundColor: colors.label,
      borderColor: neutralBorder,
    ),
    // Apple HIG 는 흰 바탕+검정 로고 변형 허용 > Google 버튼과 같은 모양
    SocialProvider.apple => SocialLoginAppearance(
      label: 'Apple로 계속하기',
      logo: SvgPicture.string(
        _appleLogoSvg,
        width: _appleLogoWidth,
        height: _appleLogoHeight,
        colorFilter: ColorFilter.mode(colors.label, BlendMode.srcIn),
      ),
      backgroundColor: neutralBackground,
      foregroundColor: colors.label,
      borderColor: neutralBorder,
    ),
    SocialProvider.github => SocialLoginAppearance(
      label: 'GitHub로 계속하기',
      logo: _brandLogo(
        _githubMarkSvg,
        size: _githubLogoSize,
        color: PassqlSocialBrandColors.githubForeground,
      ),
      backgroundColor: PassqlSocialBrandColors.githubBackground,
      foregroundColor: PassqlSocialBrandColors.githubForeground,
      // 다크 배경(검정) 위 어두운 버튼 경계 구분
      borderColor: isDarkMode ? colors.separator : null,
    ),
  };
}

Widget _brandLogo(String svg, {required double size, required Color color}) =>
    SvgPicture.string(
      svg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );

// 제공자 로고 크기 (공식 가이드 비율, 문구 크기와 시각 균형)
const double _googleLogoSize = 20;
const double _appleLogoWidth = 18;
const double _appleLogoHeight = 20;
const double _kakaoLogoSize = 20;
const double _naverLogoSize = 15;
const double _githubLogoSize = 20;

/// Google 공식 'G' 로고(4색). 브랜드 가이드상 색을 바꾸지 않고 그대로 쓴다.
const _googleLogoSvg = '''
<svg viewBox="0 0 18 18" xmlns="http://www.w3.org/2000/svg">
<path d="M17.64 9.2c0-.637-.057-1.251-.164-1.84H9v3.481h4.844c-.209 1.125-.843 2.078-1.796 2.717v2.258h2.908c1.702-1.567 2.684-3.875 2.684-6.615Z" fill="#4285F4"/>
<path d="M9 18c2.43 0 4.467-.806 5.956-2.18l-2.908-2.259c-.806.54-1.837.86-3.048.86-2.344 0-4.328-1.584-5.036-3.711H.957v2.332A8.997 8.997 0 0 0 9 18Z" fill="#34A853"/>
<path d="M3.964 10.71A5.41 5.41 0 0 1 3.682 9c0-.593.102-1.17.282-1.71V4.958H.957A8.996 8.996 0 0 0 0 9c0 1.452.348 2.827.957 4.042l3.007-2.332Z" fill="#FBBC05"/>
<path d="M9 3.58c1.321 0 2.508.454 3.44 1.345l2.582-2.58C13.463.891 11.426 0 9 0A8.997 8.997 0 0 0 .957 4.958L3.964 7.29C4.672 5.163 6.656 3.58 9 3.58Z" fill="#EA4335"/>
</svg>
''';

/// Apple 공식 로고. 경로가 viewBox 위쪽(잎사귀)으로 조금 넘어가 y 시작을 -100 으로 잡았다.
/// 색은 코드에서 입히므로 fill 을 두지 않는다.
const _appleLogoSvg = '''
<svg viewBox="0 -100 814 1110" xmlns="http://www.w3.org/2000/svg">
<path d="M702 960c-54.2 52.6-114 44.4-171 19.6-60.6-25.3-116-26.9-180 0-79.7 34.4-121.8 24.4-169.5-19.6-270-278-230-701 76.7-717 74.5 4 126.8 41.4 171 44.8 65.4-13.3 128-51.4 197.7-46.5 83.9 6.8 147 40 188 99.9-172.9 103.7-131.9 331.4 26.6 395.2-31.6 83-72.5 165.5-140.6 227.6zM423 149.5C414.9 25.9 515.4-76 631.3-86c14.9 142.6-129.4 249-208.3 235.5z"/>
</svg>
''';

/// 카카오 말풍선 심볼 (색은 코드에서 입힘)
const _kakaoSymbolSvg = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
<path d="M12 3C6.48 3 2 6.47 2 10.75c0 2.77 1.86 5.2 4.66 6.57-.15.52-.97 3.34-1 3.56 0 0-.02.17.09.23.11.07.24.02.24.02.32-.05 3.7-2.42 4.29-2.83.56.08 1.13.12 1.72.12 5.52 0 10-3.47 10-7.75S17.52 3 12 3Z"/>
</svg>
''';

/// 네이버 'N' 심볼 (색은 코드에서 입힘)
const _naverSymbolSvg = '''
<svg viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
<path d="M13.56 10.7 6.17 0H0v20h6.44V9.3L13.83 20H20V0h-6.44v10.7Z"/>
</svg>
''';

/// GitHub 마크 (Octicons mark-github, 색은 코드에서 입힘)
const _githubMarkSvg = '''
<svg viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg">
<path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0 0 16 8c0-4.42-3.58-8-8-8Z"/>
</svg>
''';
