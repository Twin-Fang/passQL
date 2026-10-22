import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../../providers/wrong_questions_provider.dart';
import '../pro/pro_offer_sheet.dart';

/// 문제 탭 공통 영역의 오답 노트 바로가기: 오답 개수 + 탭 > 오답 노트 화면 (목록 행 1개, 그룹 섹션은 호출부)
/// 무료(결제 켜짐): 오답 목록 잠금 > 개수 없이 행만, 탭 > 프로 안내 시트
class WrongNotesShortcutRow extends ConsumerWidget {
  const WrongNotesShortcutRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final isWrongNotesLocked = ref.watch(shouldShowProUiProvider);
    // 개수는 불러오기 전·실패·잠금이면 숨김 (잠금이면 Provider 가 요청 없이 null)
    final wrongCount = ref.watch(wrongQuestionTotalCountProvider).valueOrNull;
    return PassqlListRow(
      title: '오답 노트',
      leading: PassqlIconTile(
        icon: CupertinoIcons.xmark_circle,
        color: colors.wrong,
      ),
      trailing: wrongCount == null ? null : Text('$wrongCount'),
      hasChevron: true,
      onTap: isWrongNotesLocked
          ? () => showProOfferSheet(context, ref)
          : () => context.push(AppRoutes.wrongNotes),
    );
  }
}
