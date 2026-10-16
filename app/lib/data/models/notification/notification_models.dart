/// 알림함 탭 2종 (서버 category 값과 1:1)
enum NotificationCategory {
  general('GENERAL'),
  notice('NOTICE');

  const NotificationCategory(this.serverValue);

  final String serverValue;
}

/// 알림이 생긴 이유 (서버 type 값, 모르는 값은 [unknown])
enum NotificationType {
  adminMessage('ADMIN_MESSAGE'),
  reportResolved('REPORT_RESOLVED'),
  dailySetReminder('DAILY_SET_REMINDER'),
  notice('NOTICE'),
  unknown('UNKNOWN');

  const NotificationType(this.serverValue);

  final String serverValue;

  /// 서버 값 > 종류 (새 종류가 추가돼도 앱이 깨지지 않게 unknown)
  static NotificationType fromServerValue(Object? value) => values.firstWhere(
    (type) => type.serverValue == value && type != unknown,
    orElse: () => unknown,
  );
}

/// 알림함 항목 1건: 일반 알림 또는 공지
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.category,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.linkTarget,
    this.linkQuestionUuid,
    this.isImportant = false,
  });

  /// 일반 알림은 알림 UUID, 공지는 app_notice_uuid
  final String id;
  final NotificationCategory category;
  final NotificationType type;
  final String title;
  final String body;

  /// 이동 화면 (core/push PushLinkTarget 허용 목록과 같은 값)
  final String? linkTarget;
  final String? linkQuestionUuid;
  final bool isRead;
  final DateTime createdAt;
  final bool isImportant;

  NotificationItem copyWithRead() => NotificationItem(
    id: id,
    category: category,
    type: type,
    title: title,
    body: body,
    linkTarget: linkTarget,
    linkQuestionUuid: linkQuestionUuid,
    isRead: true,
    createdAt: createdAt,
    isImportant: isImportant,
  );

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: json['id'] as String,
        category: json['category'] == NotificationCategory.notice.serverValue
            ? NotificationCategory.notice
            : NotificationCategory.general,
        type: NotificationType.fromServerValue(json['type']),
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        linkTarget: json['linkTarget'] as String?,
        linkQuestionUuid: json['linkQuestionUuid'] as String?,
        isRead: json['isRead'] as bool? ?? false,
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        isImportant: json['isImportant'] as bool? ?? false,
      );
}

/// 알림함 목록 한 페이지: 항목 + 다음 페이지 커서 (null 이면 끝)
class NotificationPage {
  const NotificationPage({required this.items, this.nextCursor});

  final List<NotificationItem> items;
  final String? nextCursor;

  factory NotificationPage.fromJson(Map<String, dynamic> json) =>
      NotificationPage(
        items: [
          for (final item in json['items'] as List? ?? const [])
            NotificationItem.fromJson(item as Map<String, dynamic>),
        ],
        nextCursor: json['nextCursor'] as String?,
      );
}

/// 안 읽은 개수: 탭별 + 합계 (앱 아이콘 숫자·종 아이콘 단일 값)
class UnreadNotificationCount {
  const UnreadNotificationCount({
    this.general = 0,
    this.notice = 0,
    this.total = 0,
  });

  final int general;
  final int notice;
  final int total;

  /// 탭 하나의 개수
  int of(NotificationCategory category) =>
      category == NotificationCategory.general ? general : notice;

  factory UnreadNotificationCount.fromJson(Map<String, dynamic> json) =>
      UnreadNotificationCount(
        general: json['general'] as int? ?? 0,
        notice: json['notice'] as int? ?? 0,
        total: json['total'] as int? ?? 0,
      );

  @override
  bool operator ==(Object other) =>
      other is UnreadNotificationCount &&
      other.general == general &&
      other.notice == notice &&
      other.total == total;

  @override
  int get hashCode => Object.hash(general, notice, total);
}
