/// 투명도 단계: 토큰 색 위에 겹치는 알파 값. 화면 코드는 withValues(alpha: 숫자) 대신 이것만 쓴다
abstract final class PassqlOpacity {
  // 학습 기록 칸 accent 3단계 (0회는 fill, 7회 이상은 accent 100%)
  static const double heatmapLow = 0.25; // 1회
  static const double heatmapMedium = 0.5; // 2~3회
  static const double heatmapHigh = 0.75; // 4~6회

  // 진행 중 화면 잠금 막 (label 위)
  static const double blockingBarrier = 0.2;
}
