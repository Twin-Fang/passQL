import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/push/push_messaging_client.dart';
import '../../../data/push/push_notification_service.dart';
import '../../providers/push_notification_providers.dart';
import 'notification_permission_flow.dart';

/// 알림 권한 사전 안내: 맥락 있는 순간에 실행당 최대 1회
/// 시점 2곳: 탭 화면 첫 표시(두 번째 이후 실행·결과를 본 적 있을 때), 결과 화면 등 전체 화면을 닫고 탭 화면으로 돌아올 때
/// 조건: 권한 미결정 + "나중에" 후 7일 경과 + 의미 있는 순간(학습 결과를 봄 또는 두 번째 실행)
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
  static const Duration _launchPromptDelay = Duration(seconds: 2);
  // 탭 화면 복귀 뒤 대기 (화면 전환·전면 광고 닫힘이 끝난 뒤)
  static const Duration _returnPromptDelay = Duration(milliseconds: 800);

  Timer? _promptTimer;
  bool _hasPromptedThisLaunch = false;
  bool _hasBeenCoveredByFullScreen = false;

  @override
  void initState() {
    super.initState();
    _schedulePrompt(_launchPromptDelay);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 풀이·결과 같은 전체 화면이 덮었다가 닫혀 탭 화면이 다시 맨 위가 되면 시도
    final isShellOnTop = ModalRoute.of(context)?.isCurrent ?? true;
    if (_hasBeenCoveredByFullScreen && isShellOnTop) {
      _schedulePrompt(_returnPromptDelay);
    }
    _hasBeenCoveredByFullScreen = !isShellOnTop;
  }

  @override
  void dispose() {
    _promptTimer?.cancel();
    super.dispose();
  }

  void _schedulePrompt(Duration delay) {
    if (_hasPromptedThisLaunch) return;
    _promptTimer?.cancel();
    _promptTimer = Timer(delay, _promptIfNeeded);
  }

  /// 조건 확인 (권한 미결정 > 7일 경과 > 의미 있는 순간 > 화면 맨 위) > 안내
  Future<void> _promptIfNeeded() async {
    if (!mounted || _hasPromptedThisLaunch) return;
    final permissionStatus = await ref
        .read(pushNotificationServiceProvider)
        .readPermissionStatus();
    // 이미 허용·거부했으면 안내하지 않음 (거부는 설정 토글에서 기기 설정으로 안내)
    if (permissionStatus != PushPermissionStatus.notDetermined || !mounted) {
      return;
    }
    final promptStore = ref.read(pushPermissionPromptStoreProvider);
    if (!await promptStore.canPromptNow() || !mounted) return;
    // 가입 직후 첫 실행에는 맥락 없이 묻지 않음 (결과를 본 뒤 또는 다음 실행)
    if (!await promptStore.isMeaningfulMoment() || !mounted) return;
    // 다른 시트·창이 떠 있으면 다음 기회로
    if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
    _hasPromptedThisLaunch = true;
    await runNotificationPermissionPrompt(context, ref);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
