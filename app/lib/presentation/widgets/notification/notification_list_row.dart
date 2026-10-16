import 'package:flutter/cupertino.dart';

import '../../../core/utils/relative_time.dart';
import '../../../data/models/notification/notification_models.dart';
import '../../design/design.dart';
import 'notification_type_appearance.dart';

/// 알림함 목록 행: 안 읽음 점, 종류 아이콘, 제목(중요 배지), 본문 2줄, 경과 시간
class NotificationListRow extends StatelessWidget {
  const NotificationListRow({
    super.key,
    required this.item,
    required this.onTap,
    this.now,
  });

  final NotificationItem item;
  final VoidCallback onTap;

  /// 경과 시간 기준 시각 (테스트에서 고정)
  final DateTime? now;

  // 본문 미리보기 최대 줄 수
  static const int _bodyMaximumLines = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final appearance = NotificationTypeAppearance.of(item, colors);
    return PassqlPressable(
      onTap: onTap,
      semanticLabel: '${item.isRead ? '' : '안 읽은 '}${item.title}',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PassqlSpacing.md,
          vertical: PassqlSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 안 읽음 점 (읽으면 자리만 유지해 제목 정렬 고정)
            Padding(
              padding: const EdgeInsets.only(top: PassqlSpacing.xs),
              child: Container(
                width: PassqlSize.unreadDot,
                height: PassqlSize.unreadDot,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.isRead ? null : colors.warning,
                ),
              ),
            ),
            const SizedBox(width: PassqlSpacing.xs),
            PassqlIconTile(icon: appearance.icon, color: appearance.color),
            const SizedBox(width: PassqlSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: item.isRead
                              ? PassqlTypography.subheadline.copyWith(
                                  color: colors.secondaryLabel,
                                )
                              : PassqlTypography.subheadlineSemibold.copyWith(
                                  color: colors.label,
                                ),
                        ),
                      ),
                      if (item.isImportant) ...[
                        const SizedBox(width: PassqlSpacing.xs),
                        PassqlBadge(text: '중요', kind: PassqlBadgeKind.important),
                      ],
                    ],
                  ),
                  if (item.body.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: PassqlSpacing.hairlineGap,
                      ),
                      child: Text(
                        item.body,
                        maxLines: _bodyMaximumLines,
                        overflow: TextOverflow.ellipsis,
                        style: PassqlTypography.footnote.copyWith(
                          color: colors.secondaryLabel,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: PassqlSpacing.xxs),
                    child: Text(
                      formatNotificationElapsed(item.createdAt, now: now),
                      style: PassqlTypography.caption.copyWith(
                        color: colors.tertiaryLabel,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
