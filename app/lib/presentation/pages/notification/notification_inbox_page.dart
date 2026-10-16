import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/monitoring/app_analytics.dart';
import '../../../data/models/notification/notification_models.dart';
import '../../design/design.dart';
import '../../providers/notification_inbox_providers.dart';
import '../../providers/unread_notification_providers.dart';
import '../../widgets/notification/notification_inbox_list.dart';
import '../../widgets/notification/notification_segmented_control.dart';

/// 알림함: 알림 | 공지 탭, 탭별 안 읽은 개수, 목록은 [NotificationInboxList]
/// 진입 시 목록·안 읽은 개수를 다시 조회
class NotificationInboxPage extends ConsumerStatefulWidget {
  const NotificationInboxPage({super.key});

  @override
  ConsumerState<NotificationInboxPage> createState() =>
      _NotificationInboxPageState();
}

class _NotificationInboxPageState extends ConsumerState<NotificationInboxPage> {
  NotificationCategory _selectedCategory = NotificationCategory.general;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshOnEnter());
  }

  /// 진입 갱신: 두 탭 목록 재조회(이미 불러온 것만) + 안 읽은 개수 + 열림 기록
  void _refreshOnEnter() {
    if (!mounted) return;
    for (final category in NotificationCategory.values) {
      final inboxProvider = notificationInboxProvider(category);
      // 이번 진입에서 처음 만들어져 조회 중인 목록은 다시 조회하지 않음
      if (ref.exists(inboxProvider) && !ref.read(inboxProvider).isLoading) {
        ref.invalidate(inboxProvider);
      }
    }
    unawaited(ref.read(unreadNotificationCountProvider.notifier).refresh());
    unawaited(
      ref
          .read(appAnalyticsProvider)
          .logNotificationInboxOpened(_selectedCategory.name),
    );
  }

  void _selectCategory(NotificationCategory category) {
    if (category == _selectedCategory) return;
    setState(() => _selectedCategory = category);
    unawaited(
      ref.read(appAnalyticsProvider).logNotificationInboxOpened(category.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    return Scaffold(
      backgroundColor: context.passqlColors.background,
      appBar: const PassqlNavBar(title: '알림함', leading: PassqlNavLeading.back),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PassqlSpacing.md,
              PassqlSpacing.xs,
              PassqlSpacing.md,
              PassqlSpacing.xs,
            ),
            child: NotificationSegmentedControl(
              selectedCategory: _selectedCategory,
              unreadCountOf: unreadCount.of,
              onSelected: _selectCategory,
            ),
          ),
          Expanded(
            child: NotificationInboxList(
              key: ValueKey(_selectedCategory),
              category: _selectedCategory,
            ),
          ),
        ],
      ),
    );
  }
}
