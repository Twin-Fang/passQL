import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../study_guide/study_guide_entry_row.dart';

/// 프로필 즐겨찾기 구간 (#1082): 앞 띠 + 즐겨찾기 행 > 즐겨찾기 화면 (무료 포함 전원), 학습 가이드 행(#1078)
class ProfileBookmarksSection extends StatelessWidget {
  const ProfileBookmarksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PassqlSectionGap(),
        PassqlSection(
          // 설정 화면 행과 같은 모양: 아이콘 타일 + 제목 + 화살표
          child: PassqlListRow(
            title: '즐겨찾기',
            subtitle: '별을 누른 문제를 모아 다시 풀어요',
            leading: PassqlIconTile(
              icon: CupertinoIcons.star_fill,
              color: context.passqlColors.warning,
            ),
            hasChevron: true,
            hasHorizontalPadding: false,
            onTap: () => context.push(AppRoutes.bookmarks),
          ),
        ),
        const PassqlSectionGap(),
        const PassqlSection(
          child: StudyGuideEntryRow(hasHorizontalPadding: false),
        ),
      ],
    );
  }
}
