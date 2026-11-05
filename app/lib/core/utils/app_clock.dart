import '../config/app_build_flavor.dart';

/// 앱 시각 단일 원본 (#819): 기기 시각 + 개발자 도구 날짜 넘기기 일수
/// 오늘·D-day·하루 횟수 판정은 DateTime.now() 대신 이것으로 (운영 빌드는 넘긴 일수 0 고정)
abstract final class AppClock {
  // 개발자 도구에서 앞으로 넘긴 일수 (0 = 기기 날짜 그대로)
  static int _devShiftedDayCount = 0;

  /// 개발자 도구에서 앞으로 넘긴 일수
  static int get devShiftedDayCount => _devShiftedDayCount;

  /// 지금 시각 (넘긴 일수만큼 앞당김)
  static DateTime now() {
    final deviceNow = DateTime.now();
    if (_devShiftedDayCount == 0) return deviceNow;
    return deviceNow.add(Duration(days: _devShiftedDayCount));
  }

  /// 넘긴 일수 바꾸기 (0 = 원래 날짜, 운영 빌드는 무시)
  static void setDevShiftedDayCount(int dayCount) {
    if (!AppBuildFlavor.canUseDevTools) return;
    _devShiftedDayCount = dayCount;
  }
}
