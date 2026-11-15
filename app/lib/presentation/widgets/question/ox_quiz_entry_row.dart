import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';

/// 문제 탭 OX 퀴즈 행 (#1083): 탭 > OX 퀴즈 화면 (무료는 개념 무료 단원 카드만, 목록 그룹은 호출부)
class OxQuizEntryRow extends StatelessWidget {
  const OxQuizEntryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return PassqlListRow(
      title: 'OX 퀴즈',
      subtitle: '개념 문장을 O, X로 빠르게 복습해요',
      leading: PassqlIconTile(
        icon: CupertinoIcons.circle_grid_hex_fill,
        color: context.passqlColors.accent,
      ),
      hasChevron: true,
      onTap: () => context.push(AppRoutes.oxQuiz),
    );
  }
}
