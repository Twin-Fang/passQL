import 'package:flutter/cupertino.dart';

import '../../../data/models/notification/notification_models.dart';
import '../../design/design.dart';

/// 알림함 탭 전환 (알림 | 공지): 탭별 안 읽은 개수 배지, 선택한 탭은 카드색 알약
/// 알림함 전용 (디자인 시스템 세그먼트는 아직 3곳째가 아니라 이 화면에만 둠)
class NotificationSegmentedControl extends StatelessWidget {
  const NotificationSegmentedControl({
    super.key,
    required this.selectedCategory,
    required this.unreadCountOf,
    required this.onSelected,
  });

  final NotificationCategory selectedCategory;
  final int Function(NotificationCategory category) unreadCountOf;
  final ValueChanged<NotificationCategory> onSelected;

  // 탭 이름: 알림(GENERAL), 공지(NOTICE)
  static const Map<NotificationCategory, String> _tabLabels = {
    NotificationCategory.general: '알림',
    NotificationCategory.notice: '공지',
  };

  // 선택 알약 안쪽 여백 (트랙과 알약 사이)
  static const double _trackPadding = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Container(
      padding: const EdgeInsets.all(_trackPadding),
      decoration: BoxDecoration(
        color: colors.fill,
        borderRadius: BorderRadius.circular(PassqlRadius.md),
      ),
      child: Row(
        children: [
          for (final category in NotificationCategory.values)
            Expanded(
              child: _SegmentTab(
                label: _tabLabels[category]!,
                unreadCount: unreadCountOf(category),
                isSelected: category == selectedCategory,
                onTap: () => onSelected(category),
              ),
            ),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.label,
    required this.unreadCount,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int unreadCount;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Semantics(
      button: true,
      selected: isSelected,
      label: unreadCount > 0 ? '$label, 안 읽음 $unreadCount개' : label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: PassqlSize.buttonSmall,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? colors.cardElevated : null,
            borderRadius: BorderRadius.circular(PassqlRadius.sm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: PassqlTypography.subheadlineSemibold.copyWith(
                  color: isSelected ? colors.label : colors.secondaryLabel,
                ),
              ),
              if (unreadCount > 0) ...[
                const SizedBox(width: PassqlSpacing.xxs),
                PassqlCountBadge(count: unreadCount),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
