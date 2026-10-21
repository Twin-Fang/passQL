import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/wrong_questions_provider.dart';

/// 문제 탭 상단 오답 노트 바로가기: 오답 개수 + 탭 > 오답 노트 화면 (그룹 섹션 안의 목록 행 1개)
class WrongNotesShortcutRow extends ConsumerWidget {
  const WrongNotesShortcutRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    // 개수는 불러오기 전·실패면 숨김
    final wrongCount = ref.watch(wrongQuestionTotalCountProvider).valueOrNull;
    return PassqlGroupedSection(
      children: [
        PassqlListRow(
          title: '오답 노트',
          leading: PassqlIconTile(
            icon: CupertinoIcons.book,
            color: colors.wrong,
          ),
          trailing: wrongCount == null ? null : Text('$wrongCount'),
          hasChevron: true,
          onTap: () => context.push(AppRoutes.wrongNotes),
        ),
      ],
    );
  }
}
