import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/monitoring/app_analytics.dart';
import '../../../core/notification/notification_permission_prompt_result.dart';
import '../../../data/push/push_notification_service.dart';
import '../../design/design.dart';
import '../../providers/push_notification_providers.dart';
import '../common/app_toast.dart';
import 'notification_permission_sheet.dart';
import 'notification_permission_texts.dart';

/// 알림 권한 안내 1회: 안내 시트 > "알림 받기"일 때만 시스템 권한 요청 > 결과 기록(분석)
/// "나중에"·시트 닫기는 7일간 다시 묻지 않음. 권한을 거부해도 앱 기능은 그대로
Future<NotificationPermissionPromptResult> runNotificationPermissionPrompt(
  BuildContext context,
  WidgetRef ref,
) async {
  final isAccepted = await showNotificationPermissionSheet(context);
  final NotificationPermissionPromptResult result;
  if (!isAccepted) {
    await ref.read(pushPermissionPromptStoreProvider).deferPrompt();
    result = NotificationPermissionPromptResult.later;
  } else {
    result = await _requestSystemPermission(ref);
  }
  await ref.read(appAnalyticsProvider).logNotificationPermissionPrompt(result);
  return result;
}

/// 시스템 권한 요청 + 서버 등록 (권한 거부 > denied, 그 외 실패는 권한은 허용됐으므로 accepted)
Future<NotificationPermissionPromptResult> _requestSystemPermission(
  WidgetRef ref,
) async {
  try {
    await ref.read(pushEnabledProvider.notifier).setPushEnabled(true);
  } on PushPermissionDeniedException {
    return NotificationPermissionPromptResult.denied;
  } catch (_) {
    // 토큰 발급·서버 등록 실패는 다음 실행 때 다시 등록
  }
  return NotificationPermissionPromptResult.accepted;
}

/// 거부된 알림 권한 > 기기 설정 안내 (열 수 없는 플랫폼은 직접 켜는 방법 토스트)
Future<void> guideToDeviceNotificationSettings(
  BuildContext context,
  WidgetRef ref,
) async {
  final isOpenChosen = await showPassqlConfirmDialog(
    context,
    title: NotificationPermissionTexts.openSettingsTitle,
    message: NotificationPermissionTexts.openSettingsMessage,
    confirmLabel: NotificationPermissionTexts.openSettingsLabel,
    isDestructive: false,
  );
  if (!isOpenChosen) return;
  final isOpened = await ref
      .read(pushNotificationServiceProvider)
      .openDeviceNotificationSettings();
  if (!isOpened && context.mounted) {
    showAppToast(context, NotificationPermissionTexts.manualSettingsGuide);
  }
}
