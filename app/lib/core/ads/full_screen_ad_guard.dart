import 'dart:async';

/// 전체 화면 광고 겹침·광고 이탈 판정 공통 지점: 전면·앱 오프닝 광고가 함께 사용
/// 기록 2개: 전체 화면 광고 표시 중 여부, 마지막 광고 클릭 시각 (배너·네이티브·전면·앱 오프닝 공통) + 광고 닫힘 대기
abstract final class FullScreenAdGuard {
  /// 광고 클릭 뒤 이 시간 안에 백그라운드로 가면 광고가 연 외부 화면으로 봄 (5초)
  static const adClickToBackgroundWindow = Duration(seconds: 5);

  static bool _isFullScreenAdShowing = false;
  static DateTime? _lastAdClickedAt;
  // 광고가 닫히길 기다리는 쪽 (닫힐 때 한꺼번에 완료)
  static final List<Completer<void>> _closeWaiters = [];

  /// 전면·앱 오프닝 광고 중 하나가 화면에 떠 있는지
  static bool get isFullScreenAdShowing => _isFullScreenAdShowing;

  static void markFullScreenAdShowing() => _isFullScreenAdShowing = true;

  static void markFullScreenAdClosed() {
    _isFullScreenAdShowing = false;
    for (final closeWaiter in _closeWaiters) {
      closeWaiter.complete();
    }
    _closeWaiters.clear();
  }

  /// 전체 화면 광고가 닫힐 때까지 대기 (떠 있지 않으면 바로 완료)
  static Future<void> waitUntilFullScreenAdClosed() {
    if (!_isFullScreenAdShowing) return Future.value();
    final closeWaiter = Completer<void>();
    _closeWaiters.add(closeWaiter);
    return closeWaiter.future;
  }

  /// 광고 클릭 1회 기록 (SDK onAdClicked 에서 호출)
  static void recordAdClicked([DateTime? clickedAt]) =>
      _lastAdClickedAt = clickedAt ?? DateTime.now();

  /// 지금 백그라운드로 가는 이유가 광고인지 (전체 화면 광고 표시 중 또는 방금 광고 클릭)
  static bool isBackgroundCausedByAdAt(DateTime now) {
    if (_isFullScreenAdShowing) return true;
    final lastAdClickedAt = _lastAdClickedAt;
    if (lastAdClickedAt == null) return false;
    return now.difference(lastAdClickedAt) <= adClickToBackgroundWindow;
  }

  /// 테스트 간 상태 초기화
  static void resetForTest() {
    _isFullScreenAdShowing = false;
    _lastAdClickedAt = null;
    _closeWaiters.clear();
  }
}
