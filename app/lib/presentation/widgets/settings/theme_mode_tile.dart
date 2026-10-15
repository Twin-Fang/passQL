import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../providers/theme_mode_provider.dart';
import 'settings_group.dart';

/// 화면 모드 표시 이름. 설정 줄의 값과 선택 시트에서 같은 문구를 쓴다.
String themeModeLabel(ThemeMode mode) => switch (mode) {
  ThemeMode.system => '시스템 설정',
  ThemeMode.light => '라이트',
  ThemeMode.dark => '다크',
};

/// 화면 모드 설정 줄. 누르면 시트에서 시스템/라이트/다크 중 하나를 고른다.
class ThemeModeTile extends ConsumerWidget {
  const ThemeModeTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return SettingsRow(
      icon: CupertinoIcons.circle_lefthalf_fill,
      iconColor: context.pq.accent,
      title: '화면 모드',
      trailing: Text(themeModeLabel(mode)),
      onTap: () => showPqSheet<void>(
        context,
        title: '화면 모드',
        builder: (_) => const _ThemeModeSheet(),
      ),
    );
  }
}

class _ThemeModeSheet extends ConsumerWidget {
  const _ThemeModeSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeModeProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(PqSpace.md, 0, PqSpace.md, PqSpace.md),
      child: PqGroupedSection(
        children: [
          for (final mode in ThemeMode.values)
            PqCheckRow(
              title: themeModeLabel(mode),
              subtitle: mode == ThemeMode.system ? '기기의 라이트/다크 설정을 따라요' : null,
              selected: mode == current,
              onTap: () {
                PqHaptics.selection();
                ref.read(themeModeProvider.notifier).setMode(mode);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}
