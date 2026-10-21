import 'package:flutter/cupertino.dart';

import '../../../data/models/notification/notification_models.dart';
import '../../design/design.dart';

/// 알림함 탭 전환 (알림 | 공지): 탭별 안 읽은 개수 배지, 모양·시맨틱은 PassqlSegmentedControl
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

  @override
  Widget build(BuildContext context) {
    return PassqlSegmentedControl<NotificationCategory>(
      segments: [
        for (final category in NotificationCategory.values)
          _segmentOf(category, unreadCountOf(category)),
      ],
      selectedValue: selectedCategory,
      onSelected: onSelected,
    );
  }

  /// 카테고리 > 세그먼트 (안 읽은 개수 있으면 라벨에 개수, 오른쪽에 배지)
  PassqlSegment<NotificationCategory> _segmentOf(
    NotificationCategory category,
    int unreadCount,
  ) {
    final label = _tabLabels[category]!;
    final hasUnread = unreadCount > 0;
    return PassqlSegment(
      value: category,
      label: label,
      semanticLabel: hasUnread ? '$label, 안 읽음 $unreadCount개' : label,
      // 선택된 탭만 주황, 나머지는 중립 (주황이 두 군데로 눈을 나누지 않게)
      trailingBuilder: hasUnread
          ? (isSelected) =>
                PassqlCountBadge(count: unreadCount, isEmphasized: isSelected)
          : null,
    );
  }
}
