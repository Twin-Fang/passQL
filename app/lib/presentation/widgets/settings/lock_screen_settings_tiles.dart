import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/lock_screen_providers.dart';
import 'settings_group.dart';

/// 설정 > 학습 잠금화면 행들 (#990, Android + 서버 스위치 켜짐일 때만): 토글 > (켜짐) 간격·문제 종류·선택지 방식
/// 묶음 구분선이 행마다 들어가게 위젯 목록으로 돌려줌
List<Widget> buildLockScreenSettingsRows(WidgetRef ref) {
  if (!ref.watch(isLockScreenAvailableProvider)) return const [];
  final lockScreenState = ref.watch(lockScreenStateProvider).valueOrNull;
  final isEnabled = lockScreenState?.settings.isEnabled ?? false;
  return [
    const LockScreenToggleTile(),
    if (isEnabled) ...[
      const _LockScreenIntervalTile(),
      if (ref.watch(isLockScreenExecutableIncludedProvider))
        const _LockScreenQuestionTypeTile(),
      const _LockScreenChoiceModeTile(),
    ],
  ];
}

/// 잠금화면 문제 토글: 켤 때 필수 권한 없으면 권한 단계로, 켜진 뒤 권한이 빠지면 "권한 필요"(누르면 권한 단계)
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
    return SettingsRow(
      icon: CupertinoIcons.lock_fill,
      iconColor: colors.accent,
      title: '잠금화면 문제',
      subtitle: isPermissionMissing ? '권한이 필요해요' : '화면 켤 때 한 문제씩 풀어요',
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

/// 띄우는 간격: 매번·30분·1시간·3시간
class _LockScreenIntervalTile extends ConsumerWidget {
  const _LockScreenIntervalTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int defaultIntervalMinutes = ref.watch(
      lockScreenDefaultIntervalProvider,
    );
    final int intervalMinutes =
        ref
            .watch(lockScreenStateProvider)
            .valueOrNull
            ?.settings
            .intervalMinutes ??
        defaultIntervalMinutes;
    return SettingsRow(
      icon: CupertinoIcons.timer,
      title: '띄우는 간격',
      trailing: Text(toLockScreenIntervalLabel(intervalMinutes)),
      onTap: () async {
        final selected = await _showOptionSheet<int>(
          context,
          title: '띄우는 간격',
          options: [
            for (final option in lockScreenIntervalOptions)
              (option, toLockScreenIntervalLabel(option)),
          ],
          selectedValue: intervalMinutes,
        );
        if (selected != null) {
          await ref
              .read(lockScreenStateProvider.notifier)
              .updateInterval(selected);
        }
      },
    );
  }
}

/// 문제 종류: 전체 / 객관식만
class _LockScreenQuestionTypeTile extends ConsumerWidget {
  const _LockScreenQuestionTypeTile();

  static const String _allLabel = '전체';
  static const String _choiceOnlyLabel = '객관식만';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExecutableExcluded =
        ref
            .watch(lockScreenStateProvider)
            .valueOrNull
            ?.settings
            .isExecutableExcluded ??
        false;
    return SettingsRow(
      icon: CupertinoIcons.square_list,
      title: '문제 종류',
      trailing: Text(isExecutableExcluded ? _choiceOnlyLabel : _allLabel),
      onTap: () async {
        final shouldExcludeExecutable = await _showOptionSheet<bool>(
          context,
          title: '문제 종류',
          options: const [(false, _allLabel), (true, _choiceOnlyLabel)],
          selectedValue: isExecutableExcluded,
        );
        if (shouldExcludeExecutable != null) {
          await ref
              .read(lockScreenStateProvider.notifier)
              .updateExecutableExcluded(shouldExcludeExecutable);
        }
      },
    );
  }
}

/// 선택지 방식 (앱 보기 방식과 별개): 기본(준비된 보기, 바로 뜸) / AI로 새로 만들기(확인 창 뒤)
class _LockScreenChoiceModeTile extends ConsumerWidget {
  const _LockScreenChoiceModeTile();

  static const String _basicLabel = '기본';
  static const String _freshLabel = 'AI로 새로 만들기';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFreshChoiceMode =
        ref
            .watch(lockScreenStateProvider)
            .valueOrNull
            ?.settings
            .isFreshChoiceMode ??
        false;
    return SettingsRow(
      icon: CupertinoIcons.sparkles,
      title: '선택지 방식',
      trailing: Text(isFreshChoiceMode ? _freshLabel : _basicLabel),
      onTap: () async {
        final shouldUseFreshChoiceMode = await _showOptionSheet<bool>(
          context,
          title: '선택지 방식',
          options: const [(false, _basicLabel), (true, _freshLabel)],
          selectedValue: isFreshChoiceMode,
        );
        if (shouldUseFreshChoiceMode == null ||
            shouldUseFreshChoiceMode == isFreshChoiceMode) {
          return;
        }
        // AI 생성은 뜨기까지 기다릴 수 있어 한 번 확인 (취소면 기본 유지)
        if (shouldUseFreshChoiceMode && context.mounted) {
          final isConfirmed = await showPassqlConfirmDialog(
            context,
            title: 'AI로 새로 만들까요?',
            message: 'AI가 선택지를 새로 만들어서 문제가 뜨기까지 조금 기다릴 수 있어요.',
            confirmLabel: '사용하기',
            isDestructive: false,
          );
          if (!isConfirmed) return;
        }
        await ref
            .read(lockScreenStateProvider.notifier)
            .updateFreshChoiceMode(shouldUseFreshChoiceMode);
      },
    );
  }
}

/// 하나 고르는 시트 (고른 값, 그냥 닫으면 null)
Future<T?> _showOptionSheet<T>(
  BuildContext context, {
  required String title,
  required List<(T, String)> options,
  required T selectedValue,
}) => showPassqlSheet<T>(
  context,
  title: title,
  builder: (sheetContext) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        0,
        PassqlSpacing.md,
        PassqlSpacing.md,
      ),
      child: PassqlGroupedSection(
        children: [
          for (final (value, label) in options)
            PassqlCheckRow(
              title: label,
              isSelected: value == selectedValue,
              onTap: () => Navigator.of(sheetContext).pop(value),
            ),
        ],
      ),
    ),
  ),
);
