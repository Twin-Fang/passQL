/// 모서리 4종 + 아이콘 타일 1종. 모두 짝수 값만 쓴다 (#687).
abstract final class PassqlRadius {
  static const double sm = 8; // 코드, 태그
  static const double md = 12; // 버튼, 입력, 선택지
  // 카드, grouped 섹션. 버튼(md)과 같은 값: 카드 여백(16)이 둥글기보다 커서 동심 공식 대신 버튼과 맞춤 (#687)
  static const double lg = 12;
  static const double iconTile = 8; // 짝수 토큰 체계에 맞춤 (iOS 규격 7 대신, #687)
  static const double capsule = 999;
}
