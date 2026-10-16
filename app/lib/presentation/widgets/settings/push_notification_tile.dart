import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/push/push_messaging_client.dart';
import '../../../data/push/push_notification_service.dart';
import '../../design/design.dart';
import '../../providers/push_notification_providers.dart';
import '../common/app_toast.dart';
import '../notification/notification_permission_flow.dart';
import 'settings_group.dart';

/// 알림 받기 토글 (이 기기 수신 동의 = 서버 값)
/// 켤 때: 아직 안 물었으면 안내 시트 > 시스템 권한, 이미 거부했으면 기기 설정 안내
class PushNotificationTile extends ConsumerWidget {
  const PushNotificationTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final pushEnabled = ref.watch(pushEnabledProvider);
    final isEnabled = pushEnabled.valueOrNull ?? false;

    return SettingsRow(
      icon: CupertinoIcons.bell_fill,
      iconColor: colors.accent,
      title: '알림 받기',
      subtitle: isEnabled ? '오늘의 세트·새 소식을 알려 드려요' : '알림을 보내지 않아요',
      shouldShowChevron: false,
      trailing: CupertinoSwitch(
        value: isEnabled,
        activeTrackColor: colors.accent,
        // 등록 확인 중에는 조작 막음
        onChanged: pushEnabled.isLoading
            ? null
            : (value) => _change(context, ref, value),
      ),
    );
  }

  Future<void> _change(
    BuildContext context,
    WidgetRef ref,
    bool isEnabled,
  ) async {
    if (isEnabled && await _guideIfPermissionNotGranted(context, ref)) return;
    String? failureMessage;
    try {
      await ref.read(pushEnabledProvider.notifier).setPushEnabled(isEnabled);
    } on PushPermissionDeniedException {
      if (context.mounted) await guideToDeviceNotificationSettings(context, ref);
    } on PushSettingException catch (exception) {
      failureMessage = exception.message;
    } on AppException catch (exception) {
      failureMessage = exception.message;
    }
    // 값은 Notifier 가 이전 상태로 되돌려 둠. 이유만 알림
    if (failureMessage != null && context.mounted) {
      showAppToast(context, failureMessage);
    }
  }

  /// 켜기 전 권한 확인: 안 물었으면 안내 시트, 거부 상태면 기기 설정 안내 (처리했으면 true)
  Future<bool> _guideIfPermissionNotGranted(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final permissionStatus = await ref
        .read(pushNotificationServiceProvider)
        .readPermissionStatus();
    if (!context.mounted) return true;
    switch (permissionStatus) {
      case PushPermissionStatus.granted:
        return false;
      case PushPermissionStatus.notDetermined:
        await runNotificationPermissionPrompt(context, ref);
        return true;
      case PushPermissionStatus.denied:
        await guideToDeviceNotificationSettings(context, ref);
        return true;
    }
  }
}
