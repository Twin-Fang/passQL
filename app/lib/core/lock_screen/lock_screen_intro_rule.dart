/// 잠금화면 소개 시트 노출 판정 (#990, 과한 권유 금지): 처음 1번 + 닫은 지 7일 뒤 1번, 그 뒤 없음
/// 조건 4개: 기능 사용 가능(Android·서버 스위치), 아직 안 켬, 오늘 충분히 풂(3문제 이상 또는 세트 완료), 노출 기록
abstract final class LockScreenIntroRule {
  // 소개 시트 최대 노출 횟수 (처음 + 다시 한 번)
  static const int maximumShownCount = 2;
  // 두 번째 노출까지 기다리는 기간
  static const Duration secondShowDelay = Duration(days: 7);
  // 오늘 이만큼 제출하면 소개 대상
  static const int minimumTodaySolvedCount = 3;

  static bool shouldShow({
    required bool isAvailable,
    required bool isEnabled,
    required bool hasStudiedEnoughToday,
    required int shownCount,
    required DateTime? lastShownAt,
    required DateTime now,
  }) {
    if (!isAvailable || isEnabled || !hasStudiedEnoughToday) return false;
    if (shownCount >= maximumShownCount) return false;
    if (shownCount == 0 || lastShownAt == null) return true;
    return now.difference(lastShownAt) >= secondShowDelay;
  }
}
