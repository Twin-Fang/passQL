import 'package:flutter/material.dart';

/// 소셜 로그인 버튼 브랜드 색: 제공자 가이드 고정값 (라이트·다크 동일, 앱 색 체계와 별개)
/// 대상 3개: 카카오(공식 노랑 + 85% 검정 글자), 네이버(공식 초록 + 흰 글자), GitHub(공식 어두운 회색 + 흰 글자)
abstract final class PassqlSocialBrandColors {
  static const Color kakaoBackground = Color(0xFFFEE500);
  static const Color kakaoForeground = Color(0xD9000000);
  static const Color naverBackground = Color(0xFF03C75A);
  static const Color naverForeground = Color(0xFFFFFFFF);
  static const Color githubBackground = Color(0xFF24292F);
  static const Color githubForeground = Color(0xFFFFFFFF);
}
