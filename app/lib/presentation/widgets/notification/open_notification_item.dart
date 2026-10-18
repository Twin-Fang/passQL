import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/monitoring/app_analytics.dart';
import '../../../core/push/push_link.dart';
import '../../../data/models/notification/notification_models.dart';
import '../../../router/app_routes.dart';
import '../../../router/push_link_routes.dart';
import '../../providers/notification_inbox_providers.dart';

/// 알림함 항목 열기: 분석 기록 > 읽음 처리 > 공지는 공지 상세 화면(#529), 알림은 허용 목록 화면 이동
/// 이동 정보가 허용 목록 밖이거나 없으면 읽음 처리만 함
Future<void> openNotificationItem(
  BuildContext context,
  WidgetRef ref,
  NotificationItem item,
) async {
  unawaited(
    ref
        .read(appAnalyticsProvider)
        .logNotificationItemOpened(item.type.serverValue),
  );
  // 읽음 처리는 기다리지 않음 (이동 지연 방지)
  if (!item.isRead) {
    unawaited(
      ref
          .read(notificationInboxProvider(item.category).notifier)
          .markRead(item.id),
    );
  }
  if (item.category == NotificationCategory.notice) {
    await GoRouter.of(context).push(AppRoutes.noticeDetail(item.id));
    return;
  }
  final link = PushLink.fromData({
    PushDataKeys.linkTarget: item.linkTarget,
    PushDataKeys.questionUuid: item.linkQuestionUuid,
  });
  if (link != null) await openPushLink(GoRouter.of(context), link);
}
