import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/notification/notification_models.dart';
import '../../data/sources/api_providers.dart';
import 'auth_provider.dart';

/// 안 읽은 알림 개수 단일 출처 (종 아이콘·탭 개수·앱 아이콘 숫자가 모두 이 값)
/// 로그인·회원 변경 시 조회, 이후 복귀·푸시 수신·알림함 진입·읽음 처리 때 [refresh] (화면이 따로 조회하지 않음)
/// 조회 실패는 조용히 무시하고 이전 값 유지, 로그아웃이면 0
class UnreadNotificationCountNotifier
    extends Notifier<UnreadNotificationCount> {
  bool _isDisposed = false;

  // 진행 중인 조회 (동시에 여러 번 불려도 1회만 요청)
  Future<void>? _inFlightRefresh;

  @override
  UnreadNotificationCount build() {
    _isDisposed = false;
    _inFlightRefresh = null;
    ref.onDispose(() => _isDisposed = true);
    final memberUuid = ref.watch(
      authProvider.select((session) => session.valueOrNull?.memberUuid),
    );
    if (memberUuid != null) Future.microtask(refresh);
    return const UnreadNotificationCount();
  }

  /// 서버에서 개수 다시 조회 (로그아웃 상태·실패 > 이전 값 유지)
  Future<void> refresh() => _inFlightRefresh ??= _fetchCount().whenComplete(
    () => _inFlightRefresh = null,
  );

  Future<void> _fetchCount() async {
    if (ref.read(authProvider).valueOrNull == null) return;
    try {
      final count = await ref.read(notificationApiProvider).getUnreadCount();
      if (!_isDisposed) state = count;
    } catch (error) {
      debugPrint('[notification unread] refresh failed : $error');
    }
  }
}

final unreadNotificationCountProvider =
    NotifierProvider<UnreadNotificationCountNotifier, UnreadNotificationCount>(
      UnreadNotificationCountNotifier.new,
    );
