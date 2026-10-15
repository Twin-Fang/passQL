/// 컴포넌트 크기 토큰: 버튼·바·행 높이, 아이콘 타일, 흐림, 헤어라인.
abstract final class PassqlSize {
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
