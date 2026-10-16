import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/learning_refresh.dart';
import '../../providers/unread_notification_providers.dart';

/// 앱 복귀 감시: 포그라운드 복귀(resumed) 시 안 읽은 알림 개수 갱신, 날짜가 바뀌었으면 날짜별 데이터 재조회
/// 탭 쉘을 감싸 로그인 이후 화면에서만 동작
class AppLifecycleRefresher extends ConsumerStatefulWidget {
  const AppLifecycleRefresher({
    super.key,
    required this.child,
    this.readCurrentTime = DateTime.now,
  });

  final Widget child;

  /// 현재 시각 읽기 (테스트에서 날짜 이동용)
  final DateTime Function() readCurrentTime;

  @override
  ConsumerState<AppLifecycleRefresher> createState() =>
      _AppLifecycleRefresherState();
}

class _AppLifecycleRefresherState extends ConsumerState<AppLifecycleRefresher>
    with WidgetsBindingObserver {
  // 마지막으로 데이터를 맞춘 날짜 (기기 현지 날짜 기준)
  late DateTime _lastSyncedCalendarDay;

  @override
  void initState() {
    super.initState();
    _lastSyncedCalendarDay = _calendarDayOf(widget.readCurrentTime());
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    // 복귀할 때마다 안 읽은 알림 개수 갱신 (날짜 변경과 무관)
    ref.read(unreadNotificationCountProvider.notifier).refresh();
    final today = _calendarDayOf(widget.readCurrentTime());
    if (today == _lastSyncedCalendarDay) return;
    _lastSyncedCalendarDay = today;
    refreshDateDependentData(ref.invalidate);
  }

  /// 시각 > 날짜(시·분·초 제거)
  static DateTime _calendarDayOf(DateTime time) =>
      DateTime(time.year, time.month, time.day);

  @override
  Widget build(BuildContext context) => widget.child;
}
