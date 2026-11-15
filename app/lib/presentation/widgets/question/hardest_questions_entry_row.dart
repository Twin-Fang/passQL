import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/hardest_question_providers.dart';

/// 문제 탭 오답률 TOP 행 (#1080): 탭 > 오답률 TOP 목록 (무료·프로 공통, 목록 그룹은 호출부)
class HardestQuestionsEntryRow extends StatelessWidget {
  const HardestQuestionsEntryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return PassqlListRow(
      title: '오답률 TOP $hardestQuestionLimit',
      subtitle: '다른 수험생이 처음에 많이 틀린 문제',
      leading: PassqlIconTile(
        icon: CupertinoIcons.chart_bar_fill,
        color: context.passqlColors.warning,
      ),
      hasChevron: true,
      onTap: () => context.push(AppRoutes.hardestQuestions),
    );
  }
}
