import 'package:flutter/cupertino.dart';

import '../../design/design.dart';
import 'notification_permission_texts.dart';

/// 알림 권한 안내 시트: 받는 소식 3가지 + "알림 받기"(true) / "나중에"(false·시트 닫기)
/// 이 시트에서 "알림 받기"를 눌러야만 시스템 권한 창이 뜸
Future<bool> showNotificationPermissionSheet(BuildContext context) async {
  final isAccepted = await showPassqlSheet<bool>(
    context,
    title: NotificationPermissionTexts.sheetTitle,
    builder: (sheetContext) => const _NotificationPermissionSheetBody(),
  );
  return isAccepted ?? false;
}

class _NotificationPermissionSheetBody extends StatelessWidget {
  const _NotificationPermissionSheetBody();

  // 받는 소식 줄별 아이콘 (NotificationPermissionTexts.receivedNewsLines 순서와 같게)
  static const List<IconData> _lineIcons = [
    CupertinoIcons.speaker_2_fill,
    CupertinoIcons.checkmark_circle_fill,
    CupertinoIcons.calendar,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.xxs,
        PassqlSpacing.md,
        PassqlSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (
            var lineIndex = 0;
            lineIndex < NotificationPermissionTexts.receivedNewsLines.length;
            lineIndex++
          )
            Padding(
              padding: const EdgeInsets.only(bottom: PassqlSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    _lineIcons[lineIndex],
                    size: PassqlIconSize.lg,
                    color: colors.accent,
                  ),
                  const SizedBox(width: PassqlSpacing.sm),
                  Expanded(
                    child: Text(
                      NotificationPermissionTexts.receivedNewsLines[lineIndex],
                      style: PassqlTypography.body.copyWith(
                        color: colors.label,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Text(
            NotificationPermissionTexts.optionalNotice,
            style: PassqlTypography.footnote.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: PassqlSpacing.md),
          PassqlButton(
            label: NotificationPermissionTexts.acceptLabel,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: PassqlSpacing.xxs),
          PassqlButton(
            label: NotificationPermissionTexts.laterLabel,
            variant: PassqlButtonVariant.plain,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
