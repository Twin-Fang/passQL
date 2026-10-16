import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/push/push_messaging_client.dart';
import '../../../data/push/push_notification_service.dart';
import '../../providers/push_notification_providers.dart';
import 'notification_permission_flow.dart';

/// 알림 권한 안내: 홈 첫 진입 후 1회, 아직 권한을 묻지 않았고 "나중에" 후 7일이 지났을 때만
/// 탭 쉘을 감싸 로그인 이후 화면에서만 동작 (앱 실행마다 한 번만 시도)
class NotificationPermissionPrompter extends ConsumerStatefulWidget {
  const NotificationPermissionPrompter({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NotificationPermissionPrompter> createState() =>
      _NotificationPermissionPrompterState();
}

class _NotificationPermissionPrompterState
    extends ConsumerState<NotificationPermissionPrompter> {
  // 첫 화면이 자리 잡은 뒤 안내하기 위한 대기 (권장 업데이트 안내와 겹침 방지)
  static const Duration _promptDelay = Duration(seconds: 2);

  Timer? _promptTimer;

  @override
  void initState() {
    super.initState();
    _promptTimer = Timer(_promptDelay, _promptIfNeeded);
  }

  @override
  void dispose() {
    _promptTimer?.cancel();
    super.dispose();
  }

  Future<void> _promptIfNeeded() async {
    if (!mounted) return;
    final permissionStatus = await ref
        .read(pushNotificationServiceProvider)
        .readPermissionStatus();
    // 이미 허용·거부했으면 안내하지 않음 (거부는 설정 토글에서 기기 설정으로 안내)
    if (permissionStatus != PushPermissionStatus.notDetermined || !mounted) {
      return;
    }
    if (!await ref.read(pushPermissionPromptStoreProvider).canPromptNow() ||
        !mounted) {
      return;
    }
    // 다른 시트·창이 떠 있으면 이번 실행에서는 건너뜀
    if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
    await runNotificationPermissionPrompt(context, ref);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
