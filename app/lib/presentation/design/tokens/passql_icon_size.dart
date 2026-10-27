/// 아이콘 크기 단계(작은 것부터) + 자리별 고정 크기
abstract final class PassqlIconSize {
  static const double xxs = 12; // 배지 옆 보조 아이콘
  static const double xs = 14; // 카드 머리 아이콘
  static const double sm = 16; // 난이도 별
  static const double md = 18; // 버튼·체크 표시, 행 화살표 (14 는 작아 안 보임, #701)
  static const double lg = 20; // 목록 행 상태 아이콘
  static const double xl = 22; // 상단 바 버튼, 선택지 채점 표시
  static const double xxl = 24; // 탭 바
  static const double iconTileGlyph = 17; // 29pt 아이콘 타일 안 글리프 (iOS 설정 앱 규격)
  static const double sheetHero = 30; // 안내 시트 대표 아이콘 (64pt 원 안)
  static const double statusPlaceholder = 44; // 빈·오류 상태 화면
  static const double resultMarkLarge = 64; // 채점 결과 큰 표시
}
