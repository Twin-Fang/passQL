import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../question/wrong_notes_shortcut_row.dart';

/// 기록 탭 바로가기: 오답 노트, 오늘의 세트 순위 (목록 행 2개)
class StatsShortcutSection extends StatelessWidget {
  const StatsShortcutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlGroupedSection(
      header: '바로가기',
      children: [
        const WrongNotesShortcutRow(),
        PassqlListRow(
          title: '오늘의 세트 순위',
          leading: PassqlIconTile(
            icon: CupertinoIcons.rosette,
            color: colors.accent,
          ),
          hasChevron: true,
          onTap: () => context.push(AppRoutes.leaderboard),
        ),
      ],
    );
  }
}
