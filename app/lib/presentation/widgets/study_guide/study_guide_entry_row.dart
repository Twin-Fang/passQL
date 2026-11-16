import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';

/// 학습 가이드 입구 행 (#1078): 홈·문제 탭·프로필 공통, 탭 > 학습 가이드 화면
class StudyGuideEntryRow extends StatelessWidget {
  const StudyGuideEntryRow({super.key, this.hasHorizontalPadding = true});

  /// false: 이미 좌우 여백이 있는 구간 면 안 (홈·프로필 구간)
  final bool hasHorizontalPadding;

  static const String title = '학습 가이드';

  @override
  Widget build(BuildContext context) {
    return PassqlListRow(
      title: title,
      subtitle: '합격까지 이 순서로 공부해요',
      leading: PassqlIconTile(
        icon: CupertinoIcons.map_fill,
        color: context.passqlColors.correct,
      ),
      hasChevron: true,
      hasHorizontalPadding: hasHorizontalPadding,
      onTap: () => context.push(AppRoutes.studyGuide),
    );
  }
}
