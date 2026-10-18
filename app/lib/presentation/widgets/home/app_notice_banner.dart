import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/meta/app_config.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';

/// 홈 공지 배너: 탭 > 공지 상세 화면(#529), 닫기 > 읽음 처리(같은 공지 다시 안 띄움)
class AppNoticeBanner extends StatelessWidget {
  const AppNoticeBanner({
    super.key,
    required this.notice,
    required this.onDismiss,
  });

  final AppNotice notice;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlCard(
      onTap: () => context.push(AppRoutes.noticeDetail(notice.noticeUuid)),
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.xs,
        0,
        PassqlSpacing.xs,
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.speaker_2_fill,
            size: PassqlIconSize.lg,
            color: colors.accent,
          ),
          const SizedBox(width: PassqlSpacing.sm),
          if (notice.isImportant) ...[
            PassqlBadge(text: '중요', kind: PassqlBadgeKind.important),
            const SizedBox(width: PassqlSpacing.xs),
          ],
          Expanded(
            child: Text(
              notice.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: PassqlTypography.subheadlineSemibold.copyWith(
                color: colors.label,
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size.square(PassqlSize.minTouchTarget),
            onPressed: onDismiss,
            child: Semantics(
              label: '공지 닫기',
              child: Icon(
                CupertinoIcons.xmark,
                size: PassqlIconSize.md,
                color: colors.tertiaryLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
