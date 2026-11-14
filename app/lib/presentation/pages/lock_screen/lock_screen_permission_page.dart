import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/monitoring/app_analytics.dart';
import '../../design/design.dart';
import '../../providers/lock_screen_providers.dart';
import '../../widgets/lock_screen/lock_screen_permission_step_card.dart';

/// 잠금화면 권한 단계 하나: 분석 이름, 제목, 이유 한 줄, 필수 여부
enum LockScreenPermissionStep {
  // 설정은 앱 목록으로 열림 (Android 11+ 앱별 화면 직접 열기 불가) > 목록에서 찾는 방법을 함께 안내 (#1066)
  overlay('overlay', '다른 앱 위에 표시', '목록에서 passQL을 눌러 허용해 주세요. 잠금화면 위에 문제를 띄울 때 필요해요', true),
  notification('notification', '알림 허용', '오늘 푼 문제 수를 상단 알림으로 보여 줘요', true),
  battery('battery', '배터리 최적화 제외', '휴대폰이 기능을 멈추지 않게 해요', true),
  samsungPower('samsung_power', '절전 예외 앱에 추가', '삼성 휴대폰은 한 번 더 필요해요', false);

  const LockScreenPermissionStep(
    this.analyticsName,
    this.title,
    this.reason,
    this.isRequired,
  );

  final String analyticsName;
  final String title;
  final String reason;
  final bool isRequired;
}

/// 잠금화면 켜기 권한 단계 (#990): 진행 막대 > 단계 카드(현재 단계 강조·설정 열기) > 준비 끝
/// 필수 3개(다른 앱 위에 표시, 알림, 배터리 최적화 제외) 모두 켜지면 바로 켜기, 삼성 절전 예외는 권장(삼성만, 건너뛰기 가능)
/// 설정 앱에서 돌아오면 상태를 다시 읽어 자동 체크
class LockScreenPermissionPage extends ConsumerStatefulWidget {
  const LockScreenPermissionPage({super.key});

  @override
  ConsumerState<LockScreenPermissionPage> createState() =>
      _LockScreenPermissionPageState();
}

class _LockScreenPermissionPageState
    extends ConsumerState<LockScreenPermissionPage> {
  late final AppLifecycleListener _lifecycleListener;

  LockScreenPermissionStatus _status = LockScreenPermissionStatus.none;

  /// 설정 화면을 열고 돌아오기를 기다리는 단계 (돌아오면 결과 기록)
  LockScreenPermissionStep? _openedStep;

  /// 삼성 절전 예외: 확인할 방법이 없어 설정을 다녀오거나 건너뛰면 끝난 것으로 봄
  bool _isSamsungStepFinished = false;

  bool _isEnabled = false;
  bool _isEnabling = false;

  LockScreenBridge get _bridge => ref.read(lockScreenBridgeProvider);

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(onResume: _onResume);
    unawaited(_reloadStatus());
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  List<LockScreenPermissionStep> get _steps => [
    LockScreenPermissionStep.overlay,
    LockScreenPermissionStep.notification,
    LockScreenPermissionStep.battery,
    if (_status.isSamsung) LockScreenPermissionStep.samsungPower,
  ];

  bool _isStepDone(LockScreenPermissionStep step) => switch (step) {
    LockScreenPermissionStep.overlay => _status.canDrawOverlays,
    LockScreenPermissionStep.notification => _status.hasNotificationPermission,
    LockScreenPermissionStep.battery => _status.isIgnoringBatteryOptimizations,
    LockScreenPermissionStep.samsungPower => _isSamsungStepFinished,
  };

  /// 지금 할 단계: 순서대로 첫 미완료 (모두 끝났으면 null)
  LockScreenPermissionStep? get _currentStep =>
      _steps.where((step) => !_isStepDone(step)).firstOrNull;

  /// 설정에서 돌아옴: 다녀온 단계 결과 기록 > 상태 다시 읽기
  Future<void> _onResume() async {
    final openedStep = _openedStep;
    _openedStep = null;
    if (openedStep == LockScreenPermissionStep.samsungPower) {
      _isSamsungStepFinished = true;
    }
    await _reloadStatus();
    if (openedStep != null) {
      unawaited(
        AppAnalytics.current.logLockScreenPermissionStep(
          stepName: openedStep.analyticsName,
          isGranted: _isStepDone(openedStep),
        ),
      );
    }
  }

  /// 권한 다시 읽기 > 필수 3개 다 켜졌으면 켜기 (1회)
  Future<void> _reloadStatus() async {
    final status = await _bridge.getPermissionStatus();
    if (!mounted) return;
    setState(() => _status = status);
    if (status.hasRequiredPermissions && !_isEnabled && !_isEnabling) {
      await _enable();
    }
  }

  Future<void> _enable() async {
    setState(() => _isEnabling = true);
    final isEnabled = await ref.read(lockScreenStateProvider.notifier).enable();
    if (!mounted) return;
    setState(() {
      _isEnabling = false;
      _isEnabled = isEnabled;
    });
  }

  void _openSettings(LockScreenPermissionStep step) {
    _openedStep = step;
    unawaited(switch (step) {
      LockScreenPermissionStep.overlay => _bridge.openOverlaySettings(),
      LockScreenPermissionStep.notification =>
        _bridge.openNotificationSettings(),
      LockScreenPermissionStep.battery =>
        _bridge.openBatteryOptimizationSettings(),
      LockScreenPermissionStep.samsungPower =>
        _bridge.openSamsungPowerSettings(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final steps = _steps;
    final currentStep = _currentStep;
    final doneCount = steps.where(_isStepDone).length;
    final isFinished = currentStep == null && _isEnabled;
    return Scaffold(
      appBar: PassqlNavBar(
        title: '잠금화면 문제 켜기',
        leading: PassqlNavLeading.back,
        onLeadingTap: () => context.pop(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(PassqlSpacing.md),
        children: [
          PassqlProgressBar(value: doneCount / steps.length),
          const SizedBox(height: PassqlSpacing.md),
          for (final (index, step) in steps.indexed) ...[
            LockScreenPermissionStepCard(
              number: index + 1,
              title: step.title,
              reason: step.reason,
              isRequired: step.isRequired,
              isDone: _isStepDone(step),
              isCurrent: step == currentStep,
              onOpenSettings: () => _openSettings(step),
              // 권장 단계는 건너뛸 수 있음
              onSkip: step.isRequired
                  ? null
                  : () => setState(() => _isSamsungStepFinished = true),
            ),
            const SizedBox(height: PassqlSpacing.sm),
          ],
          if (isFinished) ...[
            const SizedBox(height: PassqlSpacing.md),
            PassqlPopIn(
              child: Text(
                '준비 끝!',
                textAlign: TextAlign.center,
                style: PassqlTypography.title2.copyWith(color: colors.label),
              ),
            ),
            const SizedBox(height: PassqlSpacing.xs),
            PassqlKeepAllText(
              '지금 화면을 껐다 켜 보세요',
              textAlign: TextAlign.center,
              style: PassqlTypography.subheadline.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: isFinished
          ? PassqlBottomActionBar(
              actions: [
                PassqlButton(label: '완료', onPressed: () => context.pop()),
              ],
            )
          : null,
    );
  }
}
