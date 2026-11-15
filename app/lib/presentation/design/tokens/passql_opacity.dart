/// 투명도 단계: 토큰 색 위에 겹치는 알파 값. 화면 코드는 withValues(alpha: 숫자) 대신 이것만 쓴다 (#789)
abstract final class PassqlOpacity {
  // 그라데이션 끝처럼 완전히 비우는 색
  static const double transparent = 0;

  // 학습 기록 칸 accent 3단계 (0회는 fill, 7회 이상은 accent 100%)
  static const double heatmapLow = 0.25; // 1회
  static const double heatmapMedium = 0.5; // 2~3회
  static const double heatmapHigh = 0.75; // 4~6회

  // 토스트 배경 (label 위, 뒤 화면이 살짝 비침)
  static const double toastBackground = 0.88;

  // 가채점 점수 막대 위 갈림 문항 범위 띠 (#1075)
  static const double examAnswerScoreRange = 0.3;
}
