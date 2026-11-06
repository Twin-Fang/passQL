import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logging/app_logger.dart';
import '../../data/models/notification/notification_models.dart';
import '../../data/sources/api_providers.dart';
import 'member_response_guard.dart';
import 'session_reset.dart';

/// 안 읽은 알림 개수 단일 출처 (종 아이콘·탭 개수·앱 아이콘 숫자가 모두 이 값)
/// 로그인·회원 변경 시 조회, 이후 복귀·푸시 수신·알림함 진입·읽음 처리 때 [refresh] (화면이 따로 조회하지 않음)
/// 조회 실패는 조용히 무시하고 이전 값 유지, 로그아웃이면 0
/// 회원 전환 전에 출발한 조회 응답은 버림 (이전 회원 개수가 새 회원을 덮지 않게)
class UnreadNotificationCountNotifier extends Notifier<UnreadNotificationCount>
    with MemberResponseGuard {
  // 진행 중인 조회 (동시에 여러 번 불려도 1회만 요청)
  Future<void>? _inFlightRefresh;

  @override
  UnreadNotificationCount build() {
    advanceResponseGenerationOnDispose(ref);
    // 이전 회원의 진행 중 조회에 합치지 않음
    _inFlightRefresh = null;
    final memberUuid = ref.watch(currentMemberUuidProvider);
    if (memberUuid != null) Future.microtask(refresh);
    return const UnreadNotificationCount();
  }

  /// 서버에서 개수 다시 조회 (로그아웃 상태·실패 > 이전 값 유지)
  Future<void> refresh() {
    final existingRefresh = _inFlightRefresh;
    if (existingRefresh != null) return existingRefresh;
    late final Future<void> startedRefresh;
    startedRefresh = _fetchCount().whenComplete(() {
      // 회원 전환 뒤 새로 시작한 조회 표시는 지우지 않음
      if (identical(_inFlightRefresh, startedRefresh)) _inFlightRefresh = null;
    });
    return _inFlightRefresh = startedRefresh;
  }

  Future<void> _fetchCount() async {
    if (ref.read(currentMemberUuidProvider) == null) return;
    final requestGeneration = currentResponseGeneration;
    try {
      final count = await ref.read(notificationApiProvider).getUnreadCount();
      if (!isStaleResponse(requestGeneration)) state = count;
    } catch (error) {
      AppLogger.warn('notification unread', 'refresh failed : $error');
    }
  }
}

final unreadNotificationCountProvider =
    NotifierProvider<UnreadNotificationCountNotifier, UnreadNotificationCount>(
      UnreadNotificationCountNotifier.new,
    );
