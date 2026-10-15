import 'package:flutter/animation.dart';

/// 간격 7단계. 화면 좌우 여백은 md(16) 하나로 고정한다.
abstract final class PqSpace {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

/// 모서리 4종 + 아이콘 타일(iOS 설정 앱 규격) 예외 1종.
abstract final class PqRadius {
  static const double sm = 8; // 코드, 태그
  static const double md = 12; // 버튼, 입력, 선택지
  static const double lg = 16; // 카드, grouped 섹션
  static const double iconTile = 7;
  static const double capsule = 999;
}

abstract final class PqSize {
  static const double buttonLarge = 50;
  static const double buttonRegular = 44;
  static const double buttonSmall = 34;
  static const double tabBar = 44; // 아이콘만 있는 탭 바(#367) 기준. 글자 있는 iOS 규격은 49
  static const double navBar = 44;
  static const double rowMin = 44; // Apple 최소 터치 영역
  static const double iconTile = 29;
  static const double blurSigma = 20;
  static const double hairline = 0.5;
}

abstract final class PqMotion {
  static const fast = Duration(milliseconds: 250);
  static const curve = Curves.easeOutCubic;
}
