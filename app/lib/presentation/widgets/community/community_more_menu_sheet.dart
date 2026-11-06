import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';

/// 토론 탭 제목 줄 더보기(…) 시트 (#863): 차단한 사용자 관리 (설정 토론 묶음과 같은 화면)
Future<void> showCommunityMoreMenuSheet(BuildContext context) async {
  final shouldOpenBlockedMembers = await showPassqlSheet<bool>(
    context,
    title: '토론',
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.xxs,
        PassqlSpacing.md,
        PassqlSpacing.md,
      ),
      // 묶음 카드 없이 글자 줄만 (카드 배경이 시트 배경과 달라 다크에서 상자가 드러남, 글 메뉴와 같은 모양)
      child: PassqlListRow(
        leading: PassqlIconTile(
          icon: CupertinoIcons.person_crop_circle_badge_xmark,
          color: sheetContext.passqlColors.secondaryLabel,
        ),
        title: '차단한 사용자 관리',
        hasChevron: true,
        hasHorizontalPadding: false,
        onTap: () => Navigator.of(sheetContext).pop(true),
      ),
    ),
  );
  // 시트를 닫은 뒤 이동 (시트 위에 화면이 쌓이지 않게)
  if (shouldOpenBlockedMembers == true && context.mounted) {
    await context.push(AppRoutes.blockedMembers);
  }
}
