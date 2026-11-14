import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/date_format.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/lock_screen_providers.dart';
import 'lock_screen_option_rows.dart';
import 'settings_group.dart';

/// 설정 > 학습 잠금화면 행들 (#990, Android + 서버 스위치 켜짐일 때만): 토글 > (켜짐) 간격·문제 종류 (선택지 방식은 앱 "새 보기로 풀기" 설정을 따름)
/// 묶음 구분선이 행마다 들어가게 위젯 목록으로 돌려줌
List<Widget> buildLockScreenSettingsRows(WidgetRef ref) {
  if (!ref.watch(isLockScreenAvailableProvider)) return const [];
  final lockScreenState = ref.watch(lockScreenStateProvider).valueOrNull;
  final isEnabled = lockScreenState?.settings.isEnabled ?? false;
  return [
    const LockScreenToggleTile(),
    if (isEnabled) ...[
      const LockScreenIntervalTile(),
      if (ref.watch(isLockScreenExecutableIncludedProvider))
        const LockScreenQuestionTypeTile(),
    ],
  ];
}

/// 잠금화면 문제 토글: 켤 때 필수 권한 없으면 권한 단계로, 켜진 뒤 권한이 빠지면 "권한 필요"(누르면 권한 단계)
/// 부제 3가지: 권한 필요 > 쉬는 중("HH:mm까지 쉬는 중", 켜면 쉬기 해제) > 기본 안내
class LockScreenToggleTile extends ConsumerStatefulWidget {
  const LockScreenToggleTile({super.key});

  @override
  ConsumerState<LockScreenToggleTile> createState() =>
      _LockScreenToggleTileState();
}

class _LockScreenToggleTileState extends ConsumerState<LockScreenToggleTile> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    // 기기 설정에서 권한을 끄고 돌아오면 "권한 필요" 반영
    _lifecycleListener = AppLifecycleListener(
      onResume: () => ref.read(lockScreenStateProvider.notifier).refresh(),
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  Future<void> _change(bool isEnabled) async {
    final notifier = ref.read(lockScreenStateProvider.notifier);
    if (!isEnabled) {
      await notifier.disable();
      return;
    }
    final latest = await notifier.refresh();
    if (!latest.permissionStatus.hasRequiredPermissions) {
      if (mounted) unawaited(context.push(AppRoutes.lockScreenPermission));
      return;
    }
    await notifier.enable();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final lockScreenAsync = ref.watch(lockScreenStateProvider);
    final lockScreenState = lockScreenAsync.valueOrNull;
    final isEnabled = lockScreenState?.settings.isEnabled ?? false;
    final isPermissionMissing = lockScreenState?.isPermissionMissing ?? false;
    final pausedUntil = isEnabled
        ? lockScreenState?.settings.pausedUntil
        : null;
    return SettingsRow(
      icon: CupertinoIcons.lock_fill,
      iconColor: colors.accent,
      title: '잠금화면 문제',
      subtitle: isPermissionMissing
          ? '권한이 필요해요'
          : pausedUntil != null
          ? '${formatHourMinute(pausedUntil)}까지 쉬는 중'
          : '화면 켤 때 한 문제씩 풀어요',
      shouldShowChevron: false,
      onTap: isPermissionMissing
          ? () => context.push(AppRoutes.lockScreenPermission)
          : null,
      trailing: CupertinoSwitch(
        value: isEnabled,
        activeTrackColor: colors.accent,
        // 읽는 중에는 값을 모르므로 막음
        onChanged: lockScreenAsync.hasValue ? _change : null,
      ),
    );
  }
}
