import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../data/models/notification/notification_models.dart';
import '../../design/design.dart';
import '../../providers/notification_preference_providers.dart';
import '../../providers/push_notification_providers.dart';
import '../common/app_toast.dart';
import 'settings_group.dart';

/// 알림 종류별 수신 설정 줄 (학습 리마인더·복귀 알림·시험 D-day)
const notificationPreferenceRows = <NotificationPreferenceRowSpec>[
  NotificationPreferenceRowSpec(
    group: NotificationPreferenceGroup.studyReminder,
    icon: CupertinoIcons.flame_fill,
    title: '학습 리마인더',
    subtitle: '오늘의 세트와 연속 학습을 챙겨 드려요',
  ),
  NotificationPreferenceRowSpec(
    group: NotificationPreferenceGroup.comeback,
    icon: CupertinoIcons.hand_raised_fill,
    title: '복귀 알림',
    subtitle: '며칠 쉬었을 때 가볍게 불러요',
  ),
  NotificationPreferenceRowSpec(
    group: NotificationPreferenceGroup.examCountdown,
    icon: CupertinoIcons.calendar,
    title: '시험 D-day',
    subtitle: '시험 30일, 7일, 1일 전에 알려 드려요',
  ),
];

/// 알림 묶음 아래 안내. 설정을 못 읽었으면 세 줄이 없으므로 안내도 없다.
/// 알림 받기를 켜고 끌 때 묶음 높이가 바뀌지 않게 두 상태 모두 한 줄을 둔다 (#774).
String? notificationPreferenceFooter(WidgetRef ref) {
  final hasPreference =
      ref.watch(notificationPreferenceProvider).valueOrNull != null;
  if (!hasPreference) return null;
  final isPushEnabled = ref.watch(pushEnabledProvider).valueOrNull ?? false;
  return isPushEnabled ? '공지는 이 설정과 상관없이 받아요' : '알림 받기를 켜면 고를 수 있어요';
}

/// 알림 종류 한 줄. 설정 묶음이 줄 사이 구분선을 그리도록 줄마다 따로 둔다 (#774).
/// 이 기기 알림 받기가 꺼져 있으면 스위치를 잠그고 흐리게 둔다 (이유는 묶음 아래 안내 한 줄).
class NotificationPreferenceTile extends ConsumerWidget {
  const NotificationPreferenceTile({super.key, required this.spec});

  final NotificationPreferenceRowSpec spec;

  /// 잠긴 줄의 흐림 정도 (iOS 설정 앱의 비활성 줄과 비슷한 값)
  static const double _lockedOpacity = 0.4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final preference = ref.watch(notificationPreferenceProvider).valueOrNull;
    final isPushEnabled = ref.watch(pushEnabledProvider).valueOrNull ?? false;
    // 설정을 아직 못 읽었거나 로그아웃이면 화면이 줄을 넣지 않는다. 그 사이 다시 그려지면 빈 자리
    if (preference == null) return const SizedBox.shrink();

    return Opacity(
      opacity: isPushEnabled ? 1 : _lockedOpacity,
      child: SettingsRow(
        icon: spec.icon,
        iconColor: colors.accent,
        title: spec.title,
        subtitle: spec.subtitle,
        shouldShowChevron: false,
        trailing: CupertinoSwitch(
          value: preference.isEnabled(spec.group),
          activeTrackColor: colors.accent,
          onChanged: isPushEnabled
              ? (value) => _change(context, ref, value)
              : null,
        ),
      ),
    );
  }

  Future<void> _change(
    BuildContext context,
    WidgetRef ref,
    bool isEnabled,
  ) async {
    try {
      await ref
          .read(notificationPreferenceProvider.notifier)
          .setGroupEnabled(spec.group, isEnabled);
    } on AppException catch (exception) {
      // 값은 Notifier 가 이전 상태로 되돌려 둠. 이유만 알림
      if (context.mounted) showAppToast(context, exception.message);
    }
  }
}

class NotificationPreferenceRowSpec {
  const NotificationPreferenceRowSpec({
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
