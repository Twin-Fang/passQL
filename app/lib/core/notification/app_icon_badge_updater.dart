import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter/foundation.dart';

/// 앱 아이콘 숫자 반영: 개수 > 숫자 표시, 0 > 제거
/// 기본은 아무것도 하지 않는 구현 > main 에서 [startAppIconBadge] 로 교체 (테스트는 가짜 구현)
abstract class AppIconBadgeUpdater {
  const AppIconBadgeUpdater();

  /// 앱 전역 갱신기. 안 읽은 개수 동기화가 이 값을 씀
  static AppIconBadgeUpdater current = const NoopAppIconBadgeUpdater();

  /// 아이콘 숫자를 [unreadCount] 로 맞춤 (0 이하는 제거, 실패는 조용히 무시)
  Future<void> update(int unreadCount);
}

/// 아무것도 하지 않는 구현 (테스트·초기화 전)
class NoopAppIconBadgeUpdater extends AppIconBadgeUpdater {
  const NoopAppIconBadgeUpdater();

  @override
  Future<void> update(int unreadCount) async {}
}

/// app_badge_plus 로 동작하는 구현 (iOS, 지원하는 Android 런처)
class AppBadgePlusIconBadgeUpdater extends AppIconBadgeUpdater {
  const AppBadgePlusIconBadgeUpdater();

  @override
  Future<void> update(int unreadCount) async {
    try {
      if (!await AppBadgePlus.isSupported()) return;
      await AppBadgePlus.updateBadge(unreadCount < 0 ? 0 : unreadCount);
    } catch (error) {
      // 숫자는 보조 표시라 실패해도 앱 동작에 영향 없음
      debugPrint('[app icon badge] update failed : $error');
    }
  }
}

/// 앱 아이콘 숫자 준비 (main 에서 1회): 전역 갱신기를 app_badge_plus 구현으로 교체
void startAppIconBadge() {
  AppIconBadgeUpdater.current = const AppBadgePlusIconBadgeUpdater();
}
