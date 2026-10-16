import 'package:flutter/cupertino.dart';

import '../../../data/models/notification/notification_models.dart';
import '../../design/design.dart';

/// 알림 종류별 아이콘·타일 색 (목록 행 왼쪽 아이콘 타일)
@immutable
class NotificationTypeAppearance {
  const NotificationTypeAppearance({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  /// 종류 > 모양 (중요 공지는 느낌표, 일반 공지는 정보)
  static NotificationTypeAppearance of(
    NotificationItem item,
    PassqlColors colors,
  ) => switch (item.type) {
    NotificationType.reportResolved => NotificationTypeAppearance(
      icon: CupertinoIcons.checkmark_alt,
      color: colors.correct,
    ),
    NotificationType.adminMessage => NotificationTypeAppearance(
      icon: CupertinoIcons.mail_solid,
      color: colors.accent,
    ),
    NotificationType.dailySetReminder => NotificationTypeAppearance(
      icon: CupertinoIcons.calendar,
      color: colors.accent,
    ),
    NotificationType.notice when item.isImportant => NotificationTypeAppearance(
      icon: CupertinoIcons.exclamationmark,
      color: colors.wrong,
    ),
    NotificationType.notice => NotificationTypeAppearance(
      icon: CupertinoIcons.info,
      color: colors.secondaryLabel,
    ),
    NotificationType.unknown => NotificationTypeAppearance(
      icon: CupertinoIcons.bell_fill,
      color: colors.accent,
    ),
  };
}
