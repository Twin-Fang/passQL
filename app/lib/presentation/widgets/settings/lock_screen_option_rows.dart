import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../providers/lock_screen_providers.dart';
import 'settings_group.dart';

// 잠금화면 선택 행 공통 (#1068): 띄우는 간격·문제 종류 (설정 화면과 켜기 단계가 함께 씀)
// 고르면 lockScreenStateProvider 에 바로 저장

/// 지금 보일 간격 (분): 한 번이라도 켰으면 저장값, 처음 켜기 전이면 서버 기본
int resolveLockScreenIntervalMinutes(WidgetRef ref) {
  final lockScreenState = ref.watch(lockScreenStateProvider).valueOrNull;
  final defaultIntervalMinutes = ref.watch(lockScreenDefaultIntervalProvider);
  if (lockScreenState == null) return defaultIntervalMinutes;
  final hasSavedInterval =
      lockScreenState.hasEverEnabled || lockScreenState.settings.isEnabled;
  return hasSavedInterval
      ? lockScreenState.settings.intervalMinutes
      : defaultIntervalMinutes;
}

/// 띄우는 간격: 매번·30분·1시간·3시간 (고른 뒤 [onSelected] 로 알림)
class LockScreenIntervalTile extends ConsumerWidget {
  const LockScreenIntervalTile({super.key, this.onSelected});

  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intervalMinutes = resolveLockScreenIntervalMinutes(ref);
    return SettingsRow(
      icon: CupertinoIcons.timer,
      title: '띄우는 간격',
      trailing: Text(toLockScreenIntervalLabel(intervalMinutes)),
      onTap: () async {
        final selected = await showLockScreenOptionSheet<int>(
          context,
          title: '띄우는 간격',
          options: [
            for (final option in lockScreenIntervalOptions)
              (option, toLockScreenIntervalLabel(option)),
          ],
          selectedValue: intervalMinutes,
        );
        if (selected == null) return;
        await ref
            .read(lockScreenStateProvider.notifier)
            .updateInterval(selected);
        onSelected?.call(selected);
      },
    );
  }
}

/// 문제 종류: 전체 / 객관식만
class LockScreenQuestionTypeTile extends ConsumerWidget {
  const LockScreenQuestionTypeTile({super.key});

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
        final shouldExcludeExecutable = await showLockScreenOptionSheet<bool>(
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

/// 하나 고르는 시트 (고른 값, 그냥 닫으면 null)
Future<T?> showLockScreenOptionSheet<T>(
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
