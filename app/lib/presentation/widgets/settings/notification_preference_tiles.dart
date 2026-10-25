import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../data/models/notification/notification_models.dart';
import '../../design/design.dart';
import '../../providers/notification_preference_providers.dart';
import '../../providers/push_notification_providers.dart';
import '../common/app_toast.dart';
import 'settings_group.dart';

/// 알림 종류별 수신 설정 3줄 (학습 리마인더·복귀 알림·시험 D-day)
/// 이 기기 알림 받기가 꺼져 있으면 스위치를 잠그고 이유를 안내 (관리자 공지는 설정과 무관하게 받음)
class NotificationPreferenceTiles extends ConsumerWidget {
  const NotificationPreferenceTiles({super.key});

  static const _rows = <_PreferenceRowSpec>[
    _PreferenceRowSpec(
      group: NotificationPreferenceGroup.studyReminder,
      icon: CupertinoIcons.flame_fill,
      title: '학습 리마인더',
      subtitle: '오늘의 세트와 연속 학습을 챙겨 드려요',
    ),
    _PreferenceRowSpec(
      group: NotificationPreferenceGroup.comeback,
      icon: CupertinoIcons.hand_raised_fill,
      title: '복귀 알림',
      subtitle: '며칠 쉬었을 때 가볍게 불러요',
    ),
    _PreferenceRowSpec(
      group: NotificationPreferenceGroup.examCountdown,
      icon: CupertinoIcons.calendar,
      title: '시험 D-day',
      subtitle: '시험 30일·7일·1일 전에 알려 드려요',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final preference = ref.watch(notificationPreferenceProvider).valueOrNull;
    final isPushEnabled = ref.watch(pushEnabledProvider).valueOrNull ?? false;
    // 설정을 아직 못 읽었거나 로그아웃이면 숨김
    if (preference == null) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in _rows)
          SettingsRow(
            icon: row.icon,
            iconColor: colors.accent,
            title: row.title,
            subtitle: isPushEnabled ? row.subtitle : '알림 받기를 켜면 고를 수 있어요',
            shouldShowChevron: false,
            trailing: CupertinoSwitch(
              value: preference.isEnabled(row.group),
              activeTrackColor: colors.accent,
              onChanged: isPushEnabled
                  ? (value) => _change(context, ref, row.group, value)
                  : null,
            ),
          ),
      ],
    );
  }

  Future<void> _change(
    BuildContext context,
    WidgetRef ref,
    NotificationPreferenceGroup group,
    bool isEnabled,
  ) async {
    try {
      await ref
          .read(notificationPreferenceProvider.notifier)
          .setGroupEnabled(group, isEnabled);
    } on AppException catch (exception) {
      // 값은 Notifier 가 이전 상태로 되돌려 둠. 이유만 알림
      if (context.mounted) showAppToast(context, exception.message);
    }
  }
}

class _PreferenceRowSpec {
  const _PreferenceRowSpec({
    required this.group,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final NotificationPreferenceGroup group;
  final IconData icon;
  final String title;
  final String subtitle;
}
