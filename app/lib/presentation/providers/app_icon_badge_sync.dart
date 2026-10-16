import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notification/app_icon_badge_updater.dart';
import '../../data/models/notification/notification_models.dart';
import 'unread_notification_providers.dart';

/// 개수 변경 > 앱 아이콘 숫자 반영 (main 에서 1회, 로그아웃으로 0이 되면 숫자 제거)
void startAppIconBadgeSync(ProviderContainer container) {
  container.listen<UnreadNotificationCount>(unreadNotificationCountProvider, (
    previous,
    next,
  ) {
    if (previous?.total == next.total) return;
    AppIconBadgeUpdater.current.update(next.total);
  });
}
