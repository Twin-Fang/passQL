/// 컴포넌트 크기 토큰: 버튼·바·행 높이, 아이콘 타일, 흐림, 헤어라인.
abstract final class PassqlSize {
  static const double buttonLarge = 50;
  static const double buttonRegular = 44;
  static const double buttonSmall = 34;
  static const double tabBar = 44; // 아이콘만 있는 탭 바(#367) 기준. 글자 있는 iOS 규격은 49
  static const double navBar = 44;
  static const double bottomStrip = 44; // 탭 바 아래 한 줄 띠 (광고, #527). 띠 전체가 터치 영역이라 최소 터치 높이와 같게
  static const double rowMin = 44; // Apple 최소 터치 영역
  static const double minTouchTarget = 44; // 아이콘 버튼 탭 영역 (Apple HIG 최소)
  static const double progressBarHeight = 4;
  static const double choiceKeyBadge = 24; // 선택지 키(A·B·C·D) 원
  static const double avatar = 52; // 설정 프로필 이니셜 원
  static const double scoreRing = 168; // 결과 점수 고리 지름
  static const double scoreRingStroke = 12;
  static const double loginLogoHeight = 44;
  static const double footerLogoHeight = 20;
  static const double navBarLogoHeight = 24; // 홈 상단 바 워드마크 (바 높이 44 안, 종 아이콘과 시각 무게 맞춤)
  // 오픈소스 라이선스 화면 상단 로고 높이
  static const double licensePageLogoHeight = 32;
  static const double messageSlotHeight =
      28; // 입력 아래 안내·오류 한 줄 자리 (나타나도 레이아웃이 밀리지 않게 고정)
  static const double iconTile = 29;
  static const double blurSigma = 20;
  static const double hairline = 0.5;
  static const double notificationBadge = 18; // 안 읽은 개수 배지 높이·한 자리 지름 (PassqlCountBadge)
  static const double unreadDot = 8; // 알림 항목 앞 안 읽음 점
  static const double sheetHeroCircle = 64; // 안내 시트 맨 위 대표 아이콘 원

  // 로딩 표시 반지름 3단계: 버튼·행 안, 섹션·시트, 화면 잠금
  static const double loadingIndicatorInlineRadius = 10;
  static const double loadingIndicatorSectionRadius = 12;
  static const double loadingIndicatorBlockingRadius = 14;
}
