import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_config_providers.dart';
import '../../widgets/app_gate/launch_blocking_view.dart';

/// 점검 차단 화면: 관리자 문구 표시, 다시 확인으로 점검 종료 여부 재조회
/// 점검이 끝나면 라우터가 홈으로 보냄 (AppLaunchGateRouting)
class MaintenancePage extends ConsumerStatefulWidget {
  const MaintenancePage({super.key});

  @override
  ConsumerState<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends ConsumerState<MaintenancePage> {
  bool _isChecking = false;

  /// 설정 재조회 > 판정 갱신 (실패해도 화면 유지)
  Future<void> _onRecheckPressed() async {
    setState(() => _isChecking = true);
    ref.invalidate(appConfigProvider);
    try {
      await ref.read(appLaunchDecisionProvider.future);
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final decision = ref.watch(appLaunchDecisionProvider).valueOrNull;
    return LaunchBlockingView(
      icon: CupertinoIcons.wrench_fill,
      title: '서비스 점검 중이에요',
      message:
          decision?.maintenanceMessage ??
          AppLaunchDecision.defaultMaintenanceMessage,
      actionLabel: '다시 확인',
      onActionPressed: _onRecheckPressed,
      isActionLoading: _isChecking,
    );
  }
}
