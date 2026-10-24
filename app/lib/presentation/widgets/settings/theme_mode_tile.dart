import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../providers/theme_mode_provider.dart';
import 'settings_group.dart';

/// 화면 모드 표시 이름 (자동 > 기기의 라이트/다크 설정을 따름)
String themeModeLabel(ThemeMode mode) => switch (mode) {
  ThemeMode.system => '자동',
  ThemeMode.light => '라이트',
  ThemeMode.dark => '다크',
};

/// 화면 모드 설정 줄: 시트 없이 줄 아래 세그먼트에서 자동/라이트/다크를 바로 고른다.
class ThemeModeTile extends ConsumerWidget {
  const ThemeModeTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Column(
      children: [
        SettingsRow(
          icon: CupertinoIcons.circle_lefthalf_fill,
          iconColor: context.passqlColors.accent,
          title: '화면 모드',
          subtitle: mode == ThemeMode.system ? '기기의 라이트/다크 설정을 따라요' : null,
          shouldShowChevron: false,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            PassqlSpacing.md,
            0,
            PassqlSpacing.md,
            PassqlSpacing.sm,
          ),
          child: PassqlSegmentedControl<ThemeMode>(
            segments: [
              for (final themeMode in ThemeMode.values)
                PassqlSegment(
                  value: themeMode,
                  label: themeModeLabel(themeMode),
                ),
            ],
            selectedValue: mode,
            onSelected: (selectedMode) {
              PassqlHaptics.playSelection();
              ref.read(themeModeProvider.notifier).setMode(selectedMode);
            },
          ),
        ),
      ],
    );
  }
}
