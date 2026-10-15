import 'package:flutter/cupertino.dart';

import '../../../data/models/meta/app_config.dart';
import '../../design/design.dart';

/// 홈 공지 배너: 탭 > 본문 시트, 닫기 > 같은 공지 다시 안 띄움
class AppNoticeBanner extends StatelessWidget {
  const AppNoticeBanner({
    super.key,
    required this.notice,
    required this.onDismiss,
  });

  final AppNotice notice;
  final VoidCallback onDismiss;

  void _showNoticeSheet(BuildContext context) {
    showPassqlSheet<void>(
      context,
      title: notice.title,
      builder: (sheetContext) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          PassqlSpacing.md,
          0,
          PassqlSpacing.md,
          PassqlSpacing.lg,
        ),
        child: Text(
          notice.body,
          style: PassqlTypography.legalBody.copyWith(
            color: sheetContext.passqlColors.label,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlCard(
      onTap: () => _showNoticeSheet(context),
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
            PassqlBadge(text: '중요', color: colors.wrong),
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
