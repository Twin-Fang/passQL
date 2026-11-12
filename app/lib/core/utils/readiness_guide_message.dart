// 준비도가 충분하다고 보는 점수 (0~1)
const double readinessSolidScore = 0.7;

/// 홈 준비도 링 아래 한 줄: 준비도 수치(점수·가장 낮은 지표)만 말함 (#995)
/// 시험 임박 문구는 상단 D-day 배지·인사말이 맡아 여기서는 반복하지 않음
/// 판정: 점수 기준 이상 > 유지 / 그 외 > 가장 낮은 지표(정확도·범위·최신성, 같으면 이 순서) 올리기
String readinessGuideMessage({
  required double score,
  required double accuracy,
  required double coverage,
  required double recency,
}) {
  if (score >= readinessSolidScore) return '준비가 탄탄해요. 지금 페이스를 지켜요';
  final lowestValue = [
    accuracy,
    coverage,
    recency,
  ].reduce((lowest, value) => value < lowest ? value : lowest);
  if (accuracy == lowestValue) return '정확도를 올리면 준비도가 가장 크게 올라요';
  if (coverage == lowestValue) return '안 푼 토픽을 풀면 범위가 채워져요';
  return '최근 푼 문제가 적어요. 오늘 몇 문제 풀어 봐요';
}
