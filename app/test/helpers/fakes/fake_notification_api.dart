import 'package:passql_app/data/models/notification/notification_models.dart';
import 'package:passql_app/data/sources/notification_api.dart';

/// 알림함 서버 대신 목록·개수를 돌려주고 읽음 요청을 남기는 가짜 API
class FakeNotificationApi implements NotificationApiClient {
  FakeNotificationApi({
    this.generalItems = const [],
    this.noticeItems = const [],
    this.pageSize = 20,
  });

  List<NotificationItem> generalItems;
  List<NotificationItem> noticeItems;
  int pageSize;
  bool shouldFail = false;

  int unreadCountRequestCount = 0;
  final readRequests = <String>[];
  final readAllRequests = <String>[];

  List<NotificationItem> _itemsOf(String category) =>
      category == NotificationCategory.notice.serverValue
      ? noticeItems
      : generalItems;

  @override
  Future<NotificationPage> getNotifications({
    required String category,
    String? cursor,
    int size = 20,
  }) async {
    if (shouldFail) throw Exception('서버 오류');
    final items = _itemsOf(category);
    final start = cursor == null ? 0 : int.parse(cursor);
    final end = (start + pageSize).clamp(0, items.length);
    return NotificationPage(
      items: items.sublist(start, end),
      nextCursor: end < items.length ? '$end' : null,
    );
  }

  @override
  Future<UnreadNotificationCount> getUnreadCount() async {
    unreadCountRequestCount++;
    if (shouldFail) throw Exception('서버 오류');
    final general = generalItems.where((item) => !item.isRead).length;
    final notice = noticeItems.where((item) => !item.isRead).length;
    return UnreadNotificationCount(
      general: general,
      notice: notice,
      total: general + notice,
    );
  }

  @override
  Future<void> markRead(String id, String category) async {
    readRequests.add('$category:$id');
    final items = _itemsOf(category);
    final index = items.indexWhere((item) => item.id == id);
    if (index >= 0) items[index] = items[index].copyWithRead();
  }

  @override
  Future<void> markAllRead(String category) async {
    if (shouldFail) throw Exception('서버 오류');
    readAllRequests.add(category);
    final items = _itemsOf(category);
    for (var index = 0; index < items.length; index++) {
      items[index] = items[index].copyWithRead();
    }
  }
}

/// 테스트용 알림함 항목
NotificationItem fakeNotificationItem(
  String id, {
  NotificationCategory category = NotificationCategory.general,
  NotificationType type = NotificationType.adminMessage,
  bool isRead = false,
  bool isImportant = false,
  String? linkTarget,
  String? linkQuestionUuid,
}) => NotificationItem(
  id: id,
  category: category,
  type: type,
  title: '제목 $id',
  body: '본문 $id',
  linkTarget: linkTarget,
  linkQuestionUuid: linkQuestionUuid,
  isRead: isRead,
  createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  isImportant: isImportant,
);
