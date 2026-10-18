import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_call.dart';
import '../../data/models/meta/app_config.dart';
import '../../data/models/notification/notification_models.dart';
import '../../data/sources/api_providers.dart';
import 'session_reset.dart';
import 'unread_notification_providers.dart';

/// 알림함 탭 1개의 목록 상태: 불러온 항목, 다음 페이지 커서, 추가 로딩 중 여부
@immutable
class NotificationInboxState {
  const NotificationInboxState({
    required this.items,
    this.nextCursor,
    this.isLoadingMore = false,
  });

  final List<NotificationItem> items;

  /// null 이면 마지막 페이지
  final String? nextCursor;
  final bool isLoadingMore;

  bool get hasMore => nextCursor != null;

  NotificationInboxState copyWith({
    List<NotificationItem>? items,
    bool? isLoadingMore,
  }) => NotificationInboxState(
    items: items ?? this.items,
    nextCursor: nextCursor,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

/// 알림함 탭 목록: 첫 페이지 조회, 커서 무한 스크롤, 읽음 처리(화면에 먼저 반영 > 서버 > 개수 재조회)
/// 로그아웃이면 로딩 유지 (API 호출 없음, 빈 목록을 이전 값으로 남기면 로그인 후 조회 실패가 빈 목록으로 보임)
class NotificationInboxNotifier
    extends
        AutoDisposeFamilyAsyncNotifier<
          NotificationInboxState,
          NotificationCategory
        > {
  @override
  Future<NotificationInboxState> build(NotificationCategory arg) async {
    if (ref.watch(currentMemberUuidProvider) == null) {
      return waitForSignedInMember();
    }
    final page = await callApiThrowingAppException(
      ref
          .read(notificationApiProvider)
          .getNotifications(category: arg.serverValue),
    );
    return NotificationInboxState(
      items: page.items,
      nextCursor: page.nextCursor,
    );
  }

  /// 처음부터 다시 조회 (당겨서 새로고침·알림함 진입)
  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }

  /// 다음 페이지 이어 붙이기 (마지막 페이지·로딩 중·실패 > 변화 없음)
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final page = await ref
          .read(notificationApiProvider)
          .getNotifications(
            category: arg.serverValue,
            cursor: current.nextCursor,
          );
      state = AsyncData(
        NotificationInboxState(
          items: [...current.items, ...page.items],
          nextCursor: page.nextCursor,
        ),
      );
    } catch (error) {
      debugPrint('[notification inbox] load more failed : $error');
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  /// 1건 읽음: 화면에 먼저 반영 > 서버 (실패해도 화면은 유지) > 개수 재조회
  Future<void> markRead(String notificationId) async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: [
          for (final item in current.items)
            item.id == notificationId ? item.copyWithRead() : item,
        ],
      ),
    );
    try {
      await ref
          .read(notificationApiProvider)
          .markRead(notificationId, arg.serverValue);
    } catch (error) {
      debugPrint('[notification inbox] mark read failed : $error');
    }
    await ref.read(unreadNotificationCountProvider.notifier).refresh();
  }

  /// 이 탭 전체 읽음: 화면에 먼저 반영 > 서버 > 개수 재조회 (실패 시 되돌리고 예외 그대로)
  Future<void> markAllRead() async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: [for (final item in current.items) item.copyWithRead()],
      ),
    );
    try {
      await callApiThrowingAppException(
        ref.read(notificationApiProvider).markAllRead(arg.serverValue),
      );
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    } finally {
      // (성공·실패 공통)
      await ref.read(unreadNotificationCountProvider.notifier).refresh();
    }
  }
}

final notificationInboxProvider = AsyncNotifierProvider.autoDispose
    .family<
      NotificationInboxNotifier,
      NotificationInboxState,
      NotificationCategory
    >(NotificationInboxNotifier.new);

/// 홈 배너에 띄울 공지 1건: 안 읽은 중요 공지 중 서버 순서상 첫 번째 (없거나 조회 실패 > null)
/// 공지 탭 목록과 같은 데이터라 읽음 처리하면 배너도 함께 사라짐
final homeNoticeProvider = Provider.autoDispose<AppNotice?>((ref) {
  final inbox = ref
      .watch(notificationInboxProvider(NotificationCategory.notice))
      .valueOrNull;
  final notice = inbox?.items
      .where((item) => item.isImportant && !item.isRead)
      .firstOrNull;
  if (notice == null) return null;
  return AppNotice(
    noticeUuid: notice.id,
    title: notice.title,
    body: notice.body,
    isImportant: true,
    // 공지 탭 createdAt = 서버 게시 시각
    publishedAt: notice.createdAt,
  );
});

/// 홈 공지 배너 닫기 = 서버 읽음 (낙관적: 서버 실패해도 배너는 닫힘)
Future<void> dismissHomeNotice(WidgetRef ref, String noticeId) => ref
    .read(notificationInboxProvider(NotificationCategory.notice).notifier)
    .markRead(noticeId);
